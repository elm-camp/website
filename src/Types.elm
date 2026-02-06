module Types exposing
    ( BackendModel
    , BackendMsg(..)
    , CityCode
    , CompletedOrder
    , ConversionRateStatus(..)
    , CzechCrown
    , EmailResult(..)
    , Euro
    , FrontendModel(..)
    , FrontendMsg(..)
    , InitData2
    , LoadedModel
    , LoadingModel
    , OrderStatus(..)
    , PendingOrder
    , Price2
    , Product(..)
    , Sponsorship(..)
    , StripePaymentId(..)
    , TicketsEnabled(..)
    , ToBackend(..)
    , ToFrontend(..)
    , maxSlotsAvailable
    )

import Effect.Browser exposing (UrlRequest)
import Effect.Browser.Dom exposing (HtmlId)
import Effect.Browser.Navigation exposing (Key)
import Effect.Http as Http
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Time as Time
import Id exposing (Id)
import NonNegative exposing (NonNegative)
import Postmark
import PurchaseForm exposing (PurchaseForm, PurchaseFormValidated, TicketCount)
import Quantity exposing (Quantity, Rate)
import Route exposing (Route)
import SeqDict exposing (SeqDict)
import Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Theme exposing (Size)
import Ui
import Untrusted exposing (Untrusted)
import Url exposing (Url)
import View.Logo


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
    , initData : Maybe InitData2
    , elmUiState : Ui.State
    , conversionRate : ConversionRateStatus
    }


type ConversionRateStatus
    = LoadingConversionRate
    | LoadedConversionRate (Quantity Float (Rate Euro CzechCrown))
    | LoadingConversionRateFailed Http.Error


type Euro
    = Euro


type CzechCrown
    = CzechCrown


type alias LoadedModel =
    { key : Key
    , now : Time.Posix
    , timeZone : Time.Zone
    , window : Size
    , prices : SeqDict (Id ProductId) { priceId : Id PriceId, price : Price }
    , form : PurchaseForm
    , route : Route
    , showTooltip : Bool
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketCount
    , isOrganiser : Bool
    , ticketsEnabled : TicketsEnabled
    , backendModel : Maybe BackendModel
    , logoModel : View.Logo.Model
    , pressedAudioButton : Bool
    , elmUiState : Ui.State
    , conversionRate : ConversionRateStatus
    }


type alias BackendModel =
    { orders : SeqDict (Id StripeSessionId) CompletedOrder
    , pendingOrder : SeqDict (Id StripeSessionId) PendingOrder
    , expiredOrders : SeqDict (Id StripeSessionId) PendingOrder
    , prices : SeqDict (Id ProductId) Price2
    , time : Time.Posix
    , ticketsEnabled : TicketsEnabled
    , backendInitialized : Bool
    }


type alias Price2 =
    { priceId : Id PriceId, price : Price }



-- backendModelCodec : Codec BackendModel
-- backendModelCodec =
--     Codec.object BackendModel
--         |> Codec.field "orders" .orders (assocListCodec orderCodec)
--         |> Codec.field "pendingOrder" .pendingOrder (assocListCodec pendingOrderCodec)
--         |> Codec.field "expiredOrders" .expiredOrders (assocListCodec pendingOrderCodec)
--         |> Codec.field "prices" .prices (assocListCodec price2Codec)
--         |> Codec.field "time" .time timeCodec
--         |> Codec.field "ticketsEnabled" .ticketsEnabled ticketsEnabledCodec
--         |> Codec.buildObject
-- ticketsEnabledCodec : Codec TicketsEnabled
-- ticketsEnabledCodec =
--     Codec.custom
--         (\a b value ->
--             case value of
--                 TicketsEnabled ->
--                     a
--                 TicketsDisabled { adminMessage } ->
--                     b adminMessage
--         )
--         |> Codec.variant0 "TicketsEnabled" TicketsEnabled
--         |> Codec.variant1 "TicketsDisabled" (\a -> TicketsDisabled { adminMessage = a }) Codec.string
--         |> Codec.buildCustom
-- price2Codec : Codec Price2
-- price2Codec =
--     Codec.object Price2
--         |> Codec.field "priceId" .priceId idCodec
--         |> Codec.field "price" .price priceCodec
--         |> Codec.buildObject
-- priceCodec : Codec Price
-- priceCodec =
--     Codec.object Price
--         |> Codec.field "currency" .currency currencyCodec
--         |> Codec.field "amount" .amount Codec.int
--         |> Codec.buildObject
-- currencyCodec : Codec Money.Currency
-- currencyCodec =
--     Codec.andThen
--         (\text ->
--             case Money.fromString text of
--                 Just money ->
--                     Codec.succeed money
--                 Nothing ->
--                     Codec.fail ("Invalid currency: " ++ text)
--         )
--         Money.toString
--         Codec.string
-- assocListCodec : Codec b -> Codec (SeqDict (Id a) b)
-- assocListCodec codec =
--     Codec.map
--         (\dict -> Dict.toList dict |> List.map (Tuple.mapFirst Id.fromString) |> SeqDict.fromList)
--         (\SeqDict -> SeqDict.toList SeqDict |> List.map (Tuple.mapFirst Id.toString) |> Dict.fromList)
--         (Codec.dict codec)
-- idCodec : Codec (Id a)
-- idCodec =
--     Codec.map Id.fromString Id.toString Codec.string


