module Evergreen.Migrate.V63 exposing (..)

{-| This migration file was automatically generated by the lamdera compiler.

It includes:

  - A migration for each of the 6 Lamdera core types that has changed
  - A function named `migrate_ModuleName_TypeName` for each changed/custom type

Expect to see:

  - `Unimplementеd` values as placeholders wherever I was unable to figure out a clear migration path for you
  - `@NOTICE` comments for things you should know about, i.e. new custom type constructors that won't get any
    value mappings from the old type by default

You can edit this file however you wish! It won't be generated again.

See <https://dashboard.lamdera.app/docs/evergreen> for more info.

-}

import AssocList
import Audio
import Evergreen.V56.EmailAddress
import Evergreen.V56.Id
import Evergreen.V56.LiveSchedule
import Evergreen.V56.Name
import Evergreen.V56.Postmark
import Evergreen.V56.PurchaseForm
import Evergreen.V56.Route
import Evergreen.V56.Stripe
import Evergreen.V56.TravelMode
import Evergreen.V56.Types
import Evergreen.V63.EmailAddress
import Evergreen.V63.Id
import Evergreen.V63.LiveSchedule
import Evergreen.V63.Name
import Evergreen.V63.Postmark
import Evergreen.V63.PurchaseForm
import Evergreen.V63.Route
import Evergreen.V63.Stripe
import Evergreen.V63.TravelMode
import Evergreen.V63.Types
import Lamdera.Migrations exposing (..)
import Maybe


frontendModel : Evergreen.V56.Types.FrontendModel -> ModelMigration Evergreen.V63.Types.FrontendModel Evergreen.V63.Types.FrontendMsg
frontendModel old =
    ModelMigrated ( migrate_Types_FrontendModel old, Cmd.none )


backendModel : Evergreen.V56.Types.BackendModel -> ModelMigration Evergreen.V63.Types.BackendModel Evergreen.V63.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V56.Types.FrontendMsg -> MsgMigration Evergreen.V63.Types.FrontendMsg Evergreen.V63.Types.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Evergreen.V56.Types.ToBackend -> MsgMigration Evergreen.V63.Types.ToBackend Evergreen.V63.Types.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Evergreen.V56.Types.BackendMsg -> MsgMigration Evergreen.V63.Types.BackendMsg Evergreen.V63.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V56.Types.ToFrontend -> MsgMigration Evergreen.V63.Types.ToFrontend Evergreen.V63.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_Types_FrontendModel : Evergreen.V56.Types.FrontendModel -> Evergreen.V63.Types.FrontendModel
migrate_Types_FrontendModel old =
    old |> migrate_Audio_Model migrate_Types_FrontendMsg_ migrate_Types_FrontendModel_


migrate_AssocList_Dict : (a_old -> a_new) -> (b_old -> b_new) -> AssocList.Dict a_old b_old -> AssocList.Dict a_new b_new
migrate_AssocList_Dict migrate_a migrate_b old =
    old
        |> AssocList.toList
        |> List.map (Tuple.mapBoth migrate_a migrate_b)
        |> AssocList.fromList


migrate_Audio_Model : (userMsg_old -> userMsg_new) -> (userModel_old -> userModel_new) -> Audio.Model userMsg_old userModel_old -> Audio.Model userMsg_new userModel_new
migrate_Audio_Model migrate_userMsg migrate_userModel old =
    old
        |> Audio.migrateModel migrate_userMsg (\userModel_old -> ( migrate_userModel userModel_old, Cmd.none ))
        |> Tuple.first


migrate_EmailAddress_EmailAddress : Evergreen.V56.EmailAddress.EmailAddress -> Evergreen.V63.EmailAddress.EmailAddress
migrate_EmailAddress_EmailAddress old =
    case old of
        Evergreen.V56.EmailAddress.EmailAddress p0 ->
            Evergreen.V63.EmailAddress.EmailAddress p0


migrate_Id_Id : (a_old -> a_new) -> Evergreen.V56.Id.Id a_old -> Evergreen.V63.Id.Id a_new
migrate_Id_Id migrate_a old =
    case old of
        Evergreen.V56.Id.Id p0 ->
            Evergreen.V63.Id.Id p0


