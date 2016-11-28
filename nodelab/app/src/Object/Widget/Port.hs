module Object.Widget.Port where

import           Data.Aeson               (ToJSON)
import           Utils.Angle              (toAngle)
import           Utils.PreludePlus        hiding (set)
import           Utils.Vector

import           Empire.API.Data.Port     (InPort (..), OutPort (..), PortId (..))
import           Empire.API.Data.PortRef  (AnyPortRef)
import qualified Empire.API.JSONInstances ()

import           Object.Widget

data Port = Port { _portRef     :: AnyPortRef
                 , _angleVector :: Vector2 Double
                 , _portCount   :: Int
                 , _isOnly      :: Bool
                 , _color       :: Int
                 , _highlight   :: Bool
                 } deriving (Eq, Show, Typeable, Generic)

makeLenses ''Port
instance ToJSON Port

angle :: Getter Port Double
angle = to (toAngle . view angleVector )

instance IsDisplayObject Port where
    widgetPosition = lens (\_ -> Vector2 0.0 0.0) (error "Port has no position setter")
    widgetSize     = lens get set where
        get _      = Vector2 0.0 0.0
        set w _    = w
    widgetVisible  = to $ const True

angleToDimVecIn  :: Double -> Vector2 Double
angleToDimVecIn  angle' = (/ 10.0) <$> Vector2 (cos angle') (-sin angle')

angleToDimVecOut :: Double -> Vector2 Double
angleToDimVecOut angle' = (/ 10.0) <$> Vector2 (-cos angle') (-sin angle')

defaultAngle :: Int -> PortId -> Vector2 Double
defaultAngle _        (OutPortId (All)               ) = angleToDimVecOut 0.0
defaultAngle numPorts (OutPortId (Projection portNum)) = angleToDimVecOut angle' where
    angle' = delta * (fromIntegral portNum) + delta / 2.0 + pi / 2.0
    delta  = pi / (fromIntegral numPorts)
defaultAngle _        (InPortId (Self)               ) = angleToDimVecIn 0.0
defaultAngle numPorts (InPortId (Arg portNum)        ) = angleToDimVecIn angle' where
    angle' = delta * (fromIntegral portNum) + delta / 2.0 + pi / 2.0
    delta  = pi / (fromIntegral numPorts)
