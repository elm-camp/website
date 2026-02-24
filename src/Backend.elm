module Backend exposing
    ( app
    , app_
    , confirmationEmail
    , confirmationEmailSubject
    , elmCampEmailAddress
    , errorEmail
    , init
    , opportunityGrantEmailBody
    , opportunityGrantEmailSubject
    , sessionIdToStripeSessionId
    , subscriptions
    , update
    , updateFromFrontend
    )

import Camp26Czech
import Duration
import Effect.Command as Command exposing (BackendOnly, Command)
import Effect.Http as Http
import Effect.Lamdera as Lamdera exposing (ClientId, SessionId)
import Effect.Process
import Effect.Subscription as Subscription exposing (Subscription)
import Effect.Task as Task
import Effect.Time as Time
import Email.Html as Html
import Email.Html.Attributes as Attributes
import EmailAddress exposing (EmailAddress)
import Env
import Fusion.Generated.Types
import HttpHelpers
import Id exposing (Id)
import Json.Decode as D
import Lamdera as LamderaCore
import List.Extra as List
import List.Nonempty exposing (Nonempty(..))
import Money
import Name
import NonNegative exposing (NonNegative)
import Postmark
import PurchaseForm exposing (PurchaseFormValidated, TicketTypes)
import Quantity
import Route exposing (Route(..))
import Sales
import SeqDict exposing (SeqDict)
import String.Nonempty exposing (NonemptyString(..))
import Stripe exposing (CheckoutItem, Price, PriceData, PriceId, ProductId(..), StripeSessionId, Webhook(..))
import Types exposing (BackendModel, BackendMsg(..), CompletedOrder, EmailResult(..), GrantApplication, PendingOrder, TicketPriceStatus(..), TicketsEnabled(..), ToBackend(..), ToFrontend(..))
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
      , pendingOrders = SeqDict.empty
      , expiredOrders = SeqDict.empty
      , prices = NotLoadingTicketPrices
      , time = Time.millisToPosix 0
      , ticketsEnabled = TicketsEnabled
      , grantApplications = []
      }
    , Command.none
    )


subscriptions : BackendModel -> Subscription BackendOnly BackendMsg
subscriptions _ =
    Subscription.batch
        [ Time.every (Duration.minutes 1) GotTime
        , Lamdera.onConnect OnConnected
        ]


