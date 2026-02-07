module Theme exposing
    ( Size
    , Theme
    , attr
    , colorWithAlpha
    , colors
    , contentAttributes
    , css
    , fontFace
    , footer
    , glow
    , greenTheme
    , h2
    , h3
    , isMobile
    , lightTheme
    , localPriceText
    , normalButtonAttributes
    , numericField
    , panel
    , rowToColumnWhen
    , spinnerWhite
    , stripePriceText
    , submitButtonAttributes
    , toggleButton
    , toggleButtonAttributes
    )

import Color
import Dict exposing (Dict)
import Effect.Http as Http
import Html exposing (Html)
import Html.Attributes
import Money
import Quantity exposing (Quantity, Rate)
import Route exposing (Route(..))
import Stripe exposing (ConversionRateStatus(..), CurrentCurrency, LocalCurrency, Price, StripeCurrency)
import Ui
import Ui.Accessibility
import Ui.Font
import Ui.Input
import Ui.Shadow


type alias Theme =
    { defaultText : Ui.Color
    , mutedText : Ui.Color
    , grey : Ui.Color
    , lightGrey : Ui.Color
    , link : Ui.Color
    , elmText : Ui.Color
    , background : Ui.Color
    }


type alias Size =
    { width : Int, height : Int }


lightTheme : Theme
lightTheme =
    { defaultText = Ui.rgb 30 50 46
    , mutedText = Ui.rgb 74 94 122
    , link = Ui.rgb 12 109 82
    , lightGrey = Ui.rgb 220 240 255
    , grey = Ui.rgb 200 220 240
    , elmText = Ui.rgb 92 176 126
    , background = Ui.rgb 255 244 225
    }


greenTheme : Theme
greenTheme =
    { defaultText = Ui.rgb 73 80 96
    , mutedText = Ui.rgb 74 94 122
    , link = Ui.rgb 12 109 82
    , lightGrey = Ui.rgb 220 240 255
    , grey = Ui.rgb 200 220 240
    , elmText = Ui.rgb 13 109 82
    , background = Ui.rgb 255 253 244
    }


contentAttributes : List (Ui.Attribute msg)
contentAttributes =
    [ Ui.widthMax 800
    , Ui.centerX
    ]


isMobile : Size -> Bool
isMobile a =
    a.width < 800


css : Html msg
css =
    Html.node "style"
        []
        [ Html.text
            (fontFace 800 "Figtree-ExtraBold" "Open Sans"
                ++ fontFace 700 "Figtree-Bold" "Open Sans"
                ++ fontFace 600 "Figtree-SemiBold" "Open Sans"
                ++ fontFace 500 "Figtree-Medium" "Open Sans"
                ++ fontFace 400 "Figtree-Regular" "Open Sans"
                ++ fontFace 300 "Figtree-Light" "Open Sans"
                ++ fontFace 700 "Fredoka-Bold" "Fredoka"
                ++ fontFace 600 "Fredoka-SemiBold" "Fredoka"
                ++ fontFace 500 "Fredoka-Medium" "Fredoka"
                ++ fontFace 400 "Fredoka-Regular" "Fredoka"
                ++ fontFace 300 "Fredoka-Light" "Fredoka"
                ++ """
/* Spinner */
@-webkit-keyframes spin { 0% { -webkit-transform: rotate(0deg); transform: rotate(0deg); } 100% { -webkit-transform: rotate(360deg); transform: rotate(360deg); } }
@keyframes spin { 0% { -webkit-transform: rotate(0deg); transform: rotate(0deg); } 100% { -webkit-transform: rotate(360deg); transform: rotate(360deg); } }

.spin {
  -webkit-animation: spin 1s infinite linear;
          animation: spin 1s infinite linear;
}
"""
            )
        ]


