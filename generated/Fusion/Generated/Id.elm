module Fusion.Generated.Id exposing (build_Id, patch_Id, patcher_Id, toValue_Id)

{-|

@docs build_Id, patch_Id, patcher_Id, toValue_Id

-}

import Fusion
import Fusion.Patch
import Id


build_Id :
    Fusion.Patch.Patcher a
    -> Fusion.Value
    -> Result Fusion.Patch.Error (Id.Id a)
build_Id aPatcher value =
    Fusion.Patch.build_Custom
        (\name params ->
            case ( name, params ) of
                ( "Id", [ patch0 ] ) ->
                    Result.map Id.Id (Fusion.Patch.build_String patch0)

                _ ->
                    Result.Err
                        (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


patch_Id :
    b
    -> { force : Bool }
    -> Fusion.Patch.Patch
    -> Id.Id a
    -> Result Fusion.Patch.Error (Id.Id a)
patch_Id aPatcher options patch value =
    case ( value, patch, options.force ) of
        ( Id.Id arg0, Fusion.Patch.PCustomSame "Id" [ patch0 ], _ ) ->
            Result.map
                Id.Id
                (Fusion.Patch.maybeApply
                    Fusion.Patch.patcher_String
                    options
                    patch0
                    arg0
                )

        ( _, Fusion.Patch.PCustomSame "Id" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patcher_Id : Fusion.Patch.Patcher a -> Fusion.Patch.Patcher (Id.Id a)
patcher_Id aPatcher =
    { patch = patch_Id aPatcher
    , build = build_Id aPatcher
    , toValue = toValue_Id aPatcher
    }


toValue_Id : b -> Id.Id a -> Fusion.Value
toValue_Id aPatcher value =
    case value of
        Id.Id arg0 ->
            Fusion.VCustom "Id" [ Fusion.VString arg0 ]
