module Evergreen.V63.Stripe exposing (..)

import Evergreen.V63.Id
import Money
import Time


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
    { priceId : Evergreen.V63.Id.Id PriceId
    , price : Price
    , productId : Evergreen.V63.Id.Id ProductId
    , isActive : Bool
    , createdAt : Time.Posix
    }