colors : { green : Ui.Color, lightGrey : Ui.Color, white : Ui.Color, red : Ui.Color }
colors =
    { green = Ui.rgb 92 176 126
    , lightGrey = Ui.rgb 200 200 200
    , white = Ui.rgb 255 255 255
    , red = Ui.rgb 234 87 59
    }


colorWithAlpha : Float -> Ui.Color -> Ui.Color
colorWithAlpha alpha color =
    let
        { red, green, blue } =
            Color.toRgba color
    in
    Color.rgba red green blue alpha


fontFace : Int -> String -> String -> String
fontFace weight name fontFamilyName =
    """
@font-face {
  font-family: '""" ++ fontFamilyName ++ """';
  font-style: normal;
  font-weight: """ ++ String.fromInt weight ++ """;
  font-stretch: normal;
  font-display: swap;
  src: url(/fonts/""" ++ name ++ """.ttf) format('truetype');
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD, U+2192, U+2713;
}"""


stripePriceText : Quantity Float StripeCurrency -> CurrentCurrency -> String
stripePriceText price currentCurrency =
    let
        amount : Int
        amount =
            Quantity.at_ currentCurrency.conversionRate price |> Quantity.unwrap |> round
    in
    Money.toNativeSymbol currentCurrency.currency ++ String.fromInt (amount // 100)


localPriceText : Quantity Int LocalCurrency -> CurrentCurrency -> String
localPriceText price currentCurrency =
    Money.toNativeSymbol currentCurrency.currency ++ String.fromInt (Quantity.unwrap price // 100)


panel : List (Ui.Attribute msg) -> List (Ui.Element msg) -> Ui.Element msg
panel attrs x =
    Ui.column
        ([ Ui.width Ui.fill
         , Ui.alignTop
         , Ui.spacing 16
         , Ui.background (Ui.rgb 255 255 255)
         , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 4, color = Ui.rgba 0 0 0 0.25 } ]
         , Ui.height Ui.fill
         , Ui.rounded 16
         , Ui.padding 16
         ]
            ++ attrs
        )
        x


submitButtonAttributes : msg -> Bool -> List (Ui.Attribute msg)
submitButtonAttributes onPress isEnabled =
    [ Ui.width Ui.shrink
    , Ui.background
        (if isEnabled then
            Ui.rgb 92 176 126

         else
            Ui.rgb 137 141 137
        )
    , Ui.padding 16
    , Ui.rounded 8
    , Ui.alignBottom
    , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 2, color = Ui.rgba 0 0 0 0.1 } ]
    , Ui.Font.weight 600
    , Ui.Font.color (Ui.rgb 255 255 255)
    , Ui.Input.button onPress
    ]


toggleButton : String -> Bool -> msg -> Ui.Element msg
toggleButton label isActive onPress =
    Ui.el
        (toggleButtonAttributes onPress isActive)
        (Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Ui.text label))


toggleButtonAttributes : msg -> Bool -> List (Ui.Attribute msg)
toggleButtonAttributes onPress isActive =
    [ Ui.background
        (if isActive then
            colors.green

         else
            colors.lightGrey
        )
    , Ui.padding 16
    , Ui.rounded 8
    , Ui.width Ui.shrink
    , Ui.alignBottom
    , Ui.Input.button onPress
    , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 2, color = Ui.rgba 0 0 0 0.1 } ]
    , Ui.Font.weight 600
    , Ui.Font.color (Ui.rgb 255 255 255)
    ]


rowToColumnWhen : Int -> Size -> List (Ui.Attribute msg) -> List (Ui.Element msg) -> Ui.Element msg
rowToColumnWhen width window attrs children =
    if window.width > width then
        Ui.row
            attrs
            children

    else
        Ui.column
            attrs
            children


spinnerWhite : Ui.Element msg
spinnerWhite =
    Ui.el
        [ Ui.width (Ui.px 16)
        , Ui.height (Ui.px 16)
        , Ui.htmlAttribute (Html.Attributes.class "spin")
        , attr "border" "2px solid #fff"
        , attr "border-top-color" "transparent"
        , attr "border-radius" "50px"
        ]
        Ui.none


