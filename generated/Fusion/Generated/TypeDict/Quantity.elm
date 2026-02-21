module Fusion.Generated.TypeDict.Quantity exposing ( typeDict, type_Quantity )

{-|
@docs typeDict, type_Quantity
-}


import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List String )
typeDict =
    Dict.fromList [ ( "Quantity", ( type_Quantity, [ "number", "units" ] ) ) ]


type_Quantity : Fusion.Type
type_Quantity =
    Fusion.TCustom
        "Quantity"
        [ "number", "units" ]
        [ ( "Quantity", [ Fusion.TVar "number" ] ) ]