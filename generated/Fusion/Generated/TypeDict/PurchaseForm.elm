module Fusion.Generated.TypeDict.PurchaseForm exposing (typeDict, type_AttendeeFormValidated, type_PurchaseFormValidated, type_TicketTypes)

{-|

@docs typeDict, type_AttendeeFormValidated, type_PurchaseFormValidated, type_TicketTypes

-}

import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List String )
typeDict =
    Dict.fromList
        [ ( "TicketTypes", ( type_TicketTypes, [ "a" ] ) )
        , ( "AttendeeFormValidated", ( type_AttendeeFormValidated, [] ) )
        , ( "PurchaseFormValidated", ( type_PurchaseFormValidated, [] ) )
        ]


type_AttendeeFormValidated : Fusion.Type
type_AttendeeFormValidated =
    Fusion.TRecord
        [ ( "name", Fusion.TNamed [ "Name" ] "Name" [] Nothing )
        , ( "country"
          , Fusion.TNamed [ "String", "Nonempty" ] "NonemptyString" [] Nothing
          )
        , ( "originCity"
          , Fusion.TNamed [ "String", "Nonempty" ] "NonemptyString" [] Nothing
          )
        ]


type_PurchaseFormValidated : Fusion.Type
type_PurchaseFormValidated =
    Fusion.TRecord
        [ ( "attendees"
          , Fusion.TNamed
                [ "List" ]
                "List"
                [ Fusion.TNamed
                    [ "PurchaseForm" ]
                    "AttendeeFormValidated"
                    []
                    Nothing
                ]
                (Just
                    (Fusion.TList
                        (Fusion.TNamed
                            [ "PurchaseForm" ]
                            "AttendeeFormValidated"
                            []
                            Nothing
                        )
                    )
                )
          )
        , ( "count"
          , Fusion.TNamed
                [ "PurchaseForm" ]
                "TicketTypes"
                [ Fusion.TNamed [ "NonNegative" ] "NonNegative" [] Nothing ]
                Nothing
          )
        , ( "billingEmail"
          , Fusion.TNamed [ "EmailAddress" ] "EmailAddress" [] Nothing
          )
        , ( "grantContribution"
          , Fusion.TNamed
                [ "Quantity" ]
                "Quantity"
                [ Fusion.TNamed [ "Basics" ] "Float" [] (Just Fusion.TFloat)
                , Fusion.TNamed [ "Stripe" ] "StripeCurrency" [] Nothing
                ]
                Nothing
          )
        ]


type_TicketTypes : Fusion.Type
type_TicketTypes =
    Fusion.TRecord
        [ ( "campfireTicket", Fusion.TVar "a" )
        , ( "singleRoomTicket", Fusion.TVar "a" )
        , ( "sharedRoomTicket", Fusion.TVar "a" )
        ]
