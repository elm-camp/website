module PurchaseForm exposing
    ( PressedSubmit(..)
    , PurchaseForm
    , PurchaseFormValidated(..)
    , SubmitStatus(..)
    , attendeeName
    , billingEmail
    , validateEmailAddress
    , validateForm
    , validateName
    )

import EmailAddress exposing (EmailAddress)
import Env
import Id exposing (Id)
import Name exposing (Name)
import Stripe exposing (ProductId(..))
import Toop exposing (T3(..), T4(..))
import TravelMode exposing (TravelMode)


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , attendee1Name : String
    , attendee2Name : String
    , billingEmail : String
    , originCity : String
    , primaryModeOfTravel : Maybe TravelMode
    }


type PurchaseFormValidated
    = SinglePurchase
        { attendeeName : Name
        , billingEmail : EmailAddress
        , originCity : String
        , primaryModeOfTravel : TravelMode
        }
    | CouplePurchase
        { attendee1Name : Name
        , attendee2Name : Name
        , billingEmail : EmailAddress
        , originCity : String
        , primaryModeOfTravel : TravelMode
        }


type SubmitStatus
    = NotSubmitted PressedSubmit
    | Submitting
    | SubmitBackendError


type PressedSubmit
    = PressedSubmit
    | NotPressedSubmit


billingEmail : PurchaseFormValidated -> EmailAddress
billingEmail paymentForm =
    case paymentForm of
        SinglePurchase a ->
            a.billingEmail

        CouplePurchase a ->
            a.billingEmail


attendeeName : PurchaseFormValidated -> Name
attendeeName paymentForm =
    case paymentForm of
        SinglePurchase a ->
            a.attendeeName

        CouplePurchase a ->
            a.attendee1Name


validateName : String -> Result String Name
validateName name =
    Name.fromString name |> Result.mapError Name.errorToString


validateEmailAddress : String -> Result String EmailAddress
validateEmailAddress text =
    if String.trim text == "" then
        Err "Please enter an email address"

    else
        case EmailAddress.fromString text of
            Just emailAddress ->
                Ok emailAddress

            Nothing ->
                Err "Invalid email address"


validateForm : Id ProductId -> PurchaseForm -> Maybe PurchaseFormValidated
validateForm productId form =
    let
        name1 =
            validateName form.attendee1Name

        name2 =
            validateName form.attendee2Name

        emailAddress =
            validateEmailAddress form.billingEmail
    in
    if productId == Id.fromString Env.couplesCampTicketProductId then
        case T4 name1 name2 emailAddress form.primaryModeOfTravel of
            T4 (Ok name1Ok) (Ok name2Ok) (Ok emailAddressOk) (Just primaryModeOfTravel) ->
                CouplePurchase
                    { attendee1Name = name1Ok
                    , attendee2Name = name2Ok
                    , billingEmail = emailAddressOk
                    , originCity = ""
                    , primaryModeOfTravel = primaryModeOfTravel
                    }
                    |> Just

            _ ->
                Nothing

    else
        case T3 name1 emailAddress form.primaryModeOfTravel of
            T3 (Ok name1Ok) (Ok emailAddressOk) (Just primaryModeOfTravel) ->
                SinglePurchase
                    { attendeeName = name1Ok
                    , billingEmail = emailAddressOk
                    , originCity = ""
                    , primaryModeOfTravel = primaryModeOfTravel
                    }
                    |> Just

            _ ->
                Nothing
