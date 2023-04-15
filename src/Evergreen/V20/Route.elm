module Evergreen.V20.Route exposing (..)

import Evergreen.V20.EmailAddress


type Route
    = HomepageRoute
    | AccessibilityRoute
    | CodeOfConductRoute
    | PaymentSuccessRoute (Maybe Evergreen.V20.EmailAddress.EmailAddress)
    | PaymentCancelRoute
