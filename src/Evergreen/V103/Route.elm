module Evergreen.V103.Route exposing (..)

import EmailAddress


type SubPage
    = Home
    | Artifacts


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | VenueAndAccessRoute
    | CodeOfConductRoute
    | OrganisersRoute
    | ElmCampArchiveRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe EmailAddress.EmailAddress)
    | PaymentCancelRoute
    | Camp23Denmark SubPage
    | Camp24Uk SubPage
    | Camp25US SubPage
    | Camp26Czech SubPage
