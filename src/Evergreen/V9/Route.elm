module Evergreen.V9.Route exposing (..)

import Evergreen.V9.EmailAddress


type Route
    = HomepageRoute
    | AccessibilityRoute
    | CodeOfConductRoute
    | PaymentSuccessRoute (Maybe Evergreen.V9.EmailAddress.EmailAddress)
    | PaymentCancelRoute
