module RPC exposing (..)

import AssocList
import Env
import Http
import Json.Decode
import Lamdera exposing (SessionId)
import Lamdera.Wire3 as Wire3
import LamderaRPC
import Stripe exposing (Webhook(..))
import Task exposing (Task)
import Types exposing (BackendModel)


purchaseCompletedEndpoint : SessionId -> BackendModel -> String -> ( Result Http.Error String, BackendModel, Cmd msg )
purchaseCompletedEndpoint _ model request =
    let
        _ =
            Debug.log "endpoint" request
    in
    ( if Env.isProduction then
        Ok ""

      else
        Ok "test"
    , case Json.Decode.decodeString Stripe.decodeWebhook request of
        Ok webhook ->
            case webhook of
                StripeSessionCompleted stripeSessionId ->
                    case AssocList.get stripeSessionId model.pendingOrder of
                        Just order ->
                            { model
                                | pendingOrder = AssocList.remove stripeSessionId model.pendingOrder
                                , orders = AssocList.insert stripeSessionId order model.orders
                            }

                        Nothing ->
                            model

        Err _ ->
            model
    , Cmd.none
    )



-- Things that should be auto-generated in future


requestPurchaseCompletedEndpoint : String -> Task Http.Error String
requestPurchaseCompletedEndpoint value =
    LamderaRPC.asTask Wire3.encodeString Wire3.decodeString value "purchaseCompletedEndpoint"


lamdera_handleEndpoints : LamderaRPC.RPCArgs -> BackendModel -> ( LamderaRPC.RPCResult, BackendModel, Cmd msg )
lamdera_handleEndpoints args model =
    case args.endpoint of
        "stripe" ->
            LamderaRPC.handleEndpointString purchaseCompletedEndpoint args model

        _ ->
            ( LamderaRPC.ResultFailure <| Http.BadBody <| "Unknown endpoint " ++ args.endpoint, model, Cmd.none )
