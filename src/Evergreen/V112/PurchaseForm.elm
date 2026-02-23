module Evergreen.V112.PurchaseForm exposing (..)

import Evergreen.V112.EmailAddress
import Evergreen.V112.Name
import Evergreen.V112.NonNegative
import Evergreen.V112.Stripe
import Quantity
import String.Nonempty


type alias TicketTypes a =
    { campfireTicket : a
    , singleRoomTicket : a
    , sharedRoomTicket : a
    }


type PressedSubmit
    = PressedSubmit
    | NotPressedSubmit


type SubmitStatus
    = NotSubmitted PressedSubmit
    | Submitting
    | SubmitBackendError String


type alias AttendeeForm =
    { name : String
    , country : String
    , originCity : String
    }


type alias PurchaseForm =
    { submitStatus : SubmitStatus
    , attendees : List AttendeeForm
    , count : TicketTypes Evergreen.V112.NonNegative.NonNegative
    , billingEmail : String
    , grantContribution : String
    }


type alias AttendeeFormValidated =
    { name : Evergreen.V112.Name.Name
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    }


type alias PurchaseFormValidated =
    { attendees : List AttendeeFormValidated
    , count : TicketTypes Evergreen.V112.NonNegative.NonNegative
    , billingEmail : Evergreen.V112.EmailAddress.EmailAddress
    , grantContribution : Quantity.Quantity Float Evergreen.V112.Stripe.StripeCurrency
    }
