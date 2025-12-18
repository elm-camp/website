module Evergreen.V97.Stripe exposing (..)

import Effect.Time
import Evergreen.V97.Id
import Money


type ProductId
    = ProductId Never


type PriceId
    = PriceId Never


type alias Price =
    { currency : Money.Currency
    , amount : Int
    }


type StripeSessionId
    = StripeSessionId Never


type alias PriceData =
    { priceId : Evergreen.V97.Id.Id PriceId
    , price : Price
    , productId : Evergreen.V97.Id.Id ProductId
    , isActive : Bool
    , createdAt : Effect.Time.Posix
    }
