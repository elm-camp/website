module Inventory exposing (..)

import AssocList
import PurchaseForm exposing (..)
import Types exposing (..)


maxCouplesCampTickets =
    20


minCampTickets =
    4


manualOrders =
    -- Team & sponsor room bookings
    -- Katja, Jim, Martin, Mario, Johannes, Concentric
    6


opportunityGrantTickets =
    4


venueCapacity =
    50


maxRoomSlots =
    -- The maximum potential number of attendees we could have if we optimally booked out rooms
    (maxCouplesCampTickets * 2) + (minCampTickets * 1)


slotsRemaining : BackendModel -> TicketAvailability
slotsRemaining model =
    let
        pendingSlots =
            AssocList.values model.pendingOrder |> List.map orderToSlots |> List.sum

        purchasedSlots =
            AssocList.values model.orders |> List.map orderToSlots |> List.sum

        totalOrderSlots =
            pendingSlots + purchasedSlots

        -- campFireOrders =
        --     AssocList.values model.orders |> List.filter isCampfireTicket |> List.length
        -- campOrders =
        --     AssocList.values model.orders |> List.filter isCampTicket |> List.length
        couplesCampOrders =
            AssocList.values model.orders |> List.filter isCouplesCampTicket |> List.length

        roomSlotsBooked =
            AssocList.values model.orders
                |> List.filter isRoomTicketPurchase
                |> List.map orderToSlots
                |> List.sum
                |> (+) manualOrders

        potentialRoomSlotsRemaining =
            maxRoomSlots - roomSlotsBooked - manualOrders - opportunityGrantTickets

        remainingCapacity =
            venueCapacity - totalOrderSlots - manualOrders - opportunityGrantTickets
    in
    if remainingCapacity > 0 then
        { campTicket = roomSlotsBooked < 24
        , couplesCampTicket = couplesCampOrders < 20 && roomSlotsBooked < 24

        -- We want to prioritise camp tickets over campfire tickets, so this inventory is dynamic
        -- based on the number of potential room slots remaining
        , campfireTicket = (remainingCapacity - potentialRoomSlotsRemaining) > 0
        }

    else
        -- We've reached capacity, no further tickets are available regardless of inventory
        { campTicket = False
        , couplesCampTicket = False
        , campfireTicket = False
        }


isCampfireTicket : { order | form : PurchaseFormValidated } -> Bool
isCampfireTicket order =
    case order.form of
        CampfireTicketPurchase _ ->
            True

        CampTicketPurchase _ ->
            False

        CouplesCampTicketPurchase _ ->
            False


isCampTicket : { order | form : PurchaseFormValidated } -> Bool
isCampTicket order =
    case order.form of
        CampfireTicketPurchase _ ->
            False

        CampTicketPurchase _ ->
            True

        CouplesCampTicketPurchase _ ->
            False


isCouplesCampTicket : { order | form : PurchaseFormValidated } -> Bool
isCouplesCampTicket order =
    case order.form of
        CampfireTicketPurchase _ ->
            False

        CampTicketPurchase _ ->
            False

        CouplesCampTicketPurchase _ ->
            True


isRoomTicketPurchase : { order | form : PurchaseFormValidated } -> Bool
isRoomTicketPurchase order =
    case order.form of
        CampfireTicketPurchase _ ->
            False

        CampTicketPurchase _ ->
            True

        CouplesCampTicketPurchase _ ->
            True


orderToSlots : { order | form : PurchaseFormValidated } -> number
orderToSlots order =
    case order.form of
        CampfireTicketPurchase _ ->
            1

        CampTicketPurchase _ ->
            1

        CouplesCampTicketPurchase _ ->
            2
