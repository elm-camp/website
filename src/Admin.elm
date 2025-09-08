module Admin exposing
    ( attendees
    , attendeesDetail
    , attendeesPending
    , loadProdBackend
    , quickTable
    , toString
    , view
    , viewAdmin
    , viewExpiredOrders
    , viewExpiredOrders2
    , viewOrder
    , viewOrders
    , viewPendingOrder
    , viewPrices
    , viewTicketsEnabled
    )

import AssocList
import Element exposing (Element, centerX, column, el, fill, html, none, padding, row, spacing, text, width)
import Element.Font as Font
import Element.Input as Input
import EmailAddress
import Env
import Html
import Id exposing (Id)
import List.Extra
import Name
import String.Nonempty
import Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Theme
import Types exposing (BackendModel, FrontendMsg_(..), LoadedModel, Price2, TicketsEnabled(..))


view : LoadedModel -> Element FrontendMsg_
view model =
    case model.backendModel of
        Just backendModel ->
            viewAdmin backendModel

        Nothing ->
            text "loading"


viewAdmin : BackendModel -> Element FrontendMsg_
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
        , padding 24
        , spacing 40
        ]
        [ if Env.mode == Env.Development then
            Input.button
                Theme.normalButtonAttributes
                { onPress = Just AdminPullBackendModel
                , label = el [ centerX ] (text "Pull Backend Model from prod")
                }

          else
            none
        , el [ Font.size 18 ] (text "Admin")
        , el [ Font.size 18 ] (text info)
        , viewOrders backendModel.orders

        -- , viewExpiredOrders2 backendModel.expiredOrders
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
                text ("TicketsDisabled" ++ d.adminMessage)
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
            orders |> AssocList.toList |> List.length
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
            orders |> AssocList.toList |> List.length
    in
    column
        [ width fill
        , spacing 12
        ]
        ([ el [] (text ("Expired orders (incorrectly marked expired due to postback issues): " ++ String.fromInt n))
         , quickTable (orders |> AssocList.values)
            [ \order -> attendeesPending order |> String.join ", "
            , \order -> attendeesDetail (\a -> EmailAddress.toString a.email) order |> String.join ", "
            , \order -> toString order.form.accommodationBookings

            -- , .form >> .grantApply >> Debug.toString
            -- , .form >> .grantContribution >> Debug.toString
            -- , .form >> .sponsorship >> Debug.toString
            , \order -> attendeesDetail (\a -> String.Nonempty.toString a.country) order |> String.join ", "
            ]
         ]
         -- ++ (orders |> AssocList.toList |> List.indexedMap viewPendingOrder)
        )


quickTable : List a -> List (a -> String) -> Element msg
quickTable collection fns =
    -- Because Element.table copy/paste doesn't do table formatting in GDocs
    collection
        |> List.map
            (\item ->
                fns
                    |> List.map
                        (\fn ->
                            Html.td [] [ Html.text (fn item) ]
                        )
                    |> Html.tr []
            )
        |> Html.table []
        |> html


viewExpiredOrders2 : AssocList.Dict (Id StripeSessionId) Types.PendingOrder -> Element msg
viewExpiredOrders2 orders =
    let
        ordersCleaned : List String
        ordersCleaned =
            orders
                |> AssocList.toList
                |> List.map (\( _, value ) -> attendeesPending value)
                |> List.concat
                |> List.Extra.unique
                |> List.sort
    in
    column
        [ width fill
        , spacing 8
        ]
        (el [] (text ("Participants: " ++ String.fromInt (List.length ordersCleaned))) :: (ordersCleaned |> List.indexedMap (\k s -> row [ Font.size 14, spacing 8 ] [ text (String.fromInt (k + 1)), text s ])))


viewOrder : Int -> ( Id StripeSessionId, Types.Order ) -> Element msg
viewOrder idx ( id, order ) =
    row
        [ width fill, Font.size 14, spacing 12 ]
        [ el [] (text (String.fromInt idx))
        , el [] (text (String.join ", " (attendees order)))
        ]


viewPendingOrder : Int -> ( Id StripeSessionId, Types.PendingOrder ) -> Element msg
viewPendingOrder idx ( id, order ) =
    row
        [ width fill, Font.size 14, spacing 12 ]
        [ el [] (text (String.fromInt (idx + 1)))
        , el [] (text (String.join ", " (attendeesPending order)))

        -- , text <| Debug.toString order
        ]


attendees : Types.Order -> List String
attendees order =
    order.form.attendees |> List.map (\a -> Name.toString a.name)


attendeesPending : Types.PendingOrder -> List String
attendeesPending order =
    order.form.attendees |> List.map (\a -> Name.toString a.name)


attendeesDetail : (a -> b) -> { c | form : { d | attendees : List a } } -> List String
attendeesDetail fn order =
    order.form.attendees |> List.map (\a -> fn a |> toString)


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


toString : a -> String
toString x =
    -- swap back to the original implementation when developing
    -- Debug.toString x
    "<toString neutered>"
