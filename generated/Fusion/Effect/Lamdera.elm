module Fusion.Effect.Lamdera exposing (..)

import Effect.Lamdera exposing (SessionId)
import Fusion exposing (Value(..))
import Fusion.Patch exposing (Error(..))


toValue_SessionId : SessionId -> Fusion.Value
toValue_SessionId email =
    Effect.Lamdera.sessionIdToString email |> VString


patch_SessionId : { force : Bool } -> Fusion.Patch.Patch -> SessionId -> Result Fusion.Patch.Error SessionId
patch_SessionId options patch value =
    case ( patch, options.force ) of
        ( Fusion.Patch.PString old new, _ ) ->
            Effect.Lamdera.sessionIdFromString new |> Ok

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


build_SessionId : Fusion.Value -> Result Fusion.Patch.Error SessionId
build_SessionId value =
    case value of
        VString text ->
            Effect.Lamdera.sessionIdFromString text |> Ok

        _ ->
            Err (WrongType "")


patcher_SessionId : Fusion.Patch.Patcher SessionId
patcher_SessionId =
    { patch = patch_SessionId
    , build = build_SessionId
    , toValue = toValue_SessionId
    }
