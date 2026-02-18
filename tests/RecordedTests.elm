module RecordedTests exposing (main, setup, stripePurchaseWebhookResponse, tests)

import Backend
import Bytes exposing (Bytes)
import Camp26Czech
import Dict exposing (Dict)
import Duration
import Effect.Browser.Dom as Dom
import Effect.Lamdera as Lamdera
import Effect.Test as T exposing (FileUpload(..), HttpRequest, HttpResponse(..), MultipleFilesUpload(..), PointerOptions(..))
import Frontend
import Json.Decode
import Json.Encode
import LamderaRPC
import RPC
import Route
import SeqDict
import Test.Html.Query
import Test.Html.Selector
import Time
import Types exposing (BackendModel, BackendMsg(..), EmailResult(..), FrontendModel, FrontendMsg, ToBackend, ToFrontend)
import Unsafe
import Url exposing (Url)


setup : T.ViewerWith (List (T.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel))
setup =
    T.viewerWith tests
        |> T.addBytesFiles (Dict.values fileRequests)


main : Program () (T.Model ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel) (T.Msg ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel)
main =
    T.startViewer setup


domain : Url
domain =
    Unsafe.url "http://localhost:8000"


{-| Please don't modify or rename this function
-}
fileRequests : Dict String String
fileRequests =
    Dict.empty


handleHttpRequests : Dict String String -> Dict String Bytes -> { currentRequest : HttpRequest, data : T.Data FrontendModel BackendModel } -> HttpResponse
handleHttpRequests overrides fileData { currentRequest } =
    let
        key : String
        key =
            currentRequest.method ++ "_" ++ currentRequest.url

        getData : String -> HttpResponse
        getData path =
            case Dict.get path fileData of
                Just data ->
                    BytesHttpResponse { url = currentRequest.url, statusCode = 200, statusText = "OK", headers = Dict.empty } data

                Nothing ->
                    UnhandledHttpRequest
    in
    case ( Dict.get key overrides, Dict.get key fileRequests ) of
        ( Just path, _ ) ->
            getData path

        ( Nothing, Just path ) ->
            getData path

        _ ->
            if currentRequest.url == "https://api.stripe.com/v1/prices" then
                StringHttpResponse
                    { url = currentRequest.url, statusCode = 200, statusText = "OK", headers = Dict.empty }
                    stripePricesResponse

            else if currentRequest.url == "https://api.stripe.com/v1/checkout/sessions" then
                StringHttpResponse
                    { url = currentRequest.url, statusCode = 200, statusText = "OK", headers = Dict.empty }
                    ("""{"id":\"""" ++ stripeSessionId ++ "\"}")

            else
                UnhandledHttpRequest


stripeSessionId : String
stripeSessionId =
    "cs_live_b11eNtNWg68DgbLFAUbiuhiUxjDXJqqOxXhFTqG0iaimcgQjayLSRJlK4Z"


