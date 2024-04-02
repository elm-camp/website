module Evergreen.V67.Route exposing (..)

import Evergreen.V67.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V67.EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | LiveScheduleRoute
    | Camp23Denmark SubPage
