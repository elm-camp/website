module Evergreen.V6.Route exposing (..)

import Evergreen.V6.EmailAddress


type Route
    = HomepageRoute
    | AccessibilityRoute
    | CodeOfConductRoute
    | PaymentSuccessRoute (Maybe Evergreen.V6.EmailAddress.EmailAddress)
    | PaymentCancelRoute
