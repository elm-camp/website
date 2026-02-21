module Fusion.Generated.Effect.Time exposing
    ( build_Posix, patch_Posix, patcher_Posix, query_Posix, toValue_Posix
    )

{-|
@docs build_Posix, patch_Posix, patcher_Posix, query_Posix, toValue_Posix
-}


import Effect.Time
import Fusion
import Fusion.Patch


build_Posix : Fusion.Value -> Result Fusion.Patch.Error Effect.Time.Posix
build_Posix value =
    Fusion.Patch.build_Posix value


patch_Posix :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Effect.Time.Posix
    -> Result Fusion.Patch.Error Effect.Time.Posix
patch_Posix options patch value =
    Fusion.Patch.patch_Posix options patch value


patcher_Posix : Fusion.Patch.Patcher Effect.Time.Posix
patcher_Posix =
    { patch = patch_Posix, build = build_Posix, toValue = toValue_Posix }


query_Posix : Fusion.Query -> Effect.Time.Posix -> Fusion.Value
query_Posix query value =
    Fusion.Patch.query_Posix query value


toValue_Posix : Effect.Time.Posix -> Fusion.Value
toValue_Posix value =
    Fusion.Patch.toValue_Posix value