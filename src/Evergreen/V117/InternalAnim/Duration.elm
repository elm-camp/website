module Evergreen.V117.InternalAnim.Duration exposing (..)

import Evergreen.V117.InternalAnim.Quantity


type Seconds
    = Seconds


type alias Duration =
    Evergreen.V117.InternalAnim.Quantity.Quantity Float Seconds