{-| You can change parts of this function represented with `...`.
The rest needs to remain unchanged in order for the test generator to be able to add new tests.

    tests : ... -> List (T.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel)
    tests ... =
        let
            config = ...

            ...
        in
        [ ...
        ]

-}
tests : Dict String Bytes -> List (T.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel)
tests fileData =
    let
        config =
            T.Config
                Frontend.app_
                Backend.app_
                (handleHttpRequests Dict.empty fileData)
                (\_ -> Nothing)
                (\_ -> UnhandledFileUpload)
                (\_ -> UnhandledMultiFileUpload)
                domain
    in
    [ T.start
        "Links are reachable"
        (Time.millisToPosix 1757440953858)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            { width = 881, height = 1312 }
            (\tab1 ->
                [ tab1.clickLink 100 "/code-of-conduct"
                , tab1.checkView 100
                    (Test.Html.Query.has [ Test.Html.Selector.exactText "Code of Conduct" ])
                , tab1.clickLink 100 "/unconference-format"
                , tab1.checkView 100
                    (Test.Html.Query.has [ Test.Html.Selector.exactText "Unconference Format" ])
                , tab1.clickLink 100 "/elm-camp-archive"
                , tab1.checkView 100
                    (Test.Html.Query.has [ Test.Html.Selector.text "Here we keep track of what has come out of past Elm Camp events." ])
                , tab1.clickLink 100 "/24-uk"
                , tab1.navigateBack 100
                , tab1.clickLink 100 "/23-denmark"
                , tab1.checkView 100
                    (Test.Html.Query.has [ Test.Html.Selector.exactText "Dallund Castle, Denmark" ])
                ]
            )
        ]
    , T.start
        "Purchase ticket"
        (Duration.addTo Camp26Czech.ticketSalesOpenAt Duration.minute)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            { width = 881, height = 1312 }
            (\_ -> [])
        , T.connectFrontend
            100
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            { width = 881, height = 1312 }
            (\tab1 ->
                [ tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                , tab1.click 100 (Dom.id "selectTicket_Single Room")
                , tab1.input 100 (Dom.id "attendeeName_0") "Sven"
                , tab1.input 100 (Dom.id "attendeeCountry_0") "Sweden"
                , tab1.input 100 (Dom.id "attendeeCity_0") "Malmö"
                , tab1.input 100 (Dom.id "billingEmail") "sven@svenmail.se"
                , tab1.click 100 (Dom.id "submitForm")
                , T.checkState 100
                    (\data ->
                        case data.portRequests of
                            head :: _ ->
                                if head.portName == "stripe_to_js" && head.clientId == tab1.clientId then
                                    Ok ()

                                else
                                    Err "Frontend doesn't trigger Stripe checkout"

                            [] ->
                                Err "Frontend doesn't trigger Stripe checkout"
                    )
                , T.backendUpdate 100 (StripeWebhookResponse stripePurchaseWebhookResponse)

                --, T.andThen
                --    100
                --    (\data ->
                --        let
                --            ( response, backend2, _ ) =
                --                RPC.lamdera_handleEndpoints
                --                    Json.Encode.null
                --                    stripePurchaseWebhookResponse
                --                    backend
                --        in
                --        if Debug.log "response" response == LamderaRPC.ResultString "dev" then
                --            case SeqDict.toList backend2.orders of
                --                [ _ ] ->
                --                    Ok ()
                --
                --                _ ->
                --                    Err "Completed order is missing"
                --
                --        else
                --            Err "Stripe webhook got an error response"
                --    )
                ]
            )
        ]
    , T.start
        "All rooms sold out"
        (Duration.addTo Camp26Czech.ticketSalesOpenAt Duration.minute)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            { width = 881, height = 1312 }
            (\_ -> [])
        , T.connectFrontend
            100
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            { width = 881, height = 1312 }
            (\tab1 ->
                [ tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                , List.range 1 40
                    |> List.concatMap
                        (\index ->
                            [ tab1.click 100 (Dom.id "selectTicket_Single Room")
                            , tab1.input 100 (Dom.id ("attendeeName_" ++ String.fromInt index)) "Sven"
                            , tab1.input 100 (Dom.id ("attendeeCountry_" ++ String.fromInt index)) "Sweden"
                            , tab1.input 100 (Dom.id ("attendeeCity_" ++ String.fromInt index)) "Malmö"
                            ]
                        )
                    |> T.collapsableGroup "Purchase a bunch of tickets"
                , tab1.input 100 (Dom.id "billingEmail") "sven@svenmail.se"
                , tab1.click 100 (Dom.id "submitForm")

                --, T.checkBackend
                --    100
                --    (\backend ->
                --        let
                --            ( response, backend2, _ ) =
                --                RPC.lamdera_handleEndpoints
                --                    Json.Encode.null
                --                    stripePurchaseWebhookResponse
                --                    backend
                --        in
                --        if Debug.log "response" response == LamderaRPC.ResultString "dev" then
                --            case SeqDict.toList backend2.orders of
                --                [ _ ] ->
                --                    Ok ()
                --
                --                _ ->
                --                    Err "Completed order is missing"
                --
                --        else
                --            Err "Stripe webhook got an error response"
                --    )
                ]
            )
        ]
    ]


