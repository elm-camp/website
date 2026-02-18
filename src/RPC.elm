module RPC exposing
    ( backendModelEndpoint
    , badReq
    , lamdera_handleEndpoints
    , requestPurchaseCompletedEndpoint
    )

import Env
import Http as HttpCore
import Json.Decode as D
import Lamdera as LamderaCore exposing (SessionId)
import Lamdera.Json as Json
import Lamdera.Wire3 as Wire3
import LamderaRPC exposing (Headers, HttpBody(..), HttpRequest, RPCResult(..), StatusCode(..))
import Task exposing (Task)
import Types exposing (BackendModel, BackendMsg(..), EmailResult(..), TicketsEnabled(..), ToFrontend(..))


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



-- Things that should be auto-generated in future


requestPurchaseCompletedEndpoint : String -> Task HttpCore.Error String
requestPurchaseCompletedEndpoint value =
    LamderaRPC.asTask Wire3.encodeString Wire3.decodeString value "purchaseCompletedEndpoint"


lamdera_handleEndpoints : Json.Value -> HttpRequest -> BackendModel -> ( RPCResult, BackendModel, Cmd BackendMsg )
lamdera_handleEndpoints reqRaw req model =
    case req.endpoint of
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
            case req.body of
                BodyString string ->
                    ( if Env.isProduction then
                        LamderaRPC.ResultString "prod"

                      else
                        LamderaRPC.ResultString "dev"
                    , model
                    , Task.perform
                        (\() -> StripeWebhookResponse { endpoint = req.endpoint, json = string })
                        (Task.succeed ())
                    )

                _ ->
                    ( LamderaRPC.ResultString "Body should be string data", model, Cmd.none )
