module Evergreen.V94.Types exposing (..)

import AssocList
import Audio
import Browser
import Browser.Navigation
import Evergreen.V94.Id
import Evergreen.V94.LiveSchedule
import Evergreen.V94.Postmark
import Evergreen.V94.PurchaseForm
import Evergreen.V94.Route
import Evergreen.V94.Stripe
import Evergreen.V94.Untrusted
import Http
import Lamdera
import Time
import Url


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V94.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { submitTime : Time.Posix
    , form : Evergreen.V94.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { submitTime : Time.Posix
    , form : Evergreen.V94.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V94.Id.Id Evergreen.V94.Stripe.PriceId
    , price : Evergreen.V94.Stripe.Price
    }


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled
        { adminMessage : String
        }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V94.Id.Id Evergreen.V94.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V94.Id.Id Evergreen.V94.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V94.Id.Id Evergreen.V94.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V94.Id.Id Evergreen.V94.Stripe.ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    }


type FrontendMsg_
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Tick Time.Posix
    | GotZone Time.Zone
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | DownloadTicketSalesReminder
    | PressedSelectTicket (Evergreen.V94.Id.Id Evergreen.V94.Stripe.ProductId) (Evergreen.V94.Id.Id Evergreen.V94.Stripe.PriceId)
    | AddAccom Evergreen.V94.PurchaseForm.Accommodation
    | RemoveAccom Evergreen.V94.PurchaseForm.Accommodation
    | FormChanged Evergreen.V94.PurchaseForm.PurchaseForm
    | PressedSubmitForm
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | LoadedMusic (Result Audio.LoadError Audio.Source)
    | LiveScheduleMsg Evergreen.V94.LiveSchedule.Msg
    | SetViewPortForElement String
    | AdminPullBackendModel
    | AdminPullBackendModelResponse (Result Http.Error BackendModel)
    | Noop


type alias TicketAvailability =
    { attendanceTickets : Bool
    , campingSpots : Bool
    , singleRooms : Bool
    , doubleRooms : Bool
    , groupRooms : Bool
    }


type alias InitData2 =
    { prices :
        AssocList.Dict
            (Evergreen.V94.Id.Id Evergreen.V94.Stripe.ProductId)
            { priceId : Evergreen.V94.Id.Id Evergreen.V94.Stripe.PriceId
            , price : Evergreen.V94.Stripe.Price
            }
    , slotsRemaining : TicketAvailability
    , ticketsEnabled : TicketsEnabled
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , zone : Maybe Time.Zone
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V94.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    , audio : Maybe (Result Audio.LoadError Audio.Source)
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , zone : Maybe Time.Zone
    , window :
        { width : Int
        , height : Int
        }
    , prices :
        AssocList.Dict
            (Evergreen.V94.Id.Id Evergreen.V94.Stripe.ProductId)
            { priceId : Evergreen.V94.Id.Id Evergreen.V94.Stripe.PriceId
            , price : Evergreen.V94.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V94.Id.Id Evergreen.V94.Stripe.ProductId, Evergreen.V94.Id.Id Evergreen.V94.Stripe.PriceId )
    , form : Evergreen.V94.PurchaseForm.PurchaseForm
    , route : Evergreen.V94.Route.Route
    , showTooltip : Bool
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    , isOrganiser : Bool
    , ticketsEnabled : TicketsEnabled
    , backendModel : Maybe BackendModel
    , audio : Maybe Audio.Source
    , pressedAudioButton : Bool
    }


type FrontendModel_
    = Loading LoadingModel
    | Loaded LoadedModel


type alias FrontendModel =
    Audio.Model FrontendMsg_ FrontendModel_


type alias FrontendMsg =
    Audio.Msg FrontendMsg_


type ToBackend
    = SubmitFormRequest (Evergreen.V94.Untrusted.Untrusted Evergreen.V94.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V94.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId Evergreen.V94.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V94.Id.Id Evergreen.V94.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V94.Id.Id Evergreen.V94.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V94.Id.Id Evergreen.V94.Stripe.StripeSessionId) (Result Http.Error Evergreen.V94.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V94.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V94.Id.Id Evergreen.V94.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
