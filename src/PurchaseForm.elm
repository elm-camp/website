module PurchaseForm exposing
    ( CouplePurchaseData
    , PressedSubmit(..)
    , PurchaseForm
    , PurchaseFormValidated(..)
    , SinglePurchaseData
    , SubmitStatus(..)
    , attendeeName
    , billingEmail
    , codec
    , validateEmailAddress
    , validateForm
    , validateInt
    , validateName
    )

import Codec exposing (Codec)
import EmailAddress exposing (EmailAddress)
import Env
import Id exposing (Id)
import Name exposing (Name)
import String.Nonempty exposing (NonemptyString)
import Stripe exposing (ProductId(..))
import Toop exposing (T3(..), T4(..), T5(..), T6(..), T7(..))
import TravelMode exposing (TravelMode)


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , attendee1Name : String
    , attendee2Name : String
    , billingEmail : String
    , country : String
    , originCity : String
    , primaryModeOfTravel : Maybe TravelMode
    , grantContribution : String
    }


type PurchaseFormValidated
    = CampfireTicketPurchase SinglePurchaseData
    | CampTicketPurchase SinglePurchaseData
    | CouplesCampTicketPurchase CouplePurchaseData


type alias SinglePurchaseData =
    { attendeeName : Name
    , billingEmail : EmailAddress
    , country : NonemptyString
    , originCity : NonemptyString
    , primaryModeOfTravel : TravelMode
    , grantContribution : Int
    }


type alias CouplePurchaseData =
    { attendee1Name : Name
    , attendee2Name : Name
    , billingEmail : EmailAddress
    , country : NonemptyString
    , originCity : NonemptyString
    , primaryModeOfTravel : TravelMode
    , grantContribution : Int
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
        CampfireTicketPurchase a ->
            a.billingEmail

        CampTicketPurchase a ->
            a.billingEmail

        CouplesCampTicketPurchase a ->
            a.billingEmail


attendeeName : PurchaseFormValidated -> Name
attendeeName paymentForm =
    case paymentForm of
        CampfireTicketPurchase a ->
            a.attendeeName

        CampTicketPurchase a ->
            a.attendeeName

        CouplesCampTicketPurchase a ->
            a.attendee1Name


validateInt : String -> Result String Int
validateInt s =
    case String.toInt s of
        Nothing ->
            Err "Invalid number"

        Just x ->
            Ok x


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

        country =
            String.Nonempty.fromString form.country

        originCity =
            String.Nonempty.fromString form.originCity

        grantContribution =
            validateInt form.grantContribution
    in
    if productId == Id.fromString Env.couplesCampTicketProductId then
        case T7 name1 name2 emailAddress form.primaryModeOfTravel country originCity grantContribution of
            T7 (Ok name1Ok) (Ok name2Ok) (Ok emailAddressOk) (Just primaryModeOfTravel) (Just countryOk) (Just originCityOk) (Ok grantContributionOk) ->
                CouplesCampTicketPurchase
                    { attendee1Name = name1Ok
                    , attendee2Name = name2Ok
                    , billingEmail = emailAddressOk
                    , country = countryOk
                    , originCity = originCityOk
                    , primaryModeOfTravel = primaryModeOfTravel
                    , grantContribution = grantContributionOk
                    }
                    |> Just

            _ ->
                Nothing

    else
        let
            product =
                if productId == Id.fromString Env.campTicketProductId then
                    CampTicketPurchase

                else
                    CampfireTicketPurchase
        in
        case T6 name1 emailAddress form.primaryModeOfTravel country originCity grantContribution of
            T6 (Ok name1Ok) (Ok emailAddressOk) (Just primaryModeOfTravel) (Just countryOk) (Just originCityOk) (Ok grantContributionOk) ->
                product
                    { attendeeName = name1Ok
                    , billingEmail = emailAddressOk
                    , country = countryOk
                    , originCity = originCityOk
                    , primaryModeOfTravel = primaryModeOfTravel
                    , grantContribution = grantContributionOk
                    }
                    |> Just

            _ ->
                Nothing


codec : Codec PurchaseFormValidated
codec =
    Codec.custom
        (\a b c value ->
            case value of
                CampfireTicketPurchase data0 ->
                    a data0

                CampTicketPurchase data0 ->
                    b data0

                CouplesCampTicketPurchase data0 ->
                    c data0
        )
        |> Codec.variant1 "CampfireTicketPurchase" CampfireTicketPurchase singlePurchaseDataCodec
        |> Codec.variant1 "CampTicketPurchase" CampTicketPurchase singlePurchaseDataCodec
        |> Codec.variant1 "CouplesCampTicketPurchase" CouplesCampTicketPurchase couplePurchaseDataCodec
        |> Codec.buildCustom


singlePurchaseDataCodec : Codec SinglePurchaseData
singlePurchaseDataCodec =
    Codec.object SinglePurchaseData
        |> Codec.field "attendeeName" .attendeeName Name.codec
        |> Codec.field "billingEmail" .billingEmail emailAddressCodec
        |> Codec.field "country" .country nonemptyStringCodec
        |> Codec.field "originCity" .originCity nonemptyStringCodec
        |> Codec.field "primaryModeOfTravel" .primaryModeOfTravel TravelMode.codec
        |> Codec.field "grantContribution" .grantContribution Codec.int
        |> Codec.buildObject


couplePurchaseDataCodec : Codec CouplePurchaseData
couplePurchaseDataCodec =
    Codec.object CouplePurchaseData
        |> Codec.field "attendee1Name" .attendee1Name Name.codec
        |> Codec.field "attendee2Name" .attendee2Name Name.codec
        |> Codec.field "billingEmail" .billingEmail emailAddressCodec
        |> Codec.field "country" .country nonemptyStringCodec
        |> Codec.field "originCity" .originCity nonemptyStringCodec
        |> Codec.field "primaryModeOfTravel" .primaryModeOfTravel TravelMode.codec
        |> Codec.field "grantContribution" .grantContribution Codec.int
        |> Codec.buildObject


nonemptyStringCodec =
    Codec.andThen
        (\text ->
            case String.Nonempty.fromString text of
                Just nonempty ->
                    Codec.succeed nonempty

                Nothing ->
                    Codec.fail ("Invalid nonempty string: " ++ text)
        )
        String.Nonempty.toString
        Codec.string


emailAddressCodec : Codec EmailAddress
emailAddressCodec =
    Codec.andThen
        (\text ->
            case EmailAddress.fromString text of
                Just email ->
                    Codec.succeed email

                Nothing ->
                    Codec.fail ("Invalid email: " ++ text)
        )
        EmailAddress.toString
        Codec.string
