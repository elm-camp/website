module Evergreen.V6.PurchaseForm exposing (..)

import Evergreen.V6.EmailAddress
import Evergreen.V6.Name
import Evergreen.V6.TravelMode
import String.Nonempty


type PressedSubmit
    = PressedSubmit
    | NotPressedSubmit


type SubmitStatus
    = NotSubmitted PressedSubmit
    | Submitting
    | SubmitBackendError


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , attendee1Name : String
    , attendee2Name : String
    , billingEmail : String
    , country : String
    , originCity : String
    , primaryModeOfTravel : Maybe Evergreen.V6.TravelMode.TravelMode
    }


type alias SinglePurchaseData =
    { attendeeName : Evergreen.V6.Name.Name
    , billingEmail : Evergreen.V6.EmailAddress.EmailAddress
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    , primaryModeOfTravel : Evergreen.V6.TravelMode.TravelMode
    }


type alias CouplePurchaseData =
    { attendee1Name : Evergreen.V6.Name.Name
    , attendee2Name : Evergreen.V6.Name.Name
    , billingEmail : Evergreen.V6.EmailAddress.EmailAddress
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    , primaryModeOfTravel : Evergreen.V6.TravelMode.TravelMode
    }


type PurchaseFormValidated
    = SinglePurchase SinglePurchaseData
    | CouplePurchase CouplePurchaseData
