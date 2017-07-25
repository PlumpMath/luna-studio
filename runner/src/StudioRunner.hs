
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules  #-}

module Main where

import Prelude hiding (FilePath)
import Control.Monad
import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Lens.Aeson
import Control.Lens
import Control.Monad.State.Layered
import Data.ByteString.Lazy  (unpack)
import Data.List.Split
import Filesystem.Path
import System.Directory (doesDirectoryExist, setCurrentDirectory, getHomeDirectory, getCurrentDirectory, createDirectoryIfMissing)
import System.Exit (ExitCode)
import System.Process.Typed (shell, runProcess, runProcess_, setWorkingDir, setEnv, readProcess_)
import System.Environment (getExecutablePath)
import qualified System.Environment  as Environment
import qualified System.IO as IO
import Data.Maybe (fromMaybe)
import Filesystem.Path.CurrentOS (decodeString, encodeString, fromText)
import qualified Shelly.Lifted as Shelly
import System.Host

-- import           Luna.Manager.System.Host

import qualified Data.Text as T
default (T.Text)


data RunnerConfig = RunnerConfig { _versionFile            :: FilePath
                                 , _mainHomeDir            :: FilePath
                                 , _userConfigFolder       :: FilePath
                                 , _configFolder           :: FilePath
                                 , _configHomeFolder       :: FilePath
                                 , _studioHome             :: FilePath
                                 , _logsFolder             :: FilePath
                                 , _atomPackageName        :: T.Text
                                 , _appName                :: T.Text
                                 , _supervisorFolder       :: FilePath
                                 , _supervisordFolder      :: FilePath
                                 , _supervisordBin         :: FilePath
                                 , _atomFolder             :: FilePath
                                 , _thirdPartyFolder       :: FilePath
                                 , _backendBinsFolder      :: FilePath
                                 , _packageFolder          :: FilePath
                                 }

makeLenses ''RunnerConfig

