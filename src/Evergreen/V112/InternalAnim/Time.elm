module Evergreen.V112.InternalAnim.Time exposing (..)

import Evergreen.V112.InternalAnim.Duration
import Evergreen.V112.InternalAnim.Quantity


type AbsoluteTime
    = AbsoluteTime


type alias Absolute =
    Evergreen.V112.InternalAnim.Quantity.Quantity Float AbsoluteTime


type alias Duration =
    Evergreen.V112.InternalAnim.Duration.Duration
