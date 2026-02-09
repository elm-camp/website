module PurchaseForm exposing
    ( AttendeeForm
    , AttendeeFormValidated
    , PressedSubmit(..)
    , PurchaseForm
    , PurchaseFormValidated
    , SubmitStatus(..)
    , TicketTypes
    , defaultAttendee
    , init
    , initTicketCount
    , unvalidateAttendee
    , unvalidateGrantContribution
    , validateAttendees
    , validateEmailAddress
    , validateForm
    , validateGrantContribution
    , validateName
    )

import EmailAddress exposing (EmailAddress)
import Name exposing (Name)
import NonNegative exposing (NonNegative)
import Quantity exposing (Quantity, Rate)
import String.Nonempty exposing (NonemptyString)
import Stripe exposing (LocalCurrency, StripeCurrency)
import Toop exposing (T3(..), T4(..), T5(..), T6(..), T7(..), T8(..))


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , attendees : List AttendeeForm
    , count : TicketTypes NonNegative
    , billingEmail : String
    , grantContribution : String
    }


init : PurchaseForm
init =
    { submitStatus = NotSubmitted NotPressedSubmit
    , attendees = []
    , count = initTicketCount
    , billingEmail = ""
    , grantContribution = "0"
    }


type alias PurchaseFormValidated =
    { attendees : List AttendeeFormValidated
    , count : TicketTypes NonNegative
    , billingEmail : EmailAddress
    , grantContribution : Quantity Float StripeCurrency
    }


type alias TicketTypes a =
    { campfireTicket : a
    , singleRoomTicket : a
    , sharedRoomTicket : a
    }


initTicketCount : TicketTypes NonNegative
initTicketCount =
    { campfireTicket = NonNegative.zero
    , singleRoomTicket = NonNegative.zero
    , sharedRoomTicket = NonNegative.zero
    }


type alias AttendeeForm =
    { name : String
    , country : String
    , originCity : String
    }


defaultAttendee : AttendeeForm
defaultAttendee =
    { name = ""
    , country = ""
    , originCity = ""
    }


type alias AttendeeFormValidated =
    { name : Name
    , country : NonemptyString
    , originCity : NonemptyString
    }


type SubmitStatus
    = NotSubmitted PressedSubmit
    | Submitting
    | SubmitBackendError String


type PressedSubmit
    = PressedSubmit
    | NotPressedSubmit


validateGrantContribution : String -> Result String (Quantity Int LocalCurrency)
validateGrantContribution s =
    if s == "" then
        Ok Quantity.zero

    else
        case String.toInt s of
            Nothing ->
                Err "Invalid number"

            Just x ->
                if x < 0 then
                    Err "Can't be negative"

                else
                    Quantity.unsafe (x * 100) |> Ok


unvalidateGrantContribution : Quantity Int LocalCurrency -> String
unvalidateGrantContribution value =
    Quantity.unwrap value // 100 |> String.fromInt


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


validateAttendees : List AttendeeForm -> Result String (List AttendeeFormValidated)
validateAttendees attendees =
    let
        attendeesValidated : List AttendeeFormValidated
        attendeesValidated =
            List.filterMap validateAttendee attendees
    in
    if List.length attendeesValidated == List.length attendees then
        Ok attendeesValidated

    else
        Err "Invalid attendees"


unvalidateAttendee : AttendeeFormValidated -> AttendeeForm
unvalidateAttendee attendee =
    { name = Name.toString attendee.name
    , country = String.Nonempty.toString attendee.country
    , originCity = String.Nonempty.toString attendee.originCity
    }


validateForm : Quantity Float (Rate StripeCurrency LocalCurrency) -> PurchaseForm -> Maybe PurchaseFormValidated
validateForm conversionRate form =
    case
        T3
            (validateEmailAddress form.billingEmail)
            (validateGrantContribution form.grantContribution)
            (validateAttendees form.attendees)
    of
        T3 (Ok billingEmail) (Ok grantContribution) (Ok attendeesOk) ->
            { attendees = attendeesOk
            , count = form.count
            , billingEmail = billingEmail
            , grantContribution = Quantity.at conversionRate (Quantity.toFloatQuantity grantContribution)
            }
                |> Just

        _ ->
            Nothing


validateAttendee : AttendeeForm -> Maybe AttendeeFormValidated
validateAttendee form =
    let
        name =
            validateName form.name

        country =
            String.Nonempty.fromString form.country

        originCity =
            String.Nonempty.fromString form.originCity
    in
    case T3 name country originCity of
        T3 (Ok nameOk) (Just countryOk) (Just originCityOk) ->
            Just
                { name = nameOk
                , country = countryOk
                , originCity = originCityOk
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
