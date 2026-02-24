module Fusion.Generated.TypeDict.Types exposing
    ( typeDict, type_BackendModel, type_CompletedOrder, type_EmailResult, type_GrantApplication, type_PendingOrder
    , type_TicketPriceStatus, type_TicketsDisabledData, type_TicketsEnabled
    )

{-|

@docs typeDict, type_BackendModel, type_CompletedOrder, type_EmailResult, type_GrantApplication, type_PendingOrder
@docs type_TicketPriceStatus, type_TicketsDisabledData, type_TicketsEnabled

-}

import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List a )
typeDict =
    Dict.fromList
        [ ( "GrantApplication", ( type_GrantApplication, [] ) )
        , ( "TicketsDisabledData", ( type_TicketsDisabledData, [] ) )
        , ( "TicketsEnabled", ( type_TicketsEnabled, [] ) )
        , ( "TicketPriceStatus", ( type_TicketPriceStatus, [] ) )
        , ( "PendingOrder", ( type_PendingOrder, [] ) )
        , ( "EmailResult", ( type_EmailResult, [] ) )
        , ( "CompletedOrder", ( type_CompletedOrder, [] ) )
        , ( "BackendModel", ( type_BackendModel, [] ) )
        ]


type_BackendModel : Fusion.Type
type_BackendModel =
    Fusion.TRecord
        [ ( "orders"
          , Fusion.TNamed
                [ "SeqDict" ]
                "SeqDict"
                [ Fusion.TNamed
                    [ "Id" ]
                    "Id"
                    [ Fusion.TNamed [ "Stripe" ] "StripeSessionId" [] Nothing ]
                    Nothing
                , Fusion.TNamed [ "Types" ] "CompletedOrder" [] Nothing
                ]
                Nothing
          )
        , ( "pendingOrders"
          , Fusion.TNamed
                [ "SeqDict" ]
                "SeqDict"
                [ Fusion.TNamed
                    [ "Id" ]
                    "Id"
                    [ Fusion.TNamed [ "Stripe" ] "StripeSessionId" [] Nothing ]
                    Nothing
                , Fusion.TNamed [ "Types" ] "PendingOrder" [] Nothing
                ]
                Nothing
          )
        , ( "expiredOrders"
          , Fusion.TNamed
                [ "SeqDict" ]
                "SeqDict"
                [ Fusion.TNamed
                    [ "Id" ]
                    "Id"
                    [ Fusion.TNamed [ "Stripe" ] "StripeSessionId" [] Nothing ]
                    Nothing
                , Fusion.TNamed [ "Types" ] "PendingOrder" [] Nothing
                ]
                Nothing
          )
        , ( "prices", Fusion.TNamed [ "Types" ] "TicketPriceStatus" [] Nothing )
        , ( "time", Fusion.TNamed [ "Effect", "Time" ] "Posix" [] Nothing )
        , ( "ticketsEnabled"
          , Fusion.TNamed [ "Types" ] "TicketsEnabled" [] Nothing
          )
        , ( "grantApplications"
          , Fusion.TNamed
                [ "List" ]
                "List"
                [ Fusion.TNamed [ "Types" ] "GrantApplication" [] Nothing ]
                (Just
                    (Fusion.TList
                        (Fusion.TNamed
                            [ "Types" ]
                            "GrantApplication"
                            []
                            Nothing
                        )
                    )
                )
          )
        ]


type_CompletedOrder : Fusion.Type
type_CompletedOrder =
    Fusion.TRecord
        [ ( "submitTime"
          , Fusion.TNamed [ "Effect", "Time" ] "Posix" [] Nothing
          )
        , ( "form"
          , Fusion.TNamed [ "PurchaseForm" ] "PurchaseFormValidated" [] Nothing
          )
        , ( "emailResult", Fusion.TNamed [ "Types" ] "EmailResult" [] Nothing )
        , ( "paymentId"
          , Fusion.TNamed
                [ "Id" ]
                "Id"
                [ Fusion.TNamed [ "Stripe" ] "StripePaymentId" [] Nothing ]
                Nothing
          )
        ]


type_EmailResult : Fusion.Type
type_EmailResult =
    Fusion.TCustom
        "EmailResult"
        []
        [ ( "SendingEmail", [] )
        , ( "EmailSuccess", [] )
        , ( "EmailFailed"
          , [ Fusion.TNamed [ "Postmark" ] "SendEmailError" [] Nothing ]
          )
        ]


type_GrantApplication : Fusion.Type
type_GrantApplication =
    Fusion.TRecord
        [ ( "email"
          , Fusion.TNamed [ "EmailAddress" ] "EmailAddress" [] Nothing
          )
        , ( "message"
          , Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString)
          )
        ]


type_PendingOrder : Fusion.Type
type_PendingOrder =
    Fusion.TRecord
        [ ( "submitTime"
          , Fusion.TNamed [ "Effect", "Time" ] "Posix" [] Nothing
          )
        , ( "form"
          , Fusion.TNamed [ "PurchaseForm" ] "PurchaseFormValidated" [] Nothing
          )
        , ( "sessionId"
          , Fusion.TNamed [ "Effect", "Lamdera" ] "SessionId" [] Nothing
          )
        ]


type_TicketPriceStatus : Fusion.Type
type_TicketPriceStatus =
    Fusion.TCustom
        "TicketPriceStatus"
        []
        [ ( "NotLoadingTicketPrices", [] )
        , ( "LoadingTicketPrices", [] )
        , ( "LoadedTicketPrices"
          , [ Fusion.TNamed [ "Money" ] "Currency" [] Nothing
            , Fusion.TNamed
                [ "PurchaseForm" ]
                "TicketTypes"
                [ Fusion.TNamed [ "Stripe" ] "Price" [] Nothing ]
                Nothing
            ]
          )
        , ( "FailedToLoadTicketPrices"
          , [ Fusion.TNamed [ "Effect", "Http" ] "Error" [] Nothing ]
          )
        , ( "TicketCurrenciesDoNotMatch", [] )
        ]


type_TicketsDisabledData : Fusion.Type
type_TicketsDisabledData =
    Fusion.TRecord
        [ ( "adminMessage"
          , Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString)
          )
        ]


type_TicketsEnabled : Fusion.Type
type_TicketsEnabled =
    Fusion.TCustom
        "TicketsEnabled"
        []
        [ ( "TicketsEnabled", [] )
        , ( "TicketsDisabled"
          , [ Fusion.TNamed [ "Types" ] "TicketsDisabledData" [] Nothing ]
          )
        ]
