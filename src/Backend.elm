module Backend exposing
    ( app
    , app_
    , codec
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
import Codec exposing (Codec)
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
import Types exposing (AdminPassword(..), BackendModel, BackendMsg(..), CompletedOrder, EmailResult(..), GrantApplication, PendingOrder, TicketPriceStatus(..), TicketsEnabled(..), ToBackend(..), ToFrontend(..))
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

        AdminInspect (AdminPassword pass) ->
            if pass == Env.adminPassword then
                ( model
                , Lamdera.sendToFrontend
                    clientId
                    (AdminInspectResponse model (Fusion.Generated.Types.toValue_BackendModel model))
                )

            else
                ( model, Command.none )

        BackendModelRequest (AdminPassword password) ->
            if password == Env.adminPassword then
                ( model
                , Codec.encodeToString 0 codec model
                    |> Ok
                    |> BackendModelResponse
                    |> Lamdera.sendToFrontend clientId
                )

            else
                ( model, Err () |> BackendModelResponse |> Lamdera.sendToFrontend clientId )

        ReplaceBackendModelRequest (AdminPassword password) jsonText ->
            if password == Env.adminPassword then
                case Codec.decodeString codec jsonText of
                    Ok newModel ->
                        if
                            (SeqDict.size newModel.orders + SeqDict.size newModel.pendingOrders + SeqDict.size newModel.expiredOrders)
                                == (SeqDict.size newModel.orders + SeqDict.size newModel.pendingOrders + SeqDict.size newModel.expiredOrders)
                        then
                            ( { newModel | time = model.time }
                            , ReplaceBackendModelResponse (Ok ()) |> Lamdera.sendToFrontend clientId
                            )

                        else
                            ( model
                            , Err "orders + pendingOrders + expiredOrders can't change. Maybe someone added an order while you were editing?"
                                |> ReplaceBackendModelResponse
                                |> Lamdera.sendToFrontend clientId
                            )

                    Err error ->
                        ( model
                        , Err (D.errorToString error)
                            |> ReplaceBackendModelResponse
                            |> Lamdera.sendToFrontend clientId
                        )

            else
                ( model, Err "Invalid password" |> ReplaceBackendModelResponse |> Lamdera.sendToFrontend clientId )


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


codec : Codec BackendModel
codec =
    Codec.object BackendModel
        |> Codec.field "orders" .orders (seqDictCodec Id.codec completedOrderCodec)
        |> Codec.field "pendingOrders" .pendingOrders (seqDictCodec Id.codec pendingOrderCodec)
        |> Codec.field "expiredOrders" .expiredOrders (seqDictCodec Id.codec pendingOrderCodec)
        |> Codec.field "prices" .prices ticketPriceStatusCodec
        |> Codec.field "time" .time timeCodec
        |> Codec.field "ticketsEnabled" .ticketsEnabled ticketsEnabledCodec
        |> Codec.field "grantApplications" .grantApplications (Codec.list grantApplicationCodec)
        |> Codec.buildObject


seqDictCodec : Codec a -> Codec b -> Codec (SeqDict a b)
seqDictCodec keyCodec valueCodec =
    Codec.map
        SeqDict.fromList
        SeqDict.toList
        (Codec.list (Codec.tuple keyCodec valueCodec))


completedOrderCodec : Codec CompletedOrder
completedOrderCodec =
    Codec.object CompletedOrder
        |> Codec.field "submitTime" .submitTime timeCodec
        |> Codec.field "form" .form purchaseFormValidatedCodec
        |> Codec.field "emailResult" .emailResult emailResultCodec
        |> Codec.field "paymentId" .paymentId Id.codec
        |> Codec.buildObject


purchaseFormValidatedCodec : Codec PurchaseFormValidated
purchaseFormValidatedCodec =
    Codec.object PurchaseFormValidated
        |> Codec.field "attendees" .attendees (Codec.list attendeeFormValidatedCodec)
        |> Codec.field "count" .count (ticketTypesCodec nonNegativeCodec)
        |> Codec.field "billingEmail" .billingEmail emailAddressCodec
        |> Codec.field "grantContribution" .grantContribution quantityCodecFloat
        |> Codec.buildObject


attendeeFormValidatedCodec : Codec PurchaseForm.AttendeeFormValidated
attendeeFormValidatedCodec =
    Codec.object PurchaseForm.AttendeeFormValidated
        |> Codec.field "name" .name Name.codec
        |> Codec.field "country" .country nonemptyStringCodec
        |> Codec.field "originCity" .originCity nonemptyStringCodec
        |> Codec.buildObject


nonemptyStringCodec : Codec NonemptyString
nonemptyStringCodec =
    Codec.custom
        (\nonemptyStringEncoder value ->
            case value of
                String.Nonempty.NonemptyString argA argB ->
                    nonemptyStringEncoder argA argB
        )
        |> Codec.variant2 "NonemptyString" NonemptyString Codec.char Codec.string
        |> Codec.buildCustom


nonNegativeCodec : Codec NonNegative
nonNegativeCodec =
    Codec.andThen
        (\text ->
            case NonNegative.fromInt text of
                Ok uint ->
                    Codec.succeed uint

                Err _ ->
                    Codec.fail "Value can't be negative"
        )
        NonNegative.toInt
        Codec.int


quantityCodecFloat : Codec (Quantity.Quantity Float units)
quantityCodecFloat =
    Codec.map Quantity.unsafe Quantity.unwrap Codec.float


quantityCodecInt : Codec (Quantity.Quantity Int units)
quantityCodecInt =
    Codec.map Quantity.unsafe Quantity.unwrap Codec.int


emailResultCodec : Codec EmailResult
emailResultCodec =
    Codec.custom
        (\sendingEmailEncoder emailSuccessEncoder emailFailedEncoder value ->
            case value of
                Types.SendingEmail ->
                    sendingEmailEncoder

                Types.EmailSuccess ->
                    emailSuccessEncoder

                Types.EmailFailed argA ->
                    emailFailedEncoder argA
        )
        |> Codec.variant0 "SendingEmail" Types.SendingEmail
        |> Codec.variant0 "EmailSuccess" Types.EmailSuccess
        |> Codec.variant1 "EmailFailed" Types.EmailFailed sendEmailErrorCodec
        |> Codec.buildCustom


sendEmailErrorCodec : Codec Postmark.SendEmailError
sendEmailErrorCodec =
    Codec.custom
        (\unknownErrorEncoder postmarkErrorEncoder networkErrorEncoder timeoutEncoder badUrlEncoder value ->
            case value of
                Postmark.UnknownError argA ->
                    unknownErrorEncoder argA

                Postmark.PostmarkError argA ->
                    postmarkErrorEncoder argA

                Postmark.NetworkError ->
                    networkErrorEncoder

                Postmark.Timeout ->
                    timeoutEncoder

                Postmark.BadUrl argA ->
                    badUrlEncoder argA
        )
        |> Codec.variant1 "UnknownError" Postmark.UnknownError unknownErrorDataCodec
        |> Codec.variant1 "PostmarkError" Postmark.PostmarkError postmarkError_Codec
        |> Codec.variant0 "NetworkError" Postmark.NetworkError
        |> Codec.variant0 "Timeout" Postmark.Timeout
        |> Codec.variant1 "BadUrl" Postmark.BadUrl Codec.string
        |> Codec.buildCustom


unknownErrorDataCodec : Codec Postmark.UnknownErrorData
unknownErrorDataCodec =
    Codec.object Postmark.UnknownErrorData
        |> Codec.field "statusCode" .statusCode Codec.int
        |> Codec.field "body" .body Codec.string
        |> Codec.buildObject


postmarkError_Codec : Codec Postmark.PostmarkError_
postmarkError_Codec =
    Codec.object Postmark.PostmarkError_
        |> Codec.field "errorCode" .errorCode Codec.int
        |> Codec.field "message" .message Codec.string
        |> Codec.field "to" .to (Codec.list emailAddressCodec)
        |> Codec.buildObject


pendingOrderCodec : Codec PendingOrder
pendingOrderCodec =
    Codec.object PendingOrder
        |> Codec.field "submitTime" .submitTime timeCodec
        |> Codec.field "form" .form purchaseFormValidatedCodec
        |> Codec.field "sessionId" .sessionId sessionIdCodec
        |> Codec.buildObject


sessionIdCodec : Codec SessionId
sessionIdCodec =
    Codec.map Lamdera.sessionIdFromString Lamdera.sessionIdToString Codec.string


ticketPriceStatusCodec : Codec TicketPriceStatus
ticketPriceStatusCodec =
    Codec.custom
        (\notLoadingTicketPricesEncoder loadingTicketPricesEncoder loadedTicketPricesEncoder failedToLoadTicketPricesEncoder ticketCurrenciesDoNotMatchEncoder value ->
            case value of
                Types.NotLoadingTicketPrices ->
                    notLoadingTicketPricesEncoder

                Types.LoadingTicketPrices ->
                    loadingTicketPricesEncoder

                Types.LoadedTicketPrices argA argB ->
                    loadedTicketPricesEncoder argA argB

                Types.FailedToLoadTicketPrices argA ->
                    failedToLoadTicketPricesEncoder argA

                Types.TicketCurrenciesDoNotMatch ->
                    ticketCurrenciesDoNotMatchEncoder
        )
        |> Codec.variant0 "NotLoadingTicketPrices" Types.NotLoadingTicketPrices
        |> Codec.variant0 "LoadingTicketPrices" Types.LoadingTicketPrices
        |> Codec.variant2 "LoadedTicketPrices" Types.LoadedTicketPrices currencyCodec (ticketTypesCodec priceCodec)
        |> Codec.variant1 "FailedToLoadTicketPrices" Types.FailedToLoadTicketPrices errorCodec
        |> Codec.variant0 "TicketCurrenciesDoNotMatch" Types.TicketCurrenciesDoNotMatch
        |> Codec.buildCustom


priceCodec : Codec Price
priceCodec =
    Codec.object Price
        |> Codec.field "priceId" .priceId Id.codec
        |> Codec.field "amount" .amount quantityCodecInt
        |> Codec.buildObject


currencyCodec : Codec Money.Currency
currencyCodec =
    Codec.custom
        (\uSDEncoder cADEncoder eUREncoder bTCEncoder aEDEncoder aFNEncoder aLLEncoder aMDEncoder aRSEncoder aUDEncoder aZNEncoder bAMEncoder bDTEncoder bGNEncoder bHDEncoder bIFEncoder bNDEncoder bOBEncoder bRLEncoder bWPEncoder bYNEncoder bZDEncoder cDFEncoder cHFEncoder cLPEncoder cNYEncoder cOPEncoder cRCEncoder cVEEncoder cZKEncoder dJFEncoder dKKEncoder dOPEncoder dZDEncoder eEKEncoder eGPEncoder eRNEncoder eTBEncoder gBPEncoder gELEncoder gHSEncoder gNFEncoder gTQEncoder hKDEncoder hNLEncoder hRKEncoder hUFEncoder iDREncoder iLSEncoder iNREncoder iQDEncoder iRREncoder iSKEncoder jMDEncoder jODEncoder jPYEncoder kESEncoder kHREncoder kMFEncoder kRWEncoder kWDEncoder kZTEncoder lAKEncoder lBPEncoder lKREncoder lTLEncoder lVLEncoder lYDEncoder mADEncoder mDLEncoder mGAEncoder mKDEncoder mMKEncoder mOPEncoder mUREncoder mXNEncoder mYREncoder mZNEncoder nADEncoder nGNEncoder nIOEncoder nOKEncoder nPREncoder nZDEncoder oMREncoder pABEncoder pENEncoder pHPEncoder pKREncoder pLNEncoder pYGEncoder qAREncoder rONEncoder rSDEncoder rUBEncoder rWFEncoder sAREncoder sDGEncoder sEKEncoder sGDEncoder sOSEncoder sYPEncoder tHBEncoder tNDEncoder tOPEncoder tRYEncoder tTDEncoder tWDEncoder tZSEncoder uAHEncoder uGXEncoder uYUEncoder uZSEncoder vEDEncoder vNDEncoder xAFEncoder xOFEncoder yEREncoder zAREncoder zMKEncoder aOAEncoder xCDEncoder aWGEncoder bSDEncoder bBDEncoder bMDEncoder bTNEncoder kYDEncoder cUPEncoder aNGEncoder sZLEncoder fKPEncoder fJDEncoder xPFEncoder gMDEncoder gIPEncoder gYDEncoder hTGEncoder kPWEncoder kGSEncoder lSLEncoder lRDEncoder mWKEncoder mVREncoder mRUEncoder mNTEncoder pGKEncoder sHPEncoder wSTEncoder sTNEncoder sCREncoder sLEEncoder sBDEncoder sSPEncoder sRDEncoder tJSEncoder tMTEncoder vUVEncoder vESEncoder zMWEncoder zWLEncoder value ->
            case value of
                Money.USD ->
                    uSDEncoder

                Money.CAD ->
                    cADEncoder

                Money.EUR ->
                    eUREncoder

                Money.BTC ->
                    bTCEncoder

                Money.AED ->
                    aEDEncoder

                Money.AFN ->
                    aFNEncoder

                Money.ALL ->
                    aLLEncoder

                Money.AMD ->
                    aMDEncoder

                Money.ARS ->
                    aRSEncoder

                Money.AUD ->
                    aUDEncoder

                Money.AZN ->
                    aZNEncoder

                Money.BAM ->
                    bAMEncoder

                Money.BDT ->
                    bDTEncoder

                Money.BGN ->
                    bGNEncoder

                Money.BHD ->
                    bHDEncoder

                Money.BIF ->
                    bIFEncoder

                Money.BND ->
                    bNDEncoder

                Money.BOB ->
                    bOBEncoder

                Money.BRL ->
                    bRLEncoder

                Money.BWP ->
                    bWPEncoder

                Money.BYN ->
                    bYNEncoder

                Money.BZD ->
                    bZDEncoder

                Money.CDF ->
                    cDFEncoder

                Money.CHF ->
                    cHFEncoder

                Money.CLP ->
                    cLPEncoder

                Money.CNY ->
                    cNYEncoder

                Money.COP ->
                    cOPEncoder

                Money.CRC ->
                    cRCEncoder

                Money.CVE ->
                    cVEEncoder

                Money.CZK ->
                    cZKEncoder

                Money.DJF ->
                    dJFEncoder

                Money.DKK ->
                    dKKEncoder

                Money.DOP ->
                    dOPEncoder

                Money.DZD ->
                    dZDEncoder

                Money.EEK ->
                    eEKEncoder

                Money.EGP ->
                    eGPEncoder

                Money.ERN ->
                    eRNEncoder

                Money.ETB ->
                    eTBEncoder

                Money.GBP ->
                    gBPEncoder

                Money.GEL ->
                    gELEncoder

                Money.GHS ->
                    gHSEncoder

                Money.GNF ->
                    gNFEncoder

                Money.GTQ ->
                    gTQEncoder

                Money.HKD ->
                    hKDEncoder

                Money.HNL ->
                    hNLEncoder

                Money.HRK ->
                    hRKEncoder

                Money.HUF ->
                    hUFEncoder

                Money.IDR ->
                    iDREncoder

                Money.ILS ->
                    iLSEncoder

                Money.INR ->
                    iNREncoder

                Money.IQD ->
                    iQDEncoder

                Money.IRR ->
                    iRREncoder

                Money.ISK ->
                    iSKEncoder

                Money.JMD ->
                    jMDEncoder

                Money.JOD ->
                    jODEncoder

                Money.JPY ->
                    jPYEncoder

                Money.KES ->
                    kESEncoder

                Money.KHR ->
                    kHREncoder

                Money.KMF ->
                    kMFEncoder

                Money.KRW ->
                    kRWEncoder

                Money.KWD ->
                    kWDEncoder

                Money.KZT ->
                    kZTEncoder

                Money.LAK ->
                    lAKEncoder

                Money.LBP ->
                    lBPEncoder

                Money.LKR ->
                    lKREncoder

                Money.LTL ->
                    lTLEncoder

                Money.LVL ->
                    lVLEncoder

                Money.LYD ->
                    lYDEncoder

                Money.MAD ->
                    mADEncoder

                Money.MDL ->
                    mDLEncoder

                Money.MGA ->
                    mGAEncoder

                Money.MKD ->
                    mKDEncoder

                Money.MMK ->
                    mMKEncoder

                Money.MOP ->
                    mOPEncoder

                Money.MUR ->
                    mUREncoder

                Money.MXN ->
                    mXNEncoder

                Money.MYR ->
                    mYREncoder

                Money.MZN ->
                    mZNEncoder

                Money.NAD ->
                    nADEncoder

                Money.NGN ->
                    nGNEncoder

                Money.NIO ->
                    nIOEncoder

                Money.NOK ->
                    nOKEncoder

                Money.NPR ->
                    nPREncoder

                Money.NZD ->
                    nZDEncoder

                Money.OMR ->
                    oMREncoder

                Money.PAB ->
                    pABEncoder

                Money.PEN ->
                    pENEncoder

                Money.PHP ->
                    pHPEncoder

                Money.PKR ->
                    pKREncoder

                Money.PLN ->
                    pLNEncoder

                Money.PYG ->
                    pYGEncoder

                Money.QAR ->
                    qAREncoder

                Money.RON ->
                    rONEncoder

                Money.RSD ->
                    rSDEncoder

                Money.RUB ->
                    rUBEncoder

                Money.RWF ->
                    rWFEncoder

                Money.SAR ->
                    sAREncoder

                Money.SDG ->
                    sDGEncoder

                Money.SEK ->
                    sEKEncoder

                Money.SGD ->
                    sGDEncoder

                Money.SOS ->
                    sOSEncoder

                Money.SYP ->
                    sYPEncoder

                Money.THB ->
                    tHBEncoder

                Money.TND ->
                    tNDEncoder

                Money.TOP ->
                    tOPEncoder

                Money.TRY ->
                    tRYEncoder

                Money.TTD ->
                    tTDEncoder

                Money.TWD ->
                    tWDEncoder

                Money.TZS ->
                    tZSEncoder

                Money.UAH ->
                    uAHEncoder

                Money.UGX ->
                    uGXEncoder

                Money.UYU ->
                    uYUEncoder

                Money.UZS ->
                    uZSEncoder

                Money.VED ->
                    vEDEncoder

                Money.VND ->
                    vNDEncoder

                Money.XAF ->
                    xAFEncoder

                Money.XOF ->
                    xOFEncoder

                Money.YER ->
                    yEREncoder

                Money.ZAR ->
                    zAREncoder

                Money.ZMK ->
                    zMKEncoder

                Money.AOA ->
                    aOAEncoder

                Money.XCD ->
                    xCDEncoder

                Money.AWG ->
                    aWGEncoder

                Money.BSD ->
                    bSDEncoder

                Money.BBD ->
                    bBDEncoder

                Money.BMD ->
                    bMDEncoder

                Money.BTN ->
                    bTNEncoder

                Money.KYD ->
                    kYDEncoder

                Money.CUP ->
                    cUPEncoder

                Money.ANG ->
                    aNGEncoder

                Money.SZL ->
                    sZLEncoder

                Money.FKP ->
                    fKPEncoder

                Money.FJD ->
                    fJDEncoder

                Money.XPF ->
                    xPFEncoder

                Money.GMD ->
                    gMDEncoder

                Money.GIP ->
                    gIPEncoder

                Money.GYD ->
                    gYDEncoder

                Money.HTG ->
                    hTGEncoder

                Money.KPW ->
                    kPWEncoder

                Money.KGS ->
                    kGSEncoder

                Money.LSL ->
                    lSLEncoder

                Money.LRD ->
                    lRDEncoder

                Money.MWK ->
                    mWKEncoder

                Money.MVR ->
                    mVREncoder

                Money.MRU ->
                    mRUEncoder

                Money.MNT ->
                    mNTEncoder

                Money.PGK ->
                    pGKEncoder

                Money.SHP ->
                    sHPEncoder

                Money.WST ->
                    wSTEncoder

                Money.STN ->
                    sTNEncoder

                Money.SCR ->
                    sCREncoder

                Money.SLE ->
                    sLEEncoder

                Money.SBD ->
                    sBDEncoder

                Money.SSP ->
                    sSPEncoder

                Money.SRD ->
                    sRDEncoder

                Money.TJS ->
                    tJSEncoder

                Money.TMT ->
                    tMTEncoder

                Money.VUV ->
                    vUVEncoder

                Money.VES ->
                    vESEncoder

                Money.ZMW ->
                    zMWEncoder

                Money.ZWL ->
                    zWLEncoder
        )
        |> Codec.variant0 "USD" Money.USD
        |> Codec.variant0 "CAD" Money.CAD
        |> Codec.variant0 "EUR" Money.EUR
        |> Codec.variant0 "BTC" Money.BTC
        |> Codec.variant0 "AED" Money.AED
        |> Codec.variant0 "AFN" Money.AFN
        |> Codec.variant0 "ALL" Money.ALL
        |> Codec.variant0 "AMD" Money.AMD
        |> Codec.variant0 "ARS" Money.ARS
        |> Codec.variant0 "AUD" Money.AUD
        |> Codec.variant0 "AZN" Money.AZN
        |> Codec.variant0 "BAM" Money.BAM
        |> Codec.variant0 "BDT" Money.BDT
        |> Codec.variant0 "BGN" Money.BGN
        |> Codec.variant0 "BHD" Money.BHD
        |> Codec.variant0 "BIF" Money.BIF
        |> Codec.variant0 "BND" Money.BND
        |> Codec.variant0 "BOB" Money.BOB
        |> Codec.variant0 "BRL" Money.BRL
        |> Codec.variant0 "BWP" Money.BWP
        |> Codec.variant0 "BYN" Money.BYN
        |> Codec.variant0 "BZD" Money.BZD
        |> Codec.variant0 "CDF" Money.CDF
        |> Codec.variant0 "CHF" Money.CHF
        |> Codec.variant0 "CLP" Money.CLP
        |> Codec.variant0 "CNY" Money.CNY
        |> Codec.variant0 "COP" Money.COP
        |> Codec.variant0 "CRC" Money.CRC
        |> Codec.variant0 "CVE" Money.CVE
        |> Codec.variant0 "CZK" Money.CZK
        |> Codec.variant0 "DJF" Money.DJF
        |> Codec.variant0 "DKK" Money.DKK
        |> Codec.variant0 "DOP" Money.DOP
        |> Codec.variant0 "DZD" Money.DZD
        |> Codec.variant0 "EEK" Money.EEK
        |> Codec.variant0 "EGP" Money.EGP
        |> Codec.variant0 "ERN" Money.ERN
        |> Codec.variant0 "ETB" Money.ETB
        |> Codec.variant0 "GBP" Money.GBP
        |> Codec.variant0 "GEL" Money.GEL
        |> Codec.variant0 "GHS" Money.GHS
        |> Codec.variant0 "GNF" Money.GNF
        |> Codec.variant0 "GTQ" Money.GTQ
        |> Codec.variant0 "HKD" Money.HKD
        |> Codec.variant0 "HNL" Money.HNL
        |> Codec.variant0 "HRK" Money.HRK
        |> Codec.variant0 "HUF" Money.HUF
        |> Codec.variant0 "IDR" Money.IDR
        |> Codec.variant0 "ILS" Money.ILS
        |> Codec.variant0 "INR" Money.INR
        |> Codec.variant0 "IQD" Money.IQD
        |> Codec.variant0 "IRR" Money.IRR
        |> Codec.variant0 "ISK" Money.ISK
        |> Codec.variant0 "JMD" Money.JMD
        |> Codec.variant0 "JOD" Money.JOD
        |> Codec.variant0 "JPY" Money.JPY
        |> Codec.variant0 "KES" Money.KES
        |> Codec.variant0 "KHR" Money.KHR
        |> Codec.variant0 "KMF" Money.KMF
        |> Codec.variant0 "KRW" Money.KRW
        |> Codec.variant0 "KWD" Money.KWD
        |> Codec.variant0 "KZT" Money.KZT
        |> Codec.variant0 "LAK" Money.LAK
        |> Codec.variant0 "LBP" Money.LBP
        |> Codec.variant0 "LKR" Money.LKR
        |> Codec.variant0 "LTL" Money.LTL
        |> Codec.variant0 "LVL" Money.LVL
        |> Codec.variant0 "LYD" Money.LYD
        |> Codec.variant0 "MAD" Money.MAD
        |> Codec.variant0 "MDL" Money.MDL
        |> Codec.variant0 "MGA" Money.MGA
        |> Codec.variant0 "MKD" Money.MKD
        |> Codec.variant0 "MMK" Money.MMK
        |> Codec.variant0 "MOP" Money.MOP
        |> Codec.variant0 "MUR" Money.MUR
        |> Codec.variant0 "MXN" Money.MXN
        |> Codec.variant0 "MYR" Money.MYR
        |> Codec.variant0 "MZN" Money.MZN
        |> Codec.variant0 "NAD" Money.NAD
        |> Codec.variant0 "NGN" Money.NGN
        |> Codec.variant0 "NIO" Money.NIO
        |> Codec.variant0 "NOK" Money.NOK
        |> Codec.variant0 "NPR" Money.NPR
        |> Codec.variant0 "NZD" Money.NZD
        |> Codec.variant0 "OMR" Money.OMR
        |> Codec.variant0 "PAB" Money.PAB
        |> Codec.variant0 "PEN" Money.PEN
        |> Codec.variant0 "PHP" Money.PHP
        |> Codec.variant0 "PKR" Money.PKR
        |> Codec.variant0 "PLN" Money.PLN
        |> Codec.variant0 "PYG" Money.PYG
        |> Codec.variant0 "QAR" Money.QAR
        |> Codec.variant0 "RON" Money.RON
        |> Codec.variant0 "RSD" Money.RSD
        |> Codec.variant0 "RUB" Money.RUB
        |> Codec.variant0 "RWF" Money.RWF
        |> Codec.variant0 "SAR" Money.SAR
        |> Codec.variant0 "SDG" Money.SDG
        |> Codec.variant0 "SEK" Money.SEK
        |> Codec.variant0 "SGD" Money.SGD
        |> Codec.variant0 "SOS" Money.SOS
        |> Codec.variant0 "SYP" Money.SYP
        |> Codec.variant0 "THB" Money.THB
        |> Codec.variant0 "TND" Money.TND
        |> Codec.variant0 "TOP" Money.TOP
        |> Codec.variant0 "TRY" Money.TRY
        |> Codec.variant0 "TTD" Money.TTD
        |> Codec.variant0 "TWD" Money.TWD
        |> Codec.variant0 "TZS" Money.TZS
        |> Codec.variant0 "UAH" Money.UAH
        |> Codec.variant0 "UGX" Money.UGX
        |> Codec.variant0 "UYU" Money.UYU
        |> Codec.variant0 "UZS" Money.UZS
        |> Codec.variant0 "VED" Money.VED
        |> Codec.variant0 "VND" Money.VND
        |> Codec.variant0 "XAF" Money.XAF
        |> Codec.variant0 "XOF" Money.XOF
        |> Codec.variant0 "YER" Money.YER
        |> Codec.variant0 "ZAR" Money.ZAR
        |> Codec.variant0 "ZMK" Money.ZMK
        |> Codec.variant0 "AOA" Money.AOA
        |> Codec.variant0 "XCD" Money.XCD
        |> Codec.variant0 "AWG" Money.AWG
        |> Codec.variant0 "BSD" Money.BSD
        |> Codec.variant0 "BBD" Money.BBD
        |> Codec.variant0 "BMD" Money.BMD
        |> Codec.variant0 "BTN" Money.BTN
        |> Codec.variant0 "KYD" Money.KYD
        |> Codec.variant0 "CUP" Money.CUP
        |> Codec.variant0 "ANG" Money.ANG
        |> Codec.variant0 "SZL" Money.SZL
        |> Codec.variant0 "FKP" Money.FKP
        |> Codec.variant0 "FJD" Money.FJD
        |> Codec.variant0 "XPF" Money.XPF
        |> Codec.variant0 "GMD" Money.GMD
        |> Codec.variant0 "GIP" Money.GIP
        |> Codec.variant0 "GYD" Money.GYD
        |> Codec.variant0 "HTG" Money.HTG
        |> Codec.variant0 "KPW" Money.KPW
        |> Codec.variant0 "KGS" Money.KGS
        |> Codec.variant0 "LSL" Money.LSL
        |> Codec.variant0 "LRD" Money.LRD
        |> Codec.variant0 "MWK" Money.MWK
        |> Codec.variant0 "MVR" Money.MVR
        |> Codec.variant0 "MRU" Money.MRU
        |> Codec.variant0 "MNT" Money.MNT
        |> Codec.variant0 "PGK" Money.PGK
        |> Codec.variant0 "SHP" Money.SHP
        |> Codec.variant0 "WST" Money.WST
        |> Codec.variant0 "STN" Money.STN
        |> Codec.variant0 "SCR" Money.SCR
        |> Codec.variant0 "SLE" Money.SLE
        |> Codec.variant0 "SBD" Money.SBD
        |> Codec.variant0 "SSP" Money.SSP
        |> Codec.variant0 "SRD" Money.SRD
        |> Codec.variant0 "TJS" Money.TJS
        |> Codec.variant0 "TMT" Money.TMT
        |> Codec.variant0 "VUV" Money.VUV
        |> Codec.variant0 "VES" Money.VES
        |> Codec.variant0 "ZMW" Money.ZMW
        |> Codec.variant0 "ZWL" Money.ZWL
        |> Codec.buildCustom


ticketTypesCodec : Codec a -> Codec (TicketTypes a)
ticketTypesCodec a =
    Codec.object TicketTypes
        |> Codec.field "campfireTicket" .campfireTicket a
        |> Codec.field "singleRoomTicket" .singleRoomTicket a
        |> Codec.field "sharedRoomTicket" .sharedRoomTicket a
        |> Codec.buildObject


errorCodec : Codec Http.Error
errorCodec =
    Codec.custom
        (\badUrlEncoder timeoutEncoder networkErrorEncoder badStatusEncoder badBodyEncoder value ->
            case value of
                Http.BadUrl argA ->
                    badUrlEncoder argA

                Http.Timeout ->
                    timeoutEncoder

                Http.NetworkError ->
                    networkErrorEncoder

                Http.BadStatus argA ->
                    badStatusEncoder argA

                Http.BadBody argA ->
                    badBodyEncoder argA
        )
        |> Codec.variant1 "BadUrl" Http.BadUrl Codec.string
        |> Codec.variant0 "Timeout" Http.Timeout
        |> Codec.variant0 "NetworkError" Http.NetworkError
        |> Codec.variant1 "BadStatus" Http.BadStatus Codec.int
        |> Codec.variant1 "BadBody" Http.BadBody Codec.string
        |> Codec.buildCustom


timeCodec : Codec Time.Posix
timeCodec =
    Codec.map Time.millisToPosix Time.posixToMillis Codec.int


ticketsEnabledCodec : Codec TicketsEnabled
ticketsEnabledCodec =
    Codec.custom
        (\ticketsEnabledEncoder ticketsDisabledEncoder value ->
            case value of
                Types.TicketsEnabled ->
                    ticketsEnabledEncoder

                Types.TicketsDisabled argA ->
                    ticketsDisabledEncoder argA
        )
        |> Codec.variant0 "TicketsEnabled" TicketsEnabled
        |> Codec.variant1 "TicketsDisabled" Types.TicketsDisabled ticketsDisabledDataCodec
        |> Codec.buildCustom


ticketsDisabledDataCodec : Codec Types.TicketsDisabledData
ticketsDisabledDataCodec =
    Codec.object Types.TicketsDisabledData |> Codec.field "adminMessage" .adminMessage Codec.string |> Codec.buildObject


grantApplicationCodec : Codec GrantApplication
grantApplicationCodec =
    Codec.object GrantApplication
        |> Codec.field "email" .email emailAddressCodec
        |> Codec.field "message" .message Codec.string
        |> Codec.buildObject


emailAddressCodec : Codec EmailAddress
emailAddressCodec =
    Codec.andThen
        (\text ->
            case EmailAddress.fromString text of
                Just email ->
                    Codec.succeed email

                Nothing ->
                    Codec.fail ("Invalid email: " ++ text)
        )
        EmailAddress.toString
        Codec.string
