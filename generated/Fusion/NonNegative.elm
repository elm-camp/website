module Fusion.NonNegative exposing (..)

import Fusion exposing (Value(..))
import Fusion.Patch exposing (Error(..))
import NonNegative exposing (NonNegative)


toValue_NonNegative : NonNegative -> Fusion.Value
toValue_NonNegative email =
    NonNegative.toString email |> VString


patch_NonNegative : { force : Bool } -> Fusion.Patch.Patch -> NonNegative -> Result Fusion.Patch.Error NonNegative
patch_NonNegative options patch value =
    case ( patch, options.force ) of
        ( Fusion.Patch.PInt old new, _ ) ->
            NonNegative.fromInt new |> Result.mapError (\_ -> WrongType "")

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


build_NonNegative : Fusion.Value -> Result Fusion.Patch.Error NonNegative
build_NonNegative value =
    case value of
        VInt int ->
            case NonNegative.fromInt int of
                Ok nonNegative ->
                    Ok nonNegative

                Err _ ->
                    Err (WrongType "")

        _ ->
            Err (WrongType "")


patcher_NonNegative : Fusion.Patch.Patcher NonNegative
patcher_NonNegative =
    { patch = patch_NonNegative
    , build = build_NonNegative
    , toValue = toValue_NonNegative
    }
