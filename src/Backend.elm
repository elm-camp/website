module Backend exposing (..)

import AssocList
import Html
import Lamdera exposing (ClientId, SessionId)
import Stripe
import Task
import Time
import Types exposing (..)


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( BackendModel, Cmd BackendMsg )
init =
    let
        _ =
            Stripe.loadCheckout
    in
    ( { orders = []
      , prices = AssocList.empty
      , time = Time.millisToPosix 0
      }
    , Cmd.batch
        [ Time.now |> Task.perform GotTime
        , Stripe.getPrices GotPrices
        ]
    )


subscriptions _ =
    Sub.batch
        [ Time.every (1000 * 60 * 15) GotTime
        , Lamdera.onConnect OnConnected
        ]


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        GotTime time ->
            ( { model | time = time }, Stripe.getPrices GotPrices )

        GotPrices result ->
            case result of
                Ok prices ->
                    ( { model
                        | prices =
                            List.filterMap
                                (\price ->
                                    if price.isActive then
                                        Just ( price.productId, { priceId = price.priceId, price = price.price } )

                                    else
                                        Nothing
                                )
                                prices
                                |> AssocList.fromList
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        OnConnected _ clientId ->
            ( model, Lamdera.sendToFrontend clientId (PricesToFrontend model.prices) )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )
