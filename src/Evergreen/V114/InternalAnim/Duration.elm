module Evergreen.V114.InternalAnim.Duration exposing (..)

import Evergreen.V114.InternalAnim.Quantity


type Seconds
    = Seconds


type alias Duration =
    Evergreen.V114.InternalAnim.Quantity.Quantity Float Seconds
