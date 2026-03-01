module Evergreen.V117.InternalAnim.Time exposing (..)

import Evergreen.V117.InternalAnim.Duration
import Evergreen.V117.InternalAnim.Quantity


type AbsoluteTime
    = AbsoluteTime


type alias Absolute =
    Evergreen.V117.InternalAnim.Quantity.Quantity Float AbsoluteTime


type alias Duration =
    Evergreen.V117.InternalAnim.Duration.Duration
