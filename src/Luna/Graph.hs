---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Luna.Graph(
Graph(..),
empty,

insNode, insNodes, insFreshNode,
delNode, delNodes,
insEdge, insEdges,
delEdge, delEdges,

nodeById,

childrenByName,
typeByName, callByName, classByName, packageByName, functionsByName

) where


import qualified Data.Graph.Inductive as DG
import qualified Data.Map             as Map
import qualified Data.MultiMap        as MultiMap
import           Data.MultiMap          (MultiMap)
import qualified Luna.Node            as Node
import           Luna.Node              (Node)
import           Luna.Edge              (Edge)
import           Luna.Common            (Graph(..))
import           Luna.Data.List         (foldri)


empty :: Graph
empty = Graph DG.empty MultiMap.empty Map.empty Map.empty Map.empty MultiMap.empty Map.empty

insNodes :: [DG.LNode Node] -> Graph -> Graph
insNodes = foldri insNode

insNode :: DG.LNode Node -> Graph -> Graph
insNode lnode@(id_, node) graph =
    let 
        newgraph                 = graph{repr=DG.insNode lnode $ repr graph}
        updateNodeMap            = Map.insert      (Node.name node) id_
        updateNodeMultiMap       = MultiMap.insert (Node.name node) id_
        updatechildrenMap graph' = newgraph{children=updateNodeMultiMap $ children graph'}
    in case node of
        Node.TypeNode     _   -> updatechildrenMap newgraph{types     = updateNodeMap      $ types graph     }
        Node.CallNode     _   -> updatechildrenMap newgraph{calls     = updateNodeMap      $ calls graph     }
        Node.ClassNode    _ _ -> updatechildrenMap newgraph{classes   = updateNodeMap      $ classes graph   }
        Node.FunctionNode _ _ -> updatechildrenMap newgraph{functions = updateNodeMultiMap $ functions graph }
        Node.PackageNode  _ _ -> updatechildrenMap newgraph{packages  = updateNodeMap      $ packages graph  }
        _                     -> newgraph

freshNodeID :: Graph -> Int
freshNodeID gr = case DG.nodes $ repr gr of
                   []       -> 0
                   nodeList -> 1 + maximum nodeList

insFreshNode :: Node -> Graph -> Graph
insFreshNode node gr = insNode ((freshNodeID gr), node) gr 


delNodes :: [DG.Node] -> Graph -> Graph
delNodes = foldri delNode

delNode :: DG.Node -> Graph -> Graph
delNode id_ graph =
    let
        newgraph                 = graph{repr=DG.delNode id_ $ repr graph }
        (_, node)                = DG.labNode' $ DG.context (repr graph) id_
        updateNodeMap            = Map.delete      (Node.name node)
        updateNodeMultiMap       = MultiMap.delete (Node.name node)
        updatechildrenMap graph' = newgraph{children=updateNodeMultiMap $ children graph'}
    in case node of
        Node.TypeNode     _   -> updatechildrenMap newgraph{types     = updateNodeMap      $ types graph}
        Node.CallNode     _   -> updatechildrenMap newgraph{calls     = updateNodeMap      $ calls graph}
        Node.ClassNode    _ _ -> updatechildrenMap newgraph{classes   = updateNodeMap      $ classes graph}
        Node.FunctionNode _ _ -> updatechildrenMap newgraph{functions = updateNodeMultiMap $ functions graph}
        Node.PackageNode  _ _ -> updatechildrenMap newgraph{packages  = updateNodeMap      $ packages graph}
        _                     -> newgraph


insEdges :: [DG.LEdge Edge] -> Graph -> Graph
insEdges = foldri insEdge 

insEdge :: DG.LEdge Edge -> Graph -> Graph
insEdge ledge graph = graph{repr = DG.insEdge ledge $ repr graph}


delEdges :: [DG.Edge] -> Graph -> Graph
delEdges = foldri delEdge 

delEdge :: DG.Edge -> Graph -> Graph
delEdge edge graph = graph{repr = DG.delEdge edge $ repr graph}


nodeById :: DG.Node -> Graph -> Node
nodeById id_ graph = let
    (_, node) = DG.labNode' $ DG.context (repr graph) id_
    in node

nodeByNameFrom :: Ord k => (Graph -> Map.Map k DG.Node) -> k -> Graph -> Maybe Node
nodeByNameFrom getter name graph = 
    case Map.lookup name $ getter graph of
        Just id_ -> Just(nodeById id_ graph)
        Nothing  -> Nothing

nodesByNameFrom :: Ord k => (Graph -> MultiMap k DG.Node) -> k -> Graph -> [Node]
nodesByNameFrom getter name graph = [nodeById elid graph | elid <- ids] where
    ids = MultiMap.lookup name $ getter graph

childrenByName :: String -> Graph -> [Node]
childrenByName = nodesByNameFrom children

typeByName :: String -> Graph -> Maybe Node
typeByName      = nodeByNameFrom  types

callByName :: String -> Graph -> Maybe Node
callByName      = nodeByNameFrom  calls

classByName :: String -> Graph -> Maybe Node
classByName     = nodeByNameFrom  classes

packageByName :: String -> Graph -> Maybe Node
packageByName   = nodeByNameFrom  packages

functionsByName :: String -> Graph -> [Node]
functionsByName = nodesByNameFrom functions
