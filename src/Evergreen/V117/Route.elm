module Evergreen.V117.Route exposing (..)

import Evergreen.V117.EmailAddress


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | CodeOfConductRoute
    | ElmCampArchiveRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V117.EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | Camp23Denmark
    | Camp24Uk
    | Camp25US
    | TicketPurchaseRoute
    | OpportunityGrantRoute
