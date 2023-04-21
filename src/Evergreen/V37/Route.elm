module Evergreen.V37.Route exposing (..)

import Evergreen.V37.EmailAddress


type Route
    = HomepageRoute
    | AccessibilityRoute
    | CodeOfConductRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V37.EmailAddress.EmailAddress)
    | PaymentCancelRoute
