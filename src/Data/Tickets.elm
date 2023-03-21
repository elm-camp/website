module Data.Tickets exposing (..)

import Element exposing (Element)
import Element.Font
import Element.Input
import Http
import Types exposing (Price)


tickets =
    [ campTicket, couplesCampTicket, campfireTicket ]



-- @TODO need to use pricing IDs here, not product IDs
-- but how do we figure out the right price given the current user? Is there a Stripe API for that?


type alias Ticket =
    { name : String
    , description : String
    , stripeProductId : ProductId
    , image : String
    }


campTicket : Ticket
campTicket =
    { name = "Elm Camp Denmark 23 - Camp Ticket"
    , description = "Ticket for 1 Person including: on-site accommodation with private ensuite for 2 nights, breakfast, lunch, tea & dinners included."
    , stripeProductId = ProductId "prod_NWZ5JHXspU1l8p"
    , image = "/product2.webp"
    }


couplesCampTicket : Ticket
couplesCampTicket =
    { name = "Elm Camp Denmark 23 - Couples Camp Ticket"
    , description = "Tickets for 2 people including: on-site accommodation for two people with private ensuite for 2 nights, breakfast, lunch, tea & dinners included."
    , stripeProductId = ProductId "prod_NWZ8FJ1Ckl9fIc"
    , image = "/product3.webp"
    }


campfireTicket : Ticket
campfireTicket =
    { name = "Elm Camp Denmark 23 - Campfire Ticket"
    , description = "Ticket for 1 Person including: breakfast, lunch, tea & dinners included. Access to castle grounds. No accommodation included."
    , stripeProductId = ProductId "prod_NWZAQ3eQgK0XlF"
    , image = "/product1.webp"
    }


viewDesktop : msg -> Ticket -> Element msg
viewDesktop onPress ticket =
    Element.column
        [ Element.width Element.fill ]
        [ Element.image [] { src = ticket.image, description = "Illustration of a camp" }
        , Element.paragraph [] [ Element.text ticket.name ]
        , Element.paragraph [] [ Element.text ticket.description ]
        , Element.el [ Element.Font.bold, Element.Font.size 36 ] (Element.text "$TEMP")
        , Element.Input.button
            [ Element.width Element.fill ]
            { onPress = Just onPress
            , label = Element.text "Select"
            }
        ]
