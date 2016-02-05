module UI.Widget.Toggle where

import           Utils.PreludePlus
import           Utils.Vector

import           Data.JSString.Text            (lazyTextToJSString)
import           GHCJS.Marshal.Pure            (PFromJSVal (..), PToJSVal (..))
import           GHCJS.Types                   (JSString, JSVal)

import           Object.UITypes
import           Object.Widget
import qualified Object.Widget.Toggle          as Model
import qualified Reactive.State.UIRegistry        as UIRegistry

import           UI.Generic                    (whenChanged)
import qualified UI.Generic                    as UI
import qualified UI.Registry                   as UI
import           UI.Widget                     (UIWidget (..))
import qualified UI.Widget                     as Widget

newtype Toggle = Toggle JSVal deriving (PToJSVal, PFromJSVal)

instance UIWidget Toggle

foreign import javascript unsafe "new Toggle($1, $2, $3)" create'   :: Int    -> Double -> Double -> IO Toggle
foreign import javascript unsafe "$1.setValue($2)"        setValue' :: Toggle -> Bool             -> IO ()
foreign import javascript unsafe "$1.setLabel($2)"        setLabel' :: Toggle -> JSString         -> IO ()
foreign import javascript unsafe "$1.setFocus($2)"        setFocus' :: Toggle -> Bool             -> IO ()

create :: WidgetId -> Model.Toggle -> IO Toggle
create oid model = do
    toggle      <- create' oid (model ^. Model.size . x) (model ^. Model.size . y)
    setLabel       model toggle
    setValue       model toggle
    UI.setWidgetPosition (model ^. widgetPosition) toggle
    return toggle

setLabel :: Model.Toggle -> Toggle -> IO ()
setLabel model toggle = setLabel' toggle $ lazyTextToJSString $ model ^. Model.label

setValue :: Model.Toggle -> Toggle -> IO ()
setValue model slider = setValue' slider $ model ^. Model.value

setFocus :: Model.Toggle -> Toggle -> IO ()
setFocus model slider = setFocus' slider $ model ^. Model.focused

instance UIDisplayObject Model.Toggle where
    createUI parentId id model = do
        toggle   <- create id model
        parent   <- UI.lookup parentId :: IO Widget.GenericWidget
        UI.register id toggle
        Widget.add toggle parent

    updateUI id old model = do
        slider <- UI.lookup id :: IO Toggle

        whenChanged old model Model.label   $ setLabel model slider
        whenChanged old model Model.value   $ setValue model slider
        whenChanged old model Model.focused $ setFocus model slider

instance CompositeWidget Model.Toggle
instance ResizableWidget Model.Toggle where
    resizeWidget = UI.defaultResize