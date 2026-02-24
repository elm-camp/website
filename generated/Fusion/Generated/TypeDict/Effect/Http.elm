module Fusion.Generated.TypeDict.Effect.Http exposing (typeDict, type_Error)

{-|

@docs typeDict, type_Error

-}

import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List a )
typeDict =
    Dict.fromList [ ( "Error", ( type_Error, [] ) ) ]


type_Error : Fusion.Type
type_Error =
    Fusion.TCustom
        "Error"
        []
        [ ( "BadUrl"
          , [ Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString) ]
          )
        , ( "Timeout", [] )
        , ( "NetworkError", [] )
        , ( "BadStatus"
          , [ Fusion.TNamed [ "Basics" ] "Int" [] (Just Fusion.TInt) ]
          )
        , ( "BadBody"
          , [ Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString) ]
          )
        ]
