module Fusion.Generated.Name exposing (build_Name, patch_Name, patcher_Name, toValue_Name)

{-|

@docs build_Name, patch_Name, patcher_Name, toValue_Name

-}

import Fusion
import Fusion.Patch
import Name


build_Name : Fusion.Value -> Result Fusion.Patch.Error Name.Name
build_Name value =
    Fusion.Patch.build_Custom
        (\name params ->
            case ( name, params ) of
                ( "Name", [ patch0 ] ) ->
                    Result.map Name.Name (Fusion.Patch.build_String patch0)

                _ ->
                    Result.Err
                        (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


patch_Name :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Name.Name
    -> Result Fusion.Patch.Error Name.Name
patch_Name options patch value =
    case ( value, patch, options.force ) of
        ( Name.Name arg0, Fusion.Patch.PCustomSame "Name" [ patch0 ], _ ) ->
            Result.map
                Name.Name
                (Fusion.Patch.maybeApply
                    Fusion.Patch.patcher_String
                    options
                    patch0
                    arg0
                )

        ( _, Fusion.Patch.PCustomSame "Name" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patcher_Name : Fusion.Patch.Patcher Name.Name
patcher_Name =
    { patch = patch_Name, build = build_Name, toValue = toValue_Name }


toValue_Name : Name.Name -> Fusion.Value
toValue_Name value =
    case value of
        Name.Name arg0 ->
            Fusion.VCustom "Name" [ Fusion.VString arg0 ]
