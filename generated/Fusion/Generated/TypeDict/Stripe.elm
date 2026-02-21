module Fusion.Generated.TypeDict.Stripe exposing ( typeDict, type_Price, type_PriceId, type_StripeSessionId )

{-|
@docs typeDict, type_Price, type_PriceId, type_StripeSessionId
-}


import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List a )
typeDict =
    Dict.fromList
        [ ( "PriceId", ( type_PriceId, [] ) )
        , ( "Price", ( type_Price, [] ) )
        , ( "StripeSessionId", ( type_StripeSessionId, [] ) )
        ]


type_Price : Fusion.Type
type_Price =
    Fusion.TRecord
        [ ( "priceId"
          , Fusion.TNamed
                [ "Id" ]
                "Id"
                [ Fusion.TNamed [ "Stripe" ] "PriceId" [] Nothing ]
                Nothing
          )
        , ( "amount"
          , Fusion.TNamed
                [ "Quantity" ]
                "Quantity"
                [ Fusion.TNamed [ "Basics" ] "Int" [] (Just Fusion.TInt)
                , Fusion.TNamed [ "Stripe" ] "StripeCurrency" [] Nothing
                ]
                Nothing
          )
        ]


type_PriceId : Fusion.Type
type_PriceId =
    Fusion.TCustom
        "PriceId"
        []
        [ ( "PriceId"
          , [ Fusion.TNamed [ "Basics" ] "Never" [] (Just Fusion.TNever) ]
          )
        ]


type_StripeSessionId : Fusion.Type
type_StripeSessionId =
    Fusion.TCustom
        "StripeSessionId"
        []
        [ ( "StripeSessionId"
          , [ Fusion.TNamed [ "Basics" ] "Never" [] (Just Fusion.TNever) ]
          )
        ]