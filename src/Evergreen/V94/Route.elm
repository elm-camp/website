module Evergreen.V94.Route exposing (..)

import Evergreen.V94.EmailAddress


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
    | PaymentSuccessRoute (Maybe Evergreen.V94.EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | LiveScheduleRoute
    | Camp23Denmark SubPage
    | Camp24Uk SubPage
    | Camp25US SubPage
