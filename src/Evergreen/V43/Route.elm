module Evergreen.V43.Route exposing (..)

import Evergreen.V43.EmailAddress


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | AccessibilityRoute
    | CodeOfConductRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V43.EmailAddress.EmailAddress)
    | PaymentCancelRoute
