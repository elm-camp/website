module Evergreen.V104.Types exposing (..)

import Effect.Browser
import Effect.Browser.Dom
import Effect.Browser.Navigation
import Effect.Http
import Effect.Lamdera
import Effect.Time
import Evergreen.V104.Id
import Evergreen.V104.PurchaseForm
import Evergreen.V104.Route
import Evergreen.V104.Stripe
import Evergreen.V104.Ui
import Evergreen.V104.Untrusted
import Evergreen.V104.View.Logo
import Postmark
import SeqDict
import Url


type alias Size =
    { width : Int
    , height : Int
    }


type alias TicketAvailability =
    { attendanceTickets : Bool
    , campingSpots : Bool
    , singleRooms : Bool
    , doubleRooms : Bool
    , groupRooms : Bool
    }


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled
        { adminMessage : String
        }


type alias InitData2 =
    { prices :
        SeqDict.SeqDict
            (Evergreen.V104.Id.Id Evergreen.V104.Stripe.ProductId)
            { priceId : Evergreen.V104.Id.Id Evergreen.V104.Stripe.PriceId
            , price : Evergreen.V104.Stripe.Price
            }
    , slotsRemaining : TicketAvailability
    , ticketsEnabled : TicketsEnabled
    }


type alias LoadingModel =
    { key : Effect.Browser.Navigation.Key
    , now : Maybe Effect.Time.Posix
    , timeZone : Maybe Effect.Time.Zone
    , window : Maybe Size
    , url : Url.Url
    , isOrganiser : Bool
    , initData : Maybe InitData2
    , elmUiState : Evergreen.V104.Ui.State
    }


type EmailResult
    = SendingEmail
    | EmailSuccess
    | EmailFailed Effect.Http.Error


type alias Order =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V104.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V104.PurchaseForm.PurchaseFormValidated
    , sessionId : Effect.Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V104.Id.Id Evergreen.V104.Stripe.PriceId
    , price : Evergreen.V104.Stripe.Price
    }


type alias BackendModel =
    { orders : SeqDict.SeqDict (Evergreen.V104.Id.Id Evergreen.V104.Stripe.StripeSessionId) Order
    , pendingOrder : SeqDict.SeqDict (Evergreen.V104.Id.Id Evergreen.V104.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : SeqDict.SeqDict (Evergreen.V104.Id.Id Evergreen.V104.Stripe.StripeSessionId) PendingOrder
    , prices : SeqDict.SeqDict (Evergreen.V104.Id.Id Evergreen.V104.Stripe.ProductId) Price2
    , time : Effect.Time.Posix
    , ticketsEnabled : TicketsEnabled
    , backendInitialized : Bool
    }


type alias LoadedModel =
    { key : Effect.Browser.Navigation.Key
    , now : Effect.Time.Posix
    , timeZone : Effect.Time.Zone
    , window : Size
    , prices :
        SeqDict.SeqDict
            (Evergreen.V104.Id.Id Evergreen.V104.Stripe.ProductId)
            { priceId : Evergreen.V104.Id.Id Evergreen.V104.Stripe.PriceId
            , price : Evergreen.V104.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V104.Id.Id Evergreen.V104.Stripe.ProductId, Evergreen.V104.Id.Id Evergreen.V104.Stripe.PriceId )
    , form : Evergreen.V104.PurchaseForm.PurchaseForm
    , route : Evergreen.V104.Route.Route
    , showTooltip : Bool
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    , isOrganiser : Bool
    , ticketsEnabled : TicketsEnabled
    , backendModel : Maybe BackendModel
    , logoModel : Evergreen.V104.View.Logo.Model
    , pressedAudioButton : Bool
    , elmUiState : Evergreen.V104.Ui.State
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type FrontendMsg
    = UrlClicked Effect.Browser.UrlRequest
    | UrlChanged Url.Url
    | Tick Effect.Time.Posix
    | GotZone Effect.Time.Zone
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | DownloadTicketSalesReminder
    | PressedSelectTicket (Evergreen.V104.Id.Id Evergreen.V104.Stripe.ProductId) (Evergreen.V104.Id.Id Evergreen.V104.Stripe.PriceId)
    | AddAccom Evergreen.V104.PurchaseForm.Accommodation
    | RemoveAccom Evergreen.V104.PurchaseForm.Accommodation
    | FormChanged Evergreen.V104.PurchaseForm.PurchaseForm
    | PressedSubmitForm
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | SetViewPortForElement Effect.Browser.Dom.HtmlId
    | AdminPullBackendModel
    | AdminPullBackendModelResponse (Result Effect.Http.Error BackendModel)
    | LogoMsg Evergreen.V104.View.Logo.Msg
    | Noop
    | ElmUiMsg Evergreen.V104.Ui.Msg
    | ScrolledToFragment


type ToBackend
    = SubmitFormRequest (Evergreen.V104.Untrusted.Untrusted Evergreen.V104.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Effect.Time.Posix
    | GotPrices (Result Effect.Http.Error (List Evergreen.V104.Stripe.PriceData))
    | OnConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | CreatedCheckoutSession Effect.Lamdera.SessionId Effect.Lamdera.ClientId Evergreen.V104.PurchaseForm.PurchaseFormValidated (Result Effect.Http.Error ( Evergreen.V104.Id.Id Evergreen.V104.Stripe.StripeSessionId, Effect.Time.Posix ))
    | ExpiredStripeSession (Evergreen.V104.Id.Id Evergreen.V104.Stripe.StripeSessionId) (Result Effect.Http.Error ())
    | ConfirmationEmailSent (Evergreen.V104.Id.Id Evergreen.V104.Stripe.StripeSessionId) (Result Effect.Http.Error ())
    | ErrorEmailSent (Result Postmark.SendEmailError ())


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V104.Id.Id Evergreen.V104.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
