module Camp24Devon.Tickets exposing (..)

import AssocList
import Camp24Devon.Product as Product
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Env
import Id exposing (Id)
import MarkdownThemed
import Money
import PurchaseForm exposing (Accommodation(..), PurchaseForm)
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



-- Campsite
-- Single
-- Double
-- Group


accomToTicket : Accommodation -> Ticket
accomToTicket accom =
    case accom of
        Offsite ->
            offsite

        Campsite ->
            campingSpot

        Single ->
            singleRoom

        Double ->
            doubleRoom

        Group ->
            groupRoom


accomToString : Accommodation -> String
accomToString accom =
    case accom of
        Offsite ->
            "Offsite"

        Campsite ->
            "Camping Spot"

        Single ->
            "Single Room"

        Double ->
            "Double Room"

        Group ->
            "Group Room"


allAccommodations =
    [ Offsite, Campsite, Single, Double, Group ]


accommodationOptions : AssocList.Dict (Id ProductId) ( Accommodation, Ticket )
accommodationOptions =
    allAccommodations
        |> List.map
            (\a ->
                let
                    t =
                        accomToTicket a
                in
                ( Id.fromString t.productId, ( a, t ) )
            )
        |> AssocList.fromList


dict : AssocList.Dict (Id ProductId) Ticket
dict =
    [ attendanceTicket, campingSpot, singleRoom, doubleRoom, groupRoom ]
        |> List.map (\t -> ( Id.fromString t.productId, t ))
        |> AssocList.fromList


viewAccom : PurchaseForm -> Accommodation -> Bool -> msg -> msg -> msg -> Price -> Ticket -> Element msg
viewAccom form accom ticketAvailable onPress removeMsg addMsg price ticket =
    let
        selectedCount =
            form.accommodationBookings |> List.filter ((==) accom) |> List.length
    in
    Theme.panel []
        [ none

        -- , image [ width (px 120) ] { src = ticket.image, description = "Illustration of a camp" }
        , paragraph [ Font.semiBold, Font.size 20 ] [ text ticket.name ]
        , MarkdownThemed.renderFull ticket.description
        , el
            [ Font.bold, Font.size 36, alignBottom ]
            (text (Theme.priceText price))
        , if ticketAvailable then
            if selectedCount > 0 then
                Theme.numericField
                    "Tickets"
                    selectedCount
                    (\_ -> removeMsg)
                    (\_ -> addMsg)

            else
                let
                    ( text_, msg ) =
                        if ticketAvailable then
                            ( "Select", Just addMsg )

                        else if ticket.name == "Campfire Ticket" then
                            ( "Waitlist", Nothing )

                        else
                            ( "Waitlist", Nothing )
                in
                Input.button
                    (Theme.submitButtonAttributes ticketAvailable)
                    { onPress = msg
                    , label =
                        el
                            [ centerX, Font.semiBold, Font.color (rgb 1 1 1) ]
                            (text text_)
                    }

          else if ticket.name == "Campfire Ticket" then
            text "Waitlist"

          else
            text "Sold out!"
        ]



-- viewMobile : Bool -> msg -> Price -> Ticket -> Element msg
-- viewMobile ticketAvailable onPress { currency, amount } ticket =
--     Theme.panel []
--         [ row
--             [ spacing 16 ]
--             [ column
--                 [ width fill, spacing 16 ]
--                 [ paragraph [ Font.semiBold, Font.size 20 ] [ text ticket.name ]
--                 , MarkdownThemed.renderFull ticket.description
--                 , el
--                     [ Font.bold, Font.size 36, alignBottom ]
--                     (text (Money.toNativeSymbol currency ++ String.fromInt (amount // 100)))
--                 ]
--             -- , image
--             --     [ width (px 80), alignTop ]
--             --     { src = ticket.image, description = "Illustration of a camp" }
--             ]
--         , Input.button
--             (Theme.submitButtonAttributes ticketAvailable)
--             { onPress = Just onPress
--             , label =
--                 el
--                     [ centerX ]
--                     (text
--                         (if ticketAvailable then
--                             "Select"
--                          else if ticket.name == "Campfire Ticket" then
--                             "Waitlist"
--                          else
--                             "Sold out!"
--                         )
--                     )
--             }
--         ]
