module RPC exposing (backendModelEndpoint, badReq, confirmationEmail, lamdera_handleEndpoints, purchaseCompletedEndpoint, requestPurchaseCompletedEndpoint)

import AssocList
import Backend
import Camp24Devon.Tickets as Tickets
import Codec
import Email.Html as Html
import Email.Html.Attributes as Attributes
import EmailAddress exposing (EmailAddress)
import Env
import Http
import Id
import Json.Decode
import Json.Encode
import Lamdera exposing (SessionId)
import Lamdera.Json as Json
import Lamdera.Wire3 as Wire3
import LamderaRPC exposing (Headers, HttpBody(..), HttpRequest, RPCResult(..), StatusCode(..))
import List.Nonempty exposing (Nonempty(..))
import Name
import Postmark
import PurchaseForm
import String.Nonempty exposing (NonemptyString(..))
import Stripe exposing (Webhook(..))
import Task exposing (Task)
import Types exposing (BackendModel, BackendMsg(..), EmailResult(..), TicketsEnabled(..), ToFrontend(..))


backendModelEndpoint : SessionId -> BackendModel -> HttpRequest -> ( RPCResult, BackendModel, Cmd BackendMsg )
backendModelEndpoint _ model request =
    case request.body of
        BodyJson json ->
            case Json.Decode.decodeValue Json.Decode.string json of
                Ok ok ->
                    if ok == Env.adminPassword then
                        ( ResultBytes <| Wire3.intListFromBytes <| Wire3.bytesEncode <| Types.w3_encode_BackendModel model, model, Cmd.none )

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
    -> Json.Value
    -> ( Result Http.Error Json.Value, BackendModel, Cmd BackendMsg )
purchaseCompletedEndpoint _ model headers json =
    let
        response =
            if Env.isProduction then
                Ok (Json.Encode.string "prod")

            else
                Ok (Json.Encode.string "dev")
    in
    case Json.Decode.decodeValue Stripe.decodeWebhook json of
        Ok webhook ->
            case webhook of
                StripeSessionCompleted stripeSessionId ->
                    case AssocList.get stripeSessionId model.pendingOrder of
                        Just _ ->
                            -- let
                            --     maybeTicket : Maybe Tickets.Ticket
                            --     maybeTicket =
                            --         case Backend.priceIdToProductId model order.priceId of
                            --             Just productId ->
                            --                 AssocList.get productId Tickets.dict
                            --             Nothing ->
                            --                 Nothing
                            -- in
                            -- case maybeTicket of
                            --     Just ticket ->
                            -- let
                            --     { subject, textBody, htmlBody } =
                            --         confirmationEmail ticket
                            -- in
                            ( response, model, Cmd.none )

                        -- ( response
                        -- , { model
                        --     | pendingOrder = AssocList.remove stripeSessionId model.pendingOrder
                        --     , orders =
                        --         AssocList.insert
                        --             stripeSessionId
                        --             { priceId = order.priceId
                        --             , submitTime = order.submitTime
                        --             , form = order.form
                        --             , emailResult = SendingEmail
                        --             }
                        --             model.orders
                        --   }
                        -- , Postmark.sendEmail
                        --     (ConfirmationEmailSent stripeSessionId)
                        --     Env.postmarkApiKey
                        --     { from = { name = "elm-camp", email = Backend.elmCampEmailAddress }
                        --     , to =
                        --         Nonempty
                        --             { name = order.form.attendees |> List.head |> Maybe.map (.name >> Name.toString) |> Maybe.withDefault "Attendee"
                        --             , email = order.form.billingEmail
                        --             }
                        --             []
                        --     , subject = subject
                        --     , body = Postmark.BodyBoth htmlBody textBody
                        --     , messageStream = "outbound"
                        --     }
                        -- )
                        -- Nothing ->
                        --     let
                        --         error =
                        --             "Ticket not found: priceId"
                        --                 ++ Id.toString order.priceId
                        --                 ++ ", stripeSessionId: "
                        --                 ++ Id.toString stripeSessionId
                        --     in
                        --     ( Err (Http.BadBody error), model, Backend.errorEmail error )
                        Nothing ->
                            let
                                error =
                                    "Stripe session not found: stripeSessionId: "
                                        ++ Id.toString stripeSessionId
                            in
                            ( Err (Http.BadBody error), model, Backend.errorEmail error )

        Err error ->
            let
                errorText =
                    "Failed to decode webhook: "
                        ++ Json.Decode.errorToString error
            in
            ( Err (Http.BadBody errorText), model, Backend.errorEmail errorText )


confirmationEmail : Tickets.Ticket -> { subject : NonemptyString, textBody : String, htmlBody : Html.Html }
confirmationEmail ticket =
    { subject =
        String.Nonempty.append
            ticket.name
            (NonemptyString ' ' " purchase confirmation")
    , textBody =
        "This is a confirmation email for your purchase of "
            ++ ticket.name
            ++ "\n("
            ++ ticket.description
            ++ ")\n\n"
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
            [ Html.div []
                [ Html.text "This is a confirmation email for your purchase of the "
                , Html.b [] [ Html.text ticket.name ]
                ]
            , Html.div [ Attributes.paddingBottom "16px" ] [ Html.text (" (" ++ ticket.description ++ ")") ]
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


requestPurchaseCompletedEndpoint : String -> Task Http.Error String
requestPurchaseCompletedEndpoint value =
    LamderaRPC.asTask Wire3.encodeString Wire3.decodeString value "purchaseCompletedEndpoint"


lamdera_handleEndpoints : Json.Value -> HttpRequest -> BackendModel -> ( LamderaRPC.RPCResult, BackendModel, Cmd BackendMsg )
lamdera_handleEndpoints reqRaw req model =
    case req.endpoint of
        "stripe" ->
            LamderaRPC.handleEndpointJson purchaseCompletedEndpoint req model

        "backend-model" ->
            LamderaRPC.handleEndpoint backendModelEndpoint req model

        "tickets-enabled" ->
            ( LamderaRPC.ResultString "enabled"
            , { model | ticketsEnabled = TicketsEnabled }
            , Lamdera.broadcast (TicketsEnabledChanged TicketsEnabled)
            )

        "tickets-disabled" ->
            let
                ticketStatus =
                    TicketsDisabled { adminMessage = "Ticket sales temporarily disabled" }
            in
            ( LamderaRPC.ResultString "enabled"
            , { model | ticketsEnabled = ticketStatus }
            , Lamdera.broadcast (TicketsEnabledChanged ticketStatus)
            )

        _ ->
            ( LamderaRPC.resultWith LamderaRPC.StatusNotFound [] <| LamderaRPC.BodyString <| "Unknown endpoint " ++ req.endpoint, model, Cmd.none )
