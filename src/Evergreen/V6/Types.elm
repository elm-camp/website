module Evergreen.V6.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V6.Id
import Evergreen.V6.Postmark
import Evergreen.V6.PurchaseForm
import Evergreen.V6.Route
import Evergreen.V6.Stripe
import Evergreen.V6.Untrusted
import Http
import Lamdera
import Time
import Url


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , windowSize : Maybe ( Int, Int )
    , prices :
        AssocList.Dict
            (Evergreen.V6.Id.Id Evergreen.V6.Stripe.ProductId)
            { priceId : Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId
            , price : Evergreen.V6.Stripe.Price
            }
    , slotsRemaining : Maybe Int
    , route : Evergreen.V6.Route.Route
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , windowSize : ( Int, Int )
    , showTooltip : Bool
    , prices :
        AssocList.Dict
            (Evergreen.V6.Id.Id Evergreen.V6.Stripe.ProductId)
            { priceId : Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId
            , price : Evergreen.V6.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V6.Id.Id Evergreen.V6.Stripe.ProductId, Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId )
    , form : Evergreen.V6.PurchaseForm.PurchaseForm
    , route : Evergreen.V6.Route.Route
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : Int
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V6.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V6.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V6.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId
    , price : Evergreen.V6.Stripe.Price
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V6.Id.Id Evergreen.V6.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V6.Id.Id Evergreen.V6.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V6.Id.Id Evergreen.V6.Stripe.ProductId) Price2
    , time : Time.Posix
    , dummyField : Int
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | PressedSelectTicket (Evergreen.V6.Id.Id Evergreen.V6.Stripe.ProductId) (Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId)
    | FormChanged Evergreen.V6.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V6.Id.Id Evergreen.V6.Stripe.ProductId) (Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport


type ToBackend
    = SubmitFormRequest (Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId) (Evergreen.V6.Untrusted.Untrusted Evergreen.V6.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V6.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId) Evergreen.V6.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V6.Id.Id Evergreen.V6.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V6.Id.Id Evergreen.V6.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V6.Id.Id Evergreen.V6.Stripe.StripeSessionId) (Result Http.Error Evergreen.V6.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V6.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData
        { prices :
            AssocList.Dict
                (Evergreen.V6.Id.Id Evergreen.V6.Stripe.ProductId)
                { priceId : Evergreen.V6.Id.Id Evergreen.V6.Stripe.PriceId
                , price : Evergreen.V6.Stripe.Price
                }
        , slotsRemaining : Int
        }
    | SubmitFormResponse (Result () (Evergreen.V6.Id.Id Evergreen.V6.Stripe.StripeSessionId))
    | SlotRemainingChanged Int
