module Evergreen.V50.Types exposing (..)

import AssocList
import Audio
import Browser
import Browser.Navigation
import Evergreen.V50.Id
import Evergreen.V50.LiveSchedule
import Evergreen.V50.Postmark
import Evergreen.V50.PurchaseForm
import Evergreen.V50.Route
import Evergreen.V50.Stripe
import Evergreen.V50.Untrusted
import Http
import Lamdera
import Time
import Url


type FrontendMsg_
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | PressedSelectTicket (Evergreen.V50.Id.Id Evergreen.V50.Stripe.ProductId) (Evergreen.V50.Id.Id Evergreen.V50.Stripe.PriceId)
    | FormChanged Evergreen.V50.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V50.Id.Id Evergreen.V50.Stripe.ProductId) (Evergreen.V50.Id.Id Evergreen.V50.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | LoadedMusic (Result Audio.LoadError Audio.Source)
    | LiveScheduleMsg Evergreen.V50.LiveSchedule.Msg


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
    { prices : (AssocList.Dict (Evergreen.V50.Id.Id Evergreen.V50.Stripe.ProductId) 
    { priceId : (Evergreen.V50.Id.Id Evergreen.V50.Stripe.PriceId)
    , price : Evergreen.V50.Stripe.Price
    })
    , slotsRemaining : TicketAvailability
    , ticketsEnabled : TicketsEnabled
    }


type alias LoadingModel = 
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window : (Maybe 
    { width : Int
    , height : Int
    })
    , route : Evergreen.V50.Route.Route
    , isOrganiser : Bool
    , initData : (Maybe InitData2)
    , audio : (Maybe (Result Audio.LoadError Audio.Source))
    }


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V50.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order = 
    { priceId : (Evergreen.V50.Id.Id Evergreen.V50.Stripe.PriceId)
    , submitTime : Time.Posix
    , form : Evergreen.V50.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder = 
    { priceId : (Evergreen.V50.Id.Id Evergreen.V50.Stripe.PriceId)
    , submitTime : Time.Posix
    , form : Evergreen.V50.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 = 
    { priceId : (Evergreen.V50.Id.Id Evergreen.V50.Stripe.PriceId)
    , price : Evergreen.V50.Stripe.Price
    }


type alias BackendModel = 
    { orders : (AssocList.Dict (Evergreen.V50.Id.Id Evergreen.V50.Stripe.StripeSessionId) Order)
    , pendingOrder : (AssocList.Dict (Evergreen.V50.Id.Id Evergreen.V50.Stripe.StripeSessionId) PendingOrder)
    , expiredOrders : (AssocList.Dict (Evergreen.V50.Id.Id Evergreen.V50.Stripe.StripeSessionId) PendingOrder)
    , prices : (AssocList.Dict (Evergreen.V50.Id.Id Evergreen.V50.Stripe.ProductId) Price2)
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
    , prices : (AssocList.Dict (Evergreen.V50.Id.Id Evergreen.V50.Stripe.ProductId) 
    { priceId : (Evergreen.V50.Id.Id Evergreen.V50.Stripe.PriceId)
    , price : Evergreen.V50.Stripe.Price
    })
    , selectedTicket : (Maybe ((Evergreen.V50.Id.Id Evergreen.V50.Stripe.ProductId), (Evergreen.V50.Id.Id Evergreen.V50.Stripe.PriceId)))
    , form : Evergreen.V50.PurchaseForm.PurchaseForm
    , route : Evergreen.V50.Route.Route
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    , isOrganiser : Bool
    , ticketsEnabled : TicketsEnabled
    , backendModel : (Maybe BackendModel)
    , audio : (Maybe Audio.Source)
    , pressedAudioButton : Bool
    }


type FrontendModel_
    = Loading LoadingModel
    | Loaded LoadedModel


type alias FrontendModel =(Audio.Model FrontendMsg_ FrontendModel_)


type alias BackendModel =
    { orders : (AssocList.Dict (Evergreen.V50.Id.Id Evergreen.V50.Stripe.StripeSessionId) Order)
    , pendingOrder : (AssocList.Dict (Evergreen.V50.Id.Id Evergreen.V50.Stripe.StripeSessionId) PendingOrder)
    , expiredOrders : (AssocList.Dict (Evergreen.V50.Id.Id Evergreen.V50.Stripe.StripeSessionId) PendingOrder)
    , prices : (AssocList.Dict (Evergreen.V50.Id.Id Evergreen.V50.Stripe.ProductId) Price2)
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    }


type alias FrontendMsg =(Audio.Msg FrontendMsg_)


type ToBackend
    = SubmitFormRequest (Evergreen.V50.Id.Id Evergreen.V50.Stripe.PriceId) (Evergreen.V50.Untrusted.Untrusted Evergreen.V50.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V50.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V50.Id.Id Evergreen.V50.Stripe.PriceId) Evergreen.V50.PurchaseForm.PurchaseFormValidated (Result Http.Error ((Evergreen.V50.Id.Id Evergreen.V50.Stripe.StripeSessionId), Time.Posix))
    | ExpiredStripeSession (Evergreen.V50.Id.Id Evergreen.V50.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V50.Id.Id Evergreen.V50.Stripe.StripeSessionId) (Result Http.Error Evergreen.V50.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V50.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V50.Id.Id Evergreen.V50.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel