module Fusion.Generated.TypeDict.Name exposing ( typeDict, type_Name )

{-|
@docs typeDict, type_Name
-}


import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List a )
typeDict =
    Dict.fromList [ ( "Name", ( type_Name, [] ) ) ]


type_Name : Fusion.Type
type_Name =
    Fusion.TCustom
        "Name"
        []
        [ ( "Name"
          , [ Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString) ]
          )
        ]