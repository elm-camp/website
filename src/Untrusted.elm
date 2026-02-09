module Untrusted exposing
    ( Untrusted(..)
    , emailAddress
    , name
    , purchaseForm
    , untrust
    )

import EmailAddress exposing (EmailAddress)
import Helpers
import List.Nonempty
import Name exposing (Name)
import PurchaseForm exposing (AttendeeFormValidated, PurchaseFormValidated)
import Quantity
import Toop exposing (T2(..), T3(..))


{-| We can't be sure a value we got from the frontend hasn't been tampered with.
In cases where an opaque type uses code to give some kind of guarantee (for example
MaxAttendees makes sure the max number of attendees is at least 2) we wrap the value in Unstrusted to
make sure we don't forget to validate the value again on the backend.
-}
type Untrusted a
    = Untrusted a


name : Untrusted Name -> Maybe Name
name (Untrusted a) =
    Name.toString a |> Name.fromString |> Result.toMaybe


emailAddress : Untrusted EmailAddress -> Maybe EmailAddress
emailAddress (Untrusted a) =
    EmailAddress.toString a |> EmailAddress.fromString


purchaseForm : Untrusted PurchaseFormValidated -> Maybe PurchaseFormValidated
purchaseForm (Untrusted form) =
    case
        T3
            (PurchaseForm.validateEmailAddress (EmailAddress.toString form.billingEmail))
            (Quantity.greaterThanZero form.grantContribution)
            (PurchaseForm.validateAttendees form.count (List.map PurchaseForm.unvalidateAttendee form.attendees))
    of
        T3 (Ok billingEmail) True (Ok attendeesOk) ->
            { attendees = attendeesOk
            , count = form.count
            , billingEmail = billingEmail
            , grantContribution = form.grantContribution
            }
                |> Just

        _ ->
            Nothing


untrust : a -> Untrusted a
untrust =
    Untrusted
