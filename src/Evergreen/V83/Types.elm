module Evergreen.V83.Types exposing (..)

import AssocList
import Audio
import Browser
import Browser.Navigation
import Evergreen.V83.Id
import Evergreen.V83.LiveSchedule
import Evergreen.V83.Postmark
import Evergreen.V83.PurchaseForm
import Evergreen.V83.Route
import Evergreen.V83.Stripe
import Evergreen.V83.Untrusted
import Http
import Lamdera
import Time
import Url


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V83.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { submitTime : Time.Posix
    , form : Evergreen.V83.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { submitTime : Time.Posix
    , form : Evergreen.V83.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V83.Id.Id Evergreen.V83.Stripe.PriceId
    , price : Evergreen.V83.Stripe.Price
    }


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled
        { adminMessage : String
        }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V83.Id.Id Evergreen.V83.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V83.Id.Id Evergreen.V83.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V83.Id.Id Evergreen.V83.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V83.Id.Id Evergreen.V83.Stripe.ProductId) Price2
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
    | PressedSelectTicket (Evergreen.V83.Id.Id Evergreen.V83.Stripe.ProductId) (Evergreen.V83.Id.Id Evergreen.V83.Stripe.PriceId)
    | AddAccom Evergreen.V83.PurchaseForm.Accommodation
    | RemoveAccom Evergreen.V83.PurchaseForm.Accommodation
    | FormChanged Evergreen.V83.PurchaseForm.PurchaseForm
    | PressedSubmitForm
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | LoadedMusic (Result Audio.LoadError Audio.Source)
    | LiveScheduleMsg Evergreen.V83.LiveSchedule.Msg
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
            (Evergreen.V83.Id.Id Evergreen.V83.Stripe.ProductId)
            { priceId : Evergreen.V83.Id.Id Evergreen.V83.Stripe.PriceId
            , price : Evergreen.V83.Stripe.Price
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
    , route : Evergreen.V83.Route.Route
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
            (Evergreen.V83.Id.Id Evergreen.V83.Stripe.ProductId)
            { priceId : Evergreen.V83.Id.Id Evergreen.V83.Stripe.PriceId
            , price : Evergreen.V83.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V83.Id.Id Evergreen.V83.Stripe.ProductId, Evergreen.V83.Id.Id Evergreen.V83.Stripe.PriceId )
    , form : Evergreen.V83.PurchaseForm.PurchaseForm
    , route : Evergreen.V83.Route.Route
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
    = SubmitFormRequest (Evergreen.V83.Untrusted.Untrusted Evergreen.V83.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V83.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId Evergreen.V83.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V83.Id.Id Evergreen.V83.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V83.Id.Id Evergreen.V83.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V83.Id.Id Evergreen.V83.Stripe.StripeSessionId) (Result Http.Error Evergreen.V83.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V83.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V83.Id.Id Evergreen.V83.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
