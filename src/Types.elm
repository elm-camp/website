module Types exposing (..)

import AssocList
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import EmailAddress exposing (EmailAddress)
import Http
import Lamdera exposing (ClientId, SessionId)
import Name exposing (Name)
import Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Time
import TravelMode exposing (TravelMode)
import Untrusted exposing (Untrusted)
import Url exposing (Url)


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type alias LoadingModel =
    { key : Key, windowSize : Maybe ( Int, Int ), prices : AssocList.Dict ProductId { priceId : PriceId, price : Price } }


type alias LoadedModel =
    { key : Key
    , windowSize : ( Int, Int )
    , showTooltip : Bool
    , prices : AssocList.Dict ProductId { priceId : PriceId, price : Price }
    , selectedTicket : Maybe ( ProductId, PriceId )
    , form : PurchaseForm
    }


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , attendee1Name : String
    , attendee2Name : String
    , billingEmail : String
    , originCity : String
    , primaryModeOfTravel : Maybe TravelMode
    }


type SubmitStatus
    = NotSubmitted PressedSubmit
    | Submitting
    | SubmitBackendError


type PressedSubmit
    = PressedSubmit
    | NotPressedSubmit


type PurchaseFormValidated
    = SinglePurchase
        { attendeeName : Name
        , billingEmail : EmailAddress
        , originCity : String
        , primaryModeOfTravel : TravelMode
        }
    | CouplePurchase
        { attendee1Name : Name
        , attendee2Name : Name
        , billingEmail : EmailAddress
        , originCity : String
        , primaryModeOfTravel : TravelMode
        }


type alias BackendModel =
    { orders : List Order
    , prices : AssocList.Dict ProductId { priceId : PriceId, price : Price }
    , time : Time.Posix
    }


type alias Order =
    { email : EmailAddress
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
    | CreatedCheckoutSession ClientId (Result Http.Error StripeSessionId)


type ToFrontend
    = PricesToFrontend (AssocList.Dict ProductId { priceId : PriceId, price : Price })
    | SubmitFormResponse (Result () StripeSessionId)
