module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Money
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
    , inventoryLimit : List ( Product, Int )
    }


type alias Order =
    { email : Email
    , products : List Product
    , sponsorship : Maybe Sponsorship
    , opportunityGrantContribution : Amount
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
    = CampTicket Amount
    | CouplesCampTicket Amount
    | CampfireTicket Amount


type Sponsorship
    = SponsorBronze Amount
    | SponsorSilver Amount
    | SponsorGold Amount


type Amount
    = Amount Money.Currency Int


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
    | PressedCloseTooltip


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
