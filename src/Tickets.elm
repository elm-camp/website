module Tickets exposing (Ticket, campTicket, campfireTicket, couplesCampTicket, dict, viewDesktop, viewMobile)

import AssocList
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Env
import Id exposing (Id)
import Money
import Stripe exposing (Price, ProductId(..))
import Theme



-- @TODO need to use pricing IDs here, not product IDs
-- but how do we figure out the right price given the current user? Is there a Stripe API for that?


type alias Ticket =
    { name : String
    , description : String
    , image : String
    , slots : Int
    , productId : String
    }


campTicket : Ticket
campTicket =
    { name = "Camp Ticket"
    , description = "Ticket for 1 Person including: on-site accommodation with private ensuite for 2 nights, breakfast, lunch, tea & dinners included."
    , image = "/product2.webp"
    , slots = 1
    , productId = Env.campTicketProductId
    }


couplesCampTicket : Ticket
couplesCampTicket =
    { name = "Couples Camp Ticket"
    , description = "Tickets for 2 people including: on-site accommodation for two people with private ensuite for 2 nights, breakfast, lunch, tea & dinners included."
    , image = "/product3.webp"
    , slots = 2
    , productId = Env.couplesCampTicketProductId
    }


campfireTicket : Ticket
campfireTicket =
    { name = "Campfire Ticket"
    , description = "Ticket for 1 Person including: breakfast, lunch, tea & dinners included. Access to castle grounds. No accommodation included."
    , image = "/product1.webp"
    , slots = 1
    , productId = Env.campfireTicketProductId
    }


dict : AssocList.Dict (Id ProductId) Ticket
dict =
    AssocList.fromList
        [ ( Id.fromString Env.campfireTicketProductId, campfireTicket )
        , ( Id.fromString Env.couplesCampTicketProductId, couplesCampTicket )
        , ( Id.fromString Env.campTicketProductId, campTicket )
        ]


viewDesktop : Bool -> msg -> Price -> Ticket -> Element msg
viewDesktop ticketAvailable onPress price ticket =
    Theme.panel []
        [ Element.image [ Element.width (Element.px 120) ] { src = ticket.image, description = "Illustration of a camp" }
        , Element.paragraph [ Element.Font.semiBold, Element.Font.size 20 ] [ Element.text ticket.name ]
        , Element.paragraph [] [ Element.text ticket.description ]
        , Element.el
            [ Element.Font.bold, Element.Font.size 36, Element.alignBottom ]
            (Element.text (Theme.priceText price))
        , Element.Input.button
            (Theme.submitButtonAttributes ticketAvailable)
            { onPress = Just onPress
            , label =
                Element.el
                    [ Element.centerX, Element.Font.semiBold, Element.Font.color (Element.rgb 1 1 1) ]
                    (Element.text
                        (if ticketAvailable then
                            "Select"

                         else
                            "Sold out!"
                        )
                    )
            }
        ]


viewMobile : Bool -> msg -> Price -> Ticket -> Element msg
viewMobile ticketAvailable onPress { currency, amount } ticket =
    Theme.panel []
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
            (Theme.submitButtonAttributes ticketAvailable)
            { onPress = Just onPress
            , label =
                Element.el
                    [ Element.centerX ]
                    (Element.text
                        (if ticketAvailable then
                            "Select"

                         else
                            "Sold out!"
                        )
                    )
            }
        ]
