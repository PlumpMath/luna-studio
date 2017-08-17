{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeSynonymInstances  #-}
module LunaStudio.API.Atom.Paste where

import           Data.Binary             (Binary)
import qualified LunaStudio.API.Request  as R
import qualified LunaStudio.API.Response as Response
import qualified LunaStudio.API.Topic    as T
import           Prologue


data Request = Request { _filePath :: FilePath
                       , _span     :: [(Int, Int)]
                       , _content  :: Text
                       } deriving (Eq, Generic, Show)

data Result  = Result { _code      :: Text
                      } deriving (Eq, Generic, Show)

makeLenses ''Request
makeLenses ''Result
instance Binary Request
instance NFData Request
instance Binary Result
instance NFData Result


type Response = Response.Response Request () Result
instance Response.ResponseResult Request () Result

topicPrefix :: T.Topic
topicPrefix = "empire.atom.file.paste"
instance T.MessageTopic (R.Request Request) where topic _ = topicPrefix <> T.request
instance T.MessageTopic Response            where topic _ = topicPrefix <> T.response