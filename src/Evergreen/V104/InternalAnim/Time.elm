module Evergreen.V104.InternalAnim.Time exposing (..)

import Evergreen.V104.InternalAnim.Duration
import Evergreen.V104.InternalAnim.Quantity


type AbsoluteTime
    = AbsoluteTime


type alias Absolute =
    Evergreen.V104.InternalAnim.Quantity.Quantity Float AbsoluteTime


type alias Duration =
    Evergreen.V104.InternalAnim.Duration.Duration
