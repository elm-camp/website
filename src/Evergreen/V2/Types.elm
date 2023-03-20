module Evergreen.V2.Types exposing (..)

import Browser
import Browser.Navigation
import Money
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , message : String
    }


type alias Email =
    String


type Amount
    = Amount Money.Currency Int


type Product
    = CampTicket Amount
    | CouplesCampTicket Amount
    | CampfireTicket Amount


type Sponsorship
    = SponsorBronze Amount
    | SponsorSilver Amount
    | SponsorGold Amount


type alias CityCode =
    String


type TravelMode
    = Flight
    | Bus
    | Car
    | Train


type alias StripePaymentId =
    String


type OrderStatus
    = Pending
    | Failed String
    | Paid StripePaymentId
    | Refunded StripePaymentId


type alias Order =
    { email : Email
    , products : List Product
    , sponsorship : Maybe Sponsorship
    , opportunityGrantContribution : Amount
    , originCity : CityCode
    , primaryTravelMode : TravelMode
    , status : OrderStatus
    }


type alias BackendModel =
    { orders : List Order
    , inventoryLimit : List ( Product, Int )
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
