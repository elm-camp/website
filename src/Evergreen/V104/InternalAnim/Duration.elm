module Evergreen.V104.InternalAnim.Duration exposing (..)

import Evergreen.V104.InternalAnim.Quantity


type Seconds
    = Seconds


type alias Duration =
    Evergreen.V104.InternalAnim.Quantity.Quantity Float Seconds
