module Evergreen.V103.Internal.Model2 exposing (..)

import Evergreen.V103.Internal.Teleport
import Set
import Time


type State
    = State
        { added : Set.Set String
        , rules : List String
        , keyframes : List String
        }


type Msg
    = Tick Time.Posix
    | Teleported Evergreen.V103.Internal.Teleport.Trigger Evergreen.V103.Internal.Teleport.Event
