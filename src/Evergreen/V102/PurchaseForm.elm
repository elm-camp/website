module Evergreen.V102.PurchaseForm exposing (..)

import EmailAddress
import Evergreen.V102.Name
import Evergreen.V102.TravelMode
import String.Nonempty


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
    , primaryModeOfTravel : Maybe Evergreen.V102.TravelMode.TravelMode
    }


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


type alias AttendeeFormValidated =
    { name : Evergreen.V102.Name.Name
    , email : EmailAddress.EmailAddress
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    , primaryModeOfTravel : Maybe Evergreen.V102.TravelMode.TravelMode
    }


type alias PurchaseFormValidated =
    { attendees : List AttendeeFormValidated
    , accommodationBookings : List Accommodation
    , billingEmail : EmailAddress.EmailAddress
    , grantContribution : Int
    , grantApply : Bool
    , sponsorship : Maybe String
    }
