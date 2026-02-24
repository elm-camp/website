module Evergreen.V114.Fusion exposing (..)

import Bytes
import Dict


type Value
    = VInt Int
    | VFloat Float
    | VString String
    | VBool Bool
    | VChar Char
    | VUnit
    | VBytes Bytes.Bytes
    | VTuple Value Value
    | VTriple Value Value Value
    | VList
        { cursor : Int
        , items : List Value
        }
    | VSet
        { cursor : Int
        , items : List Value
        }
    | VDict
        { cursor : Int
        , items : List ( Value, Value )
        }
    | VCustom String (List Value)
    | VRecord (Dict.Dict String Value)
    | VUnloaded
    | VPartialString
        { length : Int
        , partial : String
        }
