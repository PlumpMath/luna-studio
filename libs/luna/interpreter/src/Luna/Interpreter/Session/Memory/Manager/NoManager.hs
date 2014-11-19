---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Flowbox Team <contact@flowbox.io>, 2014
-- Proprietary and confidential
-- Unauthorized copying of this file, via any medium is strictly prohibited
---------------------------------------------------------------------------
{-# LANGUAGE TemplateHaskell #-}
module Luna.Interpreter.Session.Memory.Manager.NoManager where

import Flowbox.Prelude
import Flowbox.System.Log.Logger               as Logger
import Luna.Interpreter.Session.Memory.Manager



logger :: LoggerIO
logger = getLoggerIO $(moduleName)


data NoManager = NoManager
               deriving (Show)


instance MemoryManager NoManager where
    clean _ status = do
        logger warning "Cleaning memory - not implemented"
        logger warning $ show status
