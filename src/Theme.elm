module Theme exposing
    ( Theme
    , attr
    , colorWithAlpha
    , colors
    , contentAttributes
    , css
    , fontFace
    , footer
    , glow
    , greenTheme
    , h1
    , h2
    , h3
    , h4
    , heading1Attrs
    , heading2Attrs
    , heading3Attrs
    , heading4Attrs
    , lightTheme
    , normalButtonAttributes
    , numericField
    , panel
    , priceAmount
    , priceText
    , rowToColumnWhen
    , showyButtonAttributes
    , spinnerWhite
    , submitButtonAttributes
    , toggleButton
    , toggleButtonAttributes
    , viewIf
    )

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes
import Money
import Route exposing (Route(..))
import Stripe exposing (Price)


type alias Theme =
    { defaultText : Element.Color
    , mutedText : Element.Color
    , grey : Element.Color
    , lightGrey : Element.Color
    , link : Element.Color
    , elmText : Element.Color
    , background : Element.Color
    }


lightTheme : Theme
lightTheme =
    { defaultText = Element.rgb255 30 50 46
    , mutedText = Element.rgb255 74 94 122
    , link = Element.rgb255 12 109 82
    , lightGrey = Element.rgb255 220 240 255
    , grey = Element.rgb255 200 220 240
    , elmText = Element.rgb255 92 176 126
    , background = Element.rgb255 255 244 225
    }


greenTheme : Theme
greenTheme =
    { defaultText = Element.rgb255 73 80 96
    , mutedText = Element.rgb255 74 94 122
    , link = Element.rgb255 12 109 82
    , lightGrey = Element.rgb255 220 240 255
    , grey = Element.rgb255 200 220 240
    , elmText = Element.rgb255 13 109 82
    , background = Element.rgb255 255 253 244
    }


contentAttributes : List (Element.Attribute msg)
contentAttributes =
    [ Element.width (Element.maximum 800 Element.fill), Element.centerX ]


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


colors : { green : Element.Color, lightGrey : Element.Color, white : Element.Color, red : Element.Color }
colors =
    { green = Element.rgb255 92 176 126
    , lightGrey = Element.rgb255 200 200 200
    , white = Element.rgb255 255 255 255
    , red = Element.rgb255 234 87 59
    }


colorWithAlpha : Float -> Element.Color -> Element.Color
colorWithAlpha alpha color =
    let
        { red, green, blue } =
            Element.toRgb color
    in
    Element.rgba red green blue alpha


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


viewIf : Bool -> Element msg -> Element msg
viewIf condition view =
    if condition then
        view

    else
        Element.none


priceText : Price -> String
priceText { currency, amount } =
    Money.toNativeSymbol currency ++ String.fromInt (amount // 100)


priceAmount : Price -> Float
priceAmount { amount } =
    toFloat amount


panel : List (Element.Attribute msg) -> List (Element msg) -> Element msg
panel attrs x =
    Element.column
        ([ Element.width Element.fill
         , Element.alignTop
         , Element.spacing 16
         , Background.color (Element.rgb 1 1 1)
         , Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = Element.rgba 0 0 0 0.25 }
         , Element.height Element.fill
         , Border.rounded 16
         , Element.padding 16
         ]
            ++ attrs
        )
        x


submitButtonAttributes : Bool -> List (Element.Attribute msg)
submitButtonAttributes isEnabled =
    [ Element.width Element.fill
    , Background.color
        (if isEnabled then
            Element.rgb255 92 176 126

         else
            Element.rgb255 137 141 137
        )
    , Element.padding 16
    , Border.rounded 8
    , Element.alignBottom
    , Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Font.semiBold
    , Font.color (Element.rgb 1 1 1)
    ]


toggleButton : String -> Bool -> Maybe msg -> Element msg
toggleButton label isActive onPress =
    Input.button
        (toggleButtonAttributes isActive)
        { onPress = onPress
        , label = Element.el [ Element.centerX ] (Element.text label)
        }


toggleButtonAttributes : Bool -> List (Element.Attribute msg)
toggleButtonAttributes isActive =
    [ Background.color
        (if isActive then
            colors.green

         else
            colors.lightGrey
        )
    , Element.padding 16
    , Border.rounded 8
    , Element.alignBottom
    , Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Font.semiBold
    , Font.color (Element.rgb 1 1 1)
    ]


rowToColumnWhen : Int -> { width : Int, height : Int } -> List (Element.Attribute msg) -> List (Element msg) -> Element msg
rowToColumnWhen width window attrs children =
    if window.width > width then
        Element.row attrs children

    else
        Element.column attrs children


