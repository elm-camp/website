module Evergreen.V114.InternalAnim.Time exposing (..)

import Evergreen.V114.InternalAnim.Duration
import Evergreen.V114.InternalAnim.Quantity


type AbsoluteTime
    = AbsoluteTime


type alias Absolute =
    Evergreen.V114.InternalAnim.Quantity.Quantity Float AbsoluteTime


type alias Duration =
    Evergreen.V114.InternalAnim.Duration.Duration
