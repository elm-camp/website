module View.Logo exposing (Model, Msg, PieceConfig, Tangram, TangramPiece(..), init, update, view)

import Effect.Test exposing (Button(..))
import Html exposing (Html, div)
import Html.Events exposing (onClick)
import List.Extra
import List.Nonempty exposing (Nonempty(..))
import Svg exposing (Svg, g, polygon, svg)
import Svg.Attributes exposing (fill, points, stroke, strokeWidth, transform, viewBox)


type TangramPiece
    = LargeTriangle PieceConfig
    | MediumTriangle PieceConfig
    | SmallTriangle PieceConfig
    | Square PieceConfig
    | Parallelogram PieceConfig


type alias PieceConfig =
    { color : String, x : Float, y : Float, rotation : Float, scale : Float }


type alias Tangram =
    List TangramPiece


type alias Model =
    { index : Int }


type Msg
    = ToggleConfig


init : Model
init =
    { index = 0 }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleConfig ->
            { model | index = model.index + 1 }


transition : Svg.Attribute msg
transition =
    Svg.Attributes.style "transition: transform 0.4s ease-in-out"


strokeW : Svg.Attribute msg
strokeW =
    strokeWidth "12"


strokeColor : Svg.Attribute msg
strokeColor =
    stroke "#ffffff"


transformValue_ : PieceConfig -> String -> String
transformValue_ triangle center =
    "translate("
        ++ String.fromFloat triangle.x
        ++ ","
        ++ String.fromFloat triangle.y
        ++ ") rotate("
        ++ String.fromFloat triangle.rotation
        ++ " "
        ++ center
        ++ ") scale("
        ++ String.fromFloat triangle.scale
        ++ ")"


