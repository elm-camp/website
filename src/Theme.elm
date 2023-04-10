module Theme exposing (..)

import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Money
import Stripe exposing (Price)


colors =
    { green = Element.rgb255 92 176 126
    , lightGrey = Element.rgb255 200 200 200
    }


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
