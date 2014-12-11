---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE TemplateHaskell           #-}
{-# LANGUAGE DeriveGeneric             #-}


module Luna.ASTNew.Name.Multi where


import GHC.Generics (Generic)

import           Flowbox.Prelude
import qualified Data.Map        as Map
import           Data.Map        (Map)
import           Flowbox.Generics.Deriving.QShow
import           Data.String.Utils (join)
import           Data.List         (intersperse)
import           Data.String             (IsString, fromString)

----------------------------------------------------------------------
-- Data types
----------------------------------------------------------------------

data MultiName = MultiName { _base :: String, _segments :: [String] }
          deriving (Show, Eq, Generic, Read, Ord)

data Segment = Token String
             | Hole
             deriving (Show, Eq, Generic, Read, Ord)

makeLenses ''MultiName
instance QShow (MultiName)
instance QShow (Segment)



toList :: MultiName -> [String]
toList (MultiName b s) = b:s

single :: String -> MultiName
single = flip MultiName []

multi :: String -> [String] -> MultiName
multi = MultiName


isSingle :: MultiName -> Bool
isSingle = null . view segments


isMulti :: MultiName -> Bool
isMulti = not . isSingle

segmentShow :: Segment -> String
segmentShow name = case name of
    Token s -> strRepr s
    Hole    -> "_"

toStr :: MultiName -> String
toStr n = if isSingle n
    then strRepr $ n^.base
    else (strRepr $ n^.base) ++ (' ' : join " " (n^.segments))


unified :: MultiName -> String
unified n = if isSingle n
    then strRepr $ n^.base
    else (strRepr $ n^.base) ++ ('_' : join "_" (n^.segments))


-- close the definition, check if name holes are defined explicite
-- define Holes otherwise
--close :: MultiName -> MultiName
--close n@(MultiName base segments) = case Hole `elem` segments of
--    True  -> n
--    False -> case null segments of
--        True  -> n
--        False -> MultiName base $ (Hole : intersperse Hole segments)



----------------------------------------------------------------------
-- Instances
----------------------------------------------------------------------

instance IsString MultiName  where fromString = single