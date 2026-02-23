module Evergreen.V112.Route exposing (..)

import Evergreen.V112.EmailAddress


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | CodeOfConductRoute
    | ElmCampArchiveRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V112.EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | Camp23Denmark
    | Camp24Uk
    | Camp25US
    | TicketPurchaseRoute