migrate_LiveSchedule_Msg : Evergreen.V56.LiveSchedule.Msg -> Evergreen.V63.LiveSchedule.Msg
migrate_LiveSchedule_Msg old =
    case old of
        Evergreen.V56.LiveSchedule.PressedAllowAudio ->
            Evergreen.V63.LiveSchedule.PressedAllowAudio


migrate_Name_Name : Evergreen.V56.Name.Name -> Evergreen.V63.Name.Name
migrate_Name_Name old =
    case old of
        Evergreen.V56.Name.Name p0 ->
            Evergreen.V63.Name.Name p0


migrate_Postmark_PostmarkSendResponse : Evergreen.V56.Postmark.PostmarkSendResponse -> Evergreen.V63.Postmark.PostmarkSendResponse
migrate_Postmark_PostmarkSendResponse old =
    old


migrate_PurchaseForm_CouplePurchaseData : Evergreen.V56.PurchaseForm.CouplePurchaseData -> Evergreen.V63.PurchaseForm.CouplePurchaseData
migrate_PurchaseForm_CouplePurchaseData old =
    { attendee1Name = old.attendee1Name |> migrate_Name_Name
    , attendee2Name = old.attendee2Name |> migrate_Name_Name
    , billingEmail = old.billingEmail |> migrate_EmailAddress_EmailAddress
    , country = old.country
    , originCity = old.originCity
    , primaryModeOfTravel = old.primaryModeOfTravel |> migrate_TravelMode_TravelMode
    , grantContribution = old.grantContribution
    , sponsorship = old.sponsorship
    }


migrate_PurchaseForm_PressedSubmit : Evergreen.V56.PurchaseForm.PressedSubmit -> Evergreen.V63.PurchaseForm.PressedSubmit
migrate_PurchaseForm_PressedSubmit old =
    case old of
        Evergreen.V56.PurchaseForm.PressedSubmit ->
            Evergreen.V63.PurchaseForm.PressedSubmit

        Evergreen.V56.PurchaseForm.NotPressedSubmit ->
            Evergreen.V63.PurchaseForm.NotPressedSubmit


migrate_PurchaseForm_PurchaseForm : Evergreen.V56.PurchaseForm.PurchaseForm -> Evergreen.V63.PurchaseForm.PurchaseForm
migrate_PurchaseForm_PurchaseForm old =
    { submitStatus = old.submitStatus |> migrate_PurchaseForm_SubmitStatus
    , attendee1Name = old.attendee1Name
    , attendee2Name = old.attendee2Name
    , billingEmail = old.billingEmail
    , country = old.country
    , originCity = old.originCity
    , primaryModeOfTravel = old.primaryModeOfTravel |> Maybe.map migrate_TravelMode_TravelMode
    , grantContribution = old.grantContribution
    , grantApply = old.grantApply
    , sponsorship = old.sponsorship
    }


migrate_PurchaseForm_PurchaseFormValidated : Evergreen.V56.PurchaseForm.PurchaseFormValidated -> Evergreen.V63.PurchaseForm.PurchaseFormValidated
migrate_PurchaseForm_PurchaseFormValidated old =
    case old of
        Evergreen.V56.PurchaseForm.CampfireTicketPurchase p0 ->
            Evergreen.V63.PurchaseForm.CampfireTicketPurchase (p0 |> migrate_PurchaseForm_SinglePurchaseData)

        Evergreen.V56.PurchaseForm.CampTicketPurchase p0 ->
            Evergreen.V63.PurchaseForm.CampTicketPurchase (p0 |> migrate_PurchaseForm_SinglePurchaseData)

        Evergreen.V56.PurchaseForm.CouplesCampTicketPurchase p0 ->
            Evergreen.V63.PurchaseForm.CouplesCampTicketPurchase (p0 |> migrate_PurchaseForm_CouplePurchaseData)


migrate_PurchaseForm_SinglePurchaseData : Evergreen.V56.PurchaseForm.SinglePurchaseData -> Evergreen.V63.PurchaseForm.SinglePurchaseData
migrate_PurchaseForm_SinglePurchaseData old =
    { attendeeName = old.attendeeName |> migrate_Name_Name
    , billingEmail = old.billingEmail |> migrate_EmailAddress_EmailAddress
    , country = old.country
    , originCity = old.originCity
    , primaryModeOfTravel = old.primaryModeOfTravel |> migrate_TravelMode_TravelMode
    , grantContribution = old.grantContribution
    , sponsorship = old.sponsorship
    }


