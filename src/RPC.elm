module RPC exposing
    ( backendModelEndpoint
    , badReq
    , confirmationEmail
    , lamdera_handleEndpoints
    , purchaseCompletedEndpoint
    , requestPurchaseCompletedEndpoint
    )

import Backend
import Camp26Czech exposing (TicketType)
import Email.Html as Html
import Email.Html.Attributes as Attributes
import EmailAddress exposing (EmailAddress)
import Env
import Http as HttpCore
import Id
import Json.Decode as D
import Json.Encode as E
import Lamdera as LamderaCore exposing (SessionId)
import Lamdera.Json as Json
import Lamdera.Wire3 as Wire3
import LamderaRPC exposing (Headers, HttpBody(..), HttpRequest, RPCResult(..), StatusCode(..))
import List.Nonempty exposing (Nonempty(..))
import Money
import Name
import NonNegative
import Postmark
import PurchaseForm exposing (PurchaseFormValidated)
import Quantity
import SeqDict
import String.Nonempty exposing (NonemptyString(..))
import Stripe exposing (Webhook(..))
import Task exposing (Task)
import Types exposing (BackendModel, BackendMsg(..), EmailResult(..), TicketsEnabled(..), ToFrontend(..))
import View.Sales


backendModelEndpoint : SessionId -> BackendModel -> HttpRequest -> ( RPCResult, BackendModel, Cmd BackendMsg )
backendModelEndpoint _ model request =
    case request.body of
        BodyJson json ->
            case D.decodeValue D.string json of
                Ok ok ->
                    if ok == Env.adminPassword then
                        ( ResultBytes (Wire3.intListFromBytes (Wire3.bytesEncode (Types.w3_encode_BackendModel model))), model, Cmd.none )

                    else
                        ( badReq "Invalid admin password", model, Cmd.none )

                Err _ ->
                    ( badReq "Expected request body to look like this: \"SECRET_KEY\"", model, Cmd.none )

        _ ->
            ( badReq "Expected request body to be JSON", model, Cmd.none )


badReq : String -> RPCResult
badReq reason =
    LamderaRPC.resultWith StatusBadRequest [] (BodyString reason)


purchaseCompletedEndpoint :
    SessionId
    -> BackendModel
    -> Headers
    -> String
    -> ( Result HttpCore.Error String, BackendModel, Cmd BackendMsg )
purchaseCompletedEndpoint _ model headers json =
    let
        response =
            if Env.isProduction then
                Ok "prod"

            else
                Ok "dev"
    in
    case model.prices of
        Types.LoadedTicketPrices stripeCurrency _ ->
            case D.decodeString Stripe.decodeWebhook json |> Debug.log "b" of
                Ok webhook ->
                    case webhook of
                        StripeSessionCompleted stripeSessionId ->
                            case SeqDict.get stripeSessionId model.pendingOrder |> Debug.log "a" of
                                Just order ->
                                    let
                                        { subject, textBody, htmlBody } =
                                            confirmationEmail order.form stripeCurrency
                                    in
                                    ( response
                                    , { model
                                        | pendingOrder = SeqDict.remove stripeSessionId model.pendingOrder
                                        , orders =
                                            SeqDict.insert
                                                stripeSessionId
                                                { submitTime = order.submitTime
                                                , form = order.form
                                                , emailResult = SendingEmail
                                                }
                                                model.orders
                                      }
                                    , Postmark.sendEmail
                                        (ConfirmationEmailSent stripeSessionId)
                                        Env.postmarkApiKey
                                        { from = { name = "elm-camp", email = Backend.elmCampEmailAddress }
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
                                    ( Err (HttpCore.BadBody error), model, Backend.errorEmail error )

                Err error ->
                    let
                        errorText =
                            "Failed to decode webhook: "
                                ++ D.errorToString error
                    in
                    ( Err (HttpCore.BadBody errorText), model, Backend.errorEmail errorText )

        _ ->
            ( Err (HttpCore.BadBody "Internal error")
            , model
            , Backend.errorEmail "Stripe webhook occurred but prices aren't loaded on the backend"
            )


confirmationEmail : PurchaseFormValidated -> Money.Currency -> { subject : NonemptyString, textBody : String, htmlBody : Html.Html }
confirmationEmail purchaseForm stripeCurrency =
    { subject = NonemptyString 'P' "urchase confirmation"
    , textBody =
        "This is a confirmation email for your purchase of:\n\n"
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
                    |> String.join ""
               )
            ++ (if Quantity.greaterThanZero purchaseForm.grantContribution then
                    View.Sales.stripePriceText (Quantity.round purchaseForm.grantContribution) { stripeCurrency = stripeCurrency }
                        ++ " grant contribution\n\n"

                else
                    ""
               )
            ++ "We look forward to seeing you at the elm-camp unconference!\n\n"
            ++ "You can review the schedule at "
            ++ Env.domain
            ++ "/#schedule"
            ++ ". If you have any questions, email us at "
            ++ EmailAddress.toString Backend.elmCampEmailAddress
            ++ " (or just reply to this email)"
    , htmlBody =
        Html.div
            []
            [ Html.div
                [ Attributes.paddingBottom "16px" ]
                [ Html.text "This is a confirmation email for your purchase of:"
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
                        [ View.Sales.stripePriceText
                            (Quantity.round purchaseForm.grantContribution)
                            { stripeCurrency = stripeCurrency }
                            |> Html.text
                        ]
                    , Html.text " grant contribution\n\n"
                    ]

              else
                Html.text ""
            , Html.div [ Attributes.paddingBottom "16px" ] [ Html.text "We look forward to seeing you at the elm-camp unconference!" ]
            , Html.div []
                [ Html.a
                    [ Attributes.href (Env.domain ++ "/#schedule") ]
                    [ Html.text "You can review the schedule here" ]
                , Html.text ". If you have any questions, email us at "
                , Html.a
                    [ Attributes.href ("mailto:" ++ EmailAddress.toString Backend.elmCampEmailAddress) ]
                    [ Html.text (EmailAddress.toString Backend.elmCampEmailAddress) ]
                , Html.text " (or just reply to this email)"
                ]
            ]
    }



-- Things that should be auto-generated in future


requestPurchaseCompletedEndpoint : String -> Task HttpCore.Error String
requestPurchaseCompletedEndpoint value =
    LamderaRPC.asTask Wire3.encodeString Wire3.decodeString value "purchaseCompletedEndpoint"


lamdera_handleEndpoints : Json.Value -> HttpRequest -> BackendModel -> ( RPCResult, BackendModel, Cmd BackendMsg )
lamdera_handleEndpoints reqRaw req model =
    case req.endpoint of
        "stripe" ->
            LamderaRPC.handleEndpointString purchaseCompletedEndpoint req model

        "backend-model" ->
            LamderaRPC.handleEndpoint backendModelEndpoint req model

        "tickets-enabled" ->
            ( LamderaRPC.ResultString "enabled"
            , { model | ticketsEnabled = TicketsEnabled }
            , LamderaCore.broadcast (TicketsEnabledChanged TicketsEnabled)
            )

        "tickets-disabled" ->
            let
                ticketStatus =
                    TicketsDisabled { adminMessage = "Ticket sales temporarily disabled" }
            in
            ( LamderaRPC.ResultString "enabled"
            , { model | ticketsEnabled = ticketStatus }
            , LamderaCore.broadcast (TicketsEnabledChanged ticketStatus)
            )

        _ ->
            ( LamderaRPC.resultWith LamderaRPC.StatusNotFound [] (LamderaRPC.BodyString ("Unknown endpoint " ++ req.endpoint)), model, Cmd.none )
