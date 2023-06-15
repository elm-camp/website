module Evergreen.V48.Route exposing (..)

import Evergreen.V48.EmailAddress


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | VenueAndAccessRoute
    | CodeOfConductRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V48.EmailAddress.EmailAddress)
    | PaymentCancelRoute
