---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------

{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE PackageImports #-}
{-# LANGUAGE CPP #-}

module Luna.Target.HS.Control.Context.Env where

import GHC.Generics
import Control.PolyMonad
import Control.PolyApplicative
import Control.Applicative
import Control.Monad.Morph
import Data.Typeable (Typeable)
import Luna.Target.HS.Control.Context.Value

import Flowbox.Utils

--------------------------------------------------------------------------------
-- Structures
--------------------------------------------------------------------------------

data Pure a = Pure a deriving (Eq, Ord, Typeable, Generic)

fromPure (Pure a) = a

--------------------------------------------------------------------------------
-- Utils
--------------------------------------------------------------------------------

returnPure :: a -> Pure a
returnPure = return

returnIO :: a -> IO a
returnIO = return

--------------------------------------------------------------------------------
-- Type classes
--------------------------------------------------------------------------------

class Env (m :: * -> *)

class IOEnv m where
    toIOEnv :: m a -> IO a


--------------------------------------------------------------------------------
-- Type families
--------------------------------------------------------------------------------

type family BottomEnvMerge a b where
  BottomEnvMerge Pure a = a
  BottomEnvMerge a    b = IO


type family GetEnv t where
    GetEnv Pure  = Pure
    GetEnv IO    = IO
    GetEnv (t m) = GetEnv m


type family EnvMerge3 a b where
  EnvMerge3 (Value Pure) (Value Pure) = (Value Pure)
  EnvMerge3 a             b           = (Value IO)
    

--------------------------------------------------------------------------------
-- Instances
--------------------------------------------------------------------------------

instance Show a => Show (Pure a) where
#ifdef DEBUG
    show (Pure a) = "Pure (" ++ child ++ ")" where
        child = show a
        content = if ' ' `elem` child then "(" ++ child ++ ")" else child
#else
    show (Pure a) = show a
#endif

---

instance Env Pure
instance Env IO

---

instance Monad Pure where
    return = Pure
    (Pure a) >>= f = f a

instance Functor Pure where
    fmap f (Pure a) = Pure (f a)

instance Applicative Pure where
    pure = Pure
    (Pure f) <*> (Pure a) = Pure $ f a


instance MonadMorph IO IO where
    morph = id

instance MonadMorph Pure Pure where
    morph = id

instance MonadMorph Pure IO where
    morph = return . fromPure

---

instance IOEnv Pure where
    toIOEnv = return . fromPure

instance IOEnv IO where
    toIOEnv = id 