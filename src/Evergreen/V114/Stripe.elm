module Evergreen.V114.Stripe exposing (..)

import Effect.Http
import Effect.Time
import Evergreen.V114.Id
import Money
import Quantity
import SeqDict


type PriceId
    = PriceId Never


type StripeCurrency
    = StripeCurrency Never


type alias Price =
    { priceId : Evergreen.V114.Id.Id PriceId
    , amount : Quantity.Quantity Int StripeCurrency
    }


type LocalCurrency
    = LocalCurrency Never


type StripeSessionId
    = StripeSessionId Never


type StripePaymentId
    = StripePaymentId Never


type ConversionRateStatus
    = LoadingConversionRate
    | LoadedConversionRate (SeqDict.SeqDict Money.Currency (Quantity.Quantity Float (Quantity.Rate StripeCurrency LocalCurrency)))
    | LoadingConversionRateFailed Effect.Http.Error


type ProductId
    = ProductId Never


type alias PriceData =
    { price : Price
    , currency : Money.Currency
    , productId : Evergreen.V114.Id.Id ProductId
    , isActive : Bool
    , createdAt : Effect.Time.Posix
    }
