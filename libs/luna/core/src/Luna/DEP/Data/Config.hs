---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

{-# LANGUAGE FlexibleInstances         #-}
{-# LANGUAGE GADTs                     #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE TemplateHaskell           #-}
{-# LANGUAGE TypeSynonymInstances      #-}

module Luna.DEP.Data.Config where

import           Data.TypeLevel.Set     (InsertClass)
import           Flowbox.Prelude
import qualified Luna.DEP.Pragma.Pragma as Pragma


----------------------------------------------------------------------
-- Data types
----------------------------------------------------------------------

data Config a = Config { _pragmaSet :: Pragma.PragmaSet a } deriving (Show)

makeLenses ''Config


----------------------------------------------------------------------
-- Utils
----------------------------------------------------------------------

registerPragma p conf = conf & pragmaSet %~ Pragma.register p
setPragma   p conf    = conf & pragmaSet %~ Pragma.set p

----------------------------------------------------------------------
-- Instances
----------------------------------------------------------------------

instance a~() => Default (Config a) where
    def = Config def