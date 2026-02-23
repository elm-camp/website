module Stripe exposing
    ( CheckoutItem(..)
    , ConversionRateStatus(..)
    , CurrentCurrency
    , LocalCurrency(..)
    , Price
    , PriceData
    , PriceId(..)
    , ProductId(..)
    , StripeCurrency(..)
    , StripePaymentId
    , StripeSessionId(..)
    , Webhook(..)
    , cancelPath
    , createCheckoutSession
    , decodeWebhook
    , emailAddressParameter
    , expireSession
    , getPrices
    , loadCheckout
    , localCurrency
    , stripeSessionIdParameter
    , successPath
    )

import Dict exposing (Dict)
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Http as Http
import Effect.Task exposing (Task)
import Effect.Time as Time
import EmailAddress exposing (EmailAddress)
import Env
import HttpHelpers
import Id exposing (Id)
import Json.Decode as D
import Json.Decode.Pipeline
import Json.Encode as E
import Money
import Ports exposing (stripe_to_js)
import Quantity exposing (Quantity, Rate)
import SeqDict exposing (SeqDict)
import Url exposing (percentEncode)
import Url.Builder



-- HTTP Backend API


type alias Price =
    { priceId : Id PriceId, amount : Quantity Int StripeCurrency }


type ConversionRateStatus
    = LoadingConversionRate
    | LoadedConversionRate (SeqDict Money.Currency (Quantity Float (Rate StripeCurrency LocalCurrency)))
    | LoadingConversionRateFailed Http.Error


type alias CurrentCurrency =
    { currency : Money.Currency, conversionRate : Quantity Float (Rate StripeCurrency LocalCurrency) }


type StripeCurrency
    = StripeCurrency Never


type LocalCurrency
    = LocalCurrency Never


localCurrency : Money.Currency
localCurrency =
    Money.EUR


type ProductId
    = ProductId Never


type PriceId
    = PriceId Never


type Webhook
    = StripeSessionCompleted (Id StripeSessionId) (Id StripePaymentId)


type StripePaymentId
    = StripePaymentId Never


decodeWebhook : D.Decoder Webhook
decodeWebhook =
    D.field "type" D.string
        |> D.andThen
            (\eventType ->
                case eventType of
                    "checkout.session.completed" ->
                        D.at
                            [ "data", "object" ]
                            (D.map2
                                StripeSessionCompleted
                                (D.field "id" Id.decoder)
                                (D.field "payment_intent" Id.decoder)
                            )

                    _ ->
                        D.fail ("Unhandled stripe webhook event: " ++ eventType)
            )


type alias PriceData =
    { price : Price, currency : Money.Currency, productId : Id ProductId, isActive : Bool, createdAt : Time.Posix }


getPrices : Task restriction Http.Error (List PriceData)
getPrices =
    Http.task
        { method = "GET"
        , headers = headers
        , url = "https://api.stripe.com/v1/prices"
        , body = Http.emptyBody
        , resolver = HttpHelpers.jsonResolver decodePrices
        , timeout = Nothing
        }


decodePrices : D.Decoder (List PriceData)
decodePrices =
    D.field "data" (D.list decodePrice)


decodePrice : D.Decoder PriceData
decodePrice =
    D.succeed
        (\priceId currency amount productId isActive createdAt ->
            { price = { priceId = priceId, amount = Quantity.unsafe amount }
            , currency = currency
            , productId = productId
            , isActive = isActive
            , createdAt = createdAt
            }
        )
        |> Json.Decode.Pipeline.required "id" Id.decoder
        |> Json.Decode.Pipeline.required "currency" decodeCurrency
        |> Json.Decode.Pipeline.optional "unit_amount" D.int 0
        |> Json.Decode.Pipeline.required "product" Id.decoder
        |> Json.Decode.Pipeline.required "active" D.bool
        |> Json.Decode.Pipeline.required "created" (D.map Time.millisToPosix D.int)


decodeCurrency : D.Decoder Money.Currency
decodeCurrency =
    D.andThen
        (\text ->
            case Money.fromString text of
                Just currency ->
                    D.succeed currency

                Nothing ->
                    D.fail "Not recognized currency"
        )
        D.string


type CheckoutItem
    = Priced
        { priceId : Id PriceId
        , name : String
        , quantity : Int
        }
    | Unpriced
        { name : String
        , quantity : Int
        , currency : String
        , amountDecimal : Int
        }


createCheckoutSession :
    { items : List CheckoutItem
    , emailAddress : EmailAddress
    , now : Time.Posix
    , expiresInMinutes : Int
    }
    -> Task restriction Http.Error (Id StripeSessionId)
