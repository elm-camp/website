module Stripe exposing
    ( CheckoutItem(..)
    , Price
    , PriceData
    , PriceId(..)
    , ProductId(..)
    , StripeSessionId(..)
    , Webhook(..)
    , cancelPath
    , createCheckoutSession
    , decodeWebhook
    , emailAddressParameter
    , expireSession
    , getPrices
    , loadCheckout
    , stripeSessionIdParameter
    , successPath
    )

import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Http
import Effect.Task exposing (Task)
import Effect.Time
import EmailAddress exposing (EmailAddress)
import Env
import HttpHelpers
import Id exposing (Id)
import Json.Decode as D
import Json.Decode.Pipeline
import Json.Encode as E
import Money
import Ports exposing (stripe_to_js)
import Url exposing (percentEncode)
import Url.Builder



-- HTTP Backend API


type alias Price =
    { currency : Money.Currency, amount : Int }


type ProductId
    = ProductId Never


type PriceId
    = PriceId Never


type Webhook
    = StripeSessionCompleted (Id StripeSessionId)


decodeWebhook : D.Decoder Webhook
decodeWebhook =
    D.field "type" D.string
        |> D.andThen
            (\eventType ->
                case eventType of
                    "checkout.session.completed" ->
                        D.succeed StripeSessionCompleted
                            |> Json.Decode.Pipeline.required "data" (D.field "object" (D.field "id" Id.decoder))

                    _ ->
                        D.fail ("Unhandled stripe webhook event: " ++ eventType)
            )


type alias PriceData =
    { priceId : Id PriceId, price : Price, productId : Id ProductId, isActive : Bool, createdAt : Effect.Time.Posix }


getPrices : Task restriction Effect.Http.Error (List PriceData)
getPrices =
    Effect.Http.task
        { method = "GET"
        , headers = headers
        , url = "https://api.stripe.com/v1/prices"
        , body = Effect.Http.emptyBody
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
            { priceId = priceId
            , price = Price currency amount
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
        |> Json.Decode.Pipeline.required "created" (D.map Effect.Time.millisToPosix D.int)


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
    , now : Effect.Time.Posix
    , expiresInMinutes : Int
    }
    -> Effect.Task.Task restriction Effect.Http.Error (Id StripeSessionId)
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
            , ( "expires_at", String.fromInt ((Effect.Time.posixToMillis now // 1000) + (expiresInMinutes * 60)) )
            , ( "success_url"
              , Url.Builder.crossOrigin
                    Env.domain
                    [ successPath ]
                    [ Url.Builder.string emailAddressParameter (EmailAddress.toString emailAddress) ]
              )
            , ( "cancel_url", Url.Builder.crossOrigin Env.domain [ cancelPath ] [] )
            , ( "customer_email", EmailAddress.toString emailAddress )
            ]
                ++ (items |> List.indexedMap itemToStripeAttrs |> List.concat)
                |> formBody
    in
    Effect.Http.task
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


expireSession : Id StripeSessionId -> Effect.Task.Task restriction Effect.Http.Error ()
expireSession stripeSessionId =
    Effect.Http.task
        { method = "POST"
        , headers = headers
        , url =
            Url.Builder.crossOrigin
                "https://api.stripe.com"
                [ "v1", "checkout", "sessions", Id.toString stripeSessionId, "expire" ]
                []
        , body = Effect.Http.emptyBody
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


headers : List Effect.Http.Header
headers =
    [ Effect.Http.header "Authorization" ("Bearer " ++ Env.stripePrivateApiKey) ]



-- Ports API


loadCheckout : String -> Id StripeSessionId -> Command FrontendOnly toMsg msg
loadCheckout publicApiKey sid =
    toJsMessage "loadCheckout"
        [ ( "id", Id.encode sid )
        , ( "publicApiKey", E.string publicApiKey )
        ]


toJsMessage : String -> List ( String, E.Value ) -> Command FrontendOnly toMsg msg
toJsMessage msg values =
    Command.sendToJs
        "stripe_to_js"
        stripe_to_js
        (E.object
            (( "msg", E.string msg ) :: values)
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
formBody : List ( String, String ) -> Effect.Http.Body
formBody parameters =
    cgiParameters parameters |> Effect.Http.stringBody "application/x-www-form-urlencoded"
