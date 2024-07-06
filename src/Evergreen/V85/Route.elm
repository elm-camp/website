module Evergreen.V85.Route exposing (..)

import Evergreen.V85.EmailAddress


type SubPage
    = Home
    | Artifacts


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | VenueAndAccessRoute
    | CodeOfConductRoute
    | OrganisersRoute
    | ElmCampArchiveRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V85.EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | LiveScheduleRoute
    | Camp23Denmark SubPage
    | Camp24Uk SubPage
