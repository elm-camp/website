module Stripe exposing (Price(..), PriceData, PriceId(..), ProductId(..), StripeSessionId(..), cancelPath, createCheckoutSession, emailAddressParameter, getPrices, loadCheckout, successPath)

import EmailAddress exposing (EmailAddress)
import Env
import Http
import HttpHelpers exposing (..)
import Json.Decode as D
import Json.Decode.Pipeline exposing (..)
import Json.Encode as E
import Money
import Ports exposing (stripe_to_js)
import Task exposing (Task)
import Time
import Url exposing (percentEncode)
import Url.Builder



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


createCheckoutSession : PriceId -> EmailAddress -> Task Http.Error StripeSessionId
createCheckoutSession (PriceId priceId) emailAddress =
    -- @TODO support multiple prices, see Data.Tickets
    let
        body =
            formBody
                [ ( "line_items[][price]", priceId )
                , ( "line_items[][quantity]", "1" )
                , ( "mode", "payment" )
                , ( "success_url"
                  , Url.Builder.crossOrigin
                        Env.stripePostbackUrl
                        [ successPath ]
                        [ Url.Builder.string emailAddressParameter (EmailAddress.toString emailAddress) ]
                  )
                , ( "cancel_url", Url.Builder.crossOrigin Env.stripePostbackUrl [ cancelPath ] [] )
                ]
    in
    Http.task
        { method = "POST"
        , headers = headers
        , url = "https://api.stripe.com/v1/checkout/sessions"
        , body = body
        , resolver = jsonResolver decodeSession
        , timeout = Nothing
        }


emailAddressParameter : String
emailAddressParameter =
    "email-address"


successPath : String
successPath =
    "stripeSuccess"


cancelPath : String
cancelPath =
    "stripeCancel"


type alias CreateSessionRequest =
    { payment_method_types : String
    , line_items_price : String
    , line_items_quantity : Int
    , mode : String
    , success_url : String
    , cancel_url : String
    }


type StripeSessionId
    = StripeSessionId String


decodeSession : D.Decoder StripeSessionId
decodeSession =
    D.succeed StripeSessionId
        |> required "id" D.string


headers : List Http.Header
headers =
    [ Http.header "Authorization" ("Bearer " ++ Env.stripePrivateApiKey) ]



-- Ports API


loadCheckout : String -> StripeSessionId -> Cmd msg
loadCheckout publicApiKey (StripeSessionId sid) =
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
