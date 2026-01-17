module Evergreen.V103.Stripe exposing (..)

import Effect.Time
import Evergreen.V103.Id
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
    { priceId : Evergreen.V103.Id.Id PriceId
    , price : Price
    , productId : Evergreen.V103.Id.Id ProductId
    , isActive : Bool
    , createdAt : Effect.Time.Posix
    }
