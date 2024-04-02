module Evergreen.V67.Types exposing (..)

import AssocList
import Audio
import Browser
import Browser.Navigation
import Evergreen.V67.Id
import Evergreen.V67.LiveSchedule
import Evergreen.V67.Postmark
import Evergreen.V67.PurchaseForm
import Evergreen.V67.Route
import Evergreen.V67.Stripe
import Evergreen.V67.Untrusted
import Http
import Lamdera
import Time
import Url


type FrontendMsg_
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Tick Time.Posix
    | GotZone Time.Zone
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | DownloadTicketSalesReminder
    | PressedSelectTicket (Evergreen.V67.Id.Id Evergreen.V67.Stripe.ProductId) (Evergreen.V67.Id.Id Evergreen.V67.Stripe.PriceId)
    | AddAccom Evergreen.V67.PurchaseForm.Accommodation
    | RemoveAccom Evergreen.V67.PurchaseForm.Accommodation
    | FormChanged Evergreen.V67.PurchaseForm.PurchaseForm
    | PressedSubmitForm
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | LoadedMusic (Result Audio.LoadError Audio.Source)
    | LiveScheduleMsg Evergreen.V67.LiveSchedule.Msg
    | SetViewPortForElement String
    | Noop


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
        AssocList.Dict
            (Evergreen.V67.Id.Id Evergreen.V67.Stripe.ProductId)
            { priceId : Evergreen.V67.Id.Id Evergreen.V67.Stripe.PriceId
            , price : Evergreen.V67.Stripe.Price
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
    , route : Evergreen.V67.Route.Route
    , isOrganiser : Bool
    , initData : Maybe InitData2
    , audio : Maybe (Result Audio.LoadError Audio.Source)
    }


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V67.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { submitTime : Time.Posix
    , form : Evergreen.V67.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { submitTime : Time.Posix
    , form : Evergreen.V67.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V67.Id.Id Evergreen.V67.Stripe.PriceId
    , price : Evergreen.V67.Stripe.Price
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V67.Id.Id Evergreen.V67.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V67.Id.Id Evergreen.V67.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : AssocList.Dict (Evergreen.V67.Id.Id Evergreen.V67.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V67.Id.Id Evergreen.V67.Stripe.ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
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
            (Evergreen.V67.Id.Id Evergreen.V67.Stripe.ProductId)
            { priceId : Evergreen.V67.Id.Id Evergreen.V67.Stripe.PriceId
            , price : Evergreen.V67.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V67.Id.Id Evergreen.V67.Stripe.ProductId, Evergreen.V67.Id.Id Evergreen.V67.Stripe.PriceId )
    , form : Evergreen.V67.PurchaseForm.PurchaseForm
    , route : Evergreen.V67.Route.Route
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
    = SubmitFormRequest (Evergreen.V67.Untrusted.Untrusted Evergreen.V67.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V67.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId Evergreen.V67.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V67.Id.Id Evergreen.V67.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V67.Id.Id Evergreen.V67.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V67.Id.Id Evergreen.V67.Stripe.StripeSessionId) (Result Http.Error Evergreen.V67.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V67.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Evergreen.V67.Id.Id Evergreen.V67.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel
