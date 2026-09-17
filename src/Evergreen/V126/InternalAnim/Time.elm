module Evergreen.V126.InternalAnim.Time exposing (..)

import Evergreen.V126.InternalAnim.Duration
import Evergreen.V126.InternalAnim.Quantity


type AbsoluteTime
    = AbsoluteTime


type alias Absolute =
    Evergreen.V126.InternalAnim.Quantity.Quantity Float AbsoluteTime


type alias Duration =
    Evergreen.V126.InternalAnim.Duration.Duration