migrate_PurchaseForm_SubmitStatus : Evergreen.V56.PurchaseForm.SubmitStatus -> Evergreen.V63.PurchaseForm.SubmitStatus
migrate_PurchaseForm_SubmitStatus old =
    case old of
        Evergreen.V56.PurchaseForm.NotSubmitted p0 ->
            Evergreen.V63.PurchaseForm.NotSubmitted (p0 |> migrate_PurchaseForm_PressedSubmit)

        Evergreen.V56.PurchaseForm.Submitting ->
            Evergreen.V63.PurchaseForm.Submitting

        Evergreen.V56.PurchaseForm.SubmitBackendError p0 ->
            Evergreen.V63.PurchaseForm.SubmitBackendError p0


migrate_Route_Route : Evergreen.V56.Route.Route -> Evergreen.V63.Route.Route
migrate_Route_Route old =
    case old of
        Evergreen.V56.Route.HomepageRoute ->
            Evergreen.V63.Route.HomepageRoute

        Evergreen.V56.Route.UnconferenceFormatRoute ->
            Evergreen.V63.Route.UnconferenceFormatRoute

        Evergreen.V56.Route.VenueAndAccessRoute ->
            Evergreen.V63.Route.VenueAndAccessRoute

        Evergreen.V56.Route.CodeOfConductRoute ->
            Evergreen.V63.Route.CodeOfConductRoute

        Evergreen.V56.Route.AdminRoute p0 ->
            Evergreen.V63.Route.AdminRoute p0

        Evergreen.V56.Route.PaymentSuccessRoute p0 ->
            Evergreen.V63.Route.PaymentSuccessRoute (p0 |> Maybe.map migrate_EmailAddress_EmailAddress)

        Evergreen.V56.Route.PaymentCancelRoute ->
            Evergreen.V63.Route.PaymentCancelRoute

        Evergreen.V56.Route.LiveScheduleRoute ->
            Evergreen.V63.Route.LiveScheduleRoute

        Evergreen.V56.Route.Camp23Denmark p0 ->
            Evergreen.V63.Route.Camp23Denmark (p0 |> migrate_Route_SubPage)


migrate_Route_SubPage : Evergreen.V56.Route.SubPage -> Evergreen.V63.Route.SubPage
migrate_Route_SubPage old =
    case old of
        Evergreen.V56.Route.Home ->
            Evergreen.V63.Route.Home

        Evergreen.V56.Route.Artifacts ->
            Evergreen.V63.Route.Artifacts


migrate_Stripe_Price : Evergreen.V56.Stripe.Price -> Evergreen.V63.Stripe.Price
migrate_Stripe_Price old =
    old


migrate_Stripe_PriceId : Evergreen.V56.Stripe.PriceId -> Evergreen.V63.Stripe.PriceId
migrate_Stripe_PriceId old =
    case old of
        Evergreen.V56.Stripe.PriceId p0 ->
            Evergreen.V63.Stripe.PriceId p0


migrate_Stripe_ProductId : Evergreen.V56.Stripe.ProductId -> Evergreen.V63.Stripe.ProductId
migrate_Stripe_ProductId old =
    case old of
        Evergreen.V56.Stripe.ProductId p0 ->
            Evergreen.V63.Stripe.ProductId p0


migrate_Stripe_StripeSessionId : Evergreen.V56.Stripe.StripeSessionId -> Evergreen.V63.Stripe.StripeSessionId
migrate_Stripe_StripeSessionId old =
    case old of
        Evergreen.V56.Stripe.StripeSessionId p0 ->
            Evergreen.V63.Stripe.StripeSessionId p0


migrate_TravelMode_TravelMode : Evergreen.V56.TravelMode.TravelMode -> Evergreen.V63.TravelMode.TravelMode
migrate_TravelMode_TravelMode old =
    case old of
        Evergreen.V56.TravelMode.Flight ->
            Evergreen.V63.TravelMode.Flight

        Evergreen.V56.TravelMode.Bus ->
            Evergreen.V63.TravelMode.Bus

        Evergreen.V56.TravelMode.Car ->
            Evergreen.V63.TravelMode.Car

        Evergreen.V56.TravelMode.Train ->
            Evergreen.V63.TravelMode.Train

        Evergreen.V56.TravelMode.Boat ->
            Evergreen.V63.TravelMode.Boat

        Evergreen.V56.TravelMode.OtherTravelMode ->
            Evergreen.V63.TravelMode.OtherTravelMode


