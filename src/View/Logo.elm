module Camp26Czech.Logo exposing (Model, Msg, init, update, view)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Svg exposing (Svg, g, polygon, svg)
import Svg.Attributes exposing (fill, points, stroke, strokeWidth, style, transform, viewBox)


type alias ConfigZipper =
    { prev : List (List (Svg Msg))
    , current : List (Svg Msg)
    , next : List (List (Svg Msg))
    }


type alias Model =
    { configs : ConfigZipper
    }


type Msg
    = ToggleConfig


initZipper : List (List (Svg Msg)) -> ConfigZipper
initZipper configs =
    case configs of
        [] ->
            { prev = [], current = [], next = [] }

        first :: rest ->
            { prev = [], current = first, next = rest }


moveNext : ConfigZipper -> ConfigZipper
moveNext zipper =
    case zipper.next of
        [] ->
            -- Cycle to beginning
            case List.reverse (zipper.current :: zipper.prev) of
                [] ->
                    zipper

                first :: rest ->
                    { prev = [], current = first, next = rest }

        nextConfig :: remainingNext ->
            { prev = zipper.current :: zipper.prev
            , current = nextConfig
            , next = remainingNext
            }


init : Model
init =
    { configs = initZipper configurations }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleConfig ->
            { model | configs = moveNext model.configs }


type alias Triangle =
    { color : String
    , x : Float
    , y : Float
    , rotation : Float
    , scale : Float
    }


transition =
    Svg.Attributes.style "transition: transform 0.4s ease-in-out"


strokeW =
    strokeWidth "12"


strokeColor =
    stroke "#ffffff"


transformValue_ : Triangle -> String -> String
transformValue_ triangle center =
    "translate(" ++ String.fromFloat triangle.x ++ "," ++ String.fromFloat triangle.y ++ ") rotate(" ++ String.fromFloat triangle.rotation ++ " " ++ center ++ ") scale(" ++ String.fromFloat triangle.scale ++ ")"


