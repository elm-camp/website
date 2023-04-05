module Backend exposing (..)

import AssocList
import Duration
import EmailAddress exposing (EmailAddress)
import Env
import Html
import HttpHelpers
import Id exposing (Id)
import Inventory
import Lamdera exposing (ClientId, SessionId)
import List.Extra as List
import List.Nonempty
import Postmark exposing (PostmarkEmailBody(..))
import PurchaseForm exposing (PurchaseFormValidated(..))
import Quantity
import String.Nonempty exposing (NonemptyString(..))
import Stripe exposing (PriceId, ProductId(..), StripeSessionId)
import Task
import Tickets
import Time
import Types exposing (..)
import Unsafe
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
      , dummyField = 0
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
    (case msg of
        GotTime time ->
            let
                expiredOrders : List (Id StripeSessionId)
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

                Err error ->
                    ( model, errorEmail ("GotPrices failed: " ++ HttpHelpers.httpErrorToString error) )

        OnConnected _ clientId ->
            ( model
            , Lamdera.sendToFrontend
                clientId
                (InitData { prices = model.prices, slotsRemaining = Inventory.slotsRemaining model })
            )

        CreatedCheckoutSession sessionId clientId priceId purchaseForm result ->
            case result of
                Ok ( stripeSessionId, submitTime ) ->
                    let
                        existingStripeSessions =
                            AssocList.filter
                                (\_ data -> data.sessionId == sessionId)
                                model.pendingOrder
                                |> AssocList.keys
                    in
                    ( { model
                        | pendingOrder =
                            AssocList.insert
                                stripeSessionId
                                { priceId = priceId
                                , submitTime = submitTime
                                , form = purchaseForm
                                , sessionId = sessionId
                                }
                                model.pendingOrder
                      }
                    , Cmd.batch
                        [ SubmitFormResponse (Ok stripeSessionId) |> Lamdera.sendToFrontend clientId
                        , List.map
                            (\stripeSessionId2 ->
                                Stripe.expireSession stripeSessionId2
                                    |> Task.attempt (ExpiredStripeSession stripeSessionId2)
                            )
                            existingStripeSessions
                            |> Cmd.batch
                        ]
                    )

                Err error ->
                    ( model
                    , Cmd.batch
                        [ SubmitFormResponse (Err ()) |> Lamdera.sendToFrontend clientId
                        , errorEmail ("CreatedCheckoutSession failed: " ++ HttpHelpers.httpErrorToString error)
                        ]
                    )

        ExpiredStripeSession stripeSessionId result ->
            case result of
                Ok () ->
                    ( { model | pendingOrder = AssocList.remove stripeSessionId model.pendingOrder }, Cmd.none )

                Err error ->
                    ( model, errorEmail ("ExpiredStripeSession failed: " ++ HttpHelpers.httpErrorToString error) )

        ConfirmationEmailSent stripeSessionId result ->
            case AssocList.get stripeSessionId model.orders of
                Just order ->
                    case result of
                        Ok data ->
                            ( { model
                                | orders =
                                    AssocList.insert
                                        stripeSessionId
                                        { order | emailResult = EmailSuccess data }
                                        model.orders
                              }
                            , Cmd.none
                            )

                        Err error ->
                            ( { model
                                | orders =
                                    AssocList.insert
                                        stripeSessionId
                                        { order | emailResult = EmailFailed error }
                                        model.orders
                              }
                            , errorEmail ("Confirmation email failed: " ++ HttpHelpers.httpErrorToString error)
                            )

                Nothing ->
                    ( model
                    , errorEmail ("StripeSessionId not found for confirmation email: " ++ Id.toString stripeSessionId)
                    )

        ErrorEmailSent _ ->
            ( model, Cmd.none )
    )
        |> (\( newModel, cmd ) ->
                let
                    newSlotsRemaining =
                        Inventory.slotsRemaining newModel
                in
                if Inventory.slotsRemaining model == newSlotsRemaining then
                    ( newModel, cmd )

                else
                    ( newModel, Cmd.batch [ cmd, Lamdera.broadcast (SlotRemainingChanged newSlotsRemaining) ] )
           )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        SubmitFormRequest priceId a ->
            case Untrusted.purchaseForm a of
                Just purchaseForm ->
                    case priceIdToProductId model priceId of
                        Just productId ->
                            let
                                availability =
                                    Inventory.slotsRemaining model

                                validProductAndForm =
                                    case ( productId == Id.fromString Env.couplesCampTicketProductId, purchaseForm ) of
                                        ( True, CouplesCampTicketPurchase _ ) ->
                                            True && availability.couplesCampTicket

                                        ( False, CampTicketPurchase _ ) ->
                                            True && availability.campTicket

                                        ( False, CampfireTicketPurchase _ ) ->
                                            True && availability.campfireTicket

                                        _ ->
                                            False
                            in
                            if validProductAndForm then
                                ( model
                                , Task.map2
                                    Tuple.pair
                                    (Stripe.createCheckoutSession priceId (PurchaseForm.billingEmail purchaseForm))
                                    Time.now
                                    |> Task.attempt (CreatedCheckoutSession sessionId clientId priceId purchaseForm)
                                )

                            else
                                ( model, SubmitFormResponse (Err ()) |> Lamdera.sendToFrontend clientId )

                        _ ->
                            ( model, SubmitFormResponse (Err ()) |> Lamdera.sendToFrontend clientId )

                Nothing ->
                    ( model, Cmd.none )

        CancelPurchaseRequest ->
            case sessionIdToStripeSessionId sessionId model of
                Just stripeSessionId ->
                    ( model
                    , Stripe.expireSession stripeSessionId |> Task.attempt (ExpiredStripeSession stripeSessionId)
                    )

                Nothing ->
                    ( model, Cmd.none )


sessionIdToStripeSessionId : SessionId -> BackendModel -> Maybe (Id StripeSessionId)
sessionIdToStripeSessionId sessionId model =
    AssocList.toList model.pendingOrder
        |> List.findMap
            (\( stripeSessionId, data ) ->
                if data.sessionId == sessionId then
                    Just stripeSessionId

                else
                    Nothing
            )


priceIdToProductId : BackendModel -> Id PriceId -> Maybe (Id ProductId)
priceIdToProductId model priceId =
    AssocList.toList model.prices
        |> List.findMap
            (\( productId, prices ) ->
                if prices.priceId == priceId then
                    Just productId

                else
                    Nothing
            )


errorEmail : String -> Cmd BackendMsg
errorEmail errorMessage =
    case List.Nonempty.fromList Env.developerEmails of
        Just to ->
            Postmark.sendEmail
                ErrorEmailSent
                Env.postmarkApiKey
                { from = { name = "elm-camp", email = elmCampEmailAddress }
                , to = List.Nonempty.map (\email -> { name = "", email = email }) to
                , subject = NonemptyString 'E' "rror occurred"
                , body = BodyText errorMessage
                , messageStream = "outbound"
                }

        Nothing ->
            Cmd.none


elmCampEmailAddress : EmailAddress
elmCampEmailAddress =
    Unsafe.emailAddress "hello@elm.camp"
