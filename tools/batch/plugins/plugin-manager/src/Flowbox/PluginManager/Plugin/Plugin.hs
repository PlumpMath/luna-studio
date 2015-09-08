---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------
{-# LANGUAGE TemplateHaskell #-}

module Flowbox.PluginManager.Plugin.Plugin where

import Flowbox.Prelude



type ID = Int

data Plugin = Plugin { _name    :: String
                     , _command :: String
                     } deriving (Read, Show, Eq, Ord)

makeLenses (''Plugin)
