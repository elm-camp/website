module Theme exposing (..)

import Element exposing (..)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Html exposing (Html)
import Html.Attributes
import Money
import Stripe exposing (Price)


css : Html msg
css =
    Html.node "style"
        []
        [ Html.text <|
            fontFace 800 "Figtree-ExtraBold"
                ++ fontFace 700 "Figtree-Bold"
                ++ fontFace 600 "Figtree-SemiBold"
                ++ fontFace 500 "Figtree-Medium"
                ++ fontFace 400 "Figtree-Regular"
                ++ fontFace 300 "Figtree-Light"
                ++ """
/* Spinner */
@-webkit-keyframes spin { 0% { -webkit-transform: rotate(0deg); transform: rotate(0deg); } 100% { -webkit-transform: rotate(360deg); transform: rotate(360deg); } }
@keyframes spin { 0% { -webkit-transform: rotate(0deg); transform: rotate(0deg); } 100% { -webkit-transform: rotate(360deg); transform: rotate(360deg); } }

.spin {
  -webkit-animation: spin 1s infinite linear;
          animation: spin 1s infinite linear;
}
"""
        ]


colors =
    { green = Element.rgb255 92 176 126
    , lightGrey = Element.rgb255 200 200 200
    }


fontFace : Int -> String -> String
fontFace weight name =
    """
@font-face {
  font-family: 'Open Sans';
  font-style: normal;
  font-weight: """ ++ String.fromInt weight ++ """;
  font-stretch: normal;
  font-display: swap;
  src: url(/fonts/""" ++ name ++ """.ttf) format('truetype');
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD, U+2192, U+2713;
}"""


viewIf condition view =
    if condition then
        view

    else
        Element.none


priceText : Price -> String
priceText { currency, amount } =
    Money.toNativeSymbol currency ++ String.fromInt (amount // 100)


panel attrs x =
    Element.column
        ([ Element.width Element.fill
         , Element.alignTop
         , Element.spacing 16
         , Element.Background.color (Element.rgb 1 1 1)
         , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = Element.rgba 0 0 0 0.25 }
         , Element.height Element.fill
         , Element.Border.rounded 16
         , Element.padding 16
         ]
            ++ attrs
        )
        x


submitButtonAttributes : Bool -> List (Element.Attribute msg)
submitButtonAttributes isEnabled =
    [ Element.width Element.fill
    , Element.Background.color
        (if isEnabled then
            Element.rgb255 92 176 126

         else
            Element.rgb255 137 141 137
        )
    , Element.padding 16
    , Element.Border.rounded 8
    , Element.alignBottom
    , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Element.Font.semiBold
    , Element.Font.color (Element.rgb 1 1 1)
    ]


toggleButton label isActive onPress =
    Element.Input.button
        (toggleButtonAttributes isActive)
        { onPress = onPress
        , label = Element.el [ Element.centerX ] (Element.text label)
        }


toggleButtonAttributes : Bool -> List (Element.Attribute msg)
toggleButtonAttributes isActive =
    [ Element.Background.color
        (if isActive then
            colors.green

         else
            colors.lightGrey
        )
    , Element.padding 16
    , Element.Border.rounded 8
    , Element.alignBottom
    , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Element.Font.semiBold
    , Element.Font.color (Element.rgb 1 1 1)
    ]


rowToColumnWhen width model attrs children =
    if model.window.width > width then
        Element.row attrs children

    else
        Element.column attrs children


spinnerWhite =
    el
        [ width (px 16)
        , height (px 16)
        , htmlAttribute <| Html.Attributes.class "spin"
        , htmlAttribute <| Html.Attributes.style "border" "2px solid #fff"
        , htmlAttribute <| Html.Attributes.style "border-top-color" "transparent"
        , htmlAttribute <| Html.Attributes.style "border-radius" "50px"
        ]
        none
