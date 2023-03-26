module RPC exposing (..)

import AssocList
import Backend
import Email.Html as Html
import Env
import Http
import Json.Decode
import Lamdera exposing (SessionId)
import Lamdera.Wire3 as Wire3
import LamderaRPC
import List.Nonempty exposing (Nonempty(..))
import Name
import Postmark
import PurchaseForm
import String.Nonempty exposing (NonemptyString(..))
import Stripe exposing (Webhook(..))
import Task exposing (Task)
import Tickets
import Types exposing (BackendModel, BackendMsg(..), EmailResult(..))
import Unsafe


purchaseCompletedEndpoint :
    SessionId
    -> BackendModel
    -> String
    -> ( Result Http.Error String, BackendModel, Cmd BackendMsg )
purchaseCompletedEndpoint _ model request =
    let
        _ =
            Debug.log "endpoint" request

        response =
            if Env.isProduction then
                Ok "prod"

            else
                Ok "dev"
    in
    case Json.Decode.decodeString Stripe.decodeWebhook request of
        Ok webhook ->
            case webhook of
                StripeSessionCompleted stripeSessionId ->
                    case AssocList.get stripeSessionId model.pendingOrder of
                        Just order ->
                            let
                                maybeTicketName : Maybe String
                                maybeTicketName =
                                    case Backend.priceIdToProductId model order.priceId of
                                        Just productId ->
                                            case AssocList.get productId Tickets.dict of
                                                Just ticket ->
                                                    Just ticket.name

                                                Nothing ->
                                                    Nothing

                                        Nothing ->
                                            Nothing
                            in
                            ( response
                            , { model
                                | pendingOrder = AssocList.remove stripeSessionId model.pendingOrder
                                , orders =
                                    AssocList.insert
                                        stripeSessionId
                                        { priceId = order.priceId
                                        , submitTime = order.submitTime
                                        , form = order.form
                                        , emailResult = SendingEmail
                                        }
                                        model.orders
                              }
                            , Postmark.sendEmail
                                EmailSent
                                Env.postmarkApiKey
                                { from = { name = "elm-camp", email = elmCampEmailAddress }
                                , to =
                                    Nonempty
                                        { name = PurchaseForm.attendeeName order.form |> Name.toString
                                        , email = PurchaseForm.billingEmail order.form
                                        }
                                        []
                                , subject =
                                    case maybeTicketName of
                                        Just ticket ->
                                            String.Nonempty.append
                                                ticket
                                                (NonemptyString ' ' "ticket purchase confirmation")

                                        Nothing ->
                                            NonemptyString 'T' "icket purchase confirmation"
                                , body =
                                    Postmark.BodyBoth
                                        (Html.text "")
                                        ""
                                , messageStream = "outbound"
                                }
                            )

                        Nothing ->
                            ( response, model, Cmd.none )

        Err _ ->
            ( response, model, Cmd.none )


elmCampEmailAddress =
    Unsafe.emailAddress "no-reply@elm.camp"



-- Things that should be auto-generated in future


requestPurchaseCompletedEndpoint : String -> Task Http.Error String
requestPurchaseCompletedEndpoint value =
    LamderaRPC.asTask Wire3.encodeString Wire3.decodeString value "purchaseCompletedEndpoint"


lamdera_handleEndpoints :
    LamderaRPC.RPCArgs
    -> BackendModel
    -> ( LamderaRPC.RPCResult, BackendModel, Cmd BackendMsg )
lamdera_handleEndpoints args model =
    case args.endpoint of
        "stripe" ->
            LamderaRPC.handleEndpointString purchaseCompletedEndpoint args model

        _ ->
            ( LamderaRPC.ResultFailure <| Http.BadBody <| "Unknown endpoint " ++ args.endpoint, model, Cmd.none )
