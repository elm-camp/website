module Camp24Devon.Inventory exposing (..)

import AssocList
import PurchaseForm exposing (..)
import Types exposing (..)


maxAttendees =
    80


maxForAccommodationType t =
    case t of
        Campsite ->
            30

        Single ->
            5

        Double ->
            20

        Group ->
            10


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
