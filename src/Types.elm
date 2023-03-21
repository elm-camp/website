module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Money
import Stripe.Api exposing (Price)
import Url exposing (Url)


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type alias LoadingModel =
    { key : Key, windowSize : Maybe ( Int, Int ) }


type alias LoadedModel =
    { key : Key
    , windowSize : ( Int, Int )
    , showTooltip : Bool
    }


type alias BackendModel =
    { orders : List Order
    }


type alias Order =
    { email : Email
    , products : List Product
    , sponsorship : Maybe Sponsorship
    , opportunityGrantContribution : Price
    , originCity : CityCode
    , primaryTravelMode : TravelMode
    , status : OrderStatus
    }


type OrderStatus
    = Pending
    | Failed String
    | Paid StripePaymentId
    | Refunded StripePaymentId


type alias StripePaymentId =
    String


type Product
    = CampTicket Price
    | CouplesCampTicket Price
    | CampfireTicket Price


type Sponsorship
    = SponsorBronze Price
    | SponsorSilver Price
    | SponsorGold Price


type TravelMode
    = Flight
    | Bus
    | Car
    | Train


type alias Email =
    String


type alias CityCode =
    String


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