largeTriangle : PieceConfig -> Svg Msg
largeTriangle config =
    let
        transformValue =
            transformValue_ config "150 75"
    in
    g
        [ transform transformValue
        , transition
        ]
        [ polygon
            [ points "0,0 300,0 150,150"
            , fill config.color
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeOpacity "1"
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


smallTriangle : PieceConfig -> Svg Msg
smallTriangle config =
    let
        transformValue =
            transformValue_ config "75 37.5"
    in
    g
        [ transform transformValue
        , transition
        ]
        [ polygon
            [ points "0,0 150,0 75,75"
            , fill config.color
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


mediumTriangle : PieceConfig -> Svg Msg
mediumTriangle config =
    let
        transformValue =
            transformValue_ config "106.08 53.04"
    in
    g
        [ transform transformValue
        , transition
        ]
        [ polygon
            [ points "0,0 212.13,0 106.08,106.08"
            , fill config.color
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


square : PieceConfig -> Svg Msg
square config =
    let
        transformValue =
            transformValue_ config "53.04 53.04"
    in
    g
        [ transform transformValue
        , transition
        ]
        [ polygon
            [ points "0,0 106.08,0 106.08,106.08 0,106.08"
            , fill config.color
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


parallelogram : PieceConfig -> Svg Msg
parallelogram config =
    let
        transformValue =
            transformValue_ config "106.08 53.04"
    in
    g
        [ transform transformValue
        , transition
        ]
        [ polygon
            [ points "0,0 106.08,0 0,106.08 -106.08,106.08"
            , fill config.color
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


elmLogo : Tangram
elmLogo =
    [ LargeTriangle { color = "#1d322d", x = 65, y = 370, rotation = -90, scale = 1.7 }
    , LargeTriangle { color = "#5db17e", x = 350, y = 448, rotation = 180, scale = 1.7 }
    , SmallTriangle { color = "#0c6d51", x = 535, y = 378, rotation = 90, scale = 1.7 }
    , Square { color = "#a9c589", x = 468, y = 235, rotation = 45, scale = 1.7 }
    , SmallTriangle { color = "#0c6d51", x = 265, y = 210, rotation = 0, scale = 1.7 }
    , Parallelogram { color = "#a9c589", x = 335, y = 145, rotation = 45, scale = 1.7 }
    , MediumTriangle { color = "#5db17e", x = 505, y = 175, rotation = -135, scale = 1.7 }
    ]


tent : Tangram
tent =
    [ LargeTriangle { color = "#5db17e", x = 60, y = 266, rotation = 90, scale = 1.0 }
    , LargeTriangle { color = "#1d322d", x = 510, y = 266, rotation = 270, scale = 1.0 }
    , SmallTriangle { color = "#0c6d51", x = 280, y = 378, rotation = 135, scale = 1.0 }
    , Square { color = "#f0ac01", x = 381, y = 100, rotation = 45, scale = 1.0 }
    , SmallTriangle { color = "#0c6d51", x = 333, y = 323, rotation = -45, scale = 1.0 }
    , Parallelogram { color = "#a9c589", x = 383, y = 226, rotation = 270, scale = 1.0 }
    , MediumTriangle { color = "#5db17e", x = 330, y = 388, rotation = 180, scale = 1.0 }
    ]


lake : Tangram
lake =
    [ LargeTriangle { color = "#5db17e", x = 60, y = 266, rotation = 180, scale = 1.0 }
    , LargeTriangle { color = "#1d322d", x = 60, y = 416, rotation = 0, scale = 1.0 }
    , SmallTriangle { color = "#0c6d51", x = 380, y = 340, rotation = 180, scale = 1.0 }
    , Square { color = "#f0ac01", x = 315, y = 260, rotation = 45, scale = 1.0 }
    , SmallTriangle { color = "#1d322d", x = 380, y = 415, rotation = 0, scale = 1.0 }
    , Parallelogram { color = "#5fb5cc", x = 330, y = 136, rotation = 225, scale = 1.0 }
    , MediumTriangle { color = "#f0ac01", x = 263, y = 445, rotation = 180, scale = 1.0 }
    ]


byTheRiver : Tangram
byTheRiver =
    [ LargeTriangle { color = "#5fb5cc", x = 415, y = 360, rotation = 90, scale = 1.0 }
    , LargeTriangle { color = "#5fb5cc", x = 340, y = 436, rotation = 180, scale = 1.0 }
    , SmallTriangle { color = "#0c6d51", x = 180, y = 338, rotation = 135, scale = 1.0 }
    , Square { color = "#f0ac01", x = 381, y = 100, rotation = 45, scale = 1.0 }
    , SmallTriangle { color = "#0c6d51", x = 233, y = 283, rotation = -45, scale = 1.0 }
    , Parallelogram { color = "#a9c589", x = 283, y = 186, rotation = 270, scale = 1.0 }
    , MediumTriangle { color = "#5db17e", x = 230, y = 348, rotation = 180, scale = 1.0 }
    ]


tents : Tangram
tents =
    [ LargeTriangle { color = "#5db17e", x = 370, y = 40, rotation = 180, scale = 1.0 }
    , LargeTriangle { color = "#1d322d", x = 50, y = 136, rotation = 180, scale = 1.0 }
    , SmallTriangle { color = "#f0ac01", x = 394, y = 336, rotation = 45, scale = 1.0 }
    , Square { color = "#f0ac01", x = 336, y = 295, rotation = 0, scale = 1.0 }
    , SmallTriangle { color = "#f0ac01", x = 235, y = 337, rotation = -45, scale = 1.0 }
    , Parallelogram { color = "#f0ac01", x = 230, y = 296, rotation = 0, scale = 1.0 }
    , MediumTriangle { color = "#f0ac01", x = 230, y = 188, rotation = 180, scale = 1.0 }
    ]


fireplace : Tangram
fireplace =
    [ LargeTriangle { color = "#ff8000", x = 200, y = 320, rotation = 90, scale = 1.0 }
    , LargeTriangle { color = "#ff8000", x = 360, y = 290, rotation = 270, scale = 1.0 }
    , SmallTriangle { color = "#a20000", x = 400, y = 158, rotation = 90, scale = 1.0 }
    , Square { color = "#f0ac01", x = 376, y = 360, rotation = 45, scale = 1.0 }
    , SmallTriangle { color = "#a20000", x = 293, y = 203, rotation = 135, scale = 1.0 }
    , Parallelogram { color = "#996e3f", x = 313, y = 526, rotation = 45, scale = 1.0 }
    , MediumTriangle { color = "#b4814b", x = 420, y = 438, rotation = 180, scale = 1.0 }
    ]


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


viewTangramPiece : TangramPiece -> Svg Msg
viewTangramPiece piece =
    case piece of
        LargeTriangle config ->
            largeTriangle config

        SmallTriangle config ->
            smallTriangle config

        MediumTriangle config ->
            mediumTriangle config

        Square config ->
            square config

        Parallelogram config ->
            parallelogram config


viewTangram : Tangram -> Svg Msg
viewTangram tangram =
    svg
        [ viewBox "40 40 700 600"
        , onClick ToggleConfig
        ]
        (List.map viewTangramPiece tangram)


view : Model -> Html Msg
view model =
    div [] [ viewTangram (List.Nonempty.get model.index configurations) ]
