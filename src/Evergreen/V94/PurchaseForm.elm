module Evergreen.V94.PurchaseForm exposing (..)

import Evergreen.V94.EmailAddress
import Evergreen.V94.Name
import Evergreen.V94.TravelMode
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
    , primaryModeOfTravel : Maybe Evergreen.V94.TravelMode.TravelMode
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
    { name : Evergreen.V94.Name.Name
    , email : Evergreen.V94.EmailAddress.EmailAddress
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    , primaryModeOfTravel : Maybe Evergreen.V94.TravelMode.TravelMode
    }


type alias PurchaseFormValidated =
    { attendees : List AttendeeFormValidated
    , accommodationBookings : List Accommodation
    , billingEmail : Evergreen.V94.EmailAddress.EmailAddress
    , grantContribution : Int
    , grantApply : Bool
    , sponsorship : Maybe String
    }
