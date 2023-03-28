module Evergreen.V3.PurchaseForm exposing (..)

import Evergreen.V3.EmailAddress
import Evergreen.V3.Name
import Evergreen.V3.TravelMode
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
    , primaryModeOfTravel : Maybe Evergreen.V3.TravelMode.TravelMode
    }


type alias SinglePurchaseData =
    { attendeeName : Evergreen.V3.Name.Name
    , billingEmail : Evergreen.V3.EmailAddress.EmailAddress
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    , primaryModeOfTravel : Evergreen.V3.TravelMode.TravelMode
    }


type alias CouplePurchaseData =
    { attendee1Name : Evergreen.V3.Name.Name
    , attendee2Name : Evergreen.V3.Name.Name
    , billingEmail : Evergreen.V3.EmailAddress.EmailAddress
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    , primaryModeOfTravel : Evergreen.V3.TravelMode.TravelMode
    }


type PurchaseFormValidated
    = SinglePurchase SinglePurchaseData
    | CouplePurchase CouplePurchaseData