migrate_Types_BackendModel : Evergreen.V56.Types.BackendModel -> Evergreen.V63.Types.BackendModel
migrate_Types_BackendModel old =
    { orders = old.orders |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_StripeSessionId) migrate_Types_Order
    , pendingOrder = old.pendingOrder |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_StripeSessionId) migrate_Types_PendingOrder
    , expiredOrders = old.expiredOrders |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_StripeSessionId) migrate_Types_PendingOrder
    , prices = old.prices |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_ProductId) migrate_Types_Price2
    , time = old.time
    , ticketsEnabled = old.ticketsEnabled |> migrate_Types_TicketsEnabled
    }


migrate_Types_EmailResult : Evergreen.V56.Types.EmailResult -> Evergreen.V63.Types.EmailResult
migrate_Types_EmailResult old =
    case old of
        Evergreen.V56.Types.SendingEmail ->
            Evergreen.V63.Types.SendingEmail

        Evergreen.V56.Types.EmailSuccess p0 ->
            Evergreen.V63.Types.EmailSuccess (p0 |> migrate_Postmark_PostmarkSendResponse)

        Evergreen.V56.Types.EmailFailed p0 ->
            Evergreen.V63.Types.EmailFailed p0


migrate_Types_FrontendModel_ : Evergreen.V56.Types.FrontendModel_ -> Evergreen.V63.Types.FrontendModel_
migrate_Types_FrontendModel_ old =
    case old of
        Evergreen.V56.Types.Loading p0 ->
            Evergreen.V63.Types.Loading (p0 |> migrate_Types_LoadingModel)

        Evergreen.V56.Types.Loaded p0 ->
            Evergreen.V63.Types.Loaded (p0 |> migrate_Types_LoadedModel)


migrate_Types_FrontendMsg_ : Evergreen.V56.Types.FrontendMsg_ -> Evergreen.V63.Types.FrontendMsg_
migrate_Types_FrontendMsg_ old =
    case old of
        Evergreen.V56.Types.UrlClicked p0 ->
            Evergreen.V63.Types.UrlClicked p0

        Evergreen.V56.Types.UrlChanged p0 ->
            Evergreen.V63.Types.UrlChanged p0

        Evergreen.V56.Types.Tick p0 ->
            Evergreen.V63.Types.Tick p0

        Evergreen.V56.Types.GotWindowSize p0 p1 ->
            Evergreen.V63.Types.GotWindowSize p0 p1

        Evergreen.V56.Types.PressedShowTooltip ->
            Evergreen.V63.Types.PressedShowTooltip

        Evergreen.V56.Types.MouseDown ->
            Evergreen.V63.Types.MouseDown

        Evergreen.V56.Types.PressedSelectTicket p0 p1 ->
            Evergreen.V63.Types.PressedSelectTicket (p0 |> migrate_Id_Id migrate_Stripe_ProductId)
                (p1 |> migrate_Id_Id migrate_Stripe_PriceId)

        Evergreen.V56.Types.FormChanged p0 ->
            Evergreen.V63.Types.FormChanged (p0 |> migrate_PurchaseForm_PurchaseForm)

        Evergreen.V56.Types.PressedSubmitForm p0 p1 ->
            Evergreen.V63.Types.PressedSubmitForm (p0 |> migrate_Id_Id migrate_Stripe_ProductId)
                (p1 |> migrate_Id_Id migrate_Stripe_PriceId)

        Evergreen.V56.Types.PressedCancelForm ->
            Evergreen.V63.Types.PressedCancelForm

        Evergreen.V56.Types.PressedShowCarbonOffsetTooltip ->
            Evergreen.V63.Types.PressedShowCarbonOffsetTooltip

        Evergreen.V56.Types.SetViewport ->
            Evergreen.V63.Types.SetViewport

        Evergreen.V56.Types.LoadedMusic p0 ->
            Evergreen.V63.Types.LoadedMusic p0

        Evergreen.V56.Types.LiveScheduleMsg p0 ->
            Evergreen.V63.Types.LiveScheduleMsg (p0 |> migrate_LiveSchedule_Msg)


