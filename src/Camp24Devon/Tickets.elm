module Camp24Devon.Tickets exposing (..)

import AssocList
import Camp24Devon.Product as Product
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Env
import Id exposing (Id)
import MarkdownThemed
import Money
import Stripe exposing (Price, ProductId(..))
import Theme



-- @TODO need to use pricing IDs here, not product IDs
-- but how do we figure out the right price given the current user? Is there a Stripe API for that?


type alias Ticket =
    -- @TODO change this
    { name : String
    , description : String
    , image : String
    , slots : Int
    , productId : String
    }


attendanceTicket : Ticket
attendanceTicket =
    { name = "Campfire Ticket"
    , description = "Attendee ticket for one person. Full access to the event 18th - 21st June, breakfast, lunch, tea & dinner included as per schedule"
    , image = ""
    , slots = 1
    , productId = Product.ticket.attendanceTicket
    }


offsite : Ticket
offsite =
    { name = "Offsite"
    , description = "You'll be organising your own accommodation off-site and making your own way to/from the event each day. You'll still have full access to the event and all meals."
    , image = ""
    , slots = 2
    , productId = Product.ticket.offsite
    }


campingSpot : Ticket
campingSpot =
    { name = "Camping Spot"
    , description = "Bring your own tent or campervan and stay on site. Showers & toilets provided."
    , image = ""
    , slots = 2
    , productId = Product.ticket.campingSpot
    }


singleRoom : Ticket
singleRoom =
    { name = "Single Room"
    , description = "Private room for a single attendee for 3 nights."
    , image = ""
    , slots = 2
    , productId = Product.ticket.singleRoom
    }


doubleRoom : Ticket
doubleRoom =
    { name = "Double Room"
    , description = "Suitable for a couple or twin share for 3 nights."
    , image = ""
    , slots = 2
    , productId = Product.ticket.doubleRoom
    }


groupRoom : Ticket
groupRoom =
    { name = "Group Room"
    , description = "Suitable for up to 4 people for 3 nights."
    , image = ""
    , slots = 2
    , productId = Product.ticket.groupRoom
    }


campfireTicket : Ticket
campfireTicket =
    { name = "Campfire Ticket"
    , description = """
Ticket for 1 Person including: breakfast, lunch, tea & dinners included. Access to castle grounds. No accommodation included.

• [Nearby accommodation options](/venue-and-access)
• [Coordinate with other attendees](https://discord.gg/QeZDXJrN78)
"""
    , image = "/product1.webp"
    , slots = 1
    , productId = Product.ticket.singleRoom
    }


accommodationOptions : AssocList.Dict (Id ProductId) Ticket
accommodationOptions =
    [ offsite, campingSpot, singleRoom, doubleRoom, groupRoom ]
        |> List.map (\t -> ( Id.fromString t.productId, t ))
        |> AssocList.fromList


dict : AssocList.Dict (Id ProductId) Ticket
dict =
    [ attendanceTicket, campingSpot, singleRoom, doubleRoom, groupRoom ]
        |> List.map (\t -> ( Id.fromString t.productId, t ))
        |> AssocList.fromList


viewDesktop : Bool -> msg -> Price -> Ticket -> Element msg
viewDesktop ticketAvailable onPress price ticket =
    Theme.panel []
        [ Element.none

        -- , Element.image [ Element.width (Element.px 120) ] { src = ticket.image, description = "Illustration of a camp" }
        , Element.paragraph [ Element.Font.semiBold, Element.Font.size 20 ] [ Element.text ticket.name ]
        , MarkdownThemed.renderFull ticket.description
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

                         else if ticket.name == "Campfire Ticket" then
                            "Waitlist"

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
                , MarkdownThemed.renderFull ticket.description
                , Element.el
                    [ Element.Font.bold, Element.Font.size 36, Element.alignBottom ]
                    (Element.text (Money.toNativeSymbol currency ++ String.fromInt (amount // 100)))
                ]

            -- , Element.image
            --     [ Element.width (Element.px 80), Element.alignTop ]
            --     { src = ticket.image, description = "Illustration of a camp" }
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

                         else if ticket.name == "Campfire Ticket" then
                            "Waitlist"

                         else
                            "Sold out!"
                        )
                    )
            }
        ]
