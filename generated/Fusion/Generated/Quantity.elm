module Fusion.Generated.Quantity exposing
    ( build_Quantity, patch_Quantity, patcher_Quantity, query_Quantity, toValue_Quantity
    )

{-|
@docs build_Quantity, patch_Quantity, patcher_Quantity, query_Quantity, toValue_Quantity
-}


import Fusion
import Fusion.Patch
import Quantity


build_Quantity :
    Fusion.Patch.Patcher number
    -> Fusion.Patch.Patcher units
    -> Fusion.Value
    -> Result Fusion.Patch.Error (Quantity.Quantity number units)
build_Quantity numberPatcher unitsPatcher value =
    Fusion.Patch.build_Custom
        (\name params ->
             case ( name, params ) of
                 ( "Quantity", [ patch0 ] ) ->
                     Result.map Quantity.Quantity (numberPatcher.build patch0)

                 _ ->
                     Result.Err
                         (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


patch_Quantity :
    Fusion.Patch.Patcher number
    -> Fusion.Patch.Patcher units
    -> { force : Bool }
    -> Fusion.Patch.Patch
    -> Quantity.Quantity number units
    -> Result Fusion.Patch.Error (Quantity.Quantity number units)
patch_Quantity numberPatcher unitsPatcher options patch value =
    case ( value, patch, options.force ) of
        ( Quantity.Quantity arg0, Fusion.Patch.PCustomSame "Quantity" [ patch0 ], _ ) ->
            Result.map
                Quantity.Quantity
                (Fusion.Patch.maybeApply numberPatcher options patch0 arg0)

        ( _, Fusion.Patch.PCustomSame "Quantity" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patcher_Quantity :
    Fusion.Patch.Patcher number
    -> Fusion.Patch.Patcher units
    -> Fusion.Patch.Patcher (Quantity.Quantity number units)
patcher_Quantity numberPatcher unitsPatcher =
    { patch = patch_Quantity numberPatcher unitsPatcher
    , build = build_Quantity numberPatcher unitsPatcher
    , toValue = toValue_Quantity numberPatcher unitsPatcher
    }


query_Quantity :
    Fusion.Patch.Patcher number
    -> Fusion.Patch.Patcher units
    -> Fusion.Query
    -> Quantity.Quantity number units
    -> Fusion.Value
query_Quantity numberPatcher unitsPatcher query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (case value of
                     Quantity.Quantity arg0 ->
                         Fusion.VCustom
                             "Quantity"
                             [ numberPatcher.query query arg0 ]
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery

        Fusion.QIndexed fusionValue fusionQuery ->
            Debug.todo "custom - qIndexed"


toValue_Quantity :
    Fusion.Patch.Patcher number
    -> Fusion.Patch.Patcher units
    -> Quantity.Quantity number units
    -> Fusion.Value
toValue_Quantity numberPatcher unitsPatcher value =
    case value of
        Quantity.Quantity arg0 ->
            Fusion.VCustom "Quantity" [ numberPatcher.toValue arg0 ]