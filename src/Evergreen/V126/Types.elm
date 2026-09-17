module Evergreen.V126.Types exposing (..)

import Effect.Browser
import Effect.Browser.Navigation
import Effect.Http
import Effect.Lamdera
import Effect.Time
import Evergreen.V126.EmailAddress
import Evergreen.V126.Fusion
import Evergreen.V126.Fusion.Patch
import Evergreen.V126.Id
import Evergreen.V126.Logo
import Evergreen.V126.NonNegative
import Evergreen.V126.Postmark
import Evergreen.V126.PurchaseForm
import Evergreen.V126.Route
import Evergreen.V126.Stripe
import Evergreen.V126.Theme
import Evergreen.V126.Ui
import Evergreen.V126.Untrusted
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
        { campfireTicket : Evergreen.V126.Stripe.Price
        , singleRoomTicket : Evergreen.V126.Stripe.Price
        , sharedRoomTicket : Evergreen.V126.Stripe.Price
        }
    , stripeCurrency : Money.Currency
    , ticketsAlreadyPurchased : Evergreen.V126.PurchaseForm.TicketTypes Evergreen.V126.NonNegative.NonNegative
    , ticketsEnabled : TicketsEnabled
    , currentCurrency :
        { currency : Money.Currency
        , conversionRate : Quantity.Quantity Float (Quantity.Rate Evergreen.V126.Stripe.StripeCurrency Evergreen.V126.Stripe.LocalCurrency)
        }
    }


type AdminPassword
    = AdminPassword String


type alias LoadingModel =
    { key : Effect.Browser.Navigation.Key
    , now : Maybe Effect.Time.Posix
    , timeZone : Maybe Effect.Time.Zone
    , window : Maybe Evergreen.V126.Theme.Size
    , url : Url.Url
    , isOrganiser : Bool
    , initData : Maybe (Result () InitData2)
    , elmUiState : Evergreen.V126.Ui.State
    , adminPassword : Maybe AdminPassword
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
    | EmailFailed Evergreen.V126.Postmark.SendEmailError


type alias CompletedOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V126.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    , paymentId : Evergreen.V126.Id.Id Evergreen.V126.Stripe.StripePaymentId
    }


type alias PendingOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V126.PurchaseForm.PurchaseFormValidated
    , sessionId : Effect.Lamdera.SessionId
    }


type TicketPriceStatus
    = NotLoadingTicketPrices
    | LoadingTicketPrices
    | LoadedTicketPrices Money.Currency (Evergreen.V126.PurchaseForm.TicketTypes Evergreen.V126.Stripe.Price)
    | FailedToLoadTicketPrices Effect.Http.Error
    | TicketCurrenciesDoNotMatch


type alias GrantApplication =
    { email : Evergreen.V126.EmailAddress.EmailAddress
    , message : String
    }


type alias BackendModel =
    { orders : SeqDict.SeqDict (Evergreen.V126.Id.Id Evergreen.V126.Stripe.StripeSessionId) CompletedOrder
    , pendingOrders : SeqDict.SeqDict (Evergreen.V126.Id.Id Evergreen.V126.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : SeqDict.SeqDict (Evergreen.V126.Id.Id Evergreen.V126.Stripe.StripeSessionId) PendingOrder
    , prices : TicketPriceStatus
    , time : Effect.Time.Posix
    , ticketsEnabled : TicketsEnabled
    , grantApplications : List GrantApplication
    }


type ReplaceBackendModelStatus
    = NotReplacingBackendModel
    | ReplacingBackendModel
    | ReplacedBackendModel
    | FailedToReplaceBackendModel String


type alias LoadedModel =
    { key : Effect.Browser.Navigation.Key
    , now : Effect.Time.Posix
    , timeZone : Effect.Time.Zone
    , window : Evergreen.V126.Theme.Size
    , initData : Result () InitData2
    , form : Evergreen.V126.PurchaseForm.PurchaseForm
    , opportunityGrantForm : OpportunityGrantForm
    , route : Evergreen.V126.Route.Route
    , showTooltip : Bool
    , backendModel : Maybe ( BackendModel, Evergreen.V126.Fusion.Value )
    , logoModel : Evergreen.V126.Logo.Model
    , elmUiState : Evergreen.V126.Ui.State
    , conversionRate : Evergreen.V126.Stripe.ConversionRateStatus
    , backendModelJson : Result () String
    , replaceBackendModelStatus : ReplaceBackendModelStatus
    , adminPassword : Maybe AdminPassword
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
    | FormChanged Evergreen.V126.PurchaseForm.PurchaseForm
    | PressedSubmitForm
    | OpportunityGrantFormChanged OpportunityGrantForm
    | PressedSubmitOpportunityGrant
    | SetViewport
    | LogoMsg Evergreen.V126.Logo.Msg
    | Noop
    | ElmUiMsg Evergreen.V126.Ui.Msg
    | ScrolledToFragment
    | GotConversionRate (Result Effect.Http.Error (SeqDict.SeqDict Money.Currency (Quantity.Quantity Float (Quantity.Rate Evergreen.V126.Stripe.StripeCurrency Evergreen.V126.Stripe.LocalCurrency))))
    | SelectedCurrency Money.Currency
    | FusionPatch Evergreen.V126.Fusion.Patch.Patch
    | FusionQuery
    | TypedBackendModelJson String
    | PressedDownloadBackendModelJson
    | PressedUploadBackendModelJson


type ToBackend
    = SubmitFormRequest (Evergreen.V126.Untrusted.Untrusted Evergreen.V126.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect AdminPassword
    | SubmitOpportunityGrantRequest GrantApplication
    | BackendModelRequest AdminPassword
    | ReplaceBackendModelRequest AdminPassword String


type BackendMsg
    = GotTime Effect.Time.Posix
    | GotPrices (Result Effect.Http.Error (List Evergreen.V126.Stripe.PriceData))
    | OnConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | CreatedCheckoutSession Effect.Lamdera.SessionId Effect.Lamdera.ClientId Evergreen.V126.PurchaseForm.PurchaseFormValidated (Result Effect.Http.Error ( Evergreen.V126.Id.Id Evergreen.V126.Stripe.StripeSessionId, Effect.Time.Posix ))
    | ExpiredStripeSession (Evergreen.V126.Id.Id Evergreen.V126.Stripe.StripeSessionId) (Result Effect.Http.Error ())
    | ConfirmationEmailSent (Evergreen.V126.Id.Id Evergreen.V126.Stripe.StripeSessionId) (Result Evergreen.V126.Postmark.SendEmailError ())
    | ErrorEmailSent (Result Evergreen.V126.Postmark.SendEmailError ())
    | StripeWebhookResponse
        { endpoint : String
        , json : String
        }
    | OpportunityGrantEmailSent Effect.Lamdera.ClientId (Result Evergreen.V126.Postmark.SendEmailError ())


type ToFrontend
    = InitData (Result () InitData2)
    | SubmitFormResponse (Result String (Evergreen.V126.Id.Id Evergreen.V126.Stripe.StripeSessionId))
    | SlotRemainingChanged (Evergreen.V126.PurchaseForm.TicketTypes Evergreen.V126.NonNegative.NonNegative)
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel Evergreen.V126.Fusion.Value
    | OpportunityGrantSubmitResponse (Result String ())
    | BackendModelResponse (Result () String)
    | ReplaceBackendModelResponse (Result String ())
