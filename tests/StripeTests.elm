module StripeTests exposing (rpcTest)

import Backend
import Dict
import Expect
import Json.Encode as E
import LamderaRPC
import RPC
import RecordedTests
import Test exposing (Test)


rpcTest : Test
rpcTest =
    Test.describe "Stripe webhook tests"
        [ Test.test
            "Checkout completed when there's no price data"
            (\_ ->
                let
                    ( result, _, _ ) =
                        RPC.lamdera_handleEndpoints
                            (E.object [])
                            RecordedTests.stripePurchaseWebhookResponse
                            (Tuple.first Backend.init)
                in
                Expect.equal
                    (LamderaRPC.ResultRaw
                        400
                        "Bad Request"
                        []
                        (LamderaRPC.BodyString "Unexpected HTTP response: Internal error")
                    )
                    result
            )
        ]
