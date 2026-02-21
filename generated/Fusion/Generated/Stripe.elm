module Fusion.Generated.Stripe exposing
    ( build_Price, build_PriceId, build_StripeSessionId, patch_Price, patch_PriceId, patch_StripeSessionId
    , patcher_Price, patcher_PriceId, patcher_StripeSessionId, query_Price, query_PriceId, query_StripeSessionId, toValue_Price
    , toValue_PriceId, toValue_StripeSessionId
    )

{-|
@docs build_Price, build_PriceId, build_StripeSessionId, patch_Price, patch_PriceId, patch_StripeSessionId
@docs patcher_Price, patcher_PriceId, patcher_StripeSessionId, query_Price, query_PriceId, query_StripeSessionId
@docs toValue_Price, toValue_PriceId, toValue_StripeSessionId
-}


import Dict
import Fusion
import Fusion.Generated.Id
import Fusion.Generated.Quantity
import Fusion.Patch
import Fusion.Stripe
import Stripe


build_Price : Fusion.Value -> Result Fusion.Patch.Error Stripe.Price
build_Price value =
    Fusion.Patch.build_Record
        (\build_RecordUnpack ->
             Result.map2
                 (\priceId amount -> { priceId = priceId, amount = amount })
                 (Result.andThen
                      (Fusion.Generated.Id.build_Id patcher_PriceId)
                      (build_RecordUnpack "priceId")
                 )
                 (Result.andThen
                      (Fusion.Generated.Quantity.build_Quantity
                           Fusion.Patch.patcher_Int
                           Fusion.Stripe.patcher_StripeCurrency
                      )
                      (build_RecordUnpack "amount")
                 )
        )
        value


build_PriceId : Fusion.Value -> Result Fusion.Patch.Error Stripe.PriceId
build_PriceId value =
    Fusion.Patch.build_Custom
        (\name params ->
             case ( name, params ) of
                 ( "PriceId", [ patch0 ] ) ->
                     Result.map Stripe.PriceId (Fusion.Patch.build_Never patch0)

                 _ ->
                     Result.Err
                         (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


build_StripeSessionId :
    Fusion.Value -> Result Fusion.Patch.Error Stripe.StripeSessionId
build_StripeSessionId value =
    Fusion.Patch.build_Custom
        (\name params ->
             case ( name, params ) of
                 ( "StripeSessionId", [ patch0 ] ) ->
                     Result.map
                         Stripe.StripeSessionId
                         (Fusion.Patch.build_Never patch0)

                 _ ->
                     Result.Err
                         (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


patch_Price :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Stripe.Price
    -> Result Fusion.Patch.Error Stripe.Price
patch_Price options patch value =
    Fusion.Patch.patch_Record
        (\fieldName fieldPatch acc ->
             case fieldName of
                 "priceId" ->
                     Result.map
                         (\priceId -> { acc | priceId = priceId })
                         ((Fusion.Generated.Id.patch_Id patcher_PriceId)
                              options
                              fieldPatch
                              acc.priceId
                         )

                 "amount" ->
                     Result.map
                         (\amount -> { acc | amount = amount })
                         ((Fusion.Generated.Quantity.patch_Quantity
                               Fusion.Patch.patcher_Int
                               Fusion.Stripe.patcher_StripeCurrency
                          )
                              options
                              fieldPatch
                              acc.amount
                         )

                 _ ->
                     Result.Err (Fusion.Patch.UnexpectedField fieldName)
        )
        patch
        value


patch_PriceId :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Stripe.PriceId
    -> Result Fusion.Patch.Error Stripe.PriceId
patch_PriceId options patch value =
    case ( value, patch, options.force ) of
        ( Stripe.PriceId arg0, Fusion.Patch.PCustomSame "PriceId" [ patch0 ], _ ) ->
            Result.map
                Stripe.PriceId
                (Fusion.Patch.maybeApply
                     Fusion.Patch.patcher_Never
                     options
                     patch0
                     arg0
                )

        ( _, Fusion.Patch.PCustomSame "PriceId" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patch_StripeSessionId :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Stripe.StripeSessionId
    -> Result Fusion.Patch.Error Stripe.StripeSessionId
patch_StripeSessionId options patch value =
    case ( value, patch, options.force ) of
        ( Stripe.StripeSessionId arg0, Fusion.Patch.PCustomSame "StripeSessionId" [ patch0 ], _ ) ->
            Result.map
                Stripe.StripeSessionId
                (Fusion.Patch.maybeApply
                     Fusion.Patch.patcher_Never
                     options
                     patch0
                     arg0
                )

        ( _, Fusion.Patch.PCustomSame "StripeSessionId" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patcher_Price : Fusion.Patch.Patcher Stripe.Price
patcher_Price =
    { patch = patch_Price, build = build_Price, toValue = toValue_Price }


patcher_PriceId : Fusion.Patch.Patcher Stripe.PriceId
patcher_PriceId =
    { patch = patch_PriceId, build = build_PriceId, toValue = toValue_PriceId }


patcher_StripeSessionId : Fusion.Patch.Patcher Stripe.StripeSessionId
patcher_StripeSessionId =
    { patch = patch_StripeSessionId
    , build = build_StripeSessionId
    , toValue = toValue_StripeSessionId
    }


query_Price : Fusion.Query -> Stripe.Price -> Fusion.Value
query_Price query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (Fusion.VRecord
                     (Dict.fromList
                          [ ( "priceId"
                            , (Fusion.Generated.Id.query_Id patcher_PriceId)
                                  query
                                  value.priceId
                            )
                          , ( "amount"
                            , (Fusion.Generated.Quantity.query_Quantity
                                   Fusion.Patch.patcher_Int
                                   Fusion.Stripe.patcher_StripeCurrency
                              )
                                  query
                                  value.amount
                            )
                          ]
                     )
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Debug.todo "record - qRecord"

        Fusion.QIndexed fusionValue fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery


query_PriceId : Fusion.Query -> Stripe.PriceId -> Fusion.Value
query_PriceId query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (case value of
                     Stripe.PriceId arg0 ->
                         Fusion.VCustom "PriceId" [ Basics.never arg0 ]
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery

        Fusion.QIndexed fusionValue fusionQuery ->
            Debug.todo "custom - qIndexed"


query_StripeSessionId : Fusion.Query -> Stripe.StripeSessionId -> Fusion.Value
query_StripeSessionId query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (case value of
                     Stripe.StripeSessionId arg0 ->
                         Fusion.VCustom "StripeSessionId" [ Basics.never arg0 ]
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery

        Fusion.QIndexed fusionValue fusionQuery ->
            Debug.todo "custom - qIndexed"


toValue_Price : Stripe.Price -> Fusion.Value
toValue_Price value =
    Fusion.VRecord
        (Dict.fromList
             [ ( "priceId"
               , (Fusion.Generated.Id.toValue_Id patcher_PriceId) value.priceId
               )
             , ( "amount"
               , (Fusion.Generated.Quantity.toValue_Quantity
                      Fusion.Patch.patcher_Int
                      Fusion.Stripe.patcher_StripeCurrency
                 )
                     value.amount
               )
             ]
        )


toValue_PriceId : Stripe.PriceId -> Fusion.Value
toValue_PriceId value =
    case value of
        Stripe.PriceId arg0 ->
            Fusion.VCustom "PriceId" [ Basics.never arg0 ]


toValue_StripeSessionId : Stripe.StripeSessionId -> Fusion.Value
toValue_StripeSessionId value =
    case value of
        Stripe.StripeSessionId arg0 ->
            Fusion.VCustom "StripeSessionId" [ Basics.never arg0 ]