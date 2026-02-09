module Icons exposing (minus, plus)

import Html exposing (Html)
import Svg
import Svg.Attributes


minus : Html msg
minus =
    Svg.svg
        [ Svg.Attributes.fill "none"
        , Svg.Attributes.viewBox "0 0 24 24"
        , Svg.Attributes.strokeWidth "2.5"
        , Svg.Attributes.stroke "currentColor"
        , Svg.Attributes.width "24"
        ]
        [ Svg.path [ Svg.Attributes.strokeLinecap "round", Svg.Attributes.strokeLinejoin "round", Svg.Attributes.d "M18 12H6" ] [] ]


plus : Html msg
plus =
    Svg.svg
        [ Svg.Attributes.fill "none"
        , Svg.Attributes.viewBox "0 0 24 24"
        , Svg.Attributes.strokeWidth "2.5"
        , Svg.Attributes.stroke "currentColor"
        , Svg.Attributes.width "24"
        ]
        [ Svg.path [ Svg.Attributes.strokeLinecap "round", Svg.Attributes.strokeLinejoin "round", Svg.Attributes.d "M12 6v12m6-6H6" ] [] ]
