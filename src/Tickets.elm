module Tickets exposing (Ticket, couplesCampTicket, submitButtonAttributes, tickets, viewDesktop, viewMobile)

import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Env
import Money
import Stripe exposing (Price(..), ProductId(..))


tickets : List Ticket
tickets =
    [ campTicket, couplesCampTicket, campfireTicket ]



-- @TODO need to use pricing IDs here, not product IDs
-- but how do we figure out the right price given the current user? Is there a Stripe API for that?


type alias Ticket =
    { name : String
    , description : String
    , productId : ProductId
    , image : String
    }


campTicket : Ticket
campTicket =
    { name = "Camp Ticket"
    , description = "Ticket for 1 Person including: on-site accommodation with private ensuite for 2 nights, breakfast, lunch, tea & dinners included."
    , productId = ProductId Env.campTicketProductId
    , image = "/product2.webp"
    }


couplesCampTicket : Ticket
couplesCampTicket =
    { name = "Couples Camp Ticket"
    , description = "Tickets for 2 people including: on-site accommodation for two people with private ensuite for 2 nights, breakfast, lunch, tea & dinners included."
    , productId = ProductId Env.couplesCampTicketProductId
    , image = "/product3.webp"
    }


campfireTicket : Ticket
campfireTicket =
    { name = "Campfire Ticket"
    , description = "Ticket for 1 Person including: breakfast, lunch, tea & dinners included. Access to castle grounds. No accommodation included."
    , productId = ProductId Env.campfireTicketProductId
    , image = "/product1.webp"
    }


viewDesktop : msg -> Price -> Ticket -> Element msg
viewDesktop onPress (Price currency amount) ticket =
    Element.column
        [ Element.width Element.fill
        , Element.alignTop
        , Element.spacing 16
        , Element.Background.color (Element.rgb 1 1 1)
        , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = Element.rgba 0 0 0 0.25 }
        , Element.height Element.fill
        , Element.Border.rounded 16
        , Element.padding 16
        ]
        [ Element.image [ Element.width (Element.px 120) ] { src = ticket.image, description = "Illustration of a camp" }
        , Element.paragraph [ Element.Font.semiBold, Element.Font.size 20 ] [ Element.text ticket.name ]
        , Element.paragraph [] [ Element.text ticket.description ]
        , Element.el
            [ Element.Font.bold, Element.Font.size 36, Element.alignBottom ]
            (Element.text (Money.toNativeSymbol currency ++ String.fromInt (amount // 100)))
        , Element.Input.button
            [ Element.width Element.fill
            , Element.Background.color (Element.rgb255 92 176 126)
            , Element.padding 16
            , Element.Border.rounded 8
            , Element.alignBottom
            , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
            ]
            { onPress = Just onPress
            , label = Element.el [ Element.centerX, Element.Font.semiBold, Element.Font.color (Element.rgb 1 1 1) ] (Element.text "Select")
            }
        ]


viewMobile : msg -> Price -> Ticket -> Element msg
viewMobile onPress (Price currency amount) ticket =
    Element.column
        [ Element.width Element.fill
        , Element.alignTop
        , Element.spacing 16
        , Element.Background.color (Element.rgb 1 1 1)
        , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = Element.rgba 0 0 0 0.25 }
        , Element.height Element.fill
        , Element.Border.rounded 16
        , Element.padding 16
        ]
        [ Element.row
            [ Element.spacing 16 ]
            [ Element.column
                [ Element.width Element.fill, Element.spacing 16 ]
                [ Element.paragraph [ Element.Font.semiBold, Element.Font.size 20 ] [ Element.text ticket.name ]
                , Element.paragraph [] [ Element.text ticket.description ]
                , Element.el
                    [ Element.Font.bold, Element.Font.size 36, Element.alignBottom ]
                    (Element.text (Money.toNativeSymbol currency ++ String.fromInt (amount // 100)))
                ]
            , Element.image
                [ Element.width (Element.px 80), Element.alignTop ]
                { src = ticket.image, description = "Illustration of a camp" }
            ]
        , Element.Input.button
            submitButtonAttributes
            { onPress = Just onPress
            , label = Element.el [ Element.centerX ] (Element.text "Select")
            }
        ]


submitButtonAttributes : List (Element.Attribute msg)
submitButtonAttributes =
    [ Element.width Element.fill
    , Element.Background.color (Element.rgb255 92 176 126)
    , Element.padding 16
    , Element.Border.rounded 8
    , Element.alignBottom
    , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Element.Font.semiBold
    , Element.Font.color (Element.rgb 1 1 1)
    ]
