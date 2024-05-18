module Evergreen.V83.Stripe exposing (..)

import Evergreen.V83.Id
import Money
import Time


type ProductId
    = ProductId Never


type PriceId
    = PriceId Never


type StripeSessionId
    = StripeSessionId Never


type alias Price =
    { currency : Money.Currency
    , amount : Int
    }


type alias PriceData =
    { priceId : Evergreen.V83.Id.Id PriceId
    , price : Price
    , productId : Evergreen.V83.Id.Id ProductId
    , isActive : Bool
    , createdAt : Time.Posix
    }
