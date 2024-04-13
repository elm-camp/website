module Admin exposing (..)

import AssocList
import Codec
import Element exposing (..)
import Element.Font
import Id exposing (Id)
import Lamdera
import List.Extra
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
        , el [ Element.Font.size 18 ] (text info)
        , viewOrders backendModel.orders
        , viewExpiredOrders2 backendModel.expiredOrders
        , viewExpiredOrders backendModel.expiredOrders


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
    let
        n =
            orders |> AssocList.toList |> List.length |> Debug.log "Number of orders: "
    in
    column
        [ width fill
        , spacing 12
        ]
        (orders |> AssocList.toList |> List.indexedMap viewOrder)


viewExpiredOrders : AssocList.Dict (Id StripeSessionId) Types.PendingOrder -> Element msg
viewExpiredOrders orders =
    let
        n =
            orders |> AssocList.toList |> List.length |> Debug.log "Number of pending orders: "
    in
    column
        [ width fill
        , spacing 12
        ]
        (el [] (text <| "Expired orders: " ++ String.fromInt n)  :: (orders |> AssocList.toList |> List.indexedMap viewPendingOrder)


viewExpiredOrders2 : AssocList.Dict (Id StripeSessionId) Types.PendingOrder -> Element msg
viewExpiredOrders2 orders =
    let
        ordersCleaned : List String
        ordersCleaned =
            orders |> AssocList.toList
              |> List.map (Tuple.second >> attendeesPending)
              |> List.concat
              |> List.Extra.unique

    in
    column
        [ width fill
        , spacing 8
        ]
        (el [] (text <| "Expired orders (cleaned up): " ++ String.fromInt (List.length ordersCleaned))  ::(ordersCleaned |> List.indexedMap (\k s -> row [Element.Font.size 14] [text <| String.fromInt (k + 1), text s]))


viewOrder : Int -> ( Id StripeSessionId, Types.Order ) -> Element msg
viewOrder idx ( id, order ) =
    row
        [ width fill, Element.Font.size 14, spacing 12 ]
        [ Element.el [] <| text <| String.fromInt idx
        , Element.el [] <| text <| String.join ", " <| attendees order
        ]


viewPendingOrder : Int -> ( Id StripeSessionId, Types.PendingOrder ) -> Element msg
viewPendingOrder idx ( id, order ) =
    row
        [ width fill, Element.Font.size 14, spacing 12 ]
        [ Element.el [] <| text <| String.fromInt (idx + 1)
        , Element.el [] <| text <| String.join ", " <| attendeesPending order
        ]

attendees : Types.Order -> List String
attendees order =
    order.form.attendees |> List.map (.name >> (\(Name.Name n) -> n))


attendeesPending : Types.PendingOrder -> List String
attendeesPending order =
    order.form.attendees |> List.map (.name >> (\(Name.Name n) -> n))





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
