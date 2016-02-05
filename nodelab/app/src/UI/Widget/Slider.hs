module UI.Widget.Slider where

import           Utils.PreludePlus

import           GHCJS.Types        (JSVal, JSString)
import           GHCJS.Marshal.Pure (PToJSVal(..), PFromJSVal(..))

import           UI.Widget          (UIWidget(..))

newtype Slider = Slider { unSlider :: JSVal } deriving (PToJSVal, PFromJSVal)

instance UIWidget Slider

foreign import javascript unsafe "new Slider($1, $2, $3)"  create'        :: Int    -> Double    -> Double           -> IO Slider
foreign import javascript unsafe "$1.setValue($2)"         setValue'      :: Slider -> Double                        -> IO ()
foreign import javascript unsafe "$1.setLabel($2)"         setLabel'      :: Slider -> JSString                      -> IO ()
foreign import javascript unsafe "$1.setValueLabel($2)"    setValueLabel' :: Slider -> JSString                      -> IO ()
foreign import javascript unsafe "$1.setFocus($2)"         setFocus'      :: Slider -> Bool                          -> IO ()
foreign import javascript unsafe "$1.setTicks($2, $3, $4)" setTicks'      :: Slider -> Bool      -> Double -> Double -> IO ()

log10 = logBase 10

limitTicks :: Int -> Int -> Double -> (Double, Double)
limitTicks minv maxv width = (offset, span) where
    range  = fromIntegral $ maxv - minv
    step   = 10 ** (fromIntegral $ floor $ log10 (range - 1))
    steps  = range / step
    span   = width / steps
    offset = (fromIntegral $ 0 - minv) / range * width

