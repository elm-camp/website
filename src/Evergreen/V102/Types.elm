module Evergreen.V102.Types exposing (..)

import Effect.Browser
import Effect.Browser.Dom
import Effect.Browser.Navigation
import Effect.Http
import Effect.Lamdera
import Effect.Time
import Evergreen.V102.Id
import Evergreen.V102.PurchaseForm
import Evergreen.V102.Route
import Evergreen.V102.Stripe
import Evergreen.V102.Untrusted
import Evergreen.V102.View.Logo
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
            (Evergreen.V102.Id.Id Evergreen.V102.Stripe.ProductId)
            { priceId : Evergreen.V102.Id.Id Evergreen.V102.Stripe.PriceId
            , price : Evergreen.V102.Stripe.Price
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
    , route : Evergreen.V102.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    }


type EmailResult
    = SendingEmail
    | EmailSuccess
    | EmailFailed Effect.Http.Error


type alias Order =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V102.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V102.PurchaseForm.PurchaseFormValidated
    , sessionId : Effect.Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V102.Id.Id Evergreen.V102.Stripe.PriceId
    , price : Evergreen.V102.Stripe.Price
    }


type alias BackendModel =
    { orders : SeqDict.SeqDict (Evergreen.V102.Id.Id Evergreen.V102.Stripe.StripeSessionId) Order
    , pendingOrder : SeqDict.SeqDict (Evergreen.V102.Id.Id Evergreen.V102.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : SeqDict.SeqDict (Evergreen.V102.Id.Id Evergreen.V102.Stripe.StripeSessionId) PendingOrder
    , prices : SeqDict.SeqDict (Evergreen.V102.Id.Id Evergreen.V102.Stripe.ProductId) Price2
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
            (Evergreen.V102.Id.Id Evergreen.V102.Stripe.ProductId)
            { priceId : Evergreen.V102.Id.Id Evergreen.V102.Stripe.PriceId
            , price : Evergreen.V102.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V102.Id.Id Evergreen.V102.Stripe.ProductId, Evergreen.V102.Id.Id Evergreen.V102.Stripe.PriceId )
    , form : Evergreen.V102.PurchaseForm.PurchaseForm
    , route : Evergreen.V102.Route.Route
    , showTooltip : Bool
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    , isOrganiser : Bool
    , ticketsEnabled : TicketsEnabled
    , backendModel : Maybe BackendModel
    , logoModel : Evergreen.V102.View.Logo.Model
    , pressedAudioButton : Bool
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
    | PressedSelectTicket (Evergreen.V102.Id.Id Evergreen.V102.Stripe.ProductId) (Evergreen.V102.Id.Id Evergreen.V102.Stripe.PriceId)
    | AddAccom Evergreen.V102.PurchaseForm.Accommodation
    | RemoveAccom Evergreen.V102.PurchaseForm.Accommodation
    | FormChanged Evergreen.V102.PurchaseForm.PurchaseForm
    | PressedSubmitForm
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | SetViewPortForElement Effect.Browser.Dom.HtmlId
    | AdminPullBackendModel
    | AdminPullBackendModelResponse (Result Effect.Http.Error BackendModel)
    | LogoMsg Evergreen.V102.View.Logo.Msg
    | Noop


type ToBackend
    = SubmitFormRequest (Evergreen.V102.Untrusted.Untrusted Evergreen.V102.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Effect.Time.Posix
    | GotPrices (Result Effect.Http.Error (List Evergreen.V102.Stripe.PriceData))
    | OnConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | CreatedCheckoutSession Effect.Lamdera.SessionId Effect.Lamdera.ClientId Evergreen.V102.PurchaseForm.PurchaseFormValidated (Result Effect.Http.Error ( Evergreen.V102.Id.Id Evergreen.V102.Stripe.StripeSessionId, Effect.Time.Posix ))
    | ExpiredStripeSession (Evergreen.V102.Id.Id Evergreen.V102.Stripe.StripeSessionId) (Result Effect.Http.Error ())
    | ConfirmationEmailSent (Evergreen.V102.Id.Id Evergreen.V102.Stripe.StripeSessionId) (Result Effect.Http.Error ())
    | ErrorEmailSent (Result Postmark.SendEmailError ())


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V102.Id.Id Evergreen.V102.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