type alias PendingOrder =
    { submitTime : Time.Posix
    , form : PurchaseFormValidated
    , sessionId : SessionId
    }


type alias CompletedOrder =
    { submitTime : Time.Posix
    , form : PurchaseFormValidated
    , emailResult : EmailResult

    --, products : List Product
    --, sponsorship : Maybe Sponsorship
    --, opportunityGrantContribution : Price
    --, status : OrderStatus
    }



-- pendingOrderCodec : Codec PendingOrder
-- pendingOrderCodec =
--     Codec.object PendingOrder
--         |> Codec.field "priceId" .priceId idCodec
--         |> Codec.field "submitTime" .submitTime timeCodec
--         |> Codec.field "form" .form PurchaseForm.codec
--         |> Codec.field "sessionId" .sessionId Codec.string
--         |> Codec.buildObject
-- orderCodec : Codec { priceId : Id PriceId, submitTime : Time.Posix, form : PurchaseFormValidated, emailResult : EmailResult }
-- orderCodec =
--     Codec.object Order
--         |> Codec.field "priceId" .priceId idCodec
--         |> Codec.field "submitTime" .submitTime timeCodec
--         |> Codec.field "form" .form PurchaseForm.codec
--         |> Codec.field "emailResult" .emailResult emailResultCodec
--         |> Codec.buildObject
-- emailResultCodec =
--     Codec.custom
--         (\a b c value ->
--             case value of
--                 SendingEmail ->
--                     a
--                 EmailSuccess data0 ->
--                     b data0
--                 EmailFailed data0 ->
--                     c data0
--         )
--         |> Codec.variant0 "SendingEmail" SendingEmail
--         |> Codec.variant1 "EmailSuccess" EmailSuccess postmarkSendResponseCodec
--         |> Codec.variant1 "EmailFailed" EmailFailed httpErrorCodec
--         |> Codec.buildCustom
-- postmarkSendResponseCodec =
--     Codec.object PostmarkSendResponse
--         |> Codec.field "to" .to Codec.string
--         |> Codec.field "submittedAt" .submittedAt Codec.string
--         |> Codec.field "messageId" .messageId Codec.string
--         |> Codec.field "errorCode" .errorCode Codec.int
--         |> Codec.field "message" .message Codec.string
--         |> Codec.buildObject
-- httpErrorCodec =
--     Codec.custom
--         (\a b c d e value ->
--             case value of
--                 Http.BadUrl data0 ->
--                     a data0
--                 Http.Timeout ->
--                     b
--                 Http.NetworkError ->
--                     c
--                 Http.BadStatus int ->
--                     d int
--                 Http.BadBody string ->
--                     e string
--         )
--         |> Codec.variant1 "Http.BadUrl" Http.BadUrl Codec.string
--         |> Codec.variant0 "Http.Timeout" Http.Timeout
--         |> Codec.variant0 "Http.NetworkError" Http.NetworkError
--         |> Codec.variant1 "Http.BadStatus" Http.BadStatus Codec.int
--         |> Codec.variant1 "Http.BadBody" Http.BadBody Codec.string
--         |> Codec.buildCustom
-- timeCodec : Codec Time.Posix
-- timeCodec =
--     Codec.map Time.millisToPosix Time.posixToMillis Codec.int


type EmailResult
    = SendingEmail
    | EmailSuccess
    | EmailFailed Http.Error


type OrderStatus
    = Pending
    | Failed String
    | Paid StripePaymentId
    | Refunded StripePaymentId


type StripePaymentId
    = StripePaymentId String


type Product
    = CampTicket Price
    | CouplesCampTicket Price
    | CampfireTicket Price


type Sponsorship
    = SponsorBronze Price
    | SponsorSilver Price
    | SponsorGold Price


type alias CityCode =
    String


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
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport
    | AdminPullBackendModel
    | AdminPullBackendModelResponse (Result Http.Error BackendModel)
    | LogoMsg View.Logo.Msg
    | Noop
    | ElmUiMsg Ui.Msg
    | ScrolledToFragment
    | GotConversionRate (Result Http.Error (Quantity Float (Rate Euro CzechCrown)))


type ToBackend
    = SubmitFormRequest (Untrusted PurchaseFormValidated)
    | CancelPurchaseRequest
    | AdminInspect String


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List PriceData))
    | OnConnected SessionId ClientId
    | CreatedCheckoutSession SessionId ClientId PurchaseFormValidated (Result Http.Error ( Id StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Id StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Id StripeSessionId) (Result Http.Error ())
    | ErrorEmailSent (Result Postmark.SendEmailError ())


type alias InitData2 =
    { prices : SeqDict (Id ProductId) { priceId : Id PriceId, price : Price }
    , slotsRemaining : TicketCount
    , ticketsEnabled : TicketsEnabled
    }


type ToFrontend
    = InitData InitData2
    | SubmitFormResponse (Result String (Id StripeSessionId))
    | SlotRemainingChanged TicketCount
    | TicketsEnabledChanged TicketsEnabled
    | AdminInspectResponse BackendModel


type TicketsEnabled
    = TicketsEnabled
    | TicketsDisabled { adminMessage : String }


maxSlotsAvailable : number
maxSlotsAvailable =
    50
