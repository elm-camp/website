module Evergreen.V112.Types exposing (..)

import Effect.Browser
import Effect.Browser.Navigation
import Effect.Http
import Effect.Lamdera
import Effect.Time
import Evergreen.V112.Fusion
import Evergreen.V112.Fusion.Patch
import Evergreen.V112.Id
import Evergreen.V112.Logo
import Evergreen.V112.NonNegative
import Evergreen.V112.Postmark
import Evergreen.V112.PurchaseForm
import Evergreen.V112.Route
import Evergreen.V112.Stripe
import Evergreen.V112.Theme
import Evergreen.V112.Ui
import Evergreen.V112.Untrusted
import Money
import Quantity
import SeqDict
import Url


type alias TicketsDisabledData =
    { adminMessage : String
    }


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled TicketsDisabledData


type alias InitData2 =
    { prices :
        { campfireTicket : Evergreen.V112.Stripe.Price
        , singleRoomTicket : Evergreen.V112.Stripe.Price
        , sharedRoomTicket : Evergreen.V112.Stripe.Price
        }
    , stripeCurrency : Money.Currency
    , ticketsAlreadyPurchased : Evergreen.V112.PurchaseForm.TicketTypes Evergreen.V112.NonNegative.NonNegative
    , ticketsEnabled : TicketsEnabled
    , currentCurrency :
        { currency : Money.Currency
        , conversionRate : Quantity.Quantity Float (Quantity.Rate Evergreen.V112.Stripe.StripeCurrency Evergreen.V112.Stripe.LocalCurrency)
        }
    }


type alias LoadingModel =
    { key : Effect.Browser.Navigation.Key
    , now : Maybe Effect.Time.Posix
    , timeZone : Maybe Effect.Time.Zone
    , window : Maybe Evergreen.V112.Theme.Size
    , url : Url.Url
    , isOrganiser : Bool
    , initData : Maybe (Result () InitData2)
    , elmUiState : Evergreen.V112.Ui.State
    }


type EmailResult
    = SendingEmail
    | EmailSuccess
    | EmailFailed Evergreen.V112.Postmark.SendEmailError


type alias CompletedOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V112.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    , paymentId : Evergreen.V112.Id.Id Evergreen.V112.Stripe.StripePaymentId
    }


type alias PendingOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V112.PurchaseForm.PurchaseFormValidated
    , sessionId : Effect.Lamdera.SessionId
    }


type TicketPriceStatus
    = NotLoadingTicketPrices
    | LoadingTicketPrices
    | LoadedTicketPrices Money.Currency (Evergreen.V112.PurchaseForm.TicketTypes Evergreen.V112.Stripe.Price)
    | FailedToLoadTicketPrices Effect.Http.Error
    | TicketCurrenciesDoNotMatch


type alias BackendModel =
    { orders : SeqDict.SeqDict (Evergreen.V112.Id.Id Evergreen.V112.Stripe.StripeSessionId) CompletedOrder
    , pendingOrder : SeqDict.SeqDict (Evergreen.V112.Id.Id Evergreen.V112.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : SeqDict.SeqDict (Evergreen.V112.Id.Id Evergreen.V112.Stripe.StripeSessionId) PendingOrder
    , prices : TicketPriceStatus
    , time : Effect.Time.Posix
    , ticketsEnabled : TicketsEnabled
    }


type alias LoadedModel =
    { key : Effect.Browser.Navigation.Key
    , now : Effect.Time.Posix
    , timeZone : Effect.Time.Zone
    , window : Evergreen.V112.Theme.Size
    , initData : Result () InitData2
    , form : Evergreen.V112.PurchaseForm.PurchaseForm
    , route : Evergreen.V112.Route.Route
    , showTooltip : Bool
    , backendModel : Maybe ( BackendModel, Evergreen.V112.Fusion.Value )
    , logoModel : Evergreen.V112.Logo.Model
    , elmUiState : Evergreen.V112.Ui.State
    , conversionRate : Evergreen.V112.Stripe.ConversionRateStatus
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
    | FormChanged Evergreen.V112.PurchaseForm.PurchaseForm
    | PressedSubmitForm
    | SetViewport
    | LogoMsg Evergreen.V112.Logo.Msg
    | Noop
    | ElmUiMsg Evergreen.V112.Ui.Msg
    | ScrolledToFragment
    | GotConversionRate (Result Effect.Http.Error (SeqDict.SeqDict Money.Currency (Quantity.Quantity Float (Quantity.Rate Evergreen.V112.Stripe.StripeCurrency Evergreen.V112.Stripe.LocalCurrency))))
    | SelectedCurrency Money.Currency
    | FusionPatch Evergreen.V112.Fusion.Patch.Patch
    | FusionQuery


type ToBackend
    = SubmitFormRequest (Evergreen.V112.Untrusted.Untrusted Evergreen.V112.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Effect.Time.Posix
    | GotPrices (Result Effect.Http.Error (List Evergreen.V112.Stripe.PriceData))
    | OnConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | CreatedCheckoutSession Effect.Lamdera.SessionId Effect.Lamdera.ClientId Evergreen.V112.PurchaseForm.PurchaseFormValidated (Result Effect.Http.Error ( Evergreen.V112.Id.Id Evergreen.V112.Stripe.StripeSessionId, Effect.Time.Posix ))
    | ExpiredStripeSession (Evergreen.V112.Id.Id Evergreen.V112.Stripe.StripeSessionId) (Result Effect.Http.Error ())
    | ConfirmationEmailSent (Evergreen.V112.Id.Id Evergreen.V112.Stripe.StripeSessionId) (Result Evergreen.V112.Postmark.SendEmailError ())
    | ErrorEmailSent (Result Evergreen.V112.Postmark.SendEmailError ())
    | StripeWebhookResponse
        { endpoint : String
        , json : String
        }


type ToFrontend
    = InitData (Result () InitData2)
    | SubmitFormResponse (Result String (Evergreen.V112.Id.Id Evergreen.V112.Stripe.StripeSessionId))
    | SlotRemainingChanged (Evergreen.V112.PurchaseForm.TicketTypes Evergreen.V112.NonNegative.NonNegative)
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel Evergreen.V112.Fusion.Value
