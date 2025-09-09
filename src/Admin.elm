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

import Element exposing (Element)
import Element.Font as Font
import Element.Input as Input
import EmailAddress
import Env
import Html
import Id exposing (Id)
import List.Extra
import Name
import SeqDict exposing (SeqDict)
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
            Element.text "loading"


viewAdmin : BackendModel -> Element FrontendMsg_
viewAdmin backendModel =
    -- type alias BackendModel =
    --     { orders : SeqDict (Id StripeSessionId) Order
    --     , pendingOrder : SeqDict (Id StripeSessionId) PendingOrder
    --     , expiredOrders : SeqDict (Id StripeSessionId) PendingOrder
    --     , prices : SeqDict (Id ProductId) Price2
    --     , time : Time.Posix
    --     , ticketsEnabled : TicketsEnabled
    --     }
    let
        numberOfOrders =
            List.length (SeqDict.toList backendModel.orders)

        numberOfPendingOrders =
            List.length (SeqDict.toList backendModel.pendingOrder)

        numberOfExpiredOrders =
            List.length (SeqDict.toList backendModel.expiredOrders)

        info =
            "Orders (completed, pending, expired): "
                ++ (List.map String.fromInt [ numberOfOrders, numberOfPendingOrders, numberOfExpiredOrders ] |> String.join ", ")
    in
    Element.column
        [ Element.width Element.fill
        , Element.padding 24
        , Element.spacing 40
        ]
        [ if Env.mode == Env.Development then
            Input.button
                Theme.normalButtonAttributes
                { onPress = Just AdminPullBackendModel
                , label = Element.el [ Element.centerX ] (Element.text "Pull Backend Model from prod")
                }

          else
            Element.none
        , Element.el [ Font.size 18 ] (Element.text "Admin")
        , Element.el [ Font.size 18 ] (Element.text info)
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
    Element.column
        [ Element.width Element.fill
        ]
        [ Element.text "TicketsEnabled:"
        , case ticketsEnabled of
            TicketsEnabled ->
                Element.text "TicketsEnabled"

            TicketsDisabled d ->
                Element.text ("TicketsDisabled" ++ d.adminMessage)
        ]


viewPrices : SeqDict (Id ProductId) Price2 -> Element msg
viewPrices prices =
    Element.column
        [ Element.width Element.fill
        ]
        [ Element.text "Prices TODO"

        -- , Codec.encodeToString 2 (Types.assocListCodec Types.price2Codec) prices |> Element.text
        ]


viewOrders : SeqDict (Id StripeSessionId) Types.Order -> Element msg
viewOrders orders =
    let
        n =
            orders |> SeqDict.toList |> List.length
    in
    Element.column
        [ Element.width Element.fill
        , Element.spacing 12
        ]
        (orders |> SeqDict.toList |> List.indexedMap viewOrder)


viewExpiredOrders : SeqDict (Id StripeSessionId) Types.PendingOrder -> Element msg
viewExpiredOrders orders =
    let
        n =
            orders |> SeqDict.toList |> List.length
    in
    Element.column
        [ Element.width Element.fill
        , Element.spacing 12
        ]
        ([ Element.el [] (Element.text ("Expired orders (incorrectly marked expired due to postback issues): " ++ String.fromInt n))
         , quickTable (orders |> SeqDict.values)
            [ \order -> attendeesPending order |> String.join ", "
            , \order -> attendeesDetail (\a -> EmailAddress.toString a.email) order |> String.join ", "
            , \order -> toString order.form.accommodationBookings

            -- , .form >> .grantApply >> Debug.toString
            -- , .form >> .grantContribution >> Debug.toString
            -- , .form >> .sponsorship >> Debug.toString
            , \order -> attendeesDetail (\a -> String.Nonempty.toString a.country) order |> String.join ", "
            ]
         ]
         -- ++ (orders |> SeqDict.toList |> List.indexedMap viewPendingOrder)
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
        |> Element.html


viewExpiredOrders2 : SeqDict (Id StripeSessionId) Types.PendingOrder -> Element msg
viewExpiredOrders2 orders =
    let
        ordersCleaned : List String
        ordersCleaned =
            orders
                |> SeqDict.toList
                |> List.concatMap (\( _, value ) -> attendeesPending value)
                |> List.Extra.unique
                |> List.sort
    in
    Element.column
        [ Element.width Element.fill
        , Element.spacing 8
        ]
        (Element.el [] (Element.text ("Participants: " ++ String.fromInt (List.length ordersCleaned))) :: (ordersCleaned |> List.indexedMap (\k s -> Element.row [ Font.size 14, Element.spacing 8 ] [ Element.text (String.fromInt (k + 1)), Element.text s ])))


viewOrder : Int -> ( Id StripeSessionId, Types.Order ) -> Element msg
viewOrder idx ( id, order ) =
    Element.row
        [ Element.width Element.fill, Font.size 14, Element.spacing 12 ]
        [ Element.el [] (Element.text (String.fromInt idx))
        , Element.el [] (Element.text (String.join ", " (attendees order)))
        ]


viewPendingOrder : Int -> ( Id StripeSessionId, Types.PendingOrder ) -> Element msg
viewPendingOrder idx ( id, order ) =
    Element.row
        [ Element.width Element.fill, Font.size 14, Element.spacing 12 ]
        [ Element.el [] (Element.text (String.fromInt (idx + 1)))
        , Element.el [] (Element.text (String.join ", " (attendeesPending order)))

        -- , Element.text <| Debug.toString order
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



-- debugSeqDict assoc =
--     assoc
--         |> SeqDict.toList
--         |> List.map
--             (\data ->
--                 Element.column
--                     [ width fill
--                     ]
--                     [ paragraph [] [ Element.text (Debug.toString data) ]
--                     ]
--             )
--         |> Element.column []


toString : a -> String
toString x =
    -- swap back to the original implementation when developing
    -- Debug.toString x
    "<toString neutered>"
