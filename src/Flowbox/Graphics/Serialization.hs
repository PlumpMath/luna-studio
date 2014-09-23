---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

module Flowbox.Graphics.Serialization where

import Flowbox.Graphics.Prelude

import qualified Flowbox.Math.Matrix as M
import qualified Generated.Proto.Graphics.Image           as Proto
import qualified Generated.Proto.Graphics.Image.Precision as Proto
import Data.Array.Accelerate.IO
import Data.ByteString.Lazy
