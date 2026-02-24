module Fusion.Generated.TypeDict.String.Nonempty exposing (typeDict, type_NonemptyString)

{-|

@docs typeDict, type_NonemptyString

-}

import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List a )
typeDict =
    Dict.fromList [ ( "NonemptyString", ( type_NonemptyString, [] ) ) ]


type_NonemptyString : Fusion.Type
type_NonemptyString =
    Fusion.TCustom
        "NonemptyString"
        []
        [ ( "NonemptyString"
          , [ Fusion.TNamed [ "Char" ] "Char" [] (Just Fusion.TChar)
            , Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString)
            ]
          )
        ]
