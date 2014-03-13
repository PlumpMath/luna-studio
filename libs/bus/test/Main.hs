module Main where

import           Control.Monad.Reader
import qualified Data.ByteString.Char8 as Char8
import qualified Flowbox.Bus.Bus       as Bus
import           Flowbox.Prelude
import qualified System.ZMQ4.Monadic   as ZMQ

import           Flowbox.Bus.Bus     (Bus)
import qualified Flowbox.Bus.Env     as Env
import qualified Flowbox.Bus.Message as Message


test :: Bus ()
test = do
    Bus.subscribe ""
    Bus.reply (Message.CorrelationID 45 66)
              (Message.Message "project.open.request" (Char8.pack "some data"))
    putStrLn "sent"
    _ <- forever $ do
        _ <- Bus.receive
        putStrLn "received"
    return ()


main :: IO ()
main = do
    x <- ZMQ.runZMQ $ Bus.runBus test (Env.BusEndPoints "tcp://127.0.0.1:30530"
                                                        "tcp://127.0.0.1:30531"
                                                        "tcp://127.0.0.1:30532"
                                      )
    print x
    return ()

