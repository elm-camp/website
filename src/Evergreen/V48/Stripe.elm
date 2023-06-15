module Evergreen.V48.Stripe exposing (..)

import Evergreen.V48.Id
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
    { priceId : Evergreen.V48.Id.Id PriceId
    , price : Price
    , productId : Evergreen.V48.Id.Id ProductId
    , isActive : Bool
    , createdAt : Time.Posix
    }
