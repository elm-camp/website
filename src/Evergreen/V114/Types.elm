module Evergreen.V114.Types exposing (..)

import Effect.Browser
import Effect.Browser.Navigation
import Effect.Http
import Effect.Lamdera
import Effect.Time
import Evergreen.V114.EmailAddress
import Evergreen.V114.Fusion
import Evergreen.V114.Fusion.Patch
import Evergreen.V114.Id
import Evergreen.V114.Logo
import Evergreen.V114.NonNegative
import Evergreen.V114.Postmark
import Evergreen.V114.PurchaseForm
import Evergreen.V114.Route
import Evergreen.V114.Stripe
import Evergreen.V114.Theme
import Evergreen.V114.Ui
import Evergreen.V114.Untrusted
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
        { campfireTicket : Evergreen.V114.Stripe.Price
        , singleRoomTicket : Evergreen.V114.Stripe.Price
        , sharedRoomTicket : Evergreen.V114.Stripe.Price
        }
    , stripeCurrency : Money.Currency
    , ticketsAlreadyPurchased : Evergreen.V114.PurchaseForm.TicketTypes Evergreen.V114.NonNegative.NonNegative
    , ticketsEnabled : TicketsEnabled
    , currentCurrency :
        { currency : Money.Currency
        , conversionRate : Quantity.Quantity Float (Quantity.Rate Evergreen.V114.Stripe.StripeCurrency Evergreen.V114.Stripe.LocalCurrency)
        }
    }


type alias LoadingModel =
    { key : Effect.Browser.Navigation.Key
    , now : Maybe Effect.Time.Posix
    , timeZone : Maybe Effect.Time.Zone
    , window : Maybe Evergreen.V114.Theme.Size
    , url : Url.Url
    , isOrganiser : Bool
    , initData : Maybe (Result () InitData2)
    , elmUiState : Evergreen.V114.Ui.State
    }


type OpportunityGrantPressedSubmit
    = OpportunityGrantPressedSubmit
    | OpportunityGrantNotPressedSubmit


type OpportunityGrantSubmitStatus
    = OpportunityGrantNotSubmitted OpportunityGrantPressedSubmit
    | OpportunityGrantSubmitting
    | OpportunityGrantSubmitBackendError String
    | OpportunityGrantSubmittedSuccessfully


type alias OpportunityGrantForm =
    { email : String
    , message : String
    , submitStatus : OpportunityGrantSubmitStatus
    }


type EmailResult
    = SendingEmail
    | EmailSuccess
    | EmailFailed Evergreen.V114.Postmark.SendEmailError


type alias CompletedOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V114.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    , paymentId : Evergreen.V114.Id.Id Evergreen.V114.Stripe.StripePaymentId
    }


type alias PendingOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V114.PurchaseForm.PurchaseFormValidated
    , sessionId : Effect.Lamdera.SessionId
    }


type TicketPriceStatus
    = NotLoadingTicketPrices
    | LoadingTicketPrices
    | LoadedTicketPrices Money.Currency (Evergreen.V114.PurchaseForm.TicketTypes Evergreen.V114.Stripe.Price)
    | FailedToLoadTicketPrices Effect.Http.Error
    | TicketCurrenciesDoNotMatch


type alias GrantApplication =
    { email : Evergreen.V114.EmailAddress.EmailAddress
    , message : String
    }


type alias BackendModel =
    { orders : SeqDict.SeqDict (Evergreen.V114.Id.Id Evergreen.V114.Stripe.StripeSessionId) CompletedOrder
    , pendingOrders : SeqDict.SeqDict (Evergreen.V114.Id.Id Evergreen.V114.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : SeqDict.SeqDict (Evergreen.V114.Id.Id Evergreen.V114.Stripe.StripeSessionId) PendingOrder
    , prices : TicketPriceStatus
    , time : Effect.Time.Posix
    , ticketsEnabled : TicketsEnabled
    , grantApplications : List GrantApplication
    }


type alias LoadedModel =
    { key : Effect.Browser.Navigation.Key
    , now : Effect.Time.Posix
    , timeZone : Effect.Time.Zone
    , window : Evergreen.V114.Theme.Size
    , initData : Result () InitData2
    , form : Evergreen.V114.PurchaseForm.PurchaseForm
    , opportunityGrantForm : OpportunityGrantForm
    , route : Evergreen.V114.Route.Route
    , showTooltip : Bool
    , backendModel : Maybe ( BackendModel, Evergreen.V114.Fusion.Value )
    , logoModel : Evergreen.V114.Logo.Model
    , elmUiState : Evergreen.V114.Ui.State
    , conversionRate : Evergreen.V114.Stripe.ConversionRateStatus
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
    | FormChanged Evergreen.V114.PurchaseForm.PurchaseForm
    | PressedSubmitForm
    | OpportunityGrantFormChanged OpportunityGrantForm
    | PressedSubmitOpportunityGrant
    | SetViewport
    | LogoMsg Evergreen.V114.Logo.Msg
    | Noop
    | ElmUiMsg Evergreen.V114.Ui.Msg
    | ScrolledToFragment
    | GotConversionRate (Result Effect.Http.Error (SeqDict.SeqDict Money.Currency (Quantity.Quantity Float (Quantity.Rate Evergreen.V114.Stripe.StripeCurrency Evergreen.V114.Stripe.LocalCurrency))))
    | SelectedCurrency Money.Currency
    | FusionPatch Evergreen.V114.Fusion.Patch.Patch
    | FusionQuery


type ToBackend
    = SubmitFormRequest (Evergreen.V114.Untrusted.Untrusted Evergreen.V114.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String
    | SubmitOpportunityGrantRequest GrantApplication


type BackendMsg
    = GotTime Effect.Time.Posix
    | GotPrices (Result Effect.Http.Error (List Evergreen.V114.Stripe.PriceData))
    | OnConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | CreatedCheckoutSession Effect.Lamdera.SessionId Effect.Lamdera.ClientId Evergreen.V114.PurchaseForm.PurchaseFormValidated (Result Effect.Http.Error ( Evergreen.V114.Id.Id Evergreen.V114.Stripe.StripeSessionId, Effect.Time.Posix ))
    | ExpiredStripeSession (Evergreen.V114.Id.Id Evergreen.V114.Stripe.StripeSessionId) (Result Effect.Http.Error ())
    | ConfirmationEmailSent (Evergreen.V114.Id.Id Evergreen.V114.Stripe.StripeSessionId) (Result Evergreen.V114.Postmark.SendEmailError ())
    | ErrorEmailSent (Result Evergreen.V114.Postmark.SendEmailError ())
    | StripeWebhookResponse
        { endpoint : String
        , json : String
        }
    | OpportunityGrantEmailSent Effect.Lamdera.ClientId (Result Evergreen.V114.Postmark.SendEmailError ())


type ToFrontend
    = InitData (Result () InitData2)
    | SubmitFormResponse (Result String (Evergreen.V114.Id.Id Evergreen.V114.Stripe.StripeSessionId))
    | SlotRemainingChanged (Evergreen.V114.PurchaseForm.TicketTypes Evergreen.V114.NonNegative.NonNegative)
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel Evergreen.V114.Fusion.Value
    | OpportunityGrantSubmitResponse (Result String ())
