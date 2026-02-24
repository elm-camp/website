module Fusion.Generated.TypeDict.Effect.Time exposing (typeDict, type_Posix)

{-|

@docs typeDict, type_Posix

-}

import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List a )
typeDict =
    Dict.fromList [ ( "Posix", ( type_Posix, [] ) ) ]


type_Posix : Fusion.Type
type_Posix =
    Fusion.TNamed [ "Time" ] "Posix" [] Nothing
