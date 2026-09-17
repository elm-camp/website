module Evergreen.V126.InternalAnim.Duration exposing (..)

import Evergreen.V126.InternalAnim.Quantity


type Seconds
    = Seconds


type alias Duration =
    Evergreen.V126.InternalAnim.Quantity.Quantity Float Seconds