migrate_Types_InitData2 : Evergreen.V56.Types.InitData2 -> Evergreen.V63.Types.InitData2
migrate_Types_InitData2 old =
    { prices =
        old.prices
            |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_ProductId)
                (\rec ->
                    { priceId = rec.priceId |> migrate_Id_Id migrate_Stripe_PriceId
                    , price = rec.price |> migrate_Stripe_Price
                    }
                )
    , slotsRemaining = old.slotsRemaining |> migrate_Types_TicketAvailability
    , ticketsEnabled = old.ticketsEnabled |> migrate_Types_TicketsEnabled
    }


migrate_Types_LoadedModel : Evergreen.V56.Types.LoadedModel -> Evergreen.V63.Types.LoadedModel
migrate_Types_LoadedModel old =
    { key = old.key
    , now = old.now
    , window =
        old.window
            |> (\rec -> rec)
    , showTooltip = old.showTooltip
    , prices =
        old.prices
            |> migrate_AssocList_Dict (migrate_Id_Id migrate_Stripe_ProductId)
                (\rec ->
                    { priceId = rec.priceId |> migrate_Id_Id migrate_Stripe_PriceId
                    , price = rec.price |> migrate_Stripe_Price
                    }
                )
    , selectedTicket = old.selectedTicket |> Maybe.map (Tuple.mapBoth (migrate_Id_Id migrate_Stripe_ProductId) (migrate_Id_Id migrate_Stripe_PriceId))
    , form = old.form |> migrate_PurchaseForm_PurchaseForm
    , route = old.route |> migrate_Route_Route
    , showCarbonOffsetTooltip = old.showCarbonOffsetTooltip
    , slotsRemaining = old.slotsRemaining |> migrate_Types_TicketAvailability
    , isOrganiser = old.isOrganiser
    , ticketsEnabled = old.ticketsEnabled |> migrate_Types_TicketsEnabled
    , backendModel = old.backendModel |> Maybe.map migrate_Types_BackendModel
    , audio = old.audio
    , pressedAudioButton = old.pressedAudioButton
    }


migrate_Types_LoadingModel : Evergreen.V56.Types.LoadingModel -> Evergreen.V63.Types.LoadingModel
migrate_Types_LoadingModel old =
    { key = old.key
    , now = old.now
    , window = old.window
    , route = old.route |> migrate_Route_Route
    , isOrganiser = old.isOrganiser
    , initData = old.initData |> Maybe.map migrate_Types_InitData2
    , audio = old.audio
    }


migrate_Types_Order : Evergreen.V56.Types.Order -> Evergreen.V63.Types.Order
migrate_Types_Order old =
    { priceId = old.priceId |> migrate_Id_Id migrate_Stripe_PriceId
    , submitTime = old.submitTime
    , form = old.form |> migrate_PurchaseForm_PurchaseFormValidated
    , emailResult = old.emailResult |> migrate_Types_EmailResult
    }


migrate_Types_PendingOrder : Evergreen.V56.Types.PendingOrder -> Evergreen.V63.Types.PendingOrder
migrate_Types_PendingOrder old =
    { priceId = old.priceId |> migrate_Id_Id migrate_Stripe_PriceId
    , submitTime = old.submitTime
    , form = old.form |> migrate_PurchaseForm_PurchaseFormValidated
    , sessionId = old.sessionId
    }


migrate_Types_Price2 : Evergreen.V56.Types.Price2 -> Evergreen.V63.Types.Price2
migrate_Types_Price2 old =
    { priceId = old.priceId |> migrate_Id_Id migrate_Stripe_PriceId
    , price = old.price |> migrate_Stripe_Price
    }


migrate_Types_TicketAvailability : Evergreen.V56.Types.TicketAvailability -> Evergreen.V63.Types.TicketAvailability
migrate_Types_TicketAvailability old =
    old


migrate_Types_TicketsEnabled : Evergreen.V56.Types.TicketsEnabled -> Evergreen.V63.Types.TicketsEnabled
migrate_Types_TicketsEnabled old =
    case old of
        Evergreen.V56.Types.TicketsEnabled ->
            Evergreen.V63.Types.TicketsEnabled

        Evergreen.V56.Types.TicketsDisabled p0 ->
            Evergreen.V63.Types.TicketsDisabled p0
