{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FunctionalDependencies #-}

module Luna.Target.HS.Data.Struct.Mem2 where

import GHC.TypeLits
import Data.Typeable (Proxy(..))
import Luna.Target.HS.Control
import Luna.Target.HS.Data.Func.App

import qualified Luna.Target.HS.Data.Func.Args7 as Args7
import qualified Luna.Target.HS.Data.Func.Args9 as Args9
import Control.Category.Dot


import Data.Typeable
import Type.BaseType

data Mem (obj :: k) (name :: Symbol) = Mem (Proxy obj) (Proxy name) deriving (Typeable)


class MemberProvider (obj :: k) (name :: Symbol) argRep f | obj name argRep -> f where
    getMember :: Mem obj name -> argRep -> f