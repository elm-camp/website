module Evergreen.V3.Route exposing (..)

import Evergreen.V3.EmailAddress


type Route
    = HomepageRoute
    | AccessibilityRoute
    | CodeOfConductRoute
    | PaymentSuccessRoute (Maybe Evergreen.V3.EmailAddress.EmailAddress)
    | PaymentCancelRoute
