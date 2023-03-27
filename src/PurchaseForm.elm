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
    , validateName
    )

import Codec exposing (Codec)
import EmailAddress exposing (EmailAddress)
import Env
import Id exposing (Id)
import Name exposing (Name)
import String.Nonempty exposing (NonemptyString)
import Stripe exposing (ProductId(..))
import Toop exposing (T3(..), T4(..), T5(..), T6(..))
import TravelMode exposing (TravelMode)


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , attendee1Name : String
    , attendee2Name : String
    , billingEmail : String
    , country : String
    , originCity : String
    , primaryModeOfTravel : Maybe TravelMode
    }


type PurchaseFormValidated
    = SinglePurchase SinglePurchaseData
    | CouplePurchase CouplePurchaseData


type alias SinglePurchaseData =
    { attendeeName : Name
    , billingEmail : EmailAddress
    , country : NonemptyString
    , originCity : NonemptyString
    , primaryModeOfTravel : TravelMode
    }


type alias CouplePurchaseData =
    { attendee1Name : Name
    , attendee2Name : Name
    , billingEmail : EmailAddress
    , country : NonemptyString
    , originCity : NonemptyString
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

        country =
            String.Nonempty.fromString form.country

        originCity =
            String.Nonempty.fromString form.originCity
    in
    if productId == Id.fromString Env.couplesCampTicketProductId then
        case T6 name1 name2 emailAddress form.primaryModeOfTravel country originCity of
            T6 (Ok name1Ok) (Ok name2Ok) (Ok emailAddressOk) (Just primaryModeOfTravel) (Just countryOk) (Just originCityOk) ->
                CouplePurchase
                    { attendee1Name = name1Ok
                    , attendee2Name = name2Ok
                    , billingEmail = emailAddressOk
                    , country = countryOk
                    , originCity = originCityOk
                    , primaryModeOfTravel = primaryModeOfTravel
                    }
                    |> Just

            _ ->
                Nothing

    else
        case T5 name1 emailAddress form.primaryModeOfTravel country originCity of
            T5 (Ok name1Ok) (Ok emailAddressOk) (Just primaryModeOfTravel) (Just countryOk) (Just originCityOk) ->
                SinglePurchase
                    { attendeeName = name1Ok
                    , billingEmail = emailAddressOk
                    , country = countryOk
                    , originCity = originCityOk
                    , primaryModeOfTravel = primaryModeOfTravel
                    }
                    |> Just

            _ ->
                Nothing


codec : Codec PurchaseFormValidated
codec =
    Codec.custom
        (\a b value ->
            case value of
                SinglePurchase data0 ->
                    a data0

                CouplePurchase data0 ->
                    b data0
        )
        |> Codec.variant1 "SinglePurchase" SinglePurchase singlePurchaseDataCodec
        |> Codec.variant1 "CouplePurchase" CouplePurchase couplePurchaseDataCodec
        |> Codec.buildCustom


singlePurchaseDataCodec : Codec SinglePurchaseData
singlePurchaseDataCodec =
    Codec.object SinglePurchaseData
        |> Codec.field "attendeeName" .attendeeName Name.codec
        |> Codec.field "billingEmail" .billingEmail emailAddressCodec
        |> Codec.field "country" .country nonemptyStringCodec
        |> Codec.field "originCity" .originCity nonemptyStringCodec
        |> Codec.field "primaryModeOfTravel" .primaryModeOfTravel TravelMode.codec
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
