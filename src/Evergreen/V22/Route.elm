module Evergreen.V22.Route exposing (..)

import Evergreen.V22.EmailAddress


type Route
    = HomepageRoute
    | AccessibilityRoute
    | CodeOfConductRoute
    | PaymentSuccessRoute (Maybe Evergreen.V22.EmailAddress.EmailAddress)
    | PaymentCancelRoute
