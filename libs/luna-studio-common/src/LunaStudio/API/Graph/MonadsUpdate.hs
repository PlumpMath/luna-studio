module LunaStudio.API.Graph.MonadsUpdate where

import           Data.Binary                   (Binary)
import qualified LunaStudio.API.Topic          as T
import           LunaStudio.Data.GraphLocation (GraphLocation)
import           LunaStudio.Data.MonadPath     (MonadPath)
import           Prologue


data Update = Update { _location :: GraphLocation
                     , _monads   :: [MonadPath]
                     } deriving (Eq, Generic, NFData, Show)

makeLenses ''Update
instance Binary Update


topicPrefix :: T.Topic
topicPrefix = "empire.graph.monad"
instance T.MessageTopic Update where topic _ = topicPrefix <> T.update