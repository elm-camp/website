module Evergreen.V122.Route exposing (..)

import Evergreen.V122.EmailAddress


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | CodeOfConductRoute
    | ElmCampArchiveRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V122.EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | Camp23Denmark
    | Camp24Uk
    | Camp25US
    | TravelRoute
    | TicketPurchaseRoute
    | OpportunityGrantRoute
