module Fusion.Generated.TypeDict.Id exposing (typeDict, type_Id)

{-|

@docs typeDict, type_Id

-}

import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List String )
typeDict =
    Dict.fromList [ ( "Id", ( type_Id, [ "a" ] ) ) ]


type_Id : Fusion.Type
type_Id =
    Fusion.TCustom
        "Id"
        [ "a" ]
        [ ( "Id"
          , [ Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString) ]
          )
        ]
