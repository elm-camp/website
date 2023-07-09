module Evergreen.V56.Route exposing (..)

import Evergreen.V56.EmailAddress


type SubPage
    = Home
    | Artifacts


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | VenueAndAccessRoute
    | CodeOfConductRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V56.EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | LiveScheduleRoute
    | Camp23Denmark SubPage
