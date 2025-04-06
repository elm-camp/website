module Camp25US.Inventory exposing (..)

{-
   TODO for Camp25US:
   - Verify maxAttendees capacity for Ronora Lodge
   - Check accommodation types and adjust maxForAccommodationType values:
     - Confirm if Single/Double/Group rooms are still applicable
     - Update capacity limits based on actual Ronora Lodge room availability
     - Consider adding cabin-specific accommodation types if needed
   - Ensure TicketAvailability record fields match new accommodation options
   - Verify that Product IDs in purchaseable function match new 2025 Stripe products
   - Check if BackendModel structure changes would affect the slotsRemaining function
-}

import AssocList
import Camp25US.Product as Product
import PurchaseForm exposing (..)
import Types exposing (..)


maxAttendees =
    80


maxForAccommodationType t =
    case t of
        Offsite ->
            -- Effectively no limit, the attendee limit should hit first
            80

        Campsite ->
            20

        Single ->
            6

        Double ->
            15

        Group ->
            4


slotsRemaining : BackendModel -> TicketAvailability
slotsRemaining model =
    let
        bookedAccommodations =
            model.orders |> extract (\id order -> order.form.accommodationBookings)

        pendingAccommodations =
            model.pendingOrder |> extract (\id order -> order.form.accommodationBookings)

        bookedCountFor accomodationType =
            bookedAccommodations
                |> List.filter (\t -> t == accomodationType)
                |> List.length

        bookedAndPendingCountFor accomodationType =
            (bookedAccommodations ++ pendingAccommodations)
                |> List.filter (\t -> t == accomodationType)
                |> List.length

        remainingCountForAccommodation accommodationType =
            maxForAccommodationType accommodationType - bookedCountFor accommodationType

        bookedAttendees =
            model.orders
                |> extract (\id order -> order.form.attendees)
                |> List.length

        remainingCapacity =
            maxAttendees - bookedAttendees
    in
    if remainingCapacity > 0 then
        { attendanceTickets = remainingCapacity > 0
        , campingSpots = remainingCountForAccommodation Campsite > 0
        , singleRooms = remainingCountForAccommodation Single > 0
        , doubleRooms = remainingCountForAccommodation Double > 0
        , groupRooms = remainingCountForAccommodation Group > 0
        }

    else
        -- We've reached capacity, no further tickets are available regardless of inventory
        { attendanceTickets = False
        , campingSpots = False
        , singleRooms = False
        , doubleRooms = False
        , groupRooms = False
        }


allSoldOut : TicketAvailability -> Bool
allSoldOut { attendanceTickets } =
    attendanceTickets


extract selector assocList =
    assocList
        |> AssocList.map selector
        |> AssocList.toList
        |> List.map Tuple.second
        |> List.concat


purchaseable : String -> TicketAvailability -> Bool
purchaseable productId availability =
    caseof productId
        [ ( Product.ticket.attendanceTicket, availability.attendanceTickets )
        , ( Product.ticket.offsite, availability.campingSpots )
        , ( Product.ticket.campingSpot, availability.campingSpots )
        , ( Product.ticket.singleRoom, availability.singleRooms )
        , ( Product.ticket.doubleRoom, availability.doubleRooms )
        , ( Product.ticket.groupRoom, availability.groupRooms )
        ]


caseof v opts =
    case List.head (List.filter (\( a, b ) -> a == v) opts) of
        Just ( a, b ) ->
            b

        Nothing ->
            False
