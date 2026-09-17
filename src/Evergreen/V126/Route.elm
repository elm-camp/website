module Evergreen.V126.Route exposing (..)

import Evergreen.V126.EmailAddress


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | CodeOfConductRoute
    | ElmCampArchiveRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe Evergreen.V126.EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | Camp23Dk
    | Camp24Uk
    | Camp25Us
    | Camp26Cz
    | TravelRoute
    | TicketPurchaseRoute
    | OpportunityGrantRoute
    | NotFound
