module PurchaseForm exposing
    ( Accommodation(..)
    , AttendeeForm
    , AttendeeFormValidated
    , PressedSubmit(..)
    , PurchaseForm
    , PurchaseFormValidated
    , SubmitStatus(..)
    , defaultAttendee
    , init
    , validateEmailAddress
    , validateForm
    , validateInt
    , validateName
    )

import Camp24Devon.Product as Product
import Codec exposing (Codec)
import EmailAddress exposing (EmailAddress)
import Env
import Helpers
import Id exposing (Id)
import Name exposing (Name)
import Set exposing (Set)
import String.Nonempty exposing (NonemptyString)
import Stripe exposing (ProductId(..))
import Toop exposing (T3(..), T4(..), T5(..), T6(..), T7(..), T8(..))
import TravelMode exposing (TravelMode)


type Accommodation
    = Offsite
    | Campsite
    | Single
    | Double
    | Group


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , attendees : List AttendeeForm
    , accommodationBookings : List Accommodation
    , billingEmail : String
    , grantContribution : String
    , grantApply : Bool
    , sponsorship : Maybe String
    }


init : PurchaseForm
init =
    { submitStatus = NotSubmitted NotPressedSubmit
    , attendees = []
    , accommodationBookings = []
    , billingEmail = ""
    , grantContribution = ""
    , grantApply = False
    , sponsorship = Nothing
    }


type alias PurchaseFormValidated =
    { attendees : List AttendeeFormValidated
    , accommodationBookings : List Accommodation
    , billingEmail : EmailAddress
    , grantContribution : Int
    , sponsorship : Maybe String
    }


type alias AttendeeForm =
    { name : String
    , email : String
    , country : String
    , originCity : String
    , primaryModeOfTravel : Maybe TravelMode
    }


defaultAttendee : AttendeeForm
defaultAttendee =
    { name = ""
    , email = ""
    , country = ""
    , originCity = ""
    , primaryModeOfTravel = Nothing
    }


type alias AttendeeFormValidated =
    { name : Name
    , email : EmailAddress
    , country : NonemptyString
    , originCity : NonemptyString
    , primaryModeOfTravel : Maybe TravelMode
    }


type SubmitStatus
    = NotSubmitted PressedSubmit
    | Submitting
    | SubmitBackendError String


type PressedSubmit
    = PressedSubmit
    | NotPressedSubmit



-- billingEmail : PurchaseFormValidated -> EmailAddress
-- billingEmail paymentForm =
--     paymentForm.billingEmail


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


validateForm : PurchaseForm -> Maybe PurchaseFormValidated
validateForm form =
    let
        billingEmail =
            validateEmailAddress form.billingEmail

        grantContribution =
            validateInt form.grantContribution

        sponsorship =
            case form.sponsorship of
                Just id ->
                    Product.sponsorshipItems |> List.filter (\s -> s.productId == id) |> List.head |> Result.fromMaybe "Invalid sponsorship" |> Result.map (.productId >> Just)

                Nothing ->
                    Ok Nothing

        attendees =
            let
                attendeesValidated =
                    form.attendees |> List.map validateAttendee
            in
            if attendeesValidated |> List.all Helpers.isJust then
                attendeesValidated |> Helpers.justs |> Ok

            else
                Err "Invalid attendees"
    in
    case T4 billingEmail grantContribution sponsorship attendees of
        T4 (Ok billingEmailOk) (Ok grantContributionOk) (Ok sponsorshipOk) (Ok attendeesOk) ->
            Just
                { attendees = attendeesOk
                , accommodationBookings = form.accommodationBookings
                , billingEmail = billingEmailOk
                , grantContribution = grantContributionOk
                , sponsorship = sponsorshipOk
                }

        _ ->
            Nothing


validateAttendee : AttendeeForm -> Maybe AttendeeFormValidated
validateAttendee form =
    let
        name =
            validateName form.name

        emailAddress =
            validateEmailAddress form.email

        country =
            String.Nonempty.fromString form.country

        originCity =
            String.Nonempty.fromString form.originCity
    in
    case T4 name emailAddress country originCity of
        T4 (Ok nameOk) (Ok emailAddressOk) (Just countryOk) (Just originCityOk) ->
            Just
                { name = nameOk
                , email = emailAddressOk
                , country = countryOk
                , originCity = originCityOk
                , primaryModeOfTravel = form.primaryModeOfTravel
                }

        _ ->
            Nothing



-- codec : Codec PurchaseFormValidated
-- codec =
--     Codec.custom
--         (\a b c value ->
--             case value of
--                 CampfireTicketPurchase data0 ->
--                     a data0
--                 CampTicketPurchase data0 ->
--                     b data0
--                 CouplesCampTicketPurchase data0 ->
--                     c data0
--         )
--         |> Codec.variant1 "CampfireTicketPurchase" CampfireTicketPurchase singlePurchaseDataCodec
--         |> Codec.variant1 "CampTicketPurchase" CampTicketPurchase singlePurchaseDataCodec
--         |> Codec.variant1 "CouplesCampTicketPurchase" CouplesCampTicketPurchase couplePurchaseDataCodec
--         |> Codec.buildCustom
-- singlePurchaseDataCodec : Codec SinglePurchaseData
-- singlePurchaseDataCodec =
--     Codec.object SinglePurchaseData
--         |> Codec.field "attendeeName" .attendeeName Name.codec
--         |> Codec.field "billingEmail" .billingEmail emailAddressCodec
--         |> Codec.field "country" .country nonemptyStringCodec
--         |> Codec.field "originCity" .originCity nonemptyStringCodec
--         |> Codec.field "primaryModeOfTravel" .primaryModeOfTravel TravelMode.codec
--         |> Codec.field "grantContribution" .grantContribution Codec.int
--         |> Codec.field "sponsorship" .sponsorship (Codec.maybe Codec.string)
--         |> Codec.buildObject
-- couplePurchaseDataCodec : Codec CouplePurchaseData
-- couplePurchaseDataCodec =
--     Codec.object CouplePurchaseData
--         |> Codec.field "attendee1Name" .attendee1Name Name.codec
--         |> Codec.field "attendee2Name" .attendee2Name Name.codec
--         |> Codec.field "billingEmail" .billingEmail emailAddressCodec
--         |> Codec.field "country" .country nonemptyStringCodec
--         |> Codec.field "originCity" .originCity nonemptyStringCodec
--         |> Codec.field "primaryModeOfTravel" .primaryModeOfTravel TravelMode.codec
--         |> Codec.field "grantContribution" .grantContribution Codec.int
--         |> Codec.field "sponsorship" .sponsorship (Codec.maybe Codec.string)
--         |> Codec.buildObject
-- nonemptyStringCodec =
--     Codec.andThen
--         (\text ->
--             case String.Nonempty.fromString text of
--                 Just nonempty ->
--                     Codec.succeed nonempty
--                 Nothing ->
--                     Codec.fail ("Invalid nonempty string: " ++ text)
--         )
--         String.Nonempty.toString
--         Codec.string
-- emailAddressCodec : Codec EmailAddress
-- emailAddressCodec =
--     Codec.andThen
--         (\text ->
--             case EmailAddress.fromString text of
--                 Just email ->
--                     Codec.succeed email
--                 Nothing ->
--                     Codec.fail ("Invalid email: " ++ text)
--         )
--         EmailAddress.toString
--         Codec.string
