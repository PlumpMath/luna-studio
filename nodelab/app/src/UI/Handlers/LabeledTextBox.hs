module UI.Handlers.LabeledTextBox where

import           Utils.PreludePlus

import           Data.HMap.Lazy               (HTMap)
import           Utils.Vector

import           Object.Widget                (CompositeWidget, DblClickHandler, ResizableWidget, UIHandlers, WidgetId, createWidget,
                                               dblClick, resizeWidget, updateWidget)
import qualified Object.Widget.LabeledTextBox as Model
import qualified Object.Widget.TextBox        as TextBox
import           Reactive.Commands.Command    (Command)
import qualified Reactive.Commands.UIRegistry as UICmd
import           Reactive.State.Global        (inRegistry)
import qualified Reactive.State.Global        as Global
import           Reactive.State.UIRegistry    (addHandler)

import           UI.Generic                   (defaultResize)
import           UI.Widget.LabeledTextBox     ()

import           UI.Handlers.Generic          (ValueChangedHandler (..), triggerValueChanged)
import qualified UI.Handlers.TextBox          as TextBox



dblClickHandler :: DblClickHandler Global.State
dblClickHandler _ _ wid = do
    (tbId:_) <- inRegistry $ UICmd.children wid
    UICmd.takeFocus tbId
    inRegistry $ UICmd.update_ tbId $ TextBox.isEditing .~ True

widgetHandlers :: UIHandlers Global.State
widgetHandlers = def & dblClick     .~ dblClickHandler

-- Constructors


textHandlers :: WidgetId -> HTMap
textHandlers wid = addHandler (ValueChangedHandler $ textValueChangedHandler wid)
                $ addHandler (UICmd.LostFocus $ lostFocusHandler wid)
                $ mempty where

textValueChangedHandler :: WidgetId -> Text -> WidgetId -> Command Global.State ()
textValueChangedHandler parent val tbId = do
    inRegistry $ UICmd.update_ parent $ Model.value .~ val
    triggerValueChanged val parent

lostFocusHandler :: WidgetId -> WidgetId -> Command Global.State ()
lostFocusHandler _ wid = TextBox.applyChanges wid

instance CompositeWidget Model.LabeledTextBox where
    createWidget wid model = do
        let tx      = (model ^. Model.size . x) / 2.0
            ty      = (model ^. Model.size . y)
            sx      = tx - (model ^. Model.size . y / 2.0)
            textVal = model ^. Model.value
            textBox = TextBox.create (Vector2 sx ty) textVal TextBox.Right

        tbId <- UICmd.register wid textBox $ textHandlers wid
        UICmd.moveX tbId tx

    updateWidget wid old model = do
        (tbId:_) <- UICmd.children wid
        UICmd.update_ tbId $ TextBox.value .~ (model ^. Model.value)

instance ResizableWidget Model.LabeledTextBox where
    resizeWidget wid size model = do
        defaultResize wid size model

        (tbId:_) <- UICmd.children wid
        let tx      = (model ^. Model.size . x) / 2.0
            ty      = (model ^. Model.size . y)
            sx      = tx - (model ^. Model.size . y / 2.0)
        UICmd.resize tbId $ Vector2 sx ty
        UICmd.moveX tbId tx
