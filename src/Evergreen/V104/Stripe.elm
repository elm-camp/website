module Evergreen.V104.Stripe exposing (..)

import Effect.Time
import Evergreen.V104.Id
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
    { priceId : Evergreen.V104.Id.Id PriceId
    , price : Price
    , productId : Evergreen.V104.Id.Id ProductId
    , isActive : Bool
    , createdAt : Effect.Time.Posix
    }
