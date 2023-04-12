module Evergreen.V9.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V9.Id
import Evergreen.V9.Postmark
import Evergreen.V9.PurchaseForm
import Evergreen.V9.Route
import Evergreen.V9.Stripe
import Evergreen.V9.Untrusted
import Http
import Lamdera
import Time
import Url


type alias TicketAvailability =
    { campTicket : Bool
    , couplesCampTicket : Bool
    , campfireTicket : Bool
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , windowSize : Maybe ( Int, Int )
    , prices :
        AssocList.Dict
            (Evergreen.V9.Id.Id Evergreen.V9.Stripe.ProductId)
            { priceId : Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId
            , price : Evergreen.V9.Stripe.Price
            }
    , slotsRemaining : Maybe TicketAvailability
    , route : Evergreen.V9.Route.Route
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , windowSize : ( Int, Int )
    , showTooltip : Bool
    , prices :
        AssocList.Dict
            (Evergreen.V9.Id.Id Evergreen.V9.Stripe.ProductId)
            { priceId : Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId
            , price : Evergreen.V9.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V9.Id.Id Evergreen.V9.Stripe.ProductId, Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId )
    , form : Evergreen.V9.PurchaseForm.PurchaseForm
    , route : Evergreen.V9.Route.Route
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V9.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V9.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V9.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId
    , price : Evergreen.V9.Stripe.Price
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V9.Id.Id Evergreen.V9.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V9.Id.Id Evergreen.V9.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V9.Id.Id Evergreen.V9.Stripe.ProductId) Price2
    , time : Time.Posix
    , dummyField : Int
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | PressedSelectTicket (Evergreen.V9.Id.Id Evergreen.V9.Stripe.ProductId) (Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId)
    | FormChanged Evergreen.V9.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V9.Id.Id Evergreen.V9.Stripe.ProductId) (Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport


type ToBackend
    = SubmitFormRequest (Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId) (Evergreen.V9.Untrusted.Untrusted Evergreen.V9.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V9.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId) Evergreen.V9.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V9.Id.Id Evergreen.V9.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V9.Id.Id Evergreen.V9.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V9.Id.Id Evergreen.V9.Stripe.StripeSessionId) (Result Http.Error Evergreen.V9.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V9.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData
        { prices :
            AssocList.Dict
                (Evergreen.V9.Id.Id Evergreen.V9.Stripe.ProductId)
                { priceId : Evergreen.V9.Id.Id Evergreen.V9.Stripe.PriceId
                , price : Evergreen.V9.Stripe.Price
                }
        , slotsRemaining : TicketAvailability
        }
    | SubmitFormResponse (Result String (Evergreen.V9.Id.Id Evergreen.V9.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
