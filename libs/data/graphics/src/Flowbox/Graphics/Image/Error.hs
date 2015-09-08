---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------
module Flowbox.Graphics.Image.Error where

import qualified Flowbox.Graphics.Image.Channel as Channel
import			 Flowbox.Prelude



data Error = ChannelLookupError { _chanName :: Channel.Name }
		   | ViewLookupError String
		   | ChannelNameError { _chanDescriptor :: Channel.Name, _chanName :: Channel.Name }
		   | InvalidMap

instance Show Error where
    show err = case err of
        ChannelLookupError name -> "Channel lookup error: channel \"" ++ name ++ "\" not found"
        ViewLookupError name -> "View lookup error: view \"" ++ name ++ "\" not found"
        ChannelNameError descriptor name -> "Channel naming error: last part of the descriptor '" ++ descriptor ++ "' does not match '" ++ name ++ "'"
        InvalidMap -> "Map inconsistency error: the map contains values with names not matching their associated keys" -- TODO[KM]: remove this when the structures associated with Image migrate to using Sets instead of Maps

type Result a = Either Error a