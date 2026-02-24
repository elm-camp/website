module Evergreen.V114.Route exposing (..)

import Evergreen.V114.EmailAddress


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | CodeOfConductRoute
    | ElmCampArchiveRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V114.EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | Camp23Denmark
    | Camp24Uk
    | Camp25US
    | TicketPurchaseRoute
    | OpportunityGrantRoute
