module Evergreen.V104.Route exposing (..)

import EmailAddress


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | CodeOfConductRoute
    | ElmCampArchiveRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | Camp23Denmark
    | Camp24Uk
    | Camp25US
