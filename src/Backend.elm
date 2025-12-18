module Backend exposing
    ( app
    , app_
    , elmCampEmailAddress
    , errorEmail
    , init
    , priceIdToProductId
    , sessionIdToStripeSessionId
    , subscriptions
    , update
    , updateFromFrontend
    )

import Camp25US.Inventory as Inventory
import Camp25US.Product as Product
import Camp25US.Tickets as Tickets
import Duration
import Effect.Command as Command exposing (BackendOnly, Command)
import Effect.Lamdera as Lamdera exposing (ClientId, SessionId)
import Effect.Process
import Effect.Subscription as Subscription exposing (Subscription)
import Effect.Task as Task
import Effect.Time as Time
import EmailAddress exposing (EmailAddress)
import Env
import HttpHelpers
import Id exposing (Id)
import Lamdera as LamderaCore
import List.Extra as List
import List.Nonempty
import Name
import Postmark
import PurchaseForm exposing (PurchaseFormValidated)
import Quantity
import SeqDict
import String.Nonempty exposing (NonemptyString(..))
import Stripe exposing (PriceId, ProductId(..), StripeSessionId)
import Types exposing (BackendModel, BackendMsg(..), EmailResult(..), TicketsEnabled(..), ToBackend(..), ToFrontend(..))
import Unsafe
import Untrusted


app :
    { init : ( BackendModel, Cmd BackendMsg )
    , update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
    , updateFromFrontend : String -> String -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
    , subscriptions : BackendModel -> Sub BackendMsg
    }
app =
    Lamdera.backend LamderaCore.broadcast LamderaCore.sendToFrontend app_


app_ :
    { init : ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
    , update : BackendMsg -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
    , updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
    , subscriptions : BackendModel -> Subscription BackendOnly BackendMsg
    }
app_ =
    { init = init
    , update = update
    , updateFromFrontend = updateFromFrontend
    , subscriptions = subscriptions
    }


init : ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
init =
    ( { orders = SeqDict.empty
      , pendingOrder = SeqDict.empty
      , expiredOrders = SeqDict.empty
      , prices = SeqDict.empty
      , time = Time.millisToPosix 0
      , ticketsEnabled = TicketsEnabled
      , backendInitialized = False
      }
    , Command.none
    )


subscriptions : BackendModel -> Subscription BackendOnly BackendMsg
subscriptions _ =
    Subscription.batch
        [ Time.every (Duration.minutes 15) GotTime
        , Lamdera.onConnect OnConnected
        ]


