module Evergreen.V3.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V3.Id
import Evergreen.V3.Postmark
import Evergreen.V3.PurchaseForm
import Evergreen.V3.Route
import Evergreen.V3.Stripe
import Evergreen.V3.Untrusted
import Http
import Lamdera
import Time
import Url


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , windowSize : Maybe ( Int, Int )
    , prices :
        AssocList.Dict
            (Evergreen.V3.Id.Id Evergreen.V3.Stripe.ProductId)
            { priceId : Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId
            , price : Evergreen.V3.Stripe.Price
            }
    , slotsRemaining : Maybe Int
    , route : Evergreen.V3.Route.Route
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , windowSize : ( Int, Int )
    , showTooltip : Bool
    , prices :
        AssocList.Dict
            (Evergreen.V3.Id.Id Evergreen.V3.Stripe.ProductId)
            { priceId : Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId
            , price : Evergreen.V3.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V3.Id.Id Evergreen.V3.Stripe.ProductId, Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId )
    , form : Evergreen.V3.PurchaseForm.PurchaseForm
    , route : Evergreen.V3.Route.Route
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : Int
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V3.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V3.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V3.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId
    , price : Evergreen.V3.Stripe.Price
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V3.Id.Id Evergreen.V3.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V3.Id.Id Evergreen.V3.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V3.Id.Id Evergreen.V3.Stripe.ProductId) Price2
    , time : Time.Posix
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | PressedSelectTicket (Evergreen.V3.Id.Id Evergreen.V3.Stripe.ProductId) (Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId)
    | FormChanged Evergreen.V3.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V3.Id.Id Evergreen.V3.Stripe.ProductId) (Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport


type ToBackend
    = SubmitFormRequest (Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId) (Evergreen.V3.Untrusted.Untrusted Evergreen.V3.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V3.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId) Evergreen.V3.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V3.Id.Id Evergreen.V3.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V3.Id.Id Evergreen.V3.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V3.Id.Id Evergreen.V3.Stripe.StripeSessionId) (Result Http.Error Evergreen.V3.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V3.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData
        { prices :
            AssocList.Dict
                (Evergreen.V3.Id.Id Evergreen.V3.Stripe.ProductId)
                { priceId : Evergreen.V3.Id.Id Evergreen.V3.Stripe.PriceId
                , price : Evergreen.V3.Stripe.Price
                }
        , slotsRemaining : Int
        }
    | SubmitFormResponse (Result () (Evergreen.V3.Id.Id Evergreen.V3.Stripe.StripeSessionId))
    | SlotRemainingChanged Int