type MonadRun m = (MonadStates '[RunnerConfig] m, MonadIO m)

instance Monad m => MonadHostConfig RunnerConfig 'Linux arch m where
    defaultHostConfig = return $ RunnerConfig
        { _versionFile            = "version.txt"
        , _mainHomeDir            = ".luna"
        , _userConfigFolder       = "user-config"
        , _configFolder           = "config"
        , _configHomeFolder       = "config"
        , _studioHome             = "atom"
        , _logsFolder             = "logs"
        , _atomPackageName        = "luna-studio"
        , _appName                = "luna-studio"
        , _supervisorFolder       = "supervisor"
        , _supervisordFolder      = "supervisord"
        , _supervisordBin         = "supervisord"
        , _atomFolder             = "atom"
        , _thirdPartyFolder       = "third-party"
        , _backendBinsFolder      = "private"
        , _packageFolder          = "packages"
        }

instance Monad m => MonadHostConfig RunnerConfig 'Darwin arch m where
    defaultHostConfig = reconfig <$> defaultHostConfigFor @Linux where
        reconfig cfg = cfg

instance Monad m => MonadHostConfig RunnerConfig 'Windows arch m where
    defaultHostConfig = reconfig <$> defaultHostConfigFor @Linux where
        reconfig cfg = cfg



scriptDir :: MonadIO m => m FilePath
scriptDir = do
  localExePath <- liftIO $ getExecutablePath
  return $ directory $ decodeString $ localExePath

mainAppDir :: MonadIO m => m FilePath
mainAppDir = liftIO $ do
    scriptPath <- scriptDir
    return $ parent $ parent $ parent $ scriptPath

version :: (MonadRun m, MonadIO m) => m T.Text
version = do
    runnerCfg <- get @RunnerConfig
    main <- mainAppDir
    let versionFilePath = main </> (runnerCfg ^. configFolder) </> (runnerCfg ^. versionFile)
    version <- liftIO $ readFile $ encodeString versionFilePath
    return $ T.pack $ version

backendDir :: (MonadRun m, MonadIO m) => m FilePath
backendDir = do
    runnerCfg <- get @RunnerConfig
    main <- mainAppDir
    return $ main </> (runnerCfg ^. configFolder) </> (runnerCfg ^. supervisorFolder)

supervisordBinPath :: (MonadRun m, MonadIO m) => m FilePath
supervisordBinPath = do
    runnerCfg <- get @RunnerConfig
    main <- mainAppDir
    return $ main </> (runnerCfg ^. thirdPartyFolder) </> (runnerCfg ^. supervisordFolder) </> (runnerCfg ^. supervisordBin)

packageStudioAtomHome :: (MonadRun m, MonadIO m) => m FilePath
packageStudioAtomHome = do
    runnerCfg <- get @RunnerConfig
    main <- mainAppDir
    return $ main </> (runnerCfg ^. userConfigFolder) </> (runnerCfg ^. studioHome)

userStudioAtomHome :: (MonadRun m, MonadIO m) => m FilePath
userStudioAtomHome = do
    runnerCfg <- get @RunnerConfig
    home      <- liftIO $ getHomeDirectory
    v         <- version
    return $ decodeString home </> (runnerCfg ^. mainHomeDir) </> (runnerCfg ^. configHomeFolder) </> fromText (runnerCfg ^. appName) </> fromText v

userLogsDirectory :: (MonadRun m, MonadIO m) => m FilePath
userLogsDirectory = do
    runnerCfg <- get @RunnerConfig
    home      <- liftIO $ getHomeDirectory
    v         <- version
    return $ decodeString home </> (runnerCfg ^. mainHomeDir) </> (runnerCfg ^. logsFolder) </> fromText (runnerCfg ^. appName) </> fromText v

copyLunaStudio :: (MonadRun m, MonadIO m) => m ()
copyLunaStudio = do
  packageAtomHome <- packageStudioAtomHome
  atomHome <- userStudioAtomHome
  Shelly.shelly $ Shelly.mkdir_p atomHome
  Shelly.shelly $ Shelly.cp_r packageAtomHome atomHome

testDirectory :: MonadIO m => FilePath -> m Bool
testDirectory path = Shelly.shelly $ Shelly.test_d path


checkLunaHome :: (MonadRun m, MonadIO m) => m ()
checkLunaHome = do
    runnerCfg       <- get @RunnerConfig
    userAtomHome    <- userStudioAtomHome
    let pathLunaPackage = userAtomHome </> (runnerCfg ^. packageFolder) </> fromText (runnerCfg ^. atomPackageName)
    testDirectory pathLunaPackage >>= \case
        True -> return ()
        False -> copyLunaStudio

runLunaEmpireMacOS :: (MonadRun m, MonadIO m) => m ()
runLunaEmpireMacOS = do
    lunaSupervisor <- backendDir
    supervisord    <- supervisordBinPath
    logs           <- userLogsDirectory
    Shelly.shelly $ Shelly.mkdir_p logs
    Shelly.shelly $ do
        Shelly.cd lunaSupervisor
        Shelly.cmd supervisord "-c" "supervisord-mac.conf"

runMacOS :: (MonadRun m, MonadIO m) => m ()
runMacOS = do
    atomHome <- userStudioAtomHome
    logs <- userLogsDirectory
    liftIO $ Environment.setEnv "LUNAATOM" (encodeString atomHome)
    liftIO $ Environment.setEnv "SUPERVISORLOGS" (encodeString logs)
    checkLunaHome
    runLunaEmpireMacOS

-- versionFilePath :: IO FilePath
-- versionFilePath = do
--     exePath <- scriptDir
--     prepPathNoHome [exePath, versionFile]
--
--
-- versionContent :: IO String
-- versionContent = do
--     path <- versionFilePath
--     version <- readFile $ path
--     return $ version
--
-- -----Linux----
--
-- lunaAtomHome :: IO FilePath
-- lunaAtomHome = do
--   home <- getHomeDirectory
--   version <- versionContent
--   prepPathNoHome [home, mainHomeDir, config, studioName, version, studioHome]
--
-- logsDir :: IO FilePath
-- logsDir = do
--   home <- getHomeDirectory
--   version <- versionContent
--   prepPath [home, mainHomeDir, logs, studioName, version]
--
-- backendDir :: IO FilePath
-- backendDir = prepPath [ lunaFolderName, supervisorFolderName]
--
-- pathLunaAtomHomePackage ::IO FilePath
-- pathLunaAtomHomePackage = liftIO $ do
--     home         <- getHomeDirectory
--     version <- versionContent
--     lunaAtomHome <- prepPathNoHome [home, mainHomeDir, config, studioName, version, studioHome, "packages", atomPackageName]
--     return lunaAtomHome
--
-- ----MacOS----
--
-- mainDirMacOS :: IO FilePath
-- mainDirMacOS = liftIO $ do
--     localExePath <- getExecutablePath
--     path     <- parseAbsFile localExePath
--     return $ toFilePath $ parent path
--
-- backendDirMacOS :: IO FilePath
-- backendDirMacOS = liftIO $ do
--     resources <- mainDirMacOS
--     backend <- prepPathNoHome [resources, lunaFolderName, supervisorFolderName]
--     return backend
--
-- supervisordMacOS :: IO FilePath
-- supervisordMacOS = liftIO $ do
--     resources   <- mainDirMacOS
--     supervisord <- prepPathNoHome [resources, supervisordFolderName, supervisordBin]
--     return supervisord
--
-- atomMacOS :: IO FilePath
-- atomMacOS = liftIO $ do
--     resources <- mainDirMacOS
--     atom       <- prepPathNoHome [resources, atomFolderNameMacOS]
--     return atom
--
-- ------Windows------
--
-- prepPath :: [String] -> IO FilePath
-- prepPath args = do
--   localDir <- scriptDir
--   let fromHome = foldl (\acc x -> acc </> x) "" args
--   return $ normalise $ localDir </> fromHome
--
-- prepPathNoHome :: [String] -> IO FilePath
-- prepPathNoHome args = do
--   let fromHome = foldl (\acc x -> acc </> x) "" args
--   return $ normalise $ fromHome
--
-- --Linux
--
-- copyLunaStudio :: IO ()
-- copyLunaStudio = do
--   mainDir <- scriptDir
--   atomHome <- lunaAtomHome
--   createDirectoryIfMissing True atomHome
--   runProcess_ $ shell ("cp -R " ++ mainDir ++ studioHome ++ "* " ++ atomHome)
--
-- checkLunaHome :: IO ()
-- checkLunaHome = do
--   home            <- getHomeDirectory
--   pathLunaPackage <- pathLunaAtomHomePackage
--   doesDirectoryExist pathLunaPackage >>= \case
--     True -> return ()
--     False -> copyLunaStudio
--
--
-- runLunaEmpire :: IO ()
-- runLunaEmpire = do
--   a <- backendDir
--   c <- scriptDir
--   logs <- logsDir
--   createDirectoryIfMissing True logs
--
--   runProcess_ $ shell ("cd "++ a ++ "; " ++ c ++ "supervisord/supervisord -c supervisord-package.conf")
--
-- runLinux :: IO ()
-- runLinux = do
--     currentDirr <- scriptDir
--     Environment.setEnv "LUNAATOM" currentDirr
--     checkLunaHome
--     runLunaEmpire
--
--
--
-- --MacOS
--
--
--
--
-- copyLunaStudioMacOS :: IO ()
-- copyLunaStudioMacOS = do
--   resources <- mainDirMacOS
--   atomHome <- lunaAtomHome
--   createDirectoryIfMissing True atomHome
--
--   studioHomePath <- prepPathNoHome [resources, studioHome, "*"]
--
--   runProcess_ $ shell ("cp -R " ++ studioHomePath ++ " " ++ atomHome)
--
-- checkLunaHomeMacOS :: IO ()
-- checkLunaHomeMacOS = do
--   home <- getHomeDirectory
--   pathLunaPackage <- pathLunaAtomHomePackage
--   doesDirectoryExist pathLunaPackage >>= \case
--     True -> return ()
--     False -> copyLunaStudioMacOS
--
--
-- runLunaEmpireMacOS :: IO ()
-- runLunaEmpireMacOS = do
--   lunaSupervisor <- backendDirMacOS
--   supervisord    <- supervisordMacOS
--   logs <- logsDir
--   createDirectoryIfMissing True logs
--   runProcess_ $ setWorkingDir lunaSupervisor $ shell (supervisord  ++" -c supervisord-mac.conf")
--
--
-- runMacOS :: IO ()
-- runMacOS = do
--     atomHome <- lunaAtomHome
--     logs <- logsDir
--     Environment.setEnv "LUNAATOM" atomHome
--     Environment.setEnv "SUPERVISORLOGS" logs
--
--     checkLunaHomeMacOS
--     runLunaEmpireMacOS
--
-- --Windows
--
-- mkPathWithHomeWindows :: MonadIO m => [String] -> m FilePath
-- mkPathWithHomeWindows args = liftIO $ do
--     homeDir  <- getHomeDirectory
--     mkRelativePathWindows $ homeDir : args
--
-- mkRelativePathWindows :: MonadIO m => [String] -> m FilePath
-- mkRelativePathWindows args = do
--     let folded = foldl (\acc x -> acc Win.</> x) "" args
--         a = normalise $ folded
--     return a

-- logsWin :: IO FilePath
-- logsWin = do
--     version <- versionContent
--     return $ mkPathWithHomeWindows [studioHome, version, logs]
--
-- atomHomePathWin :: IO FilePath
-- atomHomePathWin = do
--     version <- versionContent
--     return $ mkPathWithHomeWindows [studioHome, version, studioHome]
--
-- pathLunaAtomHomePackageWin :: IO FilePath
-- pathLunaAtomHomePackageWin =  do
--     atomHomePath <- atomHomePathWin
--     path <- mkRelativePathWindows [atomHomePath, "packages", atomPackageName]
--     return path
--
-- atomPathWin :: IO FilePath
-- atomPathWin = liftIO $ do
--     script   <- scriptDir
--     atomFold <- mkRelativePathWindows [script, atomFolderWin]
--     return atomFold
--
-- checkLunaHomeWin :: IO ()
-- checkLunaHomeWin = liftIO $ do
--     pathLunaPackage <- pathLunaAtomHomePackageWin
--     doesDirectoryExist pathLunaPackage >>= \case
--       True -> return ()
--       False -> copyLunaStudioWin
--
-- copyLunaStudioWin :: IO ()
-- copyLunaStudioWin = liftIO $ do
--     mainDir <- scriptDir
--     atomHome <- atomHomePathWin
--     createDirectoryIfMissing True atomHome
--     runProcess_ $ shell ("xcopy " ++ mainDir ++ studioHome ++ " " ++ atomHome ++ " /e /i /h")
--
--
-- runWindows :: IO ()
-- runWindows = do
--     currentDirr <- scriptDir
--     logs <- logsWin
--     atom <- atomPathWin
--     atomHomeAbs <- atomHomePathWin
--     createDirectoryIfMissing True logs
--     checkLunaHomeWin
--     runProcess_ $ setWorkingDir atom $ setEnv [("ATOM_HOME", atomHomeAbs)] $ shell ("atom")


main :: IO ()
main = evalDefHostConfigs @'[RunnerConfig] $ runMacOS