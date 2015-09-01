{-# LANGUAGE UndecidableInstances #-}

module AST.Meta where

import           Flowbox.Prelude hiding (Cons, cons)

import           Control.Monad.State

import           Luna.Syntax.Builder.Graph hiding (get, put)
import           Luna.Syntax.Builder
import           Luna.Syntax.Layer.Labeled
import           Luna.Syntax.Layer.Typed
import           Luna.Syntax.AST.Term
import           Luna.Syntax.AST.Decl.Function
import           Luna.Repr.Styles

import           Object.Node


data Meta = Meta Node deriving (Eq, Show)

instance Default Meta where def = Meta def

instance {-# OVERLAPPABLE #-} (MonadState Meta m) => LabBuilder m Meta where
    mkLabel = get


type LabeledMeta          = Labeled Meta (Typed Draft)
type GraphMeta            = HomoGraph ArcPtr LabeledMeta
type GraphRefMeta         = Arc              LabeledMeta

type StateGraphMeta       = BldrState GraphMeta

type RefFunctionGraphMeta = (GraphRefMeta, GraphMeta)


-- instance Eq a => Eq (VectorGraph a) where
--     a == b = (a ^. _homReg) == (b ^. _homReg)

-- instance Eq g => Eq (BldrState g) where
--     a == b = (a ^. orphans) == (b ^. orphans) && (a ^. graph) == (b ^. graph)

instance Show g => Show (BldrState g) where
    show g = show (g ^. orphans) <> " " <> show (g ^. graph)

instance Repr s GraphMeta where
    repr = fromString . show


withMeta :: (MonadState l m) => l -> m b -> m b
withMeta meta f = do
    old <- get
    put meta
    out <- f
    put old
    return out