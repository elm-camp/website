module Evergreen.V114.PurchaseForm exposing (..)

import Evergreen.V114.EmailAddress
import Evergreen.V114.Name
import Evergreen.V114.NonNegative
import Evergreen.V114.Stripe
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
    , count : TicketTypes Evergreen.V114.NonNegative.NonNegative
    , billingEmail : String
    , grantContribution : String
    }


type alias AttendeeFormValidated =
    { name : Evergreen.V114.Name.Name
    , country : String.Nonempty.NonemptyString
    , originCity : String.Nonempty.NonemptyString
    }


type alias PurchaseFormValidated =
    { attendees : List AttendeeFormValidated
    , count : TicketTypes Evergreen.V114.NonNegative.NonNegative
    , billingEmail : Evergreen.V114.EmailAddress.EmailAddress
    , grantContribution : Quantity.Quantity Float Evergreen.V114.Stripe.StripeCurrency
    }