update : BackendMsg -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
update msg model =
    (case msg of
        GotTime _ ->
            ( model, Command.none )

        --let
        --    ( expiredOrders, remainingOrders ) =
        --        SeqDict.partition
        --            (\_ order -> Duration.from order.submitTime time |> Quantity.greaterThan (Duration.minutes 30))
        --            model.pendingOrder
        --in
        --( { model
        --    | time = time
        --    , pendingOrder = remainingOrders
        --    , expiredOrders = SeqDict.union expiredOrders model.expiredOrders
        --  }
        --, Command.batch
        --    [ Stripe.getPrices |> Task.attempt GotPrices
        --    , List.map
        --        (\stripeSessionId ->
        --            Stripe.expireSession stripeSessionId
        --                |> Task.attempt (ExpiredStripeSession stripeSessionId)
        --        )
        --        (SeqDict.keys expiredOrders)
        --        |> Command.batch
        --    ]
        --)
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
                                |> SeqDict.fromList
                      }
                    , Command.none
                    )

                Err error ->
                    ( model
                    , errorEmail ("GotPrices failed: " ++ HttpHelpers.httpErrorToString error)
                        |> Command.fromCmd "GotPrices failed email"
                    )

        OnConnected _ clientId ->
            ( model
            , Lamdera.sendToFrontend
                clientId
                (InitData
                    { prices = model.prices
                    , slotsRemaining = Inventory.slotsRemaining model
                    , ticketsEnabled = model.ticketsEnabled
                    }
                )
            )

        --( { model | backendInitialized = True }
        --, Command.batch
        --    [ Lamdera.sendToFrontend
        --        clientId
        --        (InitData
        --            { prices = model.prices
        --            , slotsRemaining = Inventory.slotsRemaining model
        --            , ticketsEnabled = model.ticketsEnabled
        --            }
        --        )
        --    , if model.backendInitialized then
        --        Command.none
        --
        --      else
        --        Command.batch
        --            [ Time.now |> Task.perform GotTime
        --            , Effect.Process.sleep Duration.second
        --                |> Task.andThen (\() -> Stripe.getPrices)
        --                |> Task.attempt GotPrices
        --            ]
        --    ]
        --)
        CreatedCheckoutSession sessionId clientId purchaseForm result ->
            case result of
                Ok ( stripeSessionId, submitTime ) ->
                    let
                        existingStripeSessions =
                            SeqDict.filter
                                (\_ data -> data.sessionId == sessionId)
                                model.pendingOrder
                                |> SeqDict.keys
                    in
                    ( { model
                        | pendingOrder =
                            SeqDict.insert
                                stripeSessionId
                                { submitTime = submitTime
                                , form = purchaseForm
                                , sessionId = sessionId
                                }
                                model.pendingOrder
                      }
                    , Command.batch
                        [ SubmitFormResponse (Ok stripeSessionId) |> Lamdera.sendToFrontend clientId
                        , List.map
                            (\stripeSessionId2 ->
                                Stripe.expireSession stripeSessionId2
                                    |> Task.attempt (ExpiredStripeSession stripeSessionId2)
                            )
                            existingStripeSessions
                            |> Command.batch
                        ]
                    )

                Err error ->
                    let
                        err =
                            "CreatedCheckoutSession failed: " ++ HttpHelpers.httpErrorToString error
                    in
                    ( model
                    , Command.batch
                        [ SubmitFormResponse (Err err) |> Lamdera.sendToFrontend clientId
                        , errorEmail err |> Command.fromCmd "Send email"
                        ]
                    )

        ExpiredStripeSession stripeSessionId result ->
            case result of
                Ok () ->
                    case SeqDict.get stripeSessionId model.pendingOrder of
                        Just expired ->
                            ( { model
                                | pendingOrder = SeqDict.remove stripeSessionId model.pendingOrder
                                , expiredOrders = SeqDict.insert stripeSessionId expired model.expiredOrders
                              }
                            , Command.none
                            )

                        Nothing ->
                            ( model, Command.none )

                Err error ->
                    ( model
                    , errorEmail
                        ("ExpiredStripeSession failed: "
                            ++ HttpHelpers.httpErrorToString error
                            ++ " stripeSessionId: "
                            ++ Id.toString stripeSessionId
                        )
                        |> Command.fromCmd "ExpiredStripeSession email"
                    )

        ConfirmationEmailSent stripeSessionId result ->
            case SeqDict.get stripeSessionId model.orders of
                Just order ->
                    case result of
                        Ok () ->
                            ( { model
                                | orders =
                                    SeqDict.insert
                                        stripeSessionId
                                        { order | emailResult = EmailSuccess }
                                        model.orders
                              }
                            , Command.none
                            )

                        Err error ->
                            ( { model
                                | orders =
                                    SeqDict.insert
                                        stripeSessionId
                                        { order | emailResult = EmailFailed error }
                                        model.orders
                              }
                            , errorEmail ("Confirmation email failed: " ++ HttpHelpers.httpErrorToString error)
                                |> Command.fromCmd "Confirmation email failed"
                            )

                Nothing ->
                    ( model
                    , errorEmail ("StripeSessionId not found for confirmation email: " ++ Id.toString stripeSessionId)
                        |> Command.fromCmd "StripeSessionId not found email"
                    )

        ErrorEmailSent _ ->
            ( model, Command.none )
    )
        |> (\( newModel, cmd ) ->
                let
                    newSlotsRemaining =
                        Inventory.slotsRemaining newModel
                in
                if Inventory.slotsRemaining model == newSlotsRemaining then
                    ( newModel, cmd )

                else
                    ( newModel, Command.batch [ cmd, Lamdera.broadcast (SlotRemainingChanged newSlotsRemaining) ] )
           )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        SubmitFormRequest a ->
            case ( Untrusted.purchaseForm a, model.ticketsEnabled ) of
                ( Just purchaseForm, TicketsEnabled ) ->
                    let
                        availability =
                            Inventory.slotsRemaining model

                        validProductAndForm =
                            {-
                               I'm going to leave this for now, it's supposed to protect from people hand-crafting payloads
                               from the frontend to skip form validation, but given the Lamdera wire format is opaque and
                               undocumented, and there isn't really much to gain from someone going to the pains to reverse
                               engineer it just to avoid filling in their full name or valid email, I don't think this is a
                               realistic concern for our small event :)
                            -}
                            True

                        sponsorshipItems =
                            case purchaseForm.sponsorship of
                                Just sponsorshipId ->
                                    case SeqDict.get (Id.fromString sponsorshipId) model.prices of
                                        Just price ->
                                            [ Stripe.Priced
                                                { name = "Sponsorship"
                                                , priceId = price.priceId
                                                , quantity = 1
                                                }
                                            ]

                                        Nothing ->
                                            []

                                Nothing ->
                                    []

                        ticketItems =
                            purchaseForm.attendees
                                |> List.map
                                    (\attendee ->
                                        Stripe.Priced
                                            { name = Tickets.attendanceTicket.name ++ " for " ++ Name.toString attendee.name
                                            , priceId =
                                                let
                                                    productId =
                                                        Id.fromString Tickets.attendanceTicket.productId
                                                in
                                                case SeqDict.get productId model.prices of
                                                    Just price ->
                                                        price.priceId

                                                    Nothing ->
                                                        Id.fromString "price not found"
                                            , quantity = 1
                                            }
                                    )

                        accommodationItems =
                            purchaseForm.accommodationBookings
                                |> List.group
                                |> List.map
                                    (\( accom, accomCount ) ->
                                        Stripe.Priced
                                            { name = Tickets.accomToString accom
                                            , priceId =
                                                let
                                                    productId =
                                                        Id.fromString (Tickets.accomToTicket accom).productId
                                                in
                                                case SeqDict.get productId model.prices of
                                                    Just price ->
                                                        price.priceId

                                                    Nothing ->
                                                        Id.fromString "price not found"
                                            , quantity = List.length accomCount + 1
                                            }
                                    )

                        opportunityGrantItems =
                            if purchaseForm.grantContribution > 0 then
                                [ Stripe.Unpriced
                                    { name = "Opportunity Grant"
                                    , quantity = 1
                                    , currency = "usd"
                                    , amountDecimal = purchaseForm.grantContribution * 100
                                    }
                                ]

                            else
                                []

                        items =
                            ticketItems ++ accommodationItems ++ opportunityGrantItems ++ sponsorshipItems
                    in
                    ( model
                    , Time.now
                        |> Task.andThen
                            (\now ->
                                Stripe.createCheckoutSession
                                    { items = items
                                    , emailAddress = purchaseForm.billingEmail
                                    , now = now
                                    , expiresInMinutes = 30
                                    }
                                    |> Task.map (\res -> ( res, now ))
                            )
                        |> Task.attempt (CreatedCheckoutSession sessionId clientId purchaseForm)
                    )

                _ ->
                    ( model, Command.none )

        CancelPurchaseRequest ->
            case sessionIdToStripeSessionId sessionId model of
                Just stripeSessionId ->
                    ( model
                    , Stripe.expireSession stripeSessionId |> Task.attempt (ExpiredStripeSession stripeSessionId)
                    )

                Nothing ->
                    ( model, Command.none )

        AdminInspect pass ->
            if pass == Env.adminPassword then
                ( model, Lamdera.sendToFrontend clientId (AdminInspectResponse model) )

            else
                ( model, Command.none )


sessionIdToStripeSessionId : SessionId -> BackendModel -> Maybe (Id StripeSessionId)
sessionIdToStripeSessionId sessionId model =
    SeqDict.toList model.pendingOrder
        |> List.findMap
            (\( stripeSessionId, data ) ->
                if data.sessionId == sessionId then
                    Just stripeSessionId

                else
                    Nothing
            )


priceIdToProductId : BackendModel -> Id PriceId -> Maybe (Id ProductId)
priceIdToProductId model priceId =
    SeqDict.toList model.prices
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
                , subject =
                    NonemptyString 'E'
                        ("rror occurred "
                            ++ (if Env.isProduction then
                                    "(prod)"

                                else
                                    "(dev)"
                               )
                        )
                , body = Postmark.TextBody errorMessage
                , messageStream = Postmark.TransactionalEmail
                , attachments = Postmark.noAttachments
                }

        Nothing ->
            Cmd.none


elmCampEmailAddress : EmailAddress
elmCampEmailAddress =
    Unsafe.emailAddress "team@elm.camp"
