module Evergreen.V20.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V20.Id
import Evergreen.V20.Postmark
import Evergreen.V20.PurchaseForm
import Evergreen.V20.Route
import Evergreen.V20.Stripe
import Evergreen.V20.Untrusted
import Http
import Lamdera
import Time
import Url


type alias TicketAvailability =
    { campTicket : Bool
    , couplesCampTicket : Bool
    , campfireTicket : Bool
    }


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , prices :
        AssocList.Dict
            (Evergreen.V20.Id.Id Evergreen.V20.Stripe.ProductId)
            { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId
            , price : Evergreen.V20.Stripe.Price
            }
    , slotsRemaining : Maybe TicketAvailability
    , route : Evergreen.V20.Route.Route
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , showTooltip : Bool
    , prices :
        AssocList.Dict
            (Evergreen.V20.Id.Id Evergreen.V20.Stripe.ProductId)
            { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId
            , price : Evergreen.V20.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V20.Id.Id Evergreen.V20.Stripe.ProductId, Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId )
    , form : Evergreen.V20.PurchaseForm.PurchaseForm
    , route : Evergreen.V20.Route.Route
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V20.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V20.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V20.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId
    , price : Evergreen.V20.Stripe.Price
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V20.Id.Id Evergreen.V20.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V20.Id.Id Evergreen.V20.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V20.Id.Id Evergreen.V20.Stripe.ProductId) Price2
    , time : Time.Posix
    , dummyField : Int
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
    | PressedSelectTicket (Evergreen.V20.Id.Id Evergreen.V20.Stripe.ProductId) (Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId)
    | FormChanged Evergreen.V20.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V20.Id.Id Evergreen.V20.Stripe.ProductId) (Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport


type ToBackend
    = SubmitFormRequest (Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId) (Evergreen.V20.Untrusted.Untrusted Evergreen.V20.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V20.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId) Evergreen.V20.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V20.Id.Id Evergreen.V20.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V20.Id.Id Evergreen.V20.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V20.Id.Id Evergreen.V20.Stripe.StripeSessionId) (Result Http.Error Evergreen.V20.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V20.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData
        { prices :
            AssocList.Dict
                (Evergreen.V20.Id.Id Evergreen.V20.Stripe.ProductId)
                { priceId : Evergreen.V20.Id.Id Evergreen.V20.Stripe.PriceId
                , price : Evergreen.V20.Stripe.Price
                }
        , slotsRemaining : TicketAvailability
        }
    | SubmitFormResponse (Result String (Evergreen.V20.Id.Id Evergreen.V20.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
