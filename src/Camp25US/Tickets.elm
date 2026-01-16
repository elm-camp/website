module Camp25US.Tickets exposing (Ticket, accomToString, accomToTicket, accommodationOptions, allAccommodations, attendanceTicket, campfireTicket, campingSpot, dict, doubleRoom, formIncludesAccom, formIncludesRoom, groupRoom, includesAccom, includesRoom, offsite, singleRoom, viewAccom)

{-
   TODO for Camp25US Tickets:
   - Revise accommodation types based on Ronora Lodge facilities
   - Verify product IDs match those in Product.elm after they're updated
-}

import Camp25US.Product as Product
import Env
import Helpers
import Id exposing (Id)
import MarkdownThemed
import Money
import PurchaseForm exposing (Accommodation(..), PurchaseForm)
import SeqDict exposing (SeqDict)
import Stripe exposing (Price, ProductId(..))
import Theme
import Ui
import Ui.Anim
import Ui.Events
import Ui.Font as Font
import Ui.Input as Input
import Ui.Layout
import Ui.Prose



-- @TODO need to use pricing IDs here, not product IDs
-- but how do we figure out the right price given the current user? Is there a Stripe API for that?


type alias Ticket =
    -- @TODO change this
    { name : String
    , description : String
    , image : String
    , productId : String
    }


attendanceTicket : Ticket
attendanceTicket =
    { name = "Campfire Ticket"
    , description = "Attendee ticket for one person. Full access to the event 24th - 27th June, breakfast, lunch, tea & dinner included as per schedule"
    , image = ""
    , productId = Product.ticket.attendanceTicket
    }


offsite : Ticket
offsite =
    { name = "Offsite"
    , description = "You'll be organising your own accommodation off-site and making your own way to/from the event each day. You'll have full access to the event and all meals."
    , image = ""
    , productId = Product.ticket.offsite
    }


campingSpot : Ticket
campingSpot =
    { name = "Camping Spot"
    , description = "Bring your own tent or campervan and stay on site. Showers & toilets provided."
    , image = ""
    , productId = Product.ticket.campingSpot
    }


singleRoom : Ticket
singleRoom =
    { name = "Single Room"
    , description = "Private room for a single attendee for 3 nights."
    , image = ""
    , productId = Product.ticket.singleRoom
    }


doubleRoom : Ticket
doubleRoom =
    { name = "Double Room"
    , description = "Suitable for a couple or twin share for 3 nights."
    , image = ""
    , productId = Product.ticket.doubleRoom
    }


groupRoom : Ticket
groupRoom =
    { name = "Shared Room"
    , description = "Suitable for couples or up to 4 people for 3 nights. Purchase 1 `Shared Room` ticket per person and let us know who you are sharing with."
    , image = ""
    , productId = Product.ticket.groupRoom
    }


campfireTicket : Ticket
campfireTicket =
    { name = "Campfire Ticket"
    , description = """
Ticket for 1 Person including: breakfast, lunch, tea & dinners included. Access to park grounds & activities. No accommodation included.

• [Nearby accommodation options](/venue-and-access)
• [Coordinate with other attendees](""" ++ Helpers.discordInviteLink ++ """)
"""
    , image = "/product1.webp"
    , productId = Product.ticket.singleRoom
    }


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
            "Shared Room"


allAccommodations : List Accommodation
allAccommodations =
    [ Offsite, Campsite, Single, Group ]


formIncludesAccom : PurchaseForm -> Bool
formIncludesAccom form =
    form.accommodationBookings |> List.filter includesAccom |> List.length |> (\c -> c > 0)


formIncludesRoom : PurchaseForm -> Bool
formIncludesRoom form =
    form.accommodationBookings |> List.filter includesRoom |> List.length |> (\c -> c > 0)


includesAccom : Accommodation -> Bool
includesAccom accom =
    case accom of
        Offsite ->
            False

        _ ->
            True


includesRoom : Accommodation -> Bool
includesRoom accom =
    case accom of
        Campsite ->
            False

        Offsite ->
            False

        _ ->
            True


accommodationOptions : SeqDict (Id ProductId) ( Accommodation, Ticket )
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
        |> SeqDict.fromList


dict : SeqDict (Id ProductId) Ticket
dict =
    [ offsite, campingSpot, singleRoom, groupRoom ]
        |> List.map (\t -> ( Id.fromString t.productId, t ))
        |> SeqDict.fromList


viewAccom : PurchaseForm -> Accommodation -> Bool -> msg -> msg -> msg -> Price -> Ticket -> Ui.Element msg
viewAccom form accom ticketAvailable onPress removeMsg addMsg price ticket =
    let
        selectedCount =
            form.accommodationBookings |> List.filter ((==) accom) |> List.length
    in
    Theme.panel []
        [ Ui.none

        -- , image [ width (px 120) ] { src = ticket.image, description = "Illustration of a camp" }
        , Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.semiBold, Ui.Font.size 20 ] [ Ui.text ticket.name ]
        , MarkdownThemed.renderFull ticket.description
        , Ui.el
            [ Ui.width Ui.shrink, Ui.Font.bold, Ui.Font.size 36, Ui.alignBottom ]
            (Ui.text (Theme.priceText price))
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
                        ( "Select", Just addMsg )
                in
                Ui.Input.button
                    -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
                    (Theme.submitButtonAttributes ticketAvailable)
                    { onPress = msg
                    , label =
                        Ui.el
                            [ Ui.width Ui.shrink, Ui.centerX, Ui.Font.semiBold, Ui.Font.color (Ui.rgb 255 255 255) ]
                            (Ui.text text_)
                    }

          else if ticket.name == "Campfire Ticket" then
            Ui.text "Waitlist"

          else
            Ui.text "Sold out!"
        ]
