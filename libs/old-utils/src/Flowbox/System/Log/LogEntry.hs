---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

module Flowbox.System.Log.LogEntry where

import Flowbox.System.Log.Priority (Priority)

import Flowbox.Prelude



data LogEntry = LogEntry { name     :: String
                         , priority :: Priority
                         , msg      :: String
                         } deriving (Show)