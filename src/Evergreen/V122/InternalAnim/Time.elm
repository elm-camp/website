module Evergreen.V122.InternalAnim.Time exposing (..)

import Evergreen.V122.InternalAnim.Duration
import Evergreen.V122.InternalAnim.Quantity


type AbsoluteTime
    = AbsoluteTime


type alias Absolute =
    Evergreen.V122.InternalAnim.Quantity.Quantity Float AbsoluteTime


type alias Duration =
    Evergreen.V122.InternalAnim.Duration.Duration
