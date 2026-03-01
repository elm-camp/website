module Evergreen.V117.Types exposing (..)

import Effect.Browser
import Effect.Browser.Navigation
import Effect.Http
import Effect.Lamdera
import Effect.Time
import Evergreen.V117.EmailAddress
import Evergreen.V117.Fusion
import Evergreen.V117.Fusion.Patch
import Evergreen.V117.Id
import Evergreen.V117.Logo
import Evergreen.V117.NonNegative
import Evergreen.V117.Postmark
import Evergreen.V117.PurchaseForm
import Evergreen.V117.Route
import Evergreen.V117.Stripe
import Evergreen.V117.Theme
import Evergreen.V117.Ui
import Evergreen.V117.Untrusted
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
        { campfireTicket : Evergreen.V117.Stripe.Price
        , singleRoomTicket : Evergreen.V117.Stripe.Price
        , sharedRoomTicket : Evergreen.V117.Stripe.Price
        }
    , stripeCurrency : Money.Currency
    , ticketsAlreadyPurchased : Evergreen.V117.PurchaseForm.TicketTypes Evergreen.V117.NonNegative.NonNegative
    , ticketsEnabled : TicketsEnabled
    , currentCurrency :
        { currency : Money.Currency
        , conversionRate : Quantity.Quantity Float (Quantity.Rate Evergreen.V117.Stripe.StripeCurrency Evergreen.V117.Stripe.LocalCurrency)
        }
    }


type AdminPassword
    = AdminPassword String


type alias LoadingModel =
    { key : Effect.Browser.Navigation.Key
    , now : Maybe Effect.Time.Posix
    , timeZone : Maybe Effect.Time.Zone
    , window : Maybe Evergreen.V117.Theme.Size
    , url : Url.Url
    , isOrganiser : Bool
    , initData : Maybe (Result () InitData2)
    , elmUiState : Evergreen.V117.Ui.State
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
    | EmailFailed Evergreen.V117.Postmark.SendEmailError


type alias CompletedOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V117.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    , paymentId : Evergreen.V117.Id.Id Evergreen.V117.Stripe.StripePaymentId
    }


type alias PendingOrder =
    { submitTime : Effect.Time.Posix
    , form : Evergreen.V117.PurchaseForm.PurchaseFormValidated
    , sessionId : Effect.Lamdera.SessionId
    }


type TicketPriceStatus
    = NotLoadingTicketPrices
    | LoadingTicketPrices
    | LoadedTicketPrices Money.Currency (Evergreen.V117.PurchaseForm.TicketTypes Evergreen.V117.Stripe.Price)
    | FailedToLoadTicketPrices Effect.Http.Error
    | TicketCurrenciesDoNotMatch


type alias GrantApplication =
    { email : Evergreen.V117.EmailAddress.EmailAddress
    , message : String
    }


type alias BackendModel =
    { orders : SeqDict.SeqDict (Evergreen.V117.Id.Id Evergreen.V117.Stripe.StripeSessionId) CompletedOrder
    , pendingOrders : SeqDict.SeqDict (Evergreen.V117.Id.Id Evergreen.V117.Stripe.StripeSessionId) PendingOrder
    , expiredOrders : SeqDict.SeqDict (Evergreen.V117.Id.Id Evergreen.V117.Stripe.StripeSessionId) PendingOrder
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
    , window : Evergreen.V117.Theme.Size
    , initData : Result () InitData2
    , form : Evergreen.V117.PurchaseForm.PurchaseForm
    , opportunityGrantForm : OpportunityGrantForm
    , route : Evergreen.V117.Route.Route
    , showTooltip : Bool
    , backendModel : Maybe ( BackendModel, Evergreen.V117.Fusion.Value )
    , logoModel : Evergreen.V117.Logo.Model
    , elmUiState : Evergreen.V117.Ui.State
    , conversionRate : Evergreen.V117.Stripe.ConversionRateStatus
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
    | FormChanged Evergreen.V117.PurchaseForm.PurchaseForm
    | PressedSubmitForm
    | OpportunityGrantFormChanged OpportunityGrantForm
    | PressedSubmitOpportunityGrant
    | SetViewport
    | LogoMsg Evergreen.V117.Logo.Msg
    | Noop
    | ElmUiMsg Evergreen.V117.Ui.Msg
    | ScrolledToFragment
    | GotConversionRate (Result Effect.Http.Error (SeqDict.SeqDict Money.Currency (Quantity.Quantity Float (Quantity.Rate Evergreen.V117.Stripe.StripeCurrency Evergreen.V117.Stripe.LocalCurrency))))
    | SelectedCurrency Money.Currency
    | FusionPatch Evergreen.V117.Fusion.Patch.Patch
    | FusionQuery
    | TypedBackendModelJson String
    | PressedDownloadBackendModelJson
    | PressedUploadBackendModelJson


type ToBackend
    = SubmitFormRequest (Evergreen.V117.Untrusted.Untrusted Evergreen.V117.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect AdminPassword
    | SubmitOpportunityGrantRequest GrantApplication
    | BackendModelRequest AdminPassword
    | ReplaceBackendModelRequest AdminPassword String


type BackendMsg
    = GotTime Effect.Time.Posix
    | GotPrices (Result Effect.Http.Error (List Evergreen.V117.Stripe.PriceData))
    | OnConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | CreatedCheckoutSession Effect.Lamdera.SessionId Effect.Lamdera.ClientId Evergreen.V117.PurchaseForm.PurchaseFormValidated (Result Effect.Http.Error ( Evergreen.V117.Id.Id Evergreen.V117.Stripe.StripeSessionId, Effect.Time.Posix ))
    | ExpiredStripeSession (Evergreen.V117.Id.Id Evergreen.V117.Stripe.StripeSessionId) (Result Effect.Http.Error ())
    | ConfirmationEmailSent (Evergreen.V117.Id.Id Evergreen.V117.Stripe.StripeSessionId) (Result Evergreen.V117.Postmark.SendEmailError ())
    | ErrorEmailSent (Result Evergreen.V117.Postmark.SendEmailError ())
    | StripeWebhookResponse
        { endpoint : String
        , json : String
        }
    | OpportunityGrantEmailSent Effect.Lamdera.ClientId (Result Evergreen.V117.Postmark.SendEmailError ())


type ToFrontend
    = InitData (Result () InitData2)
    | SubmitFormResponse (Result String (Evergreen.V117.Id.Id Evergreen.V117.Stripe.StripeSessionId))
    | SlotRemainingChanged (Evergreen.V117.PurchaseForm.TicketTypes Evergreen.V117.NonNegative.NonNegative)
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel Evergreen.V117.Fusion.Value
    | OpportunityGrantSubmitResponse (Result String ())
    | BackendModelResponse (Result () String)
    | ReplaceBackendModelResponse (Result String ())
