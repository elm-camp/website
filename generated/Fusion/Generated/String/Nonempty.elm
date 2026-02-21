module Fusion.Generated.String.Nonempty exposing
    ( build_NonemptyString, patch_NonemptyString, patcher_NonemptyString, query_NonemptyString, toValue_NonemptyString
    )

{-|
@docs build_NonemptyString, patch_NonemptyString, patcher_NonemptyString, query_NonemptyString, toValue_NonemptyString
-}


import Fusion
import Fusion.Patch
import String.Nonempty


build_NonemptyString :
    Fusion.Value -> Result Fusion.Patch.Error String.Nonempty.NonemptyString
build_NonemptyString value =
    Fusion.Patch.build_Custom
        (\name params ->
             case ( name, params ) of
                 ( "NonemptyString", [ patch0, patch1 ] ) ->
                     Result.map2
                         String.Nonempty.NonemptyString
                         (Fusion.Patch.build_Char patch0)
                         (Fusion.Patch.build_String patch1)

                 _ ->
                     Result.Err
                         (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


patch_NonemptyString :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> String.Nonempty.NonemptyString
    -> Result Fusion.Patch.Error String.Nonempty.NonemptyString
patch_NonemptyString options patch value =
    case ( value, patch, options.force ) of
        ( String.Nonempty.NonemptyString arg0 arg1, Fusion.Patch.PCustomSame "NonemptyString" [ patch0, patch1 ], _ ) ->
            Result.map2
                String.Nonempty.NonemptyString
                (Fusion.Patch.maybeApply
                     Fusion.Patch.patcher_Char
                     options
                     patch0
                     arg0
                )
                (Fusion.Patch.maybeApply
                     Fusion.Patch.patcher_String
                     options
                     patch1
                     arg1
                )

        ( _, Fusion.Patch.PCustomSame "NonemptyString" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patcher_NonemptyString : Fusion.Patch.Patcher String.Nonempty.NonemptyString
patcher_NonemptyString =
    { patch = patch_NonemptyString
    , build = build_NonemptyString
    , toValue = toValue_NonemptyString
    }


query_NonemptyString :
    Fusion.Query -> String.Nonempty.NonemptyString -> Fusion.Value
query_NonemptyString query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (case value of
                     String.Nonempty.NonemptyString arg0 arg1 ->
                         Fusion.VCustom
                             "NonemptyString"
                             [ Fusion.VChar arg0
                             , Fusion.Patch.query_String query arg1
                             ]
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery

        Fusion.QIndexed fusionValue fusionQuery ->
            Debug.todo "custom - qIndexed"


toValue_NonemptyString : String.Nonempty.NonemptyString -> Fusion.Value
toValue_NonemptyString value =
    case value of
        String.Nonempty.NonemptyString arg0 arg1 ->
            Fusion.VCustom
                "NonemptyString"
                [ Fusion.VChar arg0, Fusion.VString arg1 ]