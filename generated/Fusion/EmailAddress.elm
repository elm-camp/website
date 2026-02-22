module Fusion.EmailAddress exposing (..)

import EmailAddress exposing (EmailAddress)
import Fusion exposing (Value(..))
import Fusion.Patch exposing (Error(..))


toValue_EmailAddress : EmailAddress -> Fusion.Value
toValue_EmailAddress email =
    EmailAddress.toString email |> VString


patch_EmailAddress : { force : Bool } -> Fusion.Patch.Patch -> EmailAddress -> Result Fusion.Patch.Error EmailAddress
patch_EmailAddress options patch value =
    case ( patch, options.force ) of
        ( Fusion.Patch.PString old new, _ ) ->
            EmailAddress.fromString new |> Result.fromMaybe (WrongType "")

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


build_EmailAddress : Fusion.Value -> Result Fusion.Patch.Error EmailAddress
build_EmailAddress value =
    case value of
        VString text ->
            case EmailAddress.fromString text of
                Just emailAddress ->
                    Ok emailAddress

                Nothing ->
                    Err (WrongType "")

        _ ->
            Err (WrongType "")


patcher_EmailAddress : Fusion.Patch.Patcher EmailAddress
patcher_EmailAddress =
    { patch = patch_EmailAddress
    , build = build_EmailAddress
    , toValue = toValue_EmailAddress
    }
