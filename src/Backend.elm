module Backend exposing (..)

import AssocList
import Duration
import Env
import Html
import Lamdera exposing (ClientId, SessionId)
import List.Extra as List
import PurchaseForm exposing (PurchaseFormValidated(..))
import Quantity
import Stripe exposing (PriceId, ProductId(..), StripeSessionId)
import Task
import Tickets
import Time
import Types exposing (..)
import Untrusted


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { orders = AssocList.empty
      , pendingOrder = AssocList.empty
      , prices = AssocList.empty
      , time = Time.millisToPosix 0
      }
    , Cmd.batch
        [ Time.now |> Task.perform GotTime
        , Stripe.getPrices GotPrices
        ]
    )


subscriptions : BackendModel -> Sub BackendMsg
subscriptions _ =
    Sub.batch
        [ Time.every (1000 * 60 * 15) GotTime
        , Lamdera.onConnect OnConnected
        ]


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        GotTime time ->
            let
                expiredOrders : List StripeSessionId
                expiredOrders =
                    AssocList.filter
                        (\_ order -> Duration.from order.submitTime time |> Quantity.greaterThan Duration.hour)
                        model.pendingOrder
                        |> AssocList.keys
            in
            ( { model
                | time = time
              }
            , Cmd.batch
                [ Stripe.getPrices GotPrices
                , List.map
                    (\stripeSessionId ->
                        Stripe.expireSession stripeSessionId
                            |> Task.attempt (ExpiredStripeSession stripeSessionId)
                    )
                    expiredOrders
                    |> Cmd.batch
                ]
            )

        GotPrices result ->
            case result of
                Ok prices ->
                    ( { model
                        | prices =
                            List.filterMap
                                (\price ->
                                    if price.isActive then
                                        Just ( price.productId, { priceId = price.priceId, price = price.price } )

                                    else
                                        Nothing
                                )
                                prices
                                |> AssocList.fromList
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        OnConnected _ clientId ->
            ( model, Lamdera.sendToFrontend clientId (PricesToFrontend model.prices) )

        CreatedCheckoutSession clientId priceId purchaseForm result ->
            case result of
                Ok ( stripeSessionId, submitTime ) ->
                    ( { model
                        | pendingOrder =
                            AssocList.insert
                                stripeSessionId
                                { priceId = priceId
                                , submitTime = submitTime
                                , form = purchaseForm
                                }
                                model.pendingOrder
                      }
                    , SubmitFormResponse (Ok stripeSessionId) |> Lamdera.sendToFrontend clientId
                    )

                Err error ->
                    ( model, SubmitFormResponse (Err ()) |> Lamdera.sendToFrontend clientId )

        ExpiredStripeSession stripeSessionId result ->
            case result of
                Ok () ->
                    ( { model | pendingOrder = AssocList.remove stripeSessionId model.pendingOrder }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        EmailSent result ->
            case result of
                Ok response ->
                    ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend _ clientId msg model =
    case msg of
        SubmitFormRequest priceId a ->
            case Untrusted.purchaseForm a of
                Just purchaseForm ->
                    case ( priceIdToProductId model priceId, slotsRemaining model > 0 ) of
                        ( Just productId, True ) ->
                            let
                                validProductAndForm =
                                    case ( productId == ProductId Env.couplesCampTicketProductId, purchaseForm ) of
                                        ( True, CouplePurchase _ ) ->
                                            True

                                        ( False, SinglePurchase _ ) ->
                                            True

                                        _ ->
                                            False
                            in
                            if validProductAndForm then
                                ( model
                                , Task.map2
                                    Tuple.pair
                                    (Stripe.createCheckoutSession priceId (PurchaseForm.billingEmail purchaseForm))
                                    Time.now
                                    |> Task.attempt (CreatedCheckoutSession clientId priceId purchaseForm)
                                )

                            else
                                ( model, SubmitFormResponse (Err ()) |> Lamdera.sendToFrontend clientId )

                        _ ->
                            ( model, SubmitFormResponse (Err ()) |> Lamdera.sendToFrontend clientId )

                Nothing ->
                    ( model, Cmd.none )

        CancelPurchaseRequest stripeSessionId ->
            ( model
            , Stripe.expireSession stripeSessionId |> Task.attempt (ExpiredStripeSession stripeSessionId)
            )


priceIdToProductId : BackendModel -> PriceId -> Maybe ProductId
priceIdToProductId model priceId =
    AssocList.toList model.prices
        |> List.findMap
            (\( productId, prices ) ->
                if prices.priceId == priceId then
                    Just productId

                else
                    Nothing
            )


slotsRemaining : BackendModel -> Int
slotsRemaining model =
    let
        pendingOrders =
            AssocList.values model.pendingOrder |> List.map ticketToSlots |> List.sum

        orders =
            AssocList.values model.orders |> List.map ticketToSlots |> List.sum
    in
    totalSlotsAvailable - (pendingOrders + orders)


ticketToSlots : { a | form : PurchaseFormValidated } -> number
ticketToSlots pendingOrder =
    case pendingOrder.form of
        SinglePurchase _ ->
            1

        CouplePurchase _ ->
            2
