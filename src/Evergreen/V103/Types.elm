module Evergreen.V103.Types exposing (..)

import Effect.Browser
import Effect.Browser.Dom
import Effect.Browser.Navigation
import Effect.Http
import Effect.Lamdera
import Effect.Time
import Evergreen.V103.Id
import Evergreen.V103.PurchaseForm
import Evergreen.V103.Route
import Evergreen.V103.Stripe
import Evergreen.V103.Ui
import Evergreen.V103.Untrusted
import Evergreen.V103.View.Logo
import Postmark
import SeqDict
import Url


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
            (Evergreen.V103.Id.Id Evergreen.V103.Stripe.ProductId)
            { priceId : Evergreen.V103.Id.Id Evergreen.V103.Stripe.PriceId
            , price : Evergreen.V103.Stripe.Price
            }
    , slotsRemaining : TicketAvailability
    , ticketsEnabled : TicketsEnabled
    }


type alias LoadingModel =
    { key : Effect.Browser.Navigation.Key
    , now : Effect.Time.Posix
    , zone : Maybe Effect.Time.Zone
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V103.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    , elmUiState : Evergreen.V103.Ui.State
    }


type EmailResult
    = SendingEmail
    | EmailSuccess
    | EmailFailed Effect.Http.Error


type alias Order =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V103.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V103.PurchaseForm.PurchaseFormValidated
    , sessionId : Effect.Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V103.Id.Id Evergreen.V103.Stripe.PriceId
    , price : Evergreen.V103.Stripe.Price
    }


type alias BackendModel =
    { orders : SeqDict.SeqDict (Evergreen.V103.Id.Id Evergreen.V103.Stripe.StripeSessionId) Order
    , pendingOrder : SeqDict.SeqDict (Evergreen.V103.Id.Id Evergreen.V103.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : SeqDict.SeqDict (Evergreen.V103.Id.Id Evergreen.V103.Stripe.StripeSessionId) PendingOrder
    , prices : SeqDict.SeqDict (Evergreen.V103.Id.Id Evergreen.V103.Stripe.ProductId) Price2
    , time : Effect.Time.Posix
    , ticketsEnabled : TicketsEnabled
    , backendInitialized : Bool
    }


type alias LoadedModel =
    { key : Effect.Browser.Navigation.Key
    , now : Effect.Time.Posix
    , zone : Maybe Effect.Time.Zone
    , window :
        { width : Int
        , height : Int
        }
    , prices :
        SeqDict.SeqDict
            (Evergreen.V103.Id.Id Evergreen.V103.Stripe.ProductId)
            { priceId : Evergreen.V103.Id.Id Evergreen.V103.Stripe.PriceId
            , price : Evergreen.V103.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V103.Id.Id Evergreen.V103.Stripe.ProductId, Evergreen.V103.Id.Id Evergreen.V103.Stripe.PriceId )
    , form : Evergreen.V103.PurchaseForm.PurchaseForm
    , route : Evergreen.V103.Route.Route
    , showTooltip : Bool
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    , isOrganiser : Bool
    , ticketsEnabled : TicketsEnabled
    , backendModel : Maybe BackendModel
    , logoModel : Evergreen.V103.View.Logo.Model
    , pressedAudioButton : Bool
    , elmUiState : Evergreen.V103.Ui.State
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
    | PressedSelectTicket (Evergreen.V103.Id.Id Evergreen.V103.Stripe.ProductId) (Evergreen.V103.Id.Id Evergreen.V103.Stripe.PriceId)
    | AddAccom Evergreen.V103.PurchaseForm.Accommodation
    | RemoveAccom Evergreen.V103.PurchaseForm.Accommodation
    | FormChanged Evergreen.V103.PurchaseForm.PurchaseForm
    | PressedSubmitForm
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | SetViewPortForElement Effect.Browser.Dom.HtmlId
    | AdminPullBackendModel
    | AdminPullBackendModelResponse (Result Effect.Http.Error BackendModel)
    | LogoMsg Evergreen.V103.View.Logo.Msg
    | Noop
    | ElmUiMsg Evergreen.V103.Ui.Msg


type ToBackend
    = SubmitFormRequest (Evergreen.V103.Untrusted.Untrusted Evergreen.V103.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Effect.Time.Posix
    | GotPrices (Result Effect.Http.Error (List Evergreen.V103.Stripe.PriceData))
    | OnConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | CreatedCheckoutSession Effect.Lamdera.SessionId Effect.Lamdera.ClientId Evergreen.V103.PurchaseForm.PurchaseFormValidated (Result Effect.Http.Error ( Evergreen.V103.Id.Id Evergreen.V103.Stripe.StripeSessionId, Effect.Time.Posix ))
    | ExpiredStripeSession (Evergreen.V103.Id.Id Evergreen.V103.Stripe.StripeSessionId) (Result Effect.Http.Error ())
    | ConfirmationEmailSent (Evergreen.V103.Id.Id Evergreen.V103.Stripe.StripeSessionId) (Result Effect.Http.Error ())
    | ErrorEmailSent (Result Postmark.SendEmailError ())


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V103.Id.Id Evergreen.V103.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
