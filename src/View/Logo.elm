module View.Logo exposing
    ( Model
    , Msg(..)
    , PieceConfig
    , Tangram
    , init
    , needsAnimationFrame
    , update
    , view
    )

import Animator
import Animator.Timeline exposing (Timeline)
import Animator.Transition exposing (Transition)
import Animator.Value
import Color exposing (Color)
import Html exposing (Html)
import Html.Events
import List.Nonempty exposing (Nonempty(..))
import Svg exposing (Svg)
import Svg.Attributes
import Time


type alias Model =
    { index : Int
    , timeline : Timeline Tangram
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
            in
            { model
                | index = newIndex
                , timeline = Animator.Timeline.to (Animator.ms 400) newTangram model.timeline
            }

        Tick time ->
            { model | timeline = Animator.Timeline.update time model.timeline }


needsAnimationFrame : Model -> Bool
needsAnimationFrame model =
    Animator.Timeline.isRunning model.timeline


view : Model -> Html Msg
view model =
    let
        interpolatedTangram : Tangram
        interpolatedTangram =
            { firstLargeTriangle = animatePieceConfig model.timeline .firstLargeTriangle
            , secondLargeTriangle = animatePieceConfig model.timeline .secondLargeTriangle
            , firstSmallTriangle = animatePieceConfig model.timeline .firstSmallTriangle
            , secondSmallTriangle = animatePieceConfig model.timeline .secondSmallTriangle
            , mediumTriangle = animatePieceConfig model.timeline .mediumTriangle
            , square = animatePieceConfig model.timeline .square
            , parallelogram = animatePieceConfig model.timeline .parallelogram
            , scale = animateScale model.timeline
            }
    in
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 800 600"
        , Html.Events.onClick ToggleConfig
        , Svg.Attributes.width "100"
        ]
        [ largeTriangle interpolatedTangram.firstLargeTriangle interpolatedTangram.scale
        , largeTriangle interpolatedTangram.secondLargeTriangle interpolatedTangram.scale
        , smallTriangle interpolatedTangram.firstSmallTriangle interpolatedTangram.scale
        , smallTriangle interpolatedTangram.secondSmallTriangle interpolatedTangram.scale
        , mediumTriangle interpolatedTangram.mediumTriangle interpolatedTangram.scale
        , square interpolatedTangram.square interpolatedTangram.scale
        , parallelogram interpolatedTangram.parallelogram interpolatedTangram.scale
        ]



-- TANGRAM DEFINITIONS


elmLogo : Tangram
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


tent : Tangram
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


lake : Tangram
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


byTheRiver : Tangram
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


tents : Tangram
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


fireplace : Tangram
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


configurations : Nonempty Tangram
configurations =
    Nonempty
        elmLogo
        [ fireplace
        , tents
        , tent
        , lake
        , byTheRiver
        ]


type alias PieceConfig =
    { color : Color, x : Float, y : Float, rotation : Float }


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



-- ANIMATION


animatePieceConfig : Timeline Tangram -> (Tangram -> PieceConfig) -> PieceConfig
animatePieceConfig timeline getPiece =
    { color = Animator.Value.color timeline (\tangram -> (getPiece tangram).color)
    , x =
        Animator.Value.float timeline
            (\tangram -> Animator.Value.to (getPiece tangram).x |> Animator.Value.withTransition transition)
    , y =
        Animator.Value.float timeline
            (\tangram -> Animator.Value.to (getPiece tangram).y |> Animator.Value.withTransition transition)
    , rotation =
        Animator.Value.float timeline
            (\tangram -> Animator.Value.to (getPiece tangram).rotation |> Animator.Value.withTransition transition)
    }


transition : Transition
transition =
    Animator.Transition.spring { wobble = 0.5, quickness = 1 }


animateScale : Timeline Tangram -> Float
animateScale timeline =
    Animator.Value.float timeline
        (\tangram -> Animator.Value.to tangram.scale)



-- RENDERING


strokeW : Svg.Attribute msg
strokeW =
    Svg.Attributes.strokeWidth "12"


strokeColor : Svg.Attribute msg
strokeColor =
    Svg.Attributes.stroke "#ffffff"


transformValue_ : PieceConfig -> String -> Float -> String
transformValue_ triangle center scale =
    "translate("
        ++ String.fromFloat triangle.x
        ++ ","
        ++ String.fromFloat triangle.y
        ++ ") rotate("
        ++ String.fromFloat triangle.rotation
        ++ " "
        ++ center
        ++ ") scale("
        ++ String.fromFloat scale
        ++ ")"


largeTriangle : PieceConfig -> Float -> Svg msg
largeTriangle config scale =
    let
        transformValue =
            transformValue_ config "150 75" scale
    in
    Svg.g
        [ Svg.Attributes.transform transformValue
        ]
        [ Svg.polygon
            [ Svg.Attributes.points "0,0 300,0 150,150"
            , Svg.Attributes.fill (Color.toCssString config.color)
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeOpacity "1"
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


smallTriangle : PieceConfig -> Float -> Svg msg
smallTriangle config scale =
    let
        transformValue =
            transformValue_ config "75 37.5" scale
    in
    Svg.g
        [ Svg.Attributes.transform transformValue
        ]
        [ Svg.polygon
            [ Svg.Attributes.points "0,0 150,0 75,75"
            , Svg.Attributes.fill (Color.toCssString config.color)
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


mediumTriangle : PieceConfig -> Float -> Svg msg
mediumTriangle config scale =
    let
        transformValue =
            transformValue_ config "106.08 53.04" scale
    in
    Svg.g
        [ Svg.Attributes.transform transformValue
        ]
        [ Svg.polygon
            [ Svg.Attributes.points "0,0 212.13,0 106.08,106.08"
            , Svg.Attributes.fill (Color.toCssString config.color)
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


square : PieceConfig -> Float -> Svg msg
square config scale =
    let
        transformValue =
            transformValue_ config "53.04 53.04" scale
    in
    Svg.g
        [ Svg.Attributes.transform transformValue
        ]
        [ Svg.polygon
            [ Svg.Attributes.points "0,0 106.08,0 106.08,106.08 0,106.08"
            , Svg.Attributes.fill (Color.toCssString config.color)
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


parallelogram : PieceConfig -> Float -> Svg msg
parallelogram config scale =
    let
        transformValue =
            transformValue_ config "106.08 53.04" scale
    in
    Svg.g
        [ Svg.Attributes.transform transformValue
        ]
        [ Svg.polygon
            [ Svg.Attributes.points "0,0 106.08,0 0,106.08 -106.08,106.08"
            , Svg.Attributes.fill (Color.toCssString config.color)
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]