largeTriangle : Triangle -> Svg Msg
largeTriangle triangle =
    let
        transformValue =
            transformValue_ triangle "150 75"
    in
    g
        [ transform transformValue
        , transition
        ]
        [ polygon
            [ points "0,0 300,0 150,150"
            , fill triangle.color
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeOpacity "1"
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


smallTriangle : Triangle -> Svg Msg
smallTriangle triangle =
    let
        transformValue =
            transformValue_ triangle "75 37.5"
    in
    g
        [ transform transformValue
        , transition
        ]
        [ polygon
            [ points "0,0 150,0 75,75"
            , fill triangle.color
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


mediumTriangle : Triangle -> Svg Msg
mediumTriangle triangle =
    let
        transformValue =
            transformValue_ triangle "106.08 53.04"
    in
    g
        [ transform transformValue
        , transition
        ]
        [ polygon
            [ points "0,0 212.13,0 106.08,106.08"
            , fill triangle.color
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


square : Triangle -> Svg Msg
square shape =
    let
        transformValue =
            transformValue_ shape "53.04 53.04"
    in
    g
        [ transform transformValue
        , transition
        ]
        [ polygon
            [ points "0,0 106.08,0 106.08,106.08 0,106.08"
            , fill shape.color
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


parallelogram : Triangle -> Svg Msg
parallelogram shape =
    let
        transformValue =
            transformValue_ shape "106.08 53.04"
    in
    g
        [ transform transformValue
        , transition
        ]
        [ polygon
            [ points "0,0 106.08,0 0,106.08 -106.08,106.08"
            , fill shape.color
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


elmLogo =
    [ largeTriangle { color = "#1d322d", x = 65, y = 370, rotation = -90, scale = 1.7 }
    , largeTriangle { color = "#5db17e", x = 350, y = 448, rotation = 180, scale = 1.7 }
    , smallTriangle { color = "#0c6d51", x = 535, y = 378, rotation = 90, scale = 1.7 }
    , square { color = "#a9c589", x = 468, y = 235, rotation = 45, scale = 1.7 }
    , smallTriangle { color = "#0c6d51", x = 265, y = 210, rotation = 0, scale = 1.7 }
    , parallelogram { color = "#a9c589", x = 335, y = 145, rotation = 45, scale = 1.7 }
    , mediumTriangle { color = "#5db17e", x = 505, y = 175, rotation = -135, scale = 1.7 }
    ]


tent =
    [ largeTriangle { color = "#5db17e", x = 60, y = 266, rotation = 90, scale = 1.0 }
    , largeTriangle { color = "#1d322d", x = 510, y = 266, rotation = 270, scale = 1.0 }
    , smallTriangle { color = "#0c6d51", x = 280, y = 378, rotation = 135, scale = 1.0 }
    , square { color = "#f0ac01", x = 381, y = 100, rotation = 45, scale = 1.0 }
    , smallTriangle { color = "#0c6d51", x = 333, y = 323, rotation = -45, scale = 1.0 }
    , parallelogram { color = "#a9c589", x = 383, y = 226, rotation = 270, scale = 1.0 }
    , mediumTriangle { color = "#5db17e", x = 330, y = 388, rotation = 180, scale = 1.0 }
    ]


lake =
    [ largeTriangle { color = "#5db17e", x = 60, y = 266, rotation = 180, scale = 1.0 }
    , largeTriangle { color = "#1d322d", x = 60, y = 416, rotation = 0, scale = 1.0 }
    , smallTriangle { color = "#0c6d51", x = 380, y = 340, rotation = 180, scale = 1.0 }
    , square { color = "#f0ac01", x = 315, y = 260, rotation = 45, scale = 1.0 }
    , smallTriangle { color = "#1d322d", x = 380, y = 415, rotation = 0, scale = 1.0 }
    , parallelogram { color = "#5fb5cc", x = 330, y = 136, rotation = 225, scale = 1.0 }
    , mediumTriangle { color = "#f0ac01", x = 263, y = 445, rotation = 180, scale = 1.0 }
    ]


byTheRiver =
    [ largeTriangle { color = "#5fb5cc", x = 415, y = 360, rotation = 90, scale = 1.0 }
    , largeTriangle { color = "#5fb5cc", x = 340, y = 436, rotation = 180, scale = 1.0 }
    , smallTriangle { color = "#0c6d51", x = 180, y = 338, rotation = 135, scale = 1.0 }
    , square { color = "#f0ac01", x = 381, y = 100, rotation = 45, scale = 1.0 }
    , smallTriangle { color = "#0c6d51", x = 233, y = 283, rotation = -45, scale = 1.0 }
    , parallelogram { color = "#a9c589", x = 283, y = 186, rotation = 270, scale = 1.0 }
    , mediumTriangle { color = "#5db17e", x = 230, y = 348, rotation = 180, scale = 1.0 }
    ]


tents =
    [ largeTriangle { color = "#5db17e", x = 370, y = 40, rotation = 180, scale = 1.0 }
    , largeTriangle { color = "#1d322d", x = 50, y = 136, rotation = 180, scale = 1.0 }
    , smallTriangle { color = "#f0ac01", x = 394, y = 336, rotation = 45, scale = 1.0 }
    , square { color = "#f0ac01", x = 336, y = 295, rotation = 0, scale = 1.0 }
    , smallTriangle { color = "#f0ac01", x = 235, y = 337, rotation = -45, scale = 1.0 }
    , parallelogram { color = "#f0ac01", x = 230, y = 296, rotation = 0, scale = 1.0 }
    , mediumTriangle { color = "#f0ac01", x = 230, y = 188, rotation = 180, scale = 1.0 }
    ]


fireplace =
    [ largeTriangle { color = "#ff8000", x = 200, y = 320, rotation = 90, scale = 1.0 }
    , largeTriangle { color = "#ff8000", x = 360, y = 290, rotation = 270, scale = 1.0 }
    , smallTriangle { color = "#a20000", x = 400, y = 158, rotation = 90, scale = 1.0 }
    , square { color = "#f0ac01", x = 376, y = 360, rotation = 45, scale = 1.0 }
    , smallTriangle { color = "#a20000", x = 293, y = 203, rotation = 135, scale = 1.0 }
    , parallelogram { color = "#996e3f", x = 313, y = 526, rotation = 45, scale = 1.0 }
    , mediumTriangle { color = "#b4814b", x = 420, y = 438, rotation = 180, scale = 1.0 }
    ]


configurations =
    [ elmLogo
    , fireplace
    , tents
    , tent
    , lake
    , byTheRiver
    ]


view : Model -> Html Msg
view model =
    div []
        [ svg
            [ viewBox "0 40 800 600"
            , onClick ToggleConfig
            ]
            model.configs.current
        ]