spinnerWhite : Element msg
spinnerWhite =
    Element.el
        [ Element.width (Element.px 16)
        , Element.height (Element.px 16)
        , Element.htmlAttribute (Html.Attributes.class "spin")
        , attr "border" "2px solid #fff"
        , attr "border-top-color" "transparent"
        , attr "border-radius" "50px"
        ]
        Element.none


attr : String -> String -> Element.Attribute msg
attr name value =
    Element.htmlAttribute (Html.Attributes.style name value)


glow : Element.Attr decorative msg
glow =
    Font.glow (colorWithAlpha 0.25 lightTheme.defaultText) 4


footer : Element msg
footer =
    let
        btn route label =
            Element.link
                [ Background.color (Element.rgb255 12 109 82), Element.paddingXY 10 10, Border.rounded 10 ]
                { url = Route.encode route, label = Element.text label }
    in
    Element.el
        [ Element.paddingXY 24 16
        , Element.width Element.fill
        , Element.alignBottom
        ]
        (Element.wrappedRow
            ([ Element.spacing 10
             , Font.color (Element.rgb 1 1 1)
             ]
                ++ contentAttributes
            )
            [ btn CodeOfConductRoute "Code of Conduct"
            , btn UnconferenceFormatRoute "Unconference Guidelines"
            , btn VenueAndAccessRoute "Venue & Access"
            , btn OrganisersRoute "Organisers"
            , btn ElmCampArchiveRoute "Elm Camp Archives"
            ]
        )


numericField : String -> Int -> (Int -> msg) -> (Int -> msg) -> Element msg
numericField title value downMsg upMsg =
    Element.row [ Element.spacing 5, Element.width Element.fill ]
        [ Input.button
            (normalButtonAttributes
                ++ [ Background.color colors.green
                   , Font.color colors.white
                   , Element.width (Element.px 50)
                   ]
            )
            { onPress = Just (downMsg (value - 1))
            , label = Element.el [ Element.centerX ] (Element.text "-")
            }
        , Input.button
            normalButtonAttributes
            { onPress = Nothing
            , label = Element.text (String.fromInt value)
            }
        , Input.button
            (normalButtonAttributes
                ++ [ Background.color colors.green
                   , Font.color colors.white
                   , Element.width (Element.px 50)
                   ]
            )
            { onPress = Just (upMsg (value + 1))
            , label = Element.el [ Element.centerX ] (Element.text "+")
            }
        ]


normalButtonAttributes : List (Element.Attribute msg)
normalButtonAttributes =
    [ Element.width Element.fill
    , Background.color (Element.rgb255 255 255 255)
    , Element.padding 16
    , Border.rounded 8
    , Element.alignBottom
    , Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Font.semiBold
    ]


showyButtonAttributes : List (Element.Attribute msg)
showyButtonAttributes =
    [ Element.width Element.fill
    , Background.color (Element.rgb255 255 172 98)
    , Element.padding 16
    , Border.rounded 8
    , Font.color (Element.rgb 0 0 0)
    , Element.alignBottom
    , Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Font.semiBold
    ]


h1 : String -> Element msg
h1 t =
    Element.el (heading1Attrs lightTheme) (Element.text t)


h2 : String -> Element msg
h2 t =
    Element.el (heading2Attrs lightTheme) (Element.text t)


h3 : String -> Element msg
h3 t =
    Element.el (heading3Attrs lightTheme) (Element.text t)


h4 : String -> Element msg
h4 t =
    Element.el (heading4Attrs lightTheme) (Element.text t)


heading1Attrs : Theme -> List (Element.Attr () msg)
heading1Attrs theme =
    [ Font.size 36
    , Font.semiBold
    , Font.color lightTheme.defaultText
    , Element.paddingEach { top = 40, right = 0, bottom = 30, left = 0 }
    ]


heading2Attrs : Theme -> List (Element.Attr () msg)
heading2Attrs theme =
    [ Font.color theme.elmText
    , Font.size 24
    , Font.extraBold
    , Element.paddingEach { top = 0, right = 0, bottom = 20, left = 0 }
    ]


heading3Attrs : Theme -> List (Element.Attr () msg)
heading3Attrs theme =
    [ Font.color theme.defaultText
    , Font.size 18
    , Font.medium
    , Element.paddingEach { top = 0, right = 0, bottom = 10, left = 0 }
    , Font.bold
    ]


heading4Attrs : Theme -> List (Element.Attr () msg)
heading4Attrs theme =
    [ Font.color theme.defaultText
    , Font.size 16
    , Font.medium
    , Element.paddingEach { top = 0, right = 0, bottom = 10, left = 0 }
    ]
