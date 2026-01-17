module View.Tangram exposing
    ( PieceConfig
    , PieceId(..)
    , Tangram
    , viewAnimatedTangram
    )

import Animator
import Animator.Timeline exposing (Timeline)
import Animator.Transition
import Animator.Value
import Color exposing (Color)
import Html exposing (Html)
import Html.Events
import Svg exposing (Svg, g, polygon, svg)
import Svg.Attributes exposing (fill, points, stroke, strokeWidth, transform, viewBox)


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


type PieceId
    = FirstLargeTriangle
    | SecondLargeTriangle
    | MediumTriangle
    | FirstSmallTriangle
    | SecondSmallTriangle
    | Square
    | Parallelogram



-- HELPERS


getPieceConfig : PieceId -> Tangram -> PieceConfig
getPieceConfig pieceId tangram =
    case pieceId of
        FirstLargeTriangle ->
            tangram.firstLargeTriangle

        SecondLargeTriangle ->
            tangram.secondLargeTriangle

        MediumTriangle ->
            tangram.mediumTriangle

        FirstSmallTriangle ->
            tangram.firstSmallTriangle

        SecondSmallTriangle ->
            tangram.secondSmallTriangle

        Square ->
            tangram.square

        Parallelogram ->
            tangram.parallelogram


setPieceConfig : PieceId -> PieceConfig -> Tangram -> Tangram
setPieceConfig pieceId config tangram =
    case pieceId of
        FirstLargeTriangle ->
            { tangram | firstLargeTriangle = config }

        SecondLargeTriangle ->
            { tangram | secondLargeTriangle = config }

        MediumTriangle ->
            { tangram | mediumTriangle = config }

        FirstSmallTriangle ->
            { tangram | firstSmallTriangle = config }

        SecondSmallTriangle ->
            { tangram | secondSmallTriangle = config }

        Square ->
            { tangram | square = config }

        Parallelogram ->
            { tangram | parallelogram = config }



-- ANIMATION


animatePieceConfig : Timeline Tangram -> (Tangram -> PieceConfig) -> PieceConfig
animatePieceConfig timeline getPiece =
    let
        currentTangram =
            Animator.Timeline.current timeline

        currentColor =
            Animator.Value.color timeline (\tangram -> (getPiece tangram).color)

        transition =
            Animator.Transition.spring { wobble = 0.5, quickness = 1 }
    in
    { color = currentColor
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


animateScale : Timeline Tangram -> Float
animateScale timeline =
    Animator.Value.float timeline
        (\tangram -> Animator.Value.to tangram.scale)


viewAnimatedTangram : Timeline Tangram -> msg -> Svg msg
viewAnimatedTangram timeline clickMsg =
    let
        interpolatedTangram =
            { firstLargeTriangle = animatePieceConfig timeline .firstLargeTriangle
            , secondLargeTriangle = animatePieceConfig timeline .secondLargeTriangle
            , firstSmallTriangle = animatePieceConfig timeline .firstSmallTriangle
            , secondSmallTriangle = animatePieceConfig timeline .secondSmallTriangle
            , mediumTriangle = animatePieceConfig timeline .mediumTriangle
            , square = animatePieceConfig timeline .square
            , parallelogram = animatePieceConfig timeline .parallelogram
            , scale = animateScale timeline
            }
    in
    viewTangram interpolatedTangram clickMsg



-- RENDERING


strokeW : Svg.Attribute msg
strokeW =
    strokeWidth "12"


strokeColor : Svg.Attribute msg
strokeColor =
    stroke "#ffffff"


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
    g
        [ transform transformValue
        ]
        [ polygon
            [ points "0,0 300,0 150,150"
            , fill (Color.toCssString config.color)
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
    g
        [ transform transformValue
        ]
        [ polygon
            [ points "0,0 150,0 75,75"
            , fill (Color.toCssString config.color)
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
    g
        [ transform transformValue
        ]
        [ polygon
            [ points "0,0 212.13,0 106.08,106.08"
            , fill (Color.toCssString config.color)
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
    g
        [ transform transformValue
        ]
        [ polygon
            [ points "0,0 106.08,0 106.08,106.08 0,106.08"
            , fill (Color.toCssString config.color)
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
    g
        [ transform transformValue
        ]
        [ polygon
            [ points "0,0 106.08,0 0,106.08 -106.08,106.08"
            , fill (Color.toCssString config.color)
            , strokeColor
            , strokeW
            , Svg.Attributes.strokeLinejoin "round"
            ]
            []
        ]


viewTangramPieces : Tangram -> List (Svg msg)
viewTangramPieces tangram =
    [ largeTriangle tangram.firstLargeTriangle tangram.scale
    , largeTriangle tangram.secondLargeTriangle tangram.scale
    , smallTriangle tangram.firstSmallTriangle tangram.scale
    , smallTriangle tangram.secondSmallTriangle tangram.scale
    , mediumTriangle tangram.mediumTriangle tangram.scale
    , square tangram.square tangram.scale
    , parallelogram tangram.parallelogram tangram.scale
    ]


viewTangram : Tangram -> msg -> Svg msg
viewTangram tangram clickMsg =
    svg
        [ viewBox "0 0 800 600"
        , Html.Events.onClick clickMsg
        ]
        (viewTangramPieces tangram)
