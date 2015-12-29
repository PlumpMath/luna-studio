module Empire.Commands.Library
    ( withLibrary
    , listLibraries
    , createLibrary
    ) where

import           Prologue
import           Control.Monad.State
import           Control.Monad.Error      (throwError)
import           System.Path              (Path)
import qualified Data.IntMap              as IntMap

import           Empire.Data.Project      (Project)
import qualified Empire.Data.Project      as Project
import           Empire.Data.Library      (Library)
import qualified Empire.Data.Library      as Library

import           Empire.API.Data.Project  (ProjectId)
import           Empire.API.Data.Library  (LibraryId)

import           Empire.Empire            (Empire, Command)
import qualified Empire.Empire            as Empire
import           Empire.Commands.Project  (withProject)
import qualified Empire.Utils.IdGen       as IdGen

createLibrary :: ProjectId -> Maybe String -> Path -> Empire (LibraryId, Library)
createLibrary pid name path = withProject pid $ do
    let library = Library.make name path
    id <- insertAtNewId library
    return (id, library)

listLibraries :: ProjectId -> Empire [(LibraryId, Library)]
listLibraries pid = withProject pid $ uses Project.libs IntMap.toList

withLibrary :: ProjectId -> LibraryId -> Command Library a -> Empire a
withLibrary pid lid cmd = withProject pid $ do
    zoom (Project.libs . at lid) $ do
        libMay <- get
        case libMay of
            Nothing  -> throwError $ "Library " ++ (show lid) ++ "does not exist."
            Just lib -> do
                let result = (_2 %~ Just) <$> Empire.runEmpire lib cmd
                Empire.empire $ const result

-- internal

insertAtNewId :: Library -> Command Project LibraryId
insertAtNewId library = do
    libs <- use Project.libs
    let key = IdGen.nextId libs
    Project.libs . at key ?= library
    return key
