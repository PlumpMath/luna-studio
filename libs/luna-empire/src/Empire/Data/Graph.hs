module Empire.Data.Graph where

import           Prologue
import qualified Empire.Utils.IdGen     as IdGen
import           Empire.Data.AST        (AST, NodeRef)
import qualified Data.IntMap            as IntMap
import           Data.IntMap            (IntMap)
import           Empire.API.Data.Node   (NodeId)

data Graph = Graph { _ast         :: AST
                   , _nodeMapping :: IntMap (NodeRef)
                   } deriving (Show)

makeLenses ''Graph

instance Default Graph where
    def = Graph def def

nextNodeId :: Graph -> NodeId
nextNodeId graph = IdGen.nextId $ graph ^. nodeMapping