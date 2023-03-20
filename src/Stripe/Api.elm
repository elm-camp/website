module Stripe.Api exposing (..)

import Env
import Http
import HttpHelpers exposing (..)
import Json.Decode as D
import Json.Decode.Pipeline exposing (..)
import Json.Encode as E
import Ports exposing (stripe_to_js)
import RemoteData
import Url exposing (percentEncode)



-- HTTP Backend API


createCheckoutSession priceId toMsg =
    let
        body =
            formBody
                [ ( "payment_method_types[]", "card" )
                , ( "line_items[][price]", Env.stripeProductPriceSupporter )
                , ( "line_items[][quantity]", "1" )
                , ( "mode", "subscription" )
                , ( "success_url", Env.stripePostbackUrl ++ "/stripe/success?session_id={CHECKOUT_SESSION_ID}" )
                , ( "cancel_url", Env.stripePostbackUrl ++ "/stripe/cancel" )
                ]
    in
    Http.request
        { method = "POST"
        , headers =
            [ Http.header "Authorization" ("Bearer " ++ Env.stripePrivateApiKey)
            ]
        , url = "https://api.stripe.com/v1/checkout/sessions"
        , body = body
        , expect = expectJson_ (RemoteData.fromResult >> toMsg) decodeSession
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


decodeSession =
    D.succeed Session
        |> required "id" D.string



-- Ports API


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
