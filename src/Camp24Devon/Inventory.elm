module Camp24Devon.Inventory exposing
    ( allSoldOut
    , caseof
    , extract
    , maxAttendees
    , maxForAccommodationType
    , purchaseable
    , slotsRemaining
    )

import Camp24Devon.Product as Product
import PurchaseForm exposing (Accommodation(..))
import SeqDict
import Types exposing (BackendModel, TicketAvailability)


maxAttendees : number
maxAttendees =
    80


maxForAccommodationType : Accommodation -> number
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


extract : (a -> b -> List c) -> SeqDict a b -> List c
extract selector SeqDict =
    SeqDict
        |> SeqDict.map selector
        |> SeqDict.toList
        |> List.concatMap Tuple.second


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


caseof : a -> List ( a, Bool ) -> Bool
caseof v opts =
    case List.head (List.filter (\( a, b ) -> a == v) opts) of
        Just ( _, b ) ->
            b

        Nothing ->
            False