stripePurchaseWebhookResponse : { json : String, endpoint : String }
stripePurchaseWebhookResponse =
    { json =
        "{\n  \"id\": \"evt_1T28zeHHD80VvsjK4Juvu6pm\",\n  \"object\": \"event\",\n  \"api_version\": \"2020-03-02\",\n  \"created\": 1771414354,\n  \"data\": {\n    \"object\": {\n      \"id\": \""
            ++ stripeSessionId
            ++ "\",\n      \"object\": \"checkout.session\",\n      \"adaptive_pricing\": {\n        \"enabled\": true\n      },\n      \"after_expiration\": null,\n      \"allow_promotion_codes\": true,\n      \"amount_subtotal\": 2427,\n      \"amount_total\": 2427,\n      \"automatic_tax\": {\n        \"enabled\": false,\n        \"liability\": null,\n        \"provider\": null,\n        \"status\": null\n      },\n      \"billing_address_collection\": null,\n      \"branding_settings\": {\n        \"background_color\": \"#ffffff\",\n        \"border_style\": \"rounded\",\n        \"button_color\": \"#62b6ce\",\n        \"display_name\": \"Cofoundry Ltd\",\n        \"font_family\": \"default\",\n        \"icon\": {\n          \"file\": \"file_1MjQFxHHD80VvsjK6qqVMCl0\",\n          \"type\": \"file\"\n        },\n        \"logo\": {\n          \"file\": \"file_1MjQFkHHD80VvsjKFF7tUO9t\",\n          \"type\": \"file\"\n        }\n      },\n      \"cancel_url\": \"http://localhost:8000/stripeCancel\",\n      \"client_reference_id\": null,\n      \"client_secret\": null,\n      \"collected_information\": {\n        \"business_name\": null,\n        \"individual_name\": null,\n        \"shipping_details\": null\n      },\n      \"consent\": null,\n      \"consent_collection\": null,\n      \"created\": 1771414277,\n      \"currency\": \"czk\",\n      \"currency_conversion\": null,\n      \"custom_fields\": [],\n      \"custom_text\": {\n        \"after_submit\": null,\n        \"shipping_address\": null,\n        \"submit\": null,\n        \"terms_of_service_acceptance\": null\n      },\n      \"customer\": \"cus_U09IBJBVAmennB\",\n      \"customer_account\": null,\n      \"customer_creation\": \"always\",\n      \"customer_details\": {\n        \"address\": {\n          \"city\": null,\n          \"country\": \"SE\",\n          \"line1\": null,\n          \"line2\": null,\n          \"postal_code\": null,\n          \"state\": null\n        },\n        \"business_name\": null,\n        \"email\": \"martinsstewart@gmail.com\",\n        \"individual_name\": null,\n        \"name\": \"Martin Stewart\",\n        \"phone\": null,\n        \"tax_exempt\": \"none\",\n        \"tax_ids\": []\n      },\n      \"customer_email\": \"martinsstewart@gmail.com\",\n      \"discounts\": [],\n      \"expires_at\": 1771416076,\n      \"invoice\": null,\n      \"invoice_creation\": {\n        \"enabled\": false,\n        \"invoice_data\": {\n          \"account_tax_ids\": null,\n          \"custom_fields\": null,\n          \"description\": null,\n          \"footer\": null,\n          \"issuer\": null,\n          \"metadata\": {},\n          \"rendering_options\": null\n        }\n      },\n      \"livemode\": true,\n      \"locale\": null,\n      \"metadata\": {},\n      \"mode\": \"payment\",\n      \"origin_context\": null,\n      \"payment_intent\": \"pi_3T28yPHHD80VvsjK12neihui\",\n      \"payment_link\": null,\n      \"payment_method_collection\": \"always\",\n      \"payment_method_configuration_details\": {\n        \"id\": \"pmc_1MjOXdHHD80VvsjKu0s7ebsQ\",\n        \"parent\": null\n      },\n      \"payment_method_options\": {\n        \"card\": {\n          \"request_three_d_secure\": \"automatic\"\n        }\n      },\n      \"payment_method_types\": [\n        \"card\",\n        \"link\"\n      ],\n      \"payment_status\": \"paid\",\n      \"permissions\": null,\n      \"phone_number_collection\": {\n        \"enabled\": false\n      },\n      \"recovered_from\": null,\n      \"saved_payment_method_options\": {\n        \"allow_redisplay_filters\": [\n          \"always\"\n        ],\n        \"payment_method_remove\": \"disabled\",\n        \"payment_method_save\": null\n      },\n      \"setup_intent\": null,\n      \"shipping\": null,\n      \"shipping_address_collection\": null,\n      \"shipping_options\": [],\n      \"shipping_rate\": null,\n      \"status\": \"complete\",\n      \"submit_type\": null,\n      \"subscription\": null,\n      \"success_url\": \"http://localhost:8000/stripeSuccess?email-address=martinsstewart%40gmail.com\",\n      \"total_details\": {\n        \"amount_discount\": 0,\n        \"amount_shipping\": 0,\n        \"amount_tax\": 0\n      },\n      \"ui_mode\": \"hosted\",\n      \"url\": null,\n      \"wallet_options\": null\n    }\n  },\n  \"livemode\": true,\n  \"pending_webhooks\": 1,\n  \"request\": {\n    \"id\": null,\n    \"idempotency_key\": null\n  },\n  \"type\": \"checkout.session.completed\"\n}"
    , endpoint = "stripe"
    }


