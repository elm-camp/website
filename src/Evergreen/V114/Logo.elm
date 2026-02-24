module Evergreen.V114.Logo exposing (..)

import Color
import Evergreen.V114.Animator.Timeline
import Time


type alias PieceConfig =
    { color : Color.Color
    , x : Float
    , y : Float
    , rotation : Float
    }


type alias Tangram =
    { firstLargeTriangle : PieceConfig
    , secondLargeTriangle : PieceConfig
    , mediumTriangle : PieceConfig
    , firstSmallTriangle : PieceConfig
    , secondSmallTriangle : PieceConfig
    , square : PieceConfig
    , parallelogram : PieceConfig
    , scale : Float
    }


type alias Model =
    { index : Int
    , timeline : Evergreen.V114.Animator.Timeline.Timeline Tangram
    }


type Msg
    = ToggleConfig
    | Tick Time.Posix
