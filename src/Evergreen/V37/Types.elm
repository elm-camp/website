module Evergreen.V37.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V37.Id
import Evergreen.V37.Postmark
import Evergreen.V37.PurchaseForm
import Evergreen.V37.Route
import Evergreen.V37.Stripe
import Evergreen.V37.Untrusted
import Http
import Lamdera
import Time
import Url


type alias TicketAvailability =
    { campTicket : Bool
    , couplesCampTicket : Bool
    , campfireTicket : Bool
    }


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled
        { adminMessage : String
        }


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V37.Id.Id Evergreen.V37.Stripe.ProductId)
            { priceId : Evergreen.V37.Id.Id Evergreen.V37.Stripe.PriceId
            , price : Evergreen.V37.Stripe.Price
            }
    , slotsRemaining : TicketAvailability
    , ticketsEnabled : TicketsEnabled
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V37.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V37.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V37.Id.Id Evergreen.V37.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V37.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V37.Id.Id Evergreen.V37.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V37.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V37.Id.Id Evergreen.V37.Stripe.PriceId
    , price : Evergreen.V37.Stripe.Price
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V37.Id.Id Evergreen.V37.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V37.Id.Id Evergreen.V37.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V37.Id.Id Evergreen.V37.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V37.Id.Id Evergreen.V37.Stripe.ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , showTooltip : Bool
    , prices :
        AssocList.Dict
            (Evergreen.V37.Id.Id Evergreen.V37.Stripe.ProductId)
            { priceId : Evergreen.V37.Id.Id Evergreen.V37.Stripe.PriceId
            , price : Evergreen.V37.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V37.Id.Id Evergreen.V37.Stripe.ProductId, Evergreen.V37.Id.Id Evergreen.V37.Stripe.PriceId )
    , form : Evergreen.V37.PurchaseForm.PurchaseForm
    , route : Evergreen.V37.Route.Route
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    , isOrganiser : Bool
    , ticketsEnabled : TicketsEnabled
    , backendModel : Maybe BackendModel
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | PressedSelectTicket (Evergreen.V37.Id.Id Evergreen.V37.Stripe.ProductId) (Evergreen.V37.Id.Id Evergreen.V37.Stripe.PriceId)
    | FormChanged Evergreen.V37.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V37.Id.Id Evergreen.V37.Stripe.ProductId) (Evergreen.V37.Id.Id Evergreen.V37.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport


type ToBackend
    = SubmitFormRequest (Evergreen.V37.Id.Id Evergreen.V37.Stripe.PriceId) (Evergreen.V37.Untrusted.Untrusted Evergreen.V37.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V37.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V37.Id.Id Evergreen.V37.Stripe.PriceId) Evergreen.V37.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V37.Id.Id Evergreen.V37.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V37.Id.Id Evergreen.V37.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V37.Id.Id Evergreen.V37.Stripe.StripeSessionId) (Result Http.Error Evergreen.V37.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V37.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V37.Id.Id Evergreen.V37.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