stripePricesResponse : String
stripePricesResponse =
    """{
  "object": "list",
  "data": [
    {
      "id": "price_1SokONHHD80VvsjKI7Fcrgpv",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1768221523,
      "currency": "czk",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_TmJ0n8liux9A3d",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 1500000,
      "unit_amount_decimal": "1500000"
    },
    {
      "id": "price_1SokNtHHD80VvsjKBvsbpibp",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1768221493,
      "currency": "czk",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_TmIzrbSouU0bYE",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 1000000,
      "unit_amount_decimal": "1000000"
    },
    {
      "id": "price_1SokMMHHD80VvsjKBDguCA1L",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1768221398,
      "currency": "czk",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_TmIy0Mltqmgzg5",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 500000,
      "unit_amount_decimal": "500000"
    },
    {
      "id": "price_1RAxDAHHD80VvsjKwpYM6dm9",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1743961344,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_S57SF0eTq5vOvx",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 0,
      "unit_amount_decimal": "0"
    },
    {
      "id": "price_1R5XTOHHD80VvsjKhUJRznqW",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742670766,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWWOS4E6aID6y",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 500000,
      "unit_amount_decimal": "500000"
    },
    {
      "id": "price_1R5XSrHHD80VvsjKzqKGqCKV",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742670733,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWVRbQ0spItOf",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 250000,
      "unit_amount_decimal": "250000"
    },
    {
      "id": "price_1R5XR0HHD80VvsjKLs71zqeA",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742670618,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWTill7eglkFc",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 100000,
      "unit_amount_decimal": "100000"
    },
    {
      "id": "price_1R5XFkHHD80VvsjKj9YCTgLP",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742669920,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWIY7BfNEYSqF",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 50000,
      "unit_amount_decimal": "50000"
    },
    {
      "id": "price_1R5XE4HHD80VvsjKuFX5ZA2M",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742669816,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWGafvirlc2HL",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 75000,
      "unit_amount_decimal": "75000"
    },
    {
      "id": "price_1R5XAHHHD80VvsjK1TuNuqSL",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742669581,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWC4KcrRdLzBH",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 30000,
      "unit_amount_decimal": "30000"
    }
  ],
  "has_more": true,
  "url": "/v1/prices"
}"""
