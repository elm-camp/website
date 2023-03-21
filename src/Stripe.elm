module Stripe exposing (Price(..), PriceData, PriceId(..), ProductId(..), createCheckoutSession, getPrices, loadCheckout)

import Env
import Http
import HttpHelpers exposing (..)
import Json.Decode as D
import Json.Decode.Pipeline exposing (..)
import Json.Encode as E
import Money
import Ports exposing (stripe_to_js)
import Time
import Url exposing (percentEncode)



-- HTTP Backend API


type Price
    = Price Money.Currency Int


type ProductId
    = ProductId String


type PriceId
    = PriceId String


type alias PriceData =
    { priceId : PriceId, price : Price, productId : ProductId, isActive : Bool, createdAt : Time.Posix }


getPrices : (Result Http.Error (List PriceData) -> msg) -> Cmd msg
getPrices toMsg =
    Http.request
        { method = "GET"
        , headers = headers
        , url = "https://api.stripe.com/v1/prices"
        , body = Http.emptyBody
        , expect = expectJson_ toMsg decodePrices
        , timeout = Nothing
        , tracker = Nothing
        }


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
        |> required "id" (D.map PriceId D.string)
        |> required "currency" decodeCurrency
        |> required "unit_amount" D.int
        |> required "product" (D.map ProductId D.string)
        |> required "active" D.bool
        |> required "created" (D.map Time.millisToPosix D.int)


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


createCheckoutSession : PriceId -> (Result Http.Error Session -> msg) -> Cmd msg
createCheckoutSession (PriceId priceId) toMsg =
    -- @TODO support multiple prices, see Data.Tickets
    let
        body =
            formBody
                [ ( "line_items[][price]", priceId )
                , ( "line_items[][quantity]", "1" )
                , ( "mode", "payment" )
                , ( "success_url", Env.stripePostbackUrl ++ "/stripe/success?session_id={CHECKOUT_SESSION_ID}" )
                , ( "cancel_url", Env.stripePostbackUrl ++ "/stripe/cancel" )
                ]
    in
    Http.request
        { method = "POST"
        , headers = headers
        , url = "https://api.stripe.com/v1/checkout/sessions"
        , body = body
        , expect = expectJson_ toMsg decodeSession
        , timeout = Nothing
        , tracker = Nothing
        }


type alias CreateSessionRequest =
    { payment_method_types : String
    , line_items_price : String
    , line_items_quantity : Int
    , mode : String
    , success_url : String
    , cancel_url : String
    }


type alias Session =
    { id : String }


decodeSession : D.Decoder Session
decodeSession =
    D.succeed Session
        |> required "id" D.string


headers : List Http.Header
headers =
    [ Http.header "Authorization" ("Bearer " ++ Env.stripePrivateApiKey) ]



-- Ports API


loadCheckout : String -> String -> Cmd msg
loadCheckout publicApiKey sid =
    toJsMessage "loadCheckout"
        [ ( "id", E.string sid )
        , ( "publicApiKey", E.string publicApiKey )
        ]


toJsMessage : String -> List ( String, E.Value ) -> Cmd msg
toJsMessage msg values =
    stripe_to_js <|
        E.object
            (( "msg", E.string msg ) :: values)



-- Helpers


{-| Encode a CGI parameter pair.
-}
cgiParameter : ( String, String ) -> String
cgiParameter ( key, value ) =
    percentEncode key ++ "=" ++ percentEncode value


{-| Encode a CGI parameter list.
-}
cgiParameters : List ( String, String ) -> String
cgiParameters =
    List.map cgiParameter
        >> String.join "&"


{-| Put some key-value pairs in the body of your `Request`. This will automatically
add the `Content-Type: application/x-www-form-urlencoded` header.
-}
formBody : List ( String, String ) -> Http.Body
formBody =
    cgiParameters
        >> Http.stringBody "application/x-www-form-urlencoded"
