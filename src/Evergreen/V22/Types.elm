module Evergreen.V22.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Evergreen.V22.Id
import Evergreen.V22.Postmark
import Evergreen.V22.PurchaseForm
import Evergreen.V22.Route
import Evergreen.V22.Stripe
import Evergreen.V22.Untrusted
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
            (Evergreen.V22.Id.Id Evergreen.V22.Stripe.ProductId)
            { priceId : Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId
            , price : Evergreen.V22.Stripe.Price
            }
    , slotsRemaining : Maybe TicketAvailability
    , route : Evergreen.V22.Route.Route
    , isOrganiser : Bool
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
            (Evergreen.V22.Id.Id Evergreen.V22.Stripe.ProductId)
            { priceId : Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId
            , price : Evergreen.V22.Stripe.Price
            }
    , selectedTicket : Maybe ( Evergreen.V22.Id.Id Evergreen.V22.Stripe.ProductId, Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId )
    , form : Evergreen.V22.PurchaseForm.PurchaseForm
    , route : Evergreen.V22.Route.Route
    , showCarbonOffsetTooltip : Bool
    , slotsRemaining : TicketAvailability
    , isOrganiser : Bool
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type EmailResult
    = SendingEmail
    | EmailSuccess Evergreen.V22.Postmark.PostmarkSendResponse
    | EmailFailed Http.Error


type alias Order =
    { priceId : Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V22.PurchaseForm.PurchaseFormValidated
    , emailResult : EmailResult
    }


type alias PendingOrder =
    { priceId : Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId
    , submitTime : Time.Posix
    , form : Evergreen.V22.PurchaseForm.PurchaseFormValidated
    , sessionId : Lamdera.SessionId
    }


type alias Price2 =
    { priceId : Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId
    , price : Evergreen.V22.Stripe.Price
    }


type alias BackendModel =
    { orders : AssocList.Dict (Evergreen.V22.Id.Id Evergreen.V22.Stripe.StripeSessionId) Order
    , pendingOrder : AssocList.Dict (Evergreen.V22.Id.Id Evergreen.V22.Stripe.StripeSessionId) PendingOrder
    , prices : AssocList.Dict (Evergreen.V22.Id.Id Evergreen.V22.Stripe.ProductId) Price2
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
    | PressedSelectTicket (Evergreen.V22.Id.Id Evergreen.V22.Stripe.ProductId) (Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId)
    | FormChanged Evergreen.V22.PurchaseForm.PurchaseForm
    | PressedSubmitForm (Evergreen.V22.Id.Id Evergreen.V22.Stripe.ProductId) (Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId)
    | PressedCancelForm
    | PressedShowCarbonOffsetTooltip
    | SetViewport


type ToBackend
    = SubmitFormRequest (Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId) (Evergreen.V22.Untrusted.Untrusted Evergreen.V22.PurchaseForm.PurchaseFormValidated)
    | CancelPurchaseRequest


type BackendMsg
    = GotTime Time.Posix
    | GotPrices (Result Http.Error (List Evergreen.V22.Stripe.PriceData))
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | CreatedCheckoutSession Lamdera.SessionId Lamdera.ClientId (Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId) Evergreen.V22.PurchaseForm.PurchaseFormValidated (Result Http.Error ( Evergreen.V22.Id.Id Evergreen.V22.Stripe.StripeSessionId, Time.Posix ))
    | ExpiredStripeSession (Evergreen.V22.Id.Id Evergreen.V22.Stripe.StripeSessionId) (Result Http.Error ())
    | ConfirmationEmailSent (Evergreen.V22.Id.Id Evergreen.V22.Stripe.StripeSessionId) (Result Http.Error Evergreen.V22.Postmark.PostmarkSendResponse)
    | ErrorEmailSent (Result Http.Error Evergreen.V22.Postmark.PostmarkSendResponse)


type ToFrontend
    = InitData
        { prices :
            AssocList.Dict
                (Evergreen.V22.Id.Id Evergreen.V22.Stripe.ProductId)
                { priceId : Evergreen.V22.Id.Id Evergreen.V22.Stripe.PriceId
                , price : Evergreen.V22.Stripe.Price
                }
        , slotsRemaining : TicketAvailability
        }
    | SubmitFormResponse (Result String (Evergreen.V22.Id.Id Evergreen.V22.Stripe.StripeSessionId))
    | SlotRemainingChanged TicketAvailability
