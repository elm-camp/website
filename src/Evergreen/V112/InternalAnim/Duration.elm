module Evergreen.V112.InternalAnim.Duration exposing (..)

import Evergreen.V112.InternalAnim.Quantity


type Seconds
    = Seconds


type alias Duration =
    Evergreen.V112.InternalAnim.Quantity.Quantity Float Seconds
