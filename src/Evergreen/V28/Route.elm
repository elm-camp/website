module Evergreen.V28.Route exposing (..)

import Evergreen.V28.EmailAddress


type Route
    = HomepageRoute
    | AccessibilityRoute
    | CodeOfConductRoute
    | PaymentSuccessRoute (Maybe Evergreen.V28.EmailAddress.EmailAddress)
    | PaymentCancelRoute