createCheckoutSession { items, emailAddress, now, expiresInMinutes } =
    let
        itemToStripeAttrs i item =
            case item of
                Priced { priceId, quantity } ->
                    [ ( "line_items[" ++ String.fromInt i ++ "][price]", Id.toString priceId )
                    , ( "line_items[" ++ String.fromInt i ++ "][quantity]", String.fromInt quantity )
                    ]

                Unpriced { name, quantity, currency, amountDecimal } ->
                    [ ( "line_items[" ++ String.fromInt i ++ "][price_data][currency]", currency )
                    , ( "line_items[" ++ String.fromInt i ++ "][price_data][product_data][name]", name )
                    , ( "line_items[" ++ String.fromInt i ++ "][price_data][unit_amount_decimal]", String.fromInt amountDecimal )
                    , ( "line_items[" ++ String.fromInt i ++ "][quantity]", String.fromInt quantity )
                    ]

        body =
            [ ( "mode", "payment" )
            , ( "allow_promotion_codes", "true" )

            -- Stripe expects seconds since epoch
            , ( "expires_at", String.fromInt ((Time.posixToMillis now // 1000) + (expiresInMinutes * 60)) )
            , ( "success_url"
              , Url.Builder.crossOrigin
                    Env.domain
                    [ successPath ]
                    [ Url.Builder.string emailAddressParameter (EmailAddress.toString emailAddress) ]
              )
            , ( "cancel_url", Url.Builder.crossOrigin Env.domain [ cancelPath ] [] )
            , ( "customer_email", EmailAddress.toString emailAddress )
            ]
                ++ (List.filter
                        (\item ->
                            case item of
                                Priced priced ->
                                    priced.quantity > 0

                                Unpriced unpriced ->
                                    unpriced.amountDecimal > 0 && unpriced.quantity > 0
                        )
                        items
                        |> List.indexedMap itemToStripeAttrs
                        |> List.concat
                   )
                |> formBody
    in
    Http.task
        { method = "POST"
        , headers = headers
        , url = "https://api.stripe.com/v1/checkout/sessions"
        , body = body
        , resolver = HttpHelpers.jsonResolver decodeSession
        , timeout = Nothing
        }


emailAddressParameter : String
emailAddressParameter =
    "email-address"


stripeSessionIdParameter : String
stripeSessionIdParameter =
    "stripe-session"


successPath : String
successPath =
    "stripeSuccess"


cancelPath : String
cancelPath =
    "stripeCancel"


expireSession : Id StripeSessionId -> Task restriction Http.Error ()
expireSession stripeSessionId =
    Http.task
        { method = "POST"
        , headers = headers
        , url =
            Url.Builder.crossOrigin
                "https://api.stripe.com"
                [ "v1", "checkout", "sessions", Id.toString stripeSessionId, "expire" ]
                []
        , body = Http.emptyBody
        , resolver = HttpHelpers.jsonResolver (D.succeed ())
        , timeout = Nothing
        }


type alias CreateSessionRequest =
    { payment_method_types : String
    , line_items_price : String
    , line_items_quantity : Int
    , mode : String
    , success_url : String
    , cancel_url : String
    }


type StripeSessionId
    = StripeSessionId Never


decodeSession : D.Decoder (Id StripeSessionId)
decodeSession =
    D.field "id" Id.decoder


headers : List Http.Header
headers =
    [ Http.header "Authorization" ("Bearer " ++ Env.stripePrivateApiKey) ]



-- Ports API


loadCheckout : String -> Id StripeSessionId -> Command FrontendOnly toMsg msg
loadCheckout publicApiKey sid =
    Command.sendToJs
        "stripe_to_js"
        stripe_to_js
        (E.object
            [ ( "msg", E.string "loadCheckout" )
            , ( "id", Id.encode sid )
            , ( "publicApiKey", E.string publicApiKey )
            ]
        )



-- Helpers


{-| Encode a CGI parameter pair.
-}
cgiParameter : ( String, String ) -> String
cgiParameter ( key, value ) =
    percentEncode key ++ "=" ++ percentEncode value


{-| Encode a CGI parameter list.
-}
cgiParameters : List ( String, String ) -> String
cgiParameters parameters =
    List.map cgiParameter parameters |> String.join "&"


{-| Put some key-value pairs in the body of your `Request`. This will automatically
add the `Content-Type: application/x-www-form-urlencoded` header.
-}
formBody : List ( String, String ) -> Http.Body
formBody parameters =
    cgiParameters parameters |> Http.stringBody "application/x-www-form-urlencoded"
