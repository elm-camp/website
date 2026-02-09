module MyTests exposing (main, setup, tests)

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
import Test.Html.Query
import Test.Html.Selector
import Time
import Types exposing (BackendModel, BackendMsg, FrontendModel, FrontendMsg, ToBackend, ToFrontend)
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
                StringHttpResponse { url = currentRequest.url, statusCode = 200, statusText = "OK", headers = Dict.empty } stripePricesResponse

            else
                UnhandledHttpRequest


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
                [ tab1.click 100 (Dom.id "selectTicket_Single Room")
                , tab1.input 100 (Dom.id "attendeeName_0") "Sven"
                , tab1.input 100 (Dom.id "attendeeCountry_0") "Sweden"
                , tab1.input 100 (Dom.id "attendeeCity_0") "Malmö"
                , tab1.input 100 (Dom.id "billingEmail") "sven@svenmail.se"
                , tab1.click 100 (Dom.id "submitForm")
                , tab1.checkView 100 (Test.Html.Query.has [ Test.Html.Selector.exactText "Tickets purchased!" ])
                ]
            )
        ]
    ]


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
