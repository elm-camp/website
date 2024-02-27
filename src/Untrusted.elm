module Untrusted exposing
    ( Untrusted(..)
    , emailAddress
    , name
    , purchaseForm
    , untrust
    )

import EmailAddress exposing (EmailAddress)
import Helpers
import Name exposing (Name)
import PurchaseForm exposing (..)
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
purchaseForm (Untrusted a) =
    case
        T2 (untrust a.billingEmail |> emailAddress)
            (a.attendees
                |> List.map (untrust >> attendeeForm)
                |> validateList
            )
    of
        T2 (Just billingEmail) (Ok attendees) ->
            Just
                { attendees = attendees
                , accommodationBookings = a.accommodationBookings
                , billingEmail = billingEmail
                , grantContribution = a.grantContribution
                , sponsorship = a.sponsorship
                }

        _ ->
            Nothing


validateList validated =
    if validated |> List.all Helpers.isJust then
        validated |> Helpers.justs |> Ok

    else
        Err "Invalid attendees"


attendeeForm : Untrusted AttendeeFormValidated -> Maybe AttendeeFormValidated
attendeeForm (Untrusted a) =
    case T2 (untrust a.name |> name) (untrust a.email |> emailAddress) of
        T2 (Just name_) (Just email) ->
            Just
                { name = name_
                , email = email
                , country = a.country
                , originCity = a.originCity
                , primaryModeOfTravel = a.primaryModeOfTravel
                }

        _ ->
            Nothing



-- case a of
--     CampfireTicketPurchase b ->
--         case T2 (untrust b.attendeeName |> name) (untrust b.billingEmail |> emailAddress) of
--             T2 (Just attendeeName) (Just billingEmail) ->
--                 { attendeeName = attendeeName
--                 , billingEmail = billingEmail
--                 , country = b.country
--                 , originCity = b.originCity
--                 , primaryModeOfTravel = b.primaryModeOfTravel
--                 , grantContribution = b.grantContribution
--                 , sponsorship = b.sponsorship
--                 }
--                     |> CampfireTicketPurchase
--                     |> Just
--             _ ->
--                 Nothing
--     CampTicketPurchase b ->
--         case T2 (untrust b.attendeeName |> name) (untrust b.billingEmail |> emailAddress) of
--             T2 (Just attendeeName) (Just billingEmail) ->
--                 { attendeeName = attendeeName
--                 , billingEmail = billingEmail
--                 , country = b.country
--                 , originCity = b.originCity
--                 , primaryModeOfTravel = b.primaryModeOfTravel
--                 , grantContribution = b.grantContribution
--                 , sponsorship = b.sponsorship
--                 }
--                     |> CampTicketPurchase
--                     |> Just
--             _ ->
--                 Nothing
--     CouplesCampTicketPurchase b ->
--         case T3 (untrust b.attendee1Name |> name) (untrust b.attendee2Name |> name) (untrust b.billingEmail |> emailAddress) of
--             T3 (Just attendee1Name) (Just attendee2Name) (Just billingEmail) ->
--                 { attendee1Name = attendee1Name
--                 , attendee2Name = attendee2Name
--                 , billingEmail = billingEmail
--                 , country = b.country
--                 , originCity = b.originCity
--                 , primaryModeOfTravel = b.primaryModeOfTravel
--                 , grantContribution = b.grantContribution
--                 , sponsorship = b.sponsorship
--                 }
--                     |> CouplesCampTicketPurchase
--                     |> Just
--             _ ->
--                 Nothing


untrust : a -> Untrusted a
untrust =
    Untrusted
