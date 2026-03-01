module Evergreen.V117.PurchaseForm exposing (..)

import Evergreen.V117.EmailAddress
import Evergreen.V117.Name
import Evergreen.V117.NonNegative
import Evergreen.V117.Stripe
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
    , count : TicketTypes Evergreen.V117.NonNegative.NonNegative
    , billingEmail : String
    , grantContribution : String
    }


type alias AttendeeFormValidated =
    { name : Evergreen.V117.Name.Name
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    }


type alias PurchaseFormValidated =
    { attendees : List AttendeeFormValidated
    , count : TicketTypes Evergreen.V117.NonNegative.NonNegative
    , billingEmail : Evergreen.V117.EmailAddress.EmailAddress
    , grantContribution : Quantity.Quantity Float Evergreen.V117.Stripe.StripeCurrency
    }
