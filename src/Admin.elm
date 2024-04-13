module Admin exposing (..)

import AssocList
import Codec
import Element exposing (..)
import Element.Font
import Id exposing (Id)
import Lamdera
import Name
import Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Types exposing (..)


view : LoadedModel -> Element msg
view model =
    case model.backendModel of
        Just backendModel ->
            viewAdmin backendModel

        Nothing ->
            text "loading"


viewAdmin : BackendModel -> Element msg
viewAdmin backendModel =
    -- type alias BackendModel =
    --     { orders : AssocList.Dict (Id StripeSessionId) Order
    --     , pendingOrder : AssocList.Dict (Id StripeSessionId) PendingOrder
    --     , expiredOrders : AssocList.Dict (Id StripeSessionId) PendingOrder
    --     , prices : AssocList.Dict (Id ProductId) Price2
    --     , time : Time.Posix
    --     , ticketsEnabled : TicketsEnabled
    --     }
    let
        numberOfOrders =
            List.length (AssocList.toList backendModel.orders)

        numberOfPendingOrders =
            List.length (AssocList.toList backendModel.pendingOrder)

        numberOfExpiredOrders =
            List.length (AssocList.toList backendModel.expiredOrders)

        info =
            "Orders (completed, pending, expired): "
                ++ (List.map String.fromInt [ numberOfOrders, numberOfPendingOrders, numberOfExpiredOrders ] |> String.join ", ")
    in
    column
        [ width fill
        , Element.padding 24
        , spacing 40
        ]
        [ el [ Element.Font.size 18 ] (text "Admin")
        , viewOrders backendModel.orders

        --, viewPendingOrder backendModel.pendingOrder
        --, viewExpiredOrders backendModel.expiredOrders
        --, viewPrices backendModel.prices
        --, viewTicketsEnabled backendModel.ticketsEnabled
        ]


viewTicketsEnabled : TicketsEnabled -> Element msg
viewTicketsEnabled ticketsEnabled =
    column
        [ width fill
        ]
        [ text "TicketsEnabled:"
        , case ticketsEnabled of
            TicketsEnabled ->
                text "TicketsEnabled"

            TicketsDisabled d ->
                text <| "TicketsDisabled" ++ d.adminMessage
        ]


viewPrices : AssocList.Dict (Id ProductId) Price2 -> Element msg
viewPrices prices =
    column
        [ width fill
        ]
        [ text "Prices TODO"

        -- , Codec.encodeToString 2 (Types.assocListCodec Types.price2Codec) prices |> text
        ]


viewOrders : AssocList.Dict (Id StripeSessionId) Types.Order -> Element msg
viewOrders orders =
    column
        [ width fill
        , spacing 12
        ]
        (orders |> AssocList.toList |> List.indexedMap viewOrder)


viewOrder : Int -> ( Id StripeSessionId, Types.Order ) -> Element msg
viewOrder idx ( id, order ) =
    row
        [ width fill, Element.Font.size 14, spacing 12 ]
        [ Element.el [] <| text <| String.fromInt idx
        , Element.el [] <| text <| String.join ", " <| attendees order
        ]


attendees : Types.Order -> List String
attendees order =
    order.form.attendees |> List.map (.name >> (\(Name.Name n) -> n))



-- |> AssocList.toList |> List.map Tuple.first
--|> Form.attendees |> AssocList.toList |> List.map Tuple.first
--|> Order.attendees
--|> AssocList.toList
--|> List.map Tuple.first


viewPendingOrder : AssocList.Dict (Id StripeSessionId) PendingOrder -> Element msg
viewPendingOrder pendingOrders =
    column
        [ width fill
        ]
        [ text "Pending Orders TODO"

        -- , Codec.encodeToString 2 (Types.assocListCodec Types.pendingOrderCodec) pendingOrders |> text
        ]


viewExpiredOrders : AssocList.Dict (Id StripeSessionId) PendingOrder -> Element msg
viewExpiredOrders expiredOrders =
    column
        [ width fill
        ]
        [ text "Expired Orders TODO"

        -- , Codec.encodeToString 2 (Types.assocListCodec Types.pendingOrderCodec) expiredOrders |> text
        ]


loadProdBackend : Cmd msg
loadProdBackend =
    let
        x =
            1

        -- pass =
        --     Env.adminPassword
    in
    Cmd.none



-- debugAssocList assoc =
--     assoc
--         |> AssocList.toList
--         |> List.map
--             (\data ->
--                 column
--                     [ width fill
--                     ]
--                     [ paragraph [] [ text (Debug.toString data) ]
--                     ]
--             )
--         |> column []