attr : String -> String -> Ui.Attribute msg
attr name value =
    Ui.htmlAttribute (Html.Attributes.style name value)


glow : Ui.Attribute msg
glow =
    Ui.Shadow.font { offset = ( 1, 1 ), color = colorWithAlpha 0.25 lightTheme.defaultText, blur = 2 }


footerButton : Route -> String -> Ui.Element msg
footerButton route label =
    Ui.el
        [ Ui.link (Route.encode Nothing route)
        , Ui.background (Ui.rgb 12 109 82)
        , Ui.paddingXY 16 10
        , Ui.rounded 10
        , Ui.width Ui.shrink
        ]
        (Ui.text label)


footer : Ui.Element msg
footer =
    Ui.el
        [ Ui.paddingXY 24 16
        , Ui.alignBottom
        ]
        (Ui.row
            ([ Ui.spacing 10
             , Ui.Font.color (Ui.rgb 255 255 255)
             , Ui.wrap
             , Ui.contentTop
             ]
                ++ contentAttributes
            )
            [ footerButton CodeOfConductRoute "Code of Conduct"
            , footerButton UnconferenceFormatRoute "Unconference Guidelines"
            , footerButton ElmCampArchiveRoute "Elm Camp Archives"
            ]
        )


numericField : String -> Int -> (Int -> msg) -> Ui.Element msg
numericField title value onChange =
    Ui.row [ Ui.spacing 5 ]
        [ Ui.el
            (normalButtonAttributes (onChange (value - 1))
                ++ [ Ui.background colors.green
                   , Ui.Font.color colors.white
                   , Ui.width (Ui.px 50)
                   ]
            )
            (Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Ui.text "-"))
        , Ui.el
            [ Ui.width Ui.fill
            , Ui.background (Ui.rgb 255 255 255)
            , Ui.padding 16
            , Ui.rounded 8
            , Ui.alignBottom
            , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 2, color = Ui.rgba 0 0 0 0.1 } ]
            , Ui.Font.weight 600
            ]
            (Ui.text (String.fromInt value))
        , Ui.el
            (normalButtonAttributes (onChange (value + 1))
                ++ [ Ui.background colors.green
                   , Ui.Font.color colors.white
                   , Ui.width (Ui.px 50)
                   ]
            )
            (Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Ui.text "+"))
        ]


normalButtonAttributes : msg -> List (Ui.Attribute msg)
normalButtonAttributes onPress =
    [ Ui.background (Ui.rgb 255 255 255)
    , Ui.padding 16
    , Ui.rounded 8
    , Ui.alignBottom
    , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 2, color = Ui.rgba 0 0 0 0.1 } ]
    , Ui.Font.weight 600
    , Ui.Input.button onPress
    , Ui.width Ui.shrink
    ]


h2 : String -> Ui.Element msg
h2 t =
    Ui.el
        -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
        (heading2Attrs lightTheme)
        (Ui.text t)


h3 : String -> Ui.Element msg
h3 t =
    Ui.el
        -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
        (heading3Attrs lightTheme)
        (Ui.text t)


heading2Attrs : Theme -> List (Ui.Attribute msg)
heading2Attrs theme =
    [ Ui.Font.color theme.elmText
    , Ui.Font.size 24
    , Ui.Font.weight 800
    , Ui.paddingWith { top = 16, right = 0, bottom = 20, left = 0 }
    , Ui.Accessibility.h2
    ]


heading3Attrs : Theme -> List (Ui.Attribute msg)
heading3Attrs theme =
    [ Ui.Font.color theme.defaultText
    , Ui.Font.size 18
    , Ui.Font.weight 500
    , Ui.paddingWith { top = 8, right = 0, bottom = 16, left = 0 }
    , Ui.Font.bold
    , Ui.Accessibility.h3
    ]
