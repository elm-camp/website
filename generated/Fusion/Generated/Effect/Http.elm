module Fusion.Generated.Effect.Http exposing
    ( build_Error, patch_Error, patcher_Error, query_Error, toValue_Error
    )

{-|
@docs build_Error, patch_Error, patcher_Error, query_Error, toValue_Error
-}


import Effect.Http
import Fusion
import Fusion.Patch


build_Error : Fusion.Value -> Result Fusion.Patch.Error Effect.Http.Error
build_Error value =
    Fusion.Patch.build_Custom
        (\name params ->
             case ( name, params ) of
                 ( "BadUrl", [ patch0 ] ) ->
                     Result.map
                         Effect.Http.BadUrl
                         (Fusion.Patch.build_String patch0)

                 ( "Timeout", [] ) ->
                     Result.Ok Effect.Http.Timeout

                 ( "NetworkError", [] ) ->
                     Result.Ok Effect.Http.NetworkError

                 ( "BadStatus", [ patch0 ] ) ->
                     Result.map
                         Effect.Http.BadStatus
                         (Fusion.Patch.build_Int patch0)

                 ( "BadBody", [ patch0 ] ) ->
                     Result.map
                         Effect.Http.BadBody
                         (Fusion.Patch.build_String patch0)

                 _ ->
                     Result.Err
                         (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


patch_Error :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Effect.Http.Error
    -> Result Fusion.Patch.Error Effect.Http.Error
patch_Error options patch value =
    let
        isCorrectVariant expected =
            case ( value, expected ) of
                ( Effect.Http.BadUrl _, "BadUrl" ) ->
                    True

                ( Effect.Http.Timeout, "Timeout" ) ->
                    True

                ( Effect.Http.NetworkError, "NetworkError" ) ->
                    True

                ( Effect.Http.BadStatus _, "BadStatus" ) ->
                    True

                ( Effect.Http.BadBody _, "BadBody" ) ->
                    True

                _ ->
                    False
    in
    case ( value, patch, options.force ) of
        ( Effect.Http.BadUrl arg0, Fusion.Patch.PCustomSame "BadUrl" [ patch0 ], _ ) ->
            Result.map
                Effect.Http.BadUrl
                (Fusion.Patch.maybeApply
                     Fusion.Patch.patcher_String
                     options
                     patch0
                     arg0
                )

        ( _, Fusion.Patch.PCustomSame "BadUrl" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BadUrl" [ (Just patch0) ], _ ) ->
            Result.map
                Effect.Http.BadUrl
                (Fusion.Patch.buildFromPatch Fusion.Patch.build_String patch0)

        ( _, Fusion.Patch.PCustomSame "BadUrl" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( Effect.Http.Timeout, Fusion.Patch.PCustomSame "Timeout" [], _ ) ->
            Result.Ok Effect.Http.Timeout

        ( _, Fusion.Patch.PCustomSame "Timeout" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "Timeout" [], _ ) ->
            Result.Ok Effect.Http.Timeout

        ( Effect.Http.NetworkError, Fusion.Patch.PCustomSame "NetworkError" [], _ ) ->
            Result.Ok Effect.Http.NetworkError

        ( _, Fusion.Patch.PCustomSame "NetworkError" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "NetworkError" [], _ ) ->
            Result.Ok Effect.Http.NetworkError

        ( Effect.Http.BadStatus arg0, Fusion.Patch.PCustomSame "BadStatus" [ patch0 ], _ ) ->
            Result.map
                Effect.Http.BadStatus
                (Fusion.Patch.maybeApply
                     Fusion.Patch.patcher_Int
                     options
                     patch0
                     arg0
                )

        ( _, Fusion.Patch.PCustomSame "BadStatus" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BadStatus" [ (Just patch0) ], _ ) ->
            Result.map
                Effect.Http.BadStatus
                (Fusion.Patch.buildFromPatch Fusion.Patch.build_Int patch0)

        ( _, Fusion.Patch.PCustomSame "BadStatus" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( Effect.Http.BadBody arg0, Fusion.Patch.PCustomSame "BadBody" [ patch0 ], _ ) ->
            Result.map
                Effect.Http.BadBody
                (Fusion.Patch.maybeApply
                     Fusion.Patch.patcher_String
                     options
                     patch0
                     arg0
                )

        ( _, Fusion.Patch.PCustomSame "BadBody" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BadBody" [ (Just patch0) ], _ ) ->
            Result.map
                Effect.Http.BadBody
                (Fusion.Patch.buildFromPatch Fusion.Patch.build_String patch0)

        ( _, Fusion.Patch.PCustomSame "BadBody" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        ( _, Fusion.Patch.PCustomChange expectedVariant "BadUrl" [ arg0 ], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.map Effect.Http.BadUrl (Fusion.Patch.build_String arg0)

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "Timeout" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Effect.Http.Timeout

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "NetworkError" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Effect.Http.NetworkError

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BadStatus" [ arg0 ], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.map Effect.Http.BadStatus (Fusion.Patch.build_Int arg0)

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BadBody" [ arg0 ], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.map Effect.Http.BadBody (Fusion.Patch.build_String arg0)

            else
                Result.Err Fusion.Patch.Conflict

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patcher_Error : Fusion.Patch.Patcher Effect.Http.Error
patcher_Error =
    { patch = patch_Error, build = build_Error, toValue = toValue_Error }


query_Error : Fusion.Query -> Effect.Http.Error -> Fusion.Value
query_Error query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (case value of
                     Effect.Http.BadUrl arg0 ->
                         Fusion.VCustom
                             "BadUrl"
                             [ Fusion.Patch.query_String query arg0 ]

                     Effect.Http.Timeout ->
                         Fusion.VCustom "Timeout" []

                     Effect.Http.NetworkError ->
                         Fusion.VCustom "NetworkError" []

                     Effect.Http.BadStatus arg0 ->
                         Fusion.VCustom "BadStatus" [ Fusion.VInt arg0 ]

                     Effect.Http.BadBody arg0 ->
                         Fusion.VCustom
                             "BadBody"
                             [ Fusion.Patch.query_String query arg0 ]
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery

        Fusion.QIndexed fusionValue fusionQuery ->
            Debug.todo "custom - qIndexed"


toValue_Error : Effect.Http.Error -> Fusion.Value
toValue_Error value =
    case value of
        Effect.Http.BadUrl arg0 ->
            Fusion.VCustom "BadUrl" [ Fusion.VString arg0 ]

        Effect.Http.Timeout ->
            Fusion.VCustom "Timeout" []

        Effect.Http.NetworkError ->
            Fusion.VCustom "NetworkError" []

        Effect.Http.BadStatus arg0 ->
            Fusion.VCustom "BadStatus" [ Fusion.VInt arg0 ]

        Effect.Http.BadBody arg0 ->
            Fusion.VCustom "BadBody" [ Fusion.VString arg0 ]