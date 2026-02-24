module Fusion.Generated.Postmark exposing
    ( build_PostmarkError_, build_SendEmailError, build_UnknownErrorData, patch_PostmarkError_, patch_SendEmailError, patch_UnknownErrorData
    , patcher_PostmarkError_, patcher_SendEmailError, patcher_UnknownErrorData, toValue_PostmarkError_, toValue_SendEmailError, toValue_UnknownErrorData
    )

{-|

@docs build_PostmarkError_, build_SendEmailError, build_UnknownErrorData, patch_PostmarkError_, patch_SendEmailError, patch_UnknownErrorData
@docs patcher_PostmarkError_, patcher_SendEmailError, patcher_UnknownErrorData, toValue_PostmarkError_, toValue_SendEmailError, toValue_UnknownErrorData

-}

import Dict
import Fusion
import Fusion.EmailAddress
import Fusion.Patch
import Postmark


build_PostmarkError_ : Fusion.Value -> Result Fusion.Patch.Error Postmark.PostmarkError_
build_PostmarkError_ value =
    Fusion.Patch.build_Record
        (\build_RecordUnpack ->
            Result.map3
                (\errorCode message to ->
                    { errorCode = errorCode, message = message, to = to }
                )
                (Result.andThen
                    Fusion.Patch.build_Int
                    (build_RecordUnpack "errorCode")
                )
                (Result.andThen
                    Fusion.Patch.build_String
                    (build_RecordUnpack "message")
                )
                (Result.andThen
                    (Fusion.Patch.build_List
                        Fusion.EmailAddress.patcher_EmailAddress
                    )
                    (build_RecordUnpack "to")
                )
        )
        value


build_SendEmailError : Fusion.Value -> Result Fusion.Patch.Error Postmark.SendEmailError
build_SendEmailError value =
    Fusion.Patch.build_Custom
        (\name params ->
            case ( name, params ) of
                ( "UnknownError", [ patch0 ] ) ->
                    Result.map
                        Postmark.UnknownError
                        (build_UnknownErrorData patch0)

                ( "PostmarkError", [ patch0 ] ) ->
                    Result.map
                        Postmark.PostmarkError
                        (build_PostmarkError_ patch0)

                ( "NetworkError", [] ) ->
                    Result.Ok Postmark.NetworkError

                ( "Timeout", [] ) ->
                    Result.Ok Postmark.Timeout

                ( "BadUrl", [ patch0 ] ) ->
                    Result.map
                        Postmark.BadUrl
                        (Fusion.Patch.build_String patch0)

                _ ->
                    Result.Err
                        (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


build_UnknownErrorData : Fusion.Value -> Result Fusion.Patch.Error Postmark.UnknownErrorData
build_UnknownErrorData value =
    Fusion.Patch.build_Record
        (\build_RecordUnpack ->
            Result.map2
                (\statusCode body -> { statusCode = statusCode, body = body })
                (Result.andThen
                    Fusion.Patch.build_Int
                    (build_RecordUnpack "statusCode")
                )
                (Result.andThen
                    Fusion.Patch.build_String
                    (build_RecordUnpack "body")
                )
        )
        value


patch_PostmarkError_ :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Postmark.PostmarkError_
    -> Result Fusion.Patch.Error Postmark.PostmarkError_
patch_PostmarkError_ options patch value =
    Fusion.Patch.patch_Record
        (\fieldName fieldPatch acc ->
            case fieldName of
                "errorCode" ->
                    Result.map
                        (\errorCode -> { acc | errorCode = errorCode })
                        (Fusion.Patch.patch_Int
                            options
                            fieldPatch
                            acc.errorCode
                        )

                "message" ->
                    Result.map
                        (\message -> { acc | message = message })
                        (Fusion.Patch.patch_String
                            options
                            fieldPatch
                            acc.message
                        )

                "to" ->
                    Result.map
                        (\to -> { acc | to = to })
                        (Fusion.Patch.patch_List
                            Fusion.EmailAddress.patcher_EmailAddress
                            options
                            fieldPatch
                            acc.to
                        )

                _ ->
                    Result.Err (Fusion.Patch.UnexpectedField fieldName)
        )
        patch
        value


patch_SendEmailError :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Postmark.SendEmailError
    -> Result Fusion.Patch.Error Postmark.SendEmailError
patch_SendEmailError options patch value =
    let
        isCorrectVariant expected =
            case ( value, expected ) of
                ( Postmark.UnknownError _, "UnknownError" ) ->
                    True

                ( Postmark.PostmarkError _, "PostmarkError" ) ->
                    True

                ( Postmark.NetworkError, "NetworkError" ) ->
                    True

                ( Postmark.Timeout, "Timeout" ) ->
                    True

                ( Postmark.BadUrl _, "BadUrl" ) ->
                    True

                _ ->
                    False
    in
    case ( value, patch, options.force ) of
        ( Postmark.UnknownError arg0, Fusion.Patch.PCustomSame "UnknownError" [ patch0 ], _ ) ->
            Result.map
                Postmark.UnknownError
                (Fusion.Patch.maybeApply
                    patcher_UnknownErrorData
                    options
                    patch0
                    arg0
                )

        ( _, Fusion.Patch.PCustomSame "UnknownError" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "UnknownError" [ Just patch0 ], _ ) ->
            Result.map
                Postmark.UnknownError
                (Fusion.Patch.buildFromPatch build_UnknownErrorData patch0)

        ( _, Fusion.Patch.PCustomSame "UnknownError" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( Postmark.PostmarkError arg0, Fusion.Patch.PCustomSame "PostmarkError" [ patch0 ], _ ) ->
            Result.map
                Postmark.PostmarkError
                (Fusion.Patch.maybeApply
                    patcher_PostmarkError_
                    options
                    patch0
                    arg0
                )

        ( _, Fusion.Patch.PCustomSame "PostmarkError" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "PostmarkError" [ Just patch0 ], _ ) ->
            Result.map
                Postmark.PostmarkError
                (Fusion.Patch.buildFromPatch build_PostmarkError_ patch0)

        ( _, Fusion.Patch.PCustomSame "PostmarkError" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( Postmark.NetworkError, Fusion.Patch.PCustomSame "NetworkError" [], _ ) ->
            Result.Ok Postmark.NetworkError

        ( _, Fusion.Patch.PCustomSame "NetworkError" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "NetworkError" [], _ ) ->
            Result.Ok Postmark.NetworkError

        ( Postmark.Timeout, Fusion.Patch.PCustomSame "Timeout" [], _ ) ->
            Result.Ok Postmark.Timeout

        ( _, Fusion.Patch.PCustomSame "Timeout" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "Timeout" [], _ ) ->
            Result.Ok Postmark.Timeout

        ( Postmark.BadUrl arg0, Fusion.Patch.PCustomSame "BadUrl" [ patch0 ], _ ) ->
            Result.map
                Postmark.BadUrl
                (Fusion.Patch.maybeApply
                    Fusion.Patch.patcher_String
                    options
                    patch0
                    arg0
                )

        ( _, Fusion.Patch.PCustomSame "BadUrl" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BadUrl" [ Just patch0 ], _ ) ->
            Result.map
                Postmark.BadUrl
                (Fusion.Patch.buildFromPatch Fusion.Patch.build_String patch0)

        ( _, Fusion.Patch.PCustomSame "BadUrl" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        ( _, Fusion.Patch.PCustomChange expectedVariant "UnknownError" [ arg0 ], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.map Postmark.UnknownError (build_UnknownErrorData arg0)

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "PostmarkError" [ arg0 ], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.map Postmark.PostmarkError (build_PostmarkError_ arg0)

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "NetworkError" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Postmark.NetworkError

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "Timeout" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Postmark.Timeout

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BadUrl" [ arg0 ], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.map Postmark.BadUrl (Fusion.Patch.build_String arg0)

            else
                Result.Err Fusion.Patch.Conflict

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patch_UnknownErrorData :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Postmark.UnknownErrorData
    -> Result Fusion.Patch.Error Postmark.UnknownErrorData
patch_UnknownErrorData options patch value =
    Fusion.Patch.patch_Record
        (\fieldName fieldPatch acc ->
            case fieldName of
                "statusCode" ->
                    Result.map
                        (\statusCode -> { acc | statusCode = statusCode })
                        (Fusion.Patch.patch_Int
                            options
                            fieldPatch
                            acc.statusCode
                        )

                "body" ->
                    Result.map
                        (\body -> { acc | body = body })
                        (Fusion.Patch.patch_String options fieldPatch acc.body)

                _ ->
                    Result.Err (Fusion.Patch.UnexpectedField fieldName)
        )
        patch
        value


patcher_PostmarkError_ : Fusion.Patch.Patcher Postmark.PostmarkError_
patcher_PostmarkError_ =
    { patch = patch_PostmarkError_
    , build = build_PostmarkError_
    , toValue = toValue_PostmarkError_
    }


patcher_SendEmailError : Fusion.Patch.Patcher Postmark.SendEmailError
patcher_SendEmailError =
    { patch = patch_SendEmailError
    , build = build_SendEmailError
    , toValue = toValue_SendEmailError
    }


patcher_UnknownErrorData : Fusion.Patch.Patcher Postmark.UnknownErrorData
patcher_UnknownErrorData =
    { patch = patch_UnknownErrorData
    , build = build_UnknownErrorData
    , toValue = toValue_UnknownErrorData
    }


toValue_PostmarkError_ : Postmark.PostmarkError_ -> Fusion.Value
toValue_PostmarkError_ value =
    Fusion.VRecord
        (Dict.fromList
            [ ( "errorCode", Fusion.VInt value.errorCode )
            , ( "message", Fusion.VString value.message )
            , ( "to"
              , Fusion.Patch.toValue_List
                    Fusion.EmailAddress.patcher_EmailAddress
                    value.to
              )
            ]
        )


toValue_SendEmailError : Postmark.SendEmailError -> Fusion.Value
toValue_SendEmailError value =
    case value of
        Postmark.UnknownError arg0 ->
            Fusion.VCustom "UnknownError" [ toValue_UnknownErrorData arg0 ]

        Postmark.PostmarkError arg0 ->
            Fusion.VCustom "PostmarkError" [ toValue_PostmarkError_ arg0 ]

        Postmark.NetworkError ->
            Fusion.VCustom "NetworkError" []

        Postmark.Timeout ->
            Fusion.VCustom "Timeout" []

        Postmark.BadUrl arg0 ->
            Fusion.VCustom "BadUrl" [ Fusion.VString arg0 ]


toValue_UnknownErrorData : Postmark.UnknownErrorData -> Fusion.Value
toValue_UnknownErrorData value =
    Fusion.VRecord
        (Dict.fromList
            [ ( "statusCode", Fusion.VInt value.statusCode )
            , ( "body", Fusion.VString value.body )
            ]
        )