update : BackendMsg -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
update msg model =
    (case msg of
        GotTime time ->
            let
                ( expiredOrders, remainingOrders ) =
                    SeqDict.partition
                        (\_ order -> Duration.from order.submitTime time |> Quantity.greaterThan (Duration.minutes 30))
                        model.pendingOrders
            in
            ( { model
                | time = time
                , pendingOrders = remainingOrders
                , expiredOrders = SeqDict.union expiredOrders model.expiredOrders
              }
            , Command.batch
                [ Stripe.getPrices |> Task.attempt GotPrices
                , List.map
                    (\stripeSessionId ->
                        Stripe.expireSession stripeSessionId
                            |> Task.attempt (ExpiredStripeSession stripeSessionId)
                    )
                    (SeqDict.keys expiredOrders)
                    |> Command.batch
                ]
            )

        GotPrices result ->
            case result of
                Ok prices ->
                    let
                        dict : SeqDict (Id ProductId) PriceData
                        dict =
                            List.filterMap
                                (\price ->
                                    if price.isActive then
                                        Just ( price.productId, price )

                                    else
                                        Nothing
                                )
                                prices
                                |> SeqDict.fromList
                    in
                    ( { model
                        | prices =
                            case
                                ( SeqDict.get (Id.fromString "prod_TmIy0Mltqmgzg5") dict
                                , SeqDict.get (Id.fromString "prod_TmJ0n8liux9A3d") dict
                                , SeqDict.get (Id.fromString "prod_TmIzrbSouU0bYE") dict
                                )
                            of
                                ( Just campfirePrice, Just singleRoomPrice, Just sharedRoomPrice ) ->
                                    if
                                        (campfirePrice.currency == singleRoomPrice.currency)
                                            && (campfirePrice.currency == sharedRoomPrice.currency)
                                    then
                                        LoadedTicketPrices
                                            campfirePrice.currency
                                            { campfireTicket = campfirePrice.price
                                            , singleRoomTicket = singleRoomPrice.price
                                            , sharedRoomTicket = sharedRoomPrice.price
                                            }

                                    else
                                        TicketCurrenciesDoNotMatch

                                _ ->
                                    FailedToLoadTicketPrices (Http.BadBody "Missing one or more ticket prices")
                      }
                    , Command.none
                    )

                Err error ->
                    ( { model | prices = FailedToLoadTicketPrices error }
                    , errorEmail ("GotPrices failed: " ++ HttpHelpers.httpErrorToString error)
                    )

        OnConnected _ clientId ->
            case model.prices of
                NotLoadingTicketPrices ->
                    ( { model | prices = LoadingTicketPrices }
                    , Command.batch
                        [ Lamdera.sendToFrontend clientId (InitData (Err ()))
                        , Command.batch
                            [ Time.now |> Task.perform GotTime
                            , Effect.Process.sleep Duration.second
                                |> Task.andThen (\() -> Stripe.getPrices)
                                |> Task.attempt GotPrices
                            ]
                        ]
                    )

                LoadedTicketPrices stripeCurrency prices ->
                    ( model
                    , Lamdera.sendToFrontend
                        clientId
                        ({ prices = prices
                         , ticketsAlreadyPurchased = totalTicketCount model.pendingOrders model.orders
                         , ticketsEnabled = model.ticketsEnabled
                         , stripeCurrency = stripeCurrency
                         , currentCurrency = { currency = stripeCurrency, conversionRate = Quantity.unsafe 1 }
                         }
                            |> Ok
                            |> InitData
                        )
                    )

                _ ->
                    ( model, Lamdera.sendToFrontend clientId (InitData (Err ())) )

        CreatedCheckoutSession sessionId clientId purchaseForm result ->
            case result of
                Ok ( stripeSessionId, submitTime ) ->
                    let
                        existingStripeSessions : List (Id StripeSessionId)
                        existingStripeSessions =
                            SeqDict.filter
                                (\_ data -> data.sessionId == sessionId)
                                model.pendingOrders
                                |> SeqDict.keys
                    in
                    ( { model
                        | pendingOrders =
                            SeqDict.insert
                                stripeSessionId
                                { submitTime = submitTime
                                , form = purchaseForm
                                , sessionId = sessionId
                                }
                                model.pendingOrders
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
                        , errorEmail err
                        ]
                    )

        ExpiredStripeSession stripeSessionId result ->
            case result of
                Ok () ->
                    case SeqDict.get stripeSessionId model.pendingOrders of
                        Just expired ->
                            ( { model
                                | pendingOrders = SeqDict.remove stripeSessionId model.pendingOrders
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
                            , errorEmail ("Confirmation email failed: " ++ HttpHelpers.postmarkSendEmailErrorToString error)
                            )

                Nothing ->
                    ( model
                    , errorEmail ("StripeSessionId not found for confirmation email: " ++ Id.toString stripeSessionId)
                    )

        ErrorEmailSent _ ->
            ( model, Command.none )

        OpportunityGrantEmailSent clientId result ->
            ( model
            , Lamdera.sendToFrontend clientId
                (OpportunityGrantSubmitResponse
                    (Result.mapError
                        (\err -> "Failed to send application email: " ++ HttpHelpers.postmarkSendEmailErrorToString err)
                        result
                    )
                )
            )

        StripeWebhookResponse { endpoint, json } ->
            case endpoint of
                "stripe" ->
                    case model.prices of
                        Types.LoadedTicketPrices stripeCurrency _ ->
                            case D.decodeString Stripe.decodeWebhook json of
                                Ok webhook ->
                                    case webhook of
                                        StripeSessionCompleted stripeSessionId paymentId ->
                                            case SeqDict.get stripeSessionId model.pendingOrders of
                                                Just order ->
                                                    let
                                                        { subject, textBody, htmlBody } =
                                                            confirmationEmail order.form stripeCurrency
                                                    in
                                                    ( { model
                                                        | pendingOrders = SeqDict.remove stripeSessionId model.pendingOrders
                                                        , orders =
                                                            SeqDict.insert
                                                                stripeSessionId
                                                                { submitTime = order.submitTime
                                                                , form = order.form
                                                                , emailResult = SendingEmail
                                                                , paymentId = paymentId
                                                                }
                                                                model.orders
                                                      }
                                                    , Postmark.sendEmail
                                                        (ConfirmationEmailSent stripeSessionId)
                                                        Env.postmarkApiKey
                                                        { from = { name = "elm-camp", email = elmCampEmailAddress }
                                                        , to =
                                                            Nonempty
                                                                { name =
                                                                    case order.form.attendees of
                                                                        head :: _ ->
                                                                            Name.toString head.name

                                                                        [] ->
                                                                            "Attendee"
                                                                , email = order.form.billingEmail
                                                                }
                                                                []
                                                        , subject = subject
                                                        , body = Postmark.HtmlAndTextBody htmlBody textBody
                                                        , messageStream = Postmark.TransactionalEmail
                                                        , attachments = Postmark.noAttachments
                                                        }
                                                    )

                                                Nothing ->
                                                    let
                                                        error =
                                                            "Stripe session not found: stripeSessionId: "
                                                                ++ Id.toString stripeSessionId
                                                    in
                                                    ( model, errorEmail error )

                                Err error ->
                                    ( model
                                    , "Failed to decode webhook: " ++ D.errorToString error |> errorEmail
                                    )

                        _ ->
                            ( model
                            , errorEmail "Stripe webhook occurred but prices aren't loaded on the backend"
                            )

                _ ->
                    ( model, Command.none )
    )
        |> (\( newModel, cmd ) ->
                let
                    ticketsAlreadyPurchased : TicketTypes NonNegative
                    ticketsAlreadyPurchased =
                        totalTicketCount newModel.pendingOrders newModel.orders
                in
                if totalTicketCount model.pendingOrders model.orders == ticketsAlreadyPurchased then
                    ( newModel, cmd )

                else
                    ( newModel, Command.batch [ cmd, Lamdera.broadcast (SlotRemainingChanged ticketsAlreadyPurchased) ] )
           )


totalTicketCount :
    SeqDict (Id StripeSessionId) PendingOrder
    -> SeqDict (Id StripeSessionId) CompletedOrder
    -> TicketTypes NonNegative
totalTicketCount pendingOrders orders =
    SeqDict.foldl
        (\_ form count ->
            { campfireTicket = NonNegative.plus count.campfireTicket form.count.campfireTicket
            , singleRoomTicket = NonNegative.plus count.singleRoomTicket form.count.singleRoomTicket
            , sharedRoomTicket = NonNegative.plus count.sharedRoomTicket form.count.sharedRoomTicket
            }
        )
        PurchaseForm.initTicketCount
        (SeqDict.union
            (SeqDict.map (\_ order -> order.form) pendingOrders)
            (SeqDict.map (\_ order -> order.form) orders)
        )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        SubmitFormRequest a ->
            if Duration.from Camp26Czech.ticketSalesOpenAt model.time |> Quantity.lessThanZero then
                ( model, Lamdera.sendToFrontend clientId (SubmitFormResponse (Err "Tickets aren't available for sale yet.")) )

            else
                case ( Untrusted.purchaseForm a, model.ticketsEnabled, model.prices ) of
                    ( Just purchaseForm, TicketsEnabled, LoadedTicketPrices currency prices ) ->
                        let
                            ticketsAvailable : Bool
                            ticketsAvailable =
                                List.map
                                    (\ticket ->
                                        ticket.available purchaseForm.count (totalTicketCount model.pendingOrders model.orders)
                                    )
                                    (PurchaseForm.allTicketTypes Camp26Czech.ticketTypes)
                                    |> List.all identity

                            opportunityGrantItems : List CheckoutItem
                            opportunityGrantItems =
                                if Quantity.greaterThanZero purchaseForm.grantContribution then
                                    [ Stripe.Unpriced
                                        { name = "Opportunity Grant"
                                        , quantity = 1
                                        , currency = Money.toString currency |> String.toLower
                                        , amountDecimal = Quantity.round purchaseForm.grantContribution |> Quantity.unwrap
                                        }
                                    ]

                                else
                                    []
                        in
                        if ticketsAvailable then
                            ( model
                            , Time.now
                                |> Task.andThen
                                    (\now ->
                                        Stripe.createCheckoutSession
                                            { items =
                                                List.map3
                                                    (\ticket price count ->
                                                        Stripe.Priced
                                                            { name = ticket.name
                                                            , priceId = price.priceId
                                                            , quantity = NonNegative.toInt count
                                                            }
                                                    )
                                                    (PurchaseForm.allTicketTypes Camp26Czech.ticketTypes)
                                                    (PurchaseForm.allTicketTypes prices)
                                                    (PurchaseForm.allTicketTypes purchaseForm.count)
                                                    ++ opportunityGrantItems
                                            , emailAddress = purchaseForm.billingEmail
                                            , now = now
                                            , expiresInMinutes = 30
                                            }
                                            |> Task.map (\res -> ( res, now ))
                                    )
                                |> Task.attempt (CreatedCheckoutSession sessionId clientId purchaseForm)
                            )

                        else
                            ( model, Lamdera.sendToFrontend clientId (SubmitFormResponse (Err "Sorry, tickets are sold out.")) )

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

        SubmitOpportunityGrantRequest grantApplication ->
            ( { model | grantApplications = grantApplication :: model.grantApplications }
            , Postmark.sendEmail
                (OpportunityGrantEmailSent clientId)
                Env.postmarkApiKey
                { from = { name = "elm-camp", email = elmCampEmailAddress }
                , to = Nonempty { name = "Elm Camp Team", email = elmCampEmailAddress } []
                , subject = opportunityGrantEmailSubject
                , body = Postmark.TextBody (opportunityGrantEmailBody grantApplication)
                , messageStream = Postmark.TransactionalEmail
                , attachments = Postmark.noAttachments
                }
            )

        AdminInspect pass ->
            if pass == Env.adminPassword then
                ( model
                , Lamdera.sendToFrontend
                    clientId
                    (AdminInspectResponse model (Fusion.Generated.Types.toValue_BackendModel model))
                )

            else
                ( model, Command.none )


sessionIdToStripeSessionId : SessionId -> BackendModel -> Maybe (Id StripeSessionId)
sessionIdToStripeSessionId sessionId model =
    SeqDict.toList model.pendingOrders
        |> List.findMap
            (\( stripeSessionId, data ) ->
                if data.sessionId == sessionId then
                    Just stripeSessionId

                else
                    Nothing
            )


errorEmail : String -> Command BackendOnly ToFrontend BackendMsg
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
            Command.none


elmCampEmailAddress : EmailAddress
elmCampEmailAddress =
    Unsafe.emailAddress "team@elm.camp"


opportunityGrantEmailSubject : NonemptyString
opportunityGrantEmailSubject =
    NonemptyString 'O' "pportunity grant application"


opportunityGrantEmailBody : GrantApplication -> String
opportunityGrantEmailBody { email, message } =
    "New opportunity grant application\n\n"
        ++ "Applicant email: "
        ++ EmailAddress.toString email
        ++ "\n\n"
        ++ (if String.isEmpty (String.trim message) then
                "No message provided."

            else
                "Message:\n\n" ++ message
           )


confirmationEmailSubject : NonemptyString
confirmationEmailSubject =
    NonemptyString 'P' "urchase confirmation"


confirmationEmail : PurchaseFormValidated -> Money.Currency -> { subject : NonemptyString, textBody : String, htmlBody : Html.Html }
confirmationEmail purchaseForm stripeCurrency =
    let
        grantOnly =
            Quantity.greaterThanZero purchaseForm.grantContribution && purchaseForm.count == PurchaseForm.initTicketCount
    in
    { subject = confirmationEmailSubject
    , textBody =
        (if grantOnly then
            "This is a confirmation email for your donation of:\n\n"

         else
            "This is a confirmation email for your purchase of:\n\n"
        )
            ++ (List.map2
                    (\count ticketType ->
                        if count == NonNegative.zero then
                            Nothing

                        else
                            NonNegative.toString count
                                ++ " x "
                                ++ ticketType.name
                                ++ " ("
                                ++ ticketType.description
                                ++ ")\n\n"
                                |> Just
                    )
                    (PurchaseForm.allTicketTypes purchaseForm.count)
                    (PurchaseForm.allTicketTypes Camp26Czech.ticketTypes)
                    |> List.filterMap identity
                    |> String.concat
               )
            ++ (if Quantity.greaterThanZero purchaseForm.grantContribution then
                    Sales.stripePriceText (Quantity.round purchaseForm.grantContribution) { stripeCurrency = stripeCurrency }
                        ++ " grant contribution\n\n"

                else
                    ""
               )
            ++ (if grantOnly then
                    ""

                else
                    "We look forward to seeing you at the elm-camp unconference!\n\n"
               )
            ++ "You can review the schedule at "
            ++ (Env.domain ++ Route.encode (Just Camp26Czech.scheduleSection) HomepageRoute)
            ++ ". If you have any questions, email us at "
            ++ EmailAddress.toString elmCampEmailAddress
            ++ " (or just reply to this email)"
    , htmlBody =
        Html.div
            []
            [ Html.div
                [ Attributes.paddingBottom "16px" ]
                [ if grantOnly then
                    Html.text "This is a confirmation email for your donation of:"

                  else
                    Html.text "This is a confirmation email for your purchase of:"
                ]
            , List.map2
                (\count ticketType ->
                    if count == NonNegative.zero then
                        Nothing

                    else
                        Html.div
                            [ Attributes.paddingBottom "16px" ]
                            [ Html.b [] [ Html.text (NonNegative.toString count ++ " x " ++ ticketType.name) ]
                            , Html.text (" (" ++ ticketType.description ++ ")")
                            ]
                            |> Just
                )
                (PurchaseForm.allTicketTypes purchaseForm.count)
                (PurchaseForm.allTicketTypes Camp26Czech.ticketTypes)
                |> List.filterMap identity
                |> Html.div []
            , if Quantity.greaterThanZero purchaseForm.grantContribution then
                Html.div
                    [ Attributes.paddingBottom "16px" ]
                    [ Html.b
                        []
                        [ Sales.stripePriceText
                            (Quantity.round purchaseForm.grantContribution)
                            { stripeCurrency = stripeCurrency }
                            |> Html.text
                        ]
                    , Html.text " grant contribution\n\n"
                    ]

              else
                Html.text ""
            , if grantOnly then
                Html.text ""

              else
                Html.div [ Attributes.paddingBottom "16px" ] [ Html.text "We look forward to seeing you at the elm-camp unconference!" ]
            , Html.div []
                [ Html.a
                    [ Attributes.href (Env.domain ++ Route.encode (Just Camp26Czech.scheduleSection) HomepageRoute) ]
                    [ Html.text "You can review the schedule here" ]
                , Html.text ". If you have any questions, email us at "
                , Html.a
                    [ Attributes.href ("mailto:" ++ EmailAddress.toString elmCampEmailAddress) ]
                    [ Html.text (EmailAddress.toString elmCampEmailAddress) ]
                , Html.text " (or just reply to this email)"
                ]
            ]
    }
