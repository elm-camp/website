module Admin exposing
    ( attendees
    , quickTable
    , view
    , viewAdmin
    , viewExpiredOrders
    , viewOrder
    , viewOrders
    )

import Env
import Html
import Id exposing (Id)
import Name
import SeqDict exposing (SeqDict)
import String.Nonempty
import Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Theme
import Types exposing (BackendModel, FrontendMsg(..), LoadedModel, TicketsEnabled(..))
import Ui
import Ui.Font


view : LoadedModel -> Ui.Element FrontendMsg
view model =
    case model.backendModel of
        Just backendModel ->
            viewAdmin backendModel

        Nothing ->
            Ui.text "loading"


viewAdmin : BackendModel -> Ui.Element FrontendMsg
viewAdmin backendModel =
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
        [ if Env.isProduction then
            Ui.none

          else
            Ui.el
                (Theme.normalButtonAttributes AdminPullBackendModel)
                (Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Ui.text "Pull Backend Model from prod"))
        , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 18 ] (Ui.text "Admin")
        , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 18 ] (Ui.text info)
        , viewOrders backendModel.orders
        , viewExpiredOrders backendModel.expiredOrders
        ]


viewOrders : SeqDict (Id StripeSessionId) Types.CompletedOrder -> Ui.Element msg
viewOrders orders =
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
            [ \order -> List.map (\a -> Name.toString a.name) order.form.attendees |> String.join ", "

            --, \order -> toString order.form.accommodationBookings
            -- , .form >> .grantApply >> Debug.toString
            -- , .form >> .grantContribution >> Debug.toString
            , \order -> List.map (\a -> String.Nonempty.toString a.country) order.form.attendees |> String.join ", "
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


viewOrder : Int -> ( Id StripeSessionId, Types.CompletedOrder ) -> Ui.Element msg
viewOrder idx ( id, order ) =
    Ui.row
        [ Ui.Font.size 14, Ui.spacing 12 ]
        [ Ui.el [ Ui.width Ui.shrink ] (Ui.text (String.fromInt idx))
        , Ui.el [ Ui.width Ui.shrink ] (Ui.text (String.join ", " (attendees order)))
        ]


attendees : Types.CompletedOrder -> List String
attendees order =
    List.map (\a -> Name.toString a.name) order.form.attendees
