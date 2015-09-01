module Reactive.Plugins.Core.Action.State.Global where


import           Utils.PreludePlus
import           Utils.Vector

import qualified JS.Camera


import           Batch.Project
import qualified Reactive.Plugins.Core.Action.State.Camera            as Camera
import qualified Reactive.Plugins.Core.Action.State.Graph             as Graph
import qualified Reactive.Plugins.Core.Action.State.AddRemove         as AddRemove
import qualified Reactive.Plugins.Core.Action.State.Selection         as Selection
import qualified Reactive.Plugins.Core.Action.State.MultiSelection    as MultiSelection
import qualified Reactive.Plugins.Core.Action.State.Drag              as Drag
import qualified Reactive.Plugins.Core.Action.State.Connect           as Connect
import qualified Reactive.Plugins.Core.Action.State.NodeSearcher      as NodeSearcher
import qualified Reactive.Plugins.Core.Action.State.Breadcrumb        as Breadcrumb
import qualified Reactive.Plugins.Core.Action.State.UIRegistry        as UIRegistry
import qualified Reactive.Plugins.Core.Action.State.Sandbox           as Sandbox

data State = State { _iteration      :: Integer
                   , _mousePos       :: Vector2 Int
                   , _screenSize     :: Vector2 Int
                   , _graph          :: Graph.State
                   , _camera         :: Camera.State
                   , _addRemove      :: AddRemove.State
                   , _selection      :: Selection.State
                   , _multiSelection :: MultiSelection.State
                   , _drag           :: Drag.State
                   , _connect        :: Connect.State
                   , _nodeSearcher   :: NodeSearcher.State
                   , _breadcrumb     :: Breadcrumb.State
                   , _uiRegistry     :: UIRegistry.State
                   , _sandbox        :: Sandbox.State
                   , _project        :: Maybe Project
                   } deriving (Eq, Show)

makeLenses ''State

initialScreenSize = Vector2 400 200

instance Default State where
    def = State def initialScreenSize def def def def def def def def def def def def def

instance PrettyPrinter State where
    display (State iteration mousePos screenSize graph camera addRemove selection multiSelection drag connect nodeSearcher breadcrumb uiRegistry sandbox project)
        = "gS(" <> display iteration
         <> " " <> display mousePos
         <> " " <> display screenSize
         <> " " <> display graph
         <> " " <> display camera
         <> " " <> display addRemove
         <> " " <> display selection
         <> " " <> display multiSelection
         <> " " <> display drag
         <> " " <> display connect
         <> " " <> display nodeSearcher
         <> " " <> display breadcrumb
         <> " " <> display uiRegistry
         <> " " <> display sandbox
         <> " " <> "project(" <> show project <> ")"
         <> ")"

instance Monoid State where
    mempty = def
    a `mappend` b = if a ^. iteration > b ^.iteration then a else b


toCamera :: State -> JS.Camera.Camera
toCamera state = JS.Camera.Camera (state ^. screenSize) (camState ^. Camera.pan) (camState ^. Camera.factor) where
    camState   = state ^. camera . Camera.camera