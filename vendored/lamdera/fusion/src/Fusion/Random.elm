module Fusion.Random exposing (build_Seed, patch_Seed, patcher_Seed, toValue_Seed)

{-| -}

import Fusion exposing (Query(..), Value(..))
import Fusion.Patch exposing (Error(..), Patch, Patcher)
import Random exposing (Seed)


patcher_Seed : Patcher Seed
patcher_Seed =
    { patch = patch_Seed
    , build = build_Seed
    , toValue = toValue_Seed
    , query = query_Seed
    }


{-| -}
patch_Seed : { force : Bool } -> Patch -> Seed -> Result Error Seed
patch_Seed _ _ found =
    Ok found


{-| -}
build_Seed : Value -> Result Error Seed
build_Seed _ =
    Err <| WrongType "Seed"


{-| -}
toValue_Seed : Seed -> Value
toValue_Seed _ =
    VUnloaded


query_Seed : Fusion.Query -> Seed -> Result Error Value
query_Seed query seed =
    case query of
        QLoad ->
            Ok (toValue_Seed seed)

        QRecord _ _ ->
            Err WrongQuery

        QIndexed _ _ ->
            Err WrongQuery
