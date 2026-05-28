module Evergreen.V122.InternalAnim.Duration exposing (..)

import Evergreen.V122.InternalAnim.Quantity


type Seconds
    = Seconds


type alias Duration =
    Evergreen.V122.InternalAnim.Quantity.Quantity Float Seconds
