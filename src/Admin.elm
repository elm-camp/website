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

import Effect.Command as Command exposing (Command)
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
import Types exposing (BackendModel, FrontendMsg(..), LoadedModel, Price2, TicketsEnabled(..))
import Ui
import Ui.Anim
import Ui.Events
import Ui.Font as Font
import Ui.Input as Input
import Ui.Layout
import Ui.Prose


view : LoadedModel -> Ui.Element FrontendMsg
view model =
    case model.backendModel of
        Just backendModel ->
            viewAdmin backendModel

        Nothing ->
            Ui.text "loading"


viewAdmin : BackendModel -> Ui.Element FrontendMsg
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
    Ui.column
        [ Ui.padding 24
        , Ui.spacing 40
        ]
        [ if Env.mode == Env.Development then
            Ui.Input.button
                -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
                Theme.normalButtonAttributes
                { onPress = Just AdminPullBackendModel
                , label = Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Ui.text "Pull Backend Model from prod")
                }

          else
            Ui.none
        , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 18 ] (Ui.text "Admin")
        , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 18 ] (Ui.text info)
        , viewOrders backendModel.orders

        -- , viewExpiredOrders2 backendModel.expiredOrders
        , viewExpiredOrders backendModel.expiredOrders

        --, viewPendingOrder backendModel.pendingOrder
        --, viewExpiredOrders backendModel.expiredOrders
        --, viewPrices backendModel.prices
        --, viewTicketsEnabled backendModel.ticketsEnabled
        ]


viewTicketsEnabled : TicketsEnabled -> Ui.Element msg
viewTicketsEnabled ticketsEnabled =
    Ui.column
        []
        [ Ui.text "TicketsEnabled:"
        , case ticketsEnabled of
            TicketsEnabled ->
                Ui.text "TicketsEnabled"

            TicketsDisabled d ->
                Ui.text ("TicketsDisabled" ++ d.adminMessage)
        ]


viewPrices : SeqDict (Id ProductId) Price2 -> Ui.Element msg
viewPrices prices =
    Ui.column
        []
        [ Ui.text "Prices TODO"

        -- , Codec.encodeToString 2 (Types.assocListCodec Types.price2Codec) prices |> Element.text
        ]


viewOrders : SeqDict (Id StripeSessionId) Types.Order -> Ui.Element msg
viewOrders orders =
    let
        n =
            orders |> SeqDict.toList |> List.length
    in
    Ui.column
        [ Ui.spacing 12
        ]
        (orders |> SeqDict.toList |> List.indexedMap viewOrder)


viewExpiredOrders : SeqDict (Id StripeSessionId) Types.PendingOrder -> Ui.Element msg
viewExpiredOrders orders =
    let
        n =
            orders |> SeqDict.toList |> List.length
    in
    Ui.column
        [ Ui.spacing 12
        ]
        ([ Ui.el [ Ui.width Ui.shrink ] (Ui.text ("Expired orders (incorrectly marked expired due to postback issues): " ++ String.fromInt n))
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


quickTable : List a -> List (a -> String) -> Ui.Element msg
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
        |> Ui.html


viewExpiredOrders2 : SeqDict (Id StripeSessionId) Types.PendingOrder -> Ui.Element msg
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
    Ui.column
        [ Ui.spacing 8
        ]
        (Ui.el [ Ui.width Ui.shrink ] (Ui.text ("Participants: " ++ String.fromInt (List.length ordersCleaned))) :: (ordersCleaned |> List.indexedMap (\k s -> Ui.row [ Ui.width Ui.shrink, Ui.Font.size 14, Ui.spacing 8 ] [ Ui.text (String.fromInt (k + 1)), Ui.text s ])))


viewOrder : Int -> ( Id StripeSessionId, Types.Order ) -> Ui.Element msg
viewOrder idx ( id, order ) =
    Ui.row
        [ Ui.Font.size 14, Ui.spacing 12 ]
        [ Ui.el [ Ui.width Ui.shrink ] (Ui.text (String.fromInt idx))
        , Ui.el [ Ui.width Ui.shrink ] (Ui.text (String.join ", " (attendees order)))
        ]


viewPendingOrder : Int -> ( Id StripeSessionId, Types.PendingOrder ) -> Ui.Element msg
viewPendingOrder idx ( id, order ) =
    Ui.row
        [ Ui.Font.size 14, Ui.spacing 12 ]
        [ Ui.el [ Ui.width Ui.shrink ] (Ui.text (String.fromInt (idx + 1)))
        , Ui.el [ Ui.width Ui.shrink ] (Ui.text (String.join ", " (attendeesPending order)))

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


loadProdBackend : Command restriction toMsg msg
loadProdBackend =
    let
        x =
            1

        -- pass =
        --     Env.adminPassword
    in
    Command.none



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
