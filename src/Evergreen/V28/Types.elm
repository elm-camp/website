module Evergreen.V28.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V28.Id
import Evergreen.V28.Postmark
import Evergreen.V28.PurchaseForm
import Evergreen.V28.Route
import Evergreen.V28.Stripe
import Evergreen.V28.Untrusted
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
            (Evergreen.V28.Id.Id Evergreen.V28.Stripe.ProductId)
            { priceId : Evergreen.V28.Id.Id Evergreen.V28.Stripe.PriceId
            , price : Evergreen.V28.Stripe.Price
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
    , route : Evergreen.V28.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
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
            (Evergreen.V28.Id.Id Evergreen.V28.Stripe.ProductId)
            { priceId : Evergreen.V28.Id.Id Evergreen.V28.Stripe.PriceId
            , price : Evergreen.V28.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V28.Id.Id Evergreen.V28.Stripe.ProductId, Evergreen.V28.Id.Id Evergreen.V28.Stripe.PriceId )
    , form : Evergreen.V28.PurchaseForm.PurchaseForm
    , route : Evergreen.V28.Route.Route
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    , isOrganiser : Bool
    , ticketsEnabled : TicketsEnabled
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V28.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V28.Id.Id Evergreen.V28.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V28.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V28.Id.Id Evergreen.V28.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V28.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V28.Id.Id Evergreen.V28.Stripe.PriceId
    , price : Evergreen.V28.Stripe.Price
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V28.Id.Id Evergreen.V28.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V28.Id.Id Evergreen.V28.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V28.Id.Id Evergreen.V28.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V28.Id.Id Evergreen.V28.Stripe.ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | PressedSelectTicket (Evergreen.V28.Id.Id Evergreen.V28.Stripe.ProductId) (Evergreen.V28.Id.Id Evergreen.V28.Stripe.PriceId)
    | FormChanged Evergreen.V28.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V28.Id.Id Evergreen.V28.Stripe.ProductId) (Evergreen.V28.Id.Id Evergreen.V28.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport


type ToBackend
    = SubmitFormRequest (Evergreen.V28.Id.Id Evergreen.V28.Stripe.PriceId) (Evergreen.V28.Untrusted.Untrusted Evergreen.V28.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V28.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V28.Id.Id Evergreen.V28.Stripe.PriceId) Evergreen.V28.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V28.Id.Id Evergreen.V28.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V28.Id.Id Evergreen.V28.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V28.Id.Id Evergreen.V28.Stripe.StripeSessionId) (Result Http.Error Evergreen.V28.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V28.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V28.Id.Id Evergreen.V28.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
    | TicketsEnabledChanged TicketsEnabled
