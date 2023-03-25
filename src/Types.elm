module Types exposing (..)

import AssocList
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import EmailAddress exposing (EmailAddress)
import Http
import Lamdera exposing (ClientId, SessionId)
import PurchaseForm exposing (PurchaseForm, PurchaseFormValidated)
import Route exposing (Route)
import Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Time
import TravelMode exposing (TravelMode)
import Untrusted exposing (Untrusted)
import Url exposing (Url)


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type alias LoadingModel =
    { key : Key
    , windowSize : Maybe ( Int, Int )
    , prices : AssocList.Dict ProductId { priceId : PriceId, price : Price }
    , route : Route
    }


type alias LoadedModel =
    { key : Key
    , windowSize : ( Int, Int )
    , showTooltip : Bool
    , prices : AssocList.Dict ProductId { priceId : PriceId, price : Price }
    , selectedTicket : Maybe ( ProductId, PriceId )
    , form : PurchaseForm
    , route : Route
    }


type alias BackendModel =
    { orders : AssocList.Dict StripeSessionId Order
    , pendingOrder : AssocList.Dict StripeSessionId PendingOrder
    , prices : AssocList.Dict ProductId { priceId : PriceId, price : Price }
    , time : Time.Posix
    }


type alias PendingOrder =
    { priceId : PriceId
    , submitTime : Time.Posix
    , form : PurchaseFormValidated
    }


type alias Order =
    { priceId : PriceId
    , submitTime : Time.Posix
    , form : PurchaseFormValidated

    --, products : List Product
    --, sponsorship : Maybe Sponsorship
    --, opportunityGrantContribution : Price
    --, status : OrderStatus
    }


type OrderStatus
    = Pending
    | Failed String
    | Paid StripePaymentId
    | Refunded StripePaymentId


type StripePaymentId
    = StripePaymentId String


type Product
    = CampTicket Price
    | CouplesCampTicket Price
    | CampfireTicket Price


type Sponsorship
    = SponsorBronze Price
    | SponsorSilver Price
    | SponsorGold Price


type alias CityCode =
    String


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | PressedBuy ProductId PriceId
    | FormChanged PurchaseForm
    | PressedSubmitForm ProductId PriceId
    | PressedCancelForm


type ToBackend
    = SubmitFormRequest PriceId (Untrusted PurchaseFormValidated)


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List PriceData))
    | OnConnected SessionId ClientId
    | CreatedCheckoutSession ClientId PriceId PurchaseFormValidated (Result Http.Error ( StripeSessionId, Time.Posix ))


type ToFrontend
    = PricesToFrontend (AssocList.Dict ProductId { priceId : PriceId, price : Price })
    | SubmitFormResponse (Result () StripeSessionId)


totalSlotsAvailable =
    40
