module Evergreen.V85.PurchaseForm exposing (..)

import Evergreen.V85.EmailAddress
import Evergreen.V85.Name
import Evergreen.V85.TravelMode
import String.Nonempty


type Accommodation
    = Offsite
    | Campsite
    | Single
    | Double
    | Group


type PressedSubmit
    = PressedSubmit
    | NotPressedSubmit


type SubmitStatus
    = NotSubmitted PressedSubmit
    | Submitting
    | SubmitBackendError String


type alias AttendeeForm =
    { name : String
    , email : String
    , country : String
    , originCity : String
    , primaryModeOfTravel : Maybe Evergreen.V85.TravelMode.TravelMode
    }


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , attendees : List AttendeeForm
    , accommodationBookings : List Accommodation
    , billingEmail : String
    , grantContribution : String
    , grantApply : Bool
    , sponsorship : Maybe String
    }


type alias AttendeeFormValidated =
    { name : Evergreen.V85.Name.Name
    , email : Evergreen.V85.EmailAddress.EmailAddress
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    , primaryModeOfTravel : Maybe Evergreen.V85.TravelMode.TravelMode
    }


type alias PurchaseFormValidated =
    { attendees : List AttendeeFormValidated
    , accommodationBookings : List Accommodation
    , billingEmail : Evergreen.V85.EmailAddress.EmailAddress
    , grantContribution : Int
    , grantApply : Bool
    , sponsorship : Maybe String
    }
