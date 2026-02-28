module Types exposing
    ( BackendModel
    , BackendMsg(..)
    , CompletedOrder
    , EmailResult(..)
    , FrontendModel(..)
    , FrontendMsg(..)
    , GrantApplication
    , InitData2
    , LoadedModel
    , LoadingModel
    , OpportunityGrantForm
    , OpportunityGrantPressedSubmit(..)
    , OpportunityGrantSubmitStatus(..)
    , PendingOrder
    , TicketPriceStatus(..)
    , TicketsDisabledData
    , TicketsEnabled(..)
    , ToBackend(..)
    , ToFrontend(..)
    )

import Effect.Browser exposing (UrlRequest)
import Effect.Browser.Navigation exposing (Key)
import Effect.Http as Http
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Time as Time
import EmailAddress exposing (EmailAddress)
import Fusion
import Fusion.Patch
import Id exposing (Id)
import Logo
import Money
import NonNegative exposing (NonNegative)
import Postmark
import PurchaseForm exposing (PurchaseForm, PurchaseFormValidated, TicketTypes)
import Quantity exposing (Quantity, Rate)
import Route exposing (Route)
import SeqDict exposing (SeqDict)
import Stripe exposing (ConversionRateStatus, CurrentCurrency, LocalCurrency, Price, PriceData, PriceId, ProductId, StripeCurrency, StripePaymentId, StripeSessionId)
import Theme exposing (Size)
import Ui
import Untrusted exposing (Untrusted)
import Url exposing (Url)


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type alias LoadingModel =
    { key : Key
    , now : Maybe Time.Posix
    , timeZone : Maybe Time.Zone
    , window : Maybe Size
    , url : Url
    , isOrganiser : Bool
    , initData : Maybe (Result () InitData2)
    , elmUiState : Ui.State
    }


type alias LoadedModel =
    { key : Key
    , now : Time.Posix
    , timeZone : Time.Zone
    , window : Size
    , initData : Result () InitData2
    , form : PurchaseForm
    , opportunityGrantForm : OpportunityGrantForm
    , route : Route
    , showTooltip : Bool
    , backendModel : Maybe ( BackendModel, Fusion.Value )
    , logoModel : Logo.Model
    , elmUiState : Ui.State
    , conversionRate : ConversionRateStatus
    }


type alias OpportunityGrantForm =
    { email : String
    , message : String
    , submitStatus : OpportunityGrantSubmitStatus
    }


type OpportunityGrantSubmitStatus
    = OpportunityGrantNotSubmitted OpportunityGrantPressedSubmit
    | OpportunityGrantSubmitting
    | OpportunityGrantSubmitBackendError String
    | OpportunityGrantSubmittedSuccessfully


type OpportunityGrantPressedSubmit
    = OpportunityGrantPressedSubmit
    | OpportunityGrantNotPressedSubmit


type alias BackendModel =
    { orders : SeqDict (Id StripeSessionId) CompletedOrder
    , pendingOrders : SeqDict (Id StripeSessionId) PendingOrder
    , expiredOrders : SeqDict (Id StripeSessionId) PendingOrder
    , prices : TicketPriceStatus
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    , grantApplications : List GrantApplication
    }


type alias GrantApplication =
    { email : EmailAddress, message : String }


type TicketPriceStatus
    = NotLoadingTicketPrices
    | LoadingTicketPrices
    | LoadedTicketPrices Money.Currency (TicketTypes Price)
    | FailedToLoadTicketPrices Http.Error
    | TicketCurrenciesDoNotMatch


type alias PendingOrder =
    { submitTime : Time.Posix
    , form : PurchaseFormValidated
    , sessionId : SessionId
    }


type alias CompletedOrder =
    { submitTime : Time.Posix
    , form : PurchaseFormValidated
    , emailResult : EmailResult
    , paymentId : Id StripePaymentId
    }


type EmailResult
    = SendingEmail
    | EmailSuccess
    | EmailFailed Postmark.SendEmailError


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | Tick Time.Posix
    | GotZone Time.Zone
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | DownloadTicketSalesReminder
    | FormChanged PurchaseForm
    | PressedSubmitForm
    | OpportunityGrantFormChanged OpportunityGrantForm
    | PressedSubmitOpportunityGrant
    | SetViewport
    | LogoMsg Logo.Msg
    | Noop
    | ElmUiMsg Ui.Msg
    | ScrolledToFragment
    | GotConversionRate (Result Http.Error (SeqDict Money.Currency (Quantity Float (Rate StripeCurrency LocalCurrency))))
    | SelectedCurrency Money.Currency
    | FusionPatch Fusion.Patch.Patch
    | FusionQuery


type ToBackend
    = SubmitFormRequest (Untrusted PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String
    | SubmitOpportunityGrantRequest GrantApplication
    | BackendModelRequest String
    | ReplaceBackendModelRequest String String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List PriceData))
    | OnConnected SessionId ClientId
    | CreatedCheckoutSession SessionId ClientId PurchaseFormValidated (Result Http.Error ( Id StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Id StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Id StripeSessionId) (Result Postmark.SendEmailError ())
    | ErrorEmailSent (Result Postmark.SendEmailError ())
    | StripeWebhookResponse { endpoint : String, json : String }
    | OpportunityGrantEmailSent ClientId (Result Postmark.SendEmailError ())


type alias InitData2 =
    { prices : { campfireTicket : Price, singleRoomTicket : Price, sharedRoomTicket : Price }
    , stripeCurrency : Money.Currency
    , ticketsAlreadyPurchased : TicketTypes NonNegative
    , ticketsEnabled : TicketsEnabled
    , currentCurrency : { currency : Money.Currency, conversionRate : Quantity Float (Rate StripeCurrency LocalCurrency) }
    }


type ToFrontend
    = InitData (Result () InitData2)
    | SubmitFormResponse (Result String (Id StripeSessionId))
    | SlotRemainingChanged (TicketTypes NonNegative)
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel Fusion.Value
    | OpportunityGrantSubmitResponse (Result String ())
    | BackendModelResponse (Result () String)
    | ReplaceBackendModelResponse (Result String ())


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled TicketsDisabledData


type alias TicketsDisabledData =
    { adminMessage : String }
