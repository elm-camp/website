module View.Logo2 exposing
    ( Model
    , Msg(..)
    , byTheRiver
    , configurations
    , elmLogo
    , fireplace
    , init
    , lake
    , needsAnimationFrame
    , tent
    , tents
    , update
    , view
    )

import Animator
import Animator.Timeline exposing (Timeline)
import Color exposing (Color)
import Html exposing (Html, div)
import Html.Attributes
import List.Nonempty exposing (Nonempty(..))
import Svg exposing (Svg)
import Time
import View.Tangram as Tangram


type alias Model =
    { index : Int
    , timeline : Timeline Tangram.Tangram
    }


type Msg
    = ToggleConfig
    | Tick Time.Posix


init : Model
init =
    { index = 0
    , timeline = Animator.Timeline.init elmLogo
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleConfig ->
            let
                newIndex =
                    model.index + 1

                newTangram =
                    List.Nonempty.get newIndex configurations

                _ =
                    Debug.log "new tangram" newTangram
            in
            { model
                | index = newIndex
                , timeline = Animator.Timeline.to (Animator.ms 500) newTangram model.timeline
            }

        Tick time ->
            { model | timeline = Animator.Timeline.update time model.timeline }


needsAnimationFrame : Model -> Bool
needsAnimationFrame model =
    Animator.Timeline.isRunning model.timeline


view : Model -> Html Msg
view model =
    div [ Html.Attributes.style "width" "100px" ]
        [ Tangram.viewAnimatedTangram model.timeline ToggleConfig
        ]



-- TANGRAM DEFINITIONS


elmLogo : Tangram.Tangram
elmLogo =
    { firstLargeTriangle = { color = Color.rgb255 29 50 45, x = 154, y = 328, rotation = -90 }
    , secondLargeTriangle = { color = Color.rgb255 93 177 126, x = 439, y = 406, rotation = 180 }
    , firstSmallTriangle = { color = Color.rgb255 12 109 81, x = 627, y = 339, rotation = 90 }
    , square = { color = Color.rgb255 169 197 137, x = 558, y = 194, rotation = 45 }
    , secondSmallTriangle = { color = Color.rgb255 12 109 81, x = 354, y = 168, rotation = 0 }
    , parallelogram = { color = Color.rgb255 169 197 137, x = 416, y = 103, rotation = 45 }
    , mediumTriangle = { color = Color.rgb255 93 177 126, x = 596, y = 133, rotation = -135 }
    , scale = 1.7
    }


tent : Tangram.Tangram
tent =
    { firstLargeTriangle = { color = Color.rgb255 93 177 126, x = -7, y = 239, rotation = 90 }
    , secondLargeTriangle = { color = Color.rgb255 29 50 45, x = 480, y = 297, rotation = 270 }
    , firstSmallTriangle = { color = Color.rgb255 12 109 81, x = 230, y = 386, rotation = 135 }
    , square = { color = Color.rgb255 240 172 1, x = 333, y = 61, rotation = -135 }
    , secondSmallTriangle = { color = Color.rgb255 12 109 81, x = 263, y = 331, rotation = -45 }
    , parallelogram = { color = Color.rgb255 169 197 137, x = 333, y = 237, rotation = 270 }
    , mediumTriangle = { color = Color.rgb255 93 177 126, x = 300, y = 419, rotation = 180 }
    , scale = 1.2
    }


lake : Tangram.Tangram
lake =
    { firstLargeTriangle = { color = Color.rgb255 93 177 126, x = 145, y = 196, rotation = 180 }
    , secondLargeTriangle = { color = Color.rgb255 29 50 45, x = 25, y = 346, rotation = 0 }
    , firstSmallTriangle = { color = Color.rgb255 12 109 81, x = 560, y = 275, rotation = 180 }
    , square = { color = Color.rgb255 240 172 1, x = 420, y = 135, rotation = 45 }
    , secondSmallTriangle = { color = Color.rgb255 29 50 45, x = 499, y = 355, rotation = 0 }
    , parallelogram = { color = Color.rgb255 95 181 204, x = 430, y = -4, rotation = 225 }
    , mediumTriangle = { color = Color.rgb255 240 172 1, x = 408, y = 420, rotation = 180 }
    , scale = 1.4
    }


byTheRiver : Tangram.Tangram
byTheRiver =
    { firstLargeTriangle = { color = Color.rgb255 95 181 204, x = 415, y = 360, rotation = 90 }
    , secondLargeTriangle = { color = Color.rgb255 95 181 204, x = 340, y = 436, rotation = 180 }
    , firstSmallTriangle = { color = Color.rgb255 12 109 81, x = 180, y = 338, rotation = 135 }
    , square = { color = Color.rgb255 240 172 1, x = 381, y = 100, rotation = 45 }
    , secondSmallTriangle = { color = Color.rgb255 12 109 81, x = 233, y = 283, rotation = -45 }
    , parallelogram = { color = Color.rgb255 169 197 137, x = 283, y = 186, rotation = 270 }
    , mediumTriangle = { color = Color.rgb255 93 177 126, x = 230, y = 348, rotation = 180 }
    , scale = 1.0
    }


tents : Tangram.Tangram
tents =
    { firstLargeTriangle = { color = Color.rgb255 93 177 126, x = 485, y = 83, rotation = 180 }
    , secondLargeTriangle = { color = Color.rgb255 29 50 45, x = 140, y = 201, rotation = 180 }
    , firstSmallTriangle = { color = Color.rgb255 240 172 1, x = 488, y = 407, rotation = 45 }
    , square = { color = Color.rgb255 240 172 1, x = 388, y = 365, rotation = 0 }
    , secondSmallTriangle = { color = Color.rgb255 240 172 1, x = 250, y = 450, rotation = -45 }
    , parallelogram = { color = Color.rgb255 240 172 1, x = 240, y = 366, rotation = 0 }
    , mediumTriangle = { color = Color.rgb255 240 172 1, x = 324, y = 259, rotation = 180 }
    , scale = 1.4
    }


fireplace : Tangram.Tangram
fireplace =
    { firstLargeTriangle = { color = Color.rgb255 255 128 0, x = 200, y = 226, rotation = 90 }
    , secondLargeTriangle = { color = Color.rgb255 255 128 0, x = 352, y = 259, rotation = 270 }
    , firstSmallTriangle = { color = Color.rgb255 162 0 0, x = 406, y = 71, rotation = 90 }
    , square = { color = Color.rgb255 240 172 1, x = 376, y = 320, rotation = 135 }
    , secondSmallTriangle = { color = Color.rgb255 162 0 0, x = 263, y = 148, rotation = 135 }
    , parallelogram = { color = Color.rgb255 153 110 63, x = 324, y = 501, rotation = 45 }
    , mediumTriangle = { color = Color.rgb255 180 129 75, x = 419, y = 425, rotation = 180 }
    , scale = 1.2
    }


configurations : Nonempty Tangram.Tangram
configurations =
    Nonempty
        elmLogo
        [ fireplace
        , tents
        , tent
        , lake
        , byTheRiver
        ]
