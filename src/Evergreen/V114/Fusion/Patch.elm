module Evergreen.V114.Fusion.Patch exposing (..)

import Bytes
import Dict
import Evergreen.V114.Fusion
import Evergreen.V114.Fusion.ValueDict


type alias ListPatch =
    { edited : Dict.Dict Int Patch
    , removed : Dict.Dict Int Evergreen.V114.Fusion.Value
    , added : Dict.Dict Int Evergreen.V114.Fusion.Value
    }


type alias SetPatch =
    { removed : Evergreen.V114.Fusion.ValueDict.ValueDict ()
    , added : Evergreen.V114.Fusion.ValueDict.ValueDict ()
    }


type alias DictPatch =
    { edited : Evergreen.V114.Fusion.ValueDict.ValueDict Patch
    , removed : Evergreen.V114.Fusion.ValueDict.ValueDict Evergreen.V114.Fusion.Value
    , added : Evergreen.V114.Fusion.ValueDict.ValueDict Evergreen.V114.Fusion.Value
    }


type Patch
    = PInt Int Int
    | PFloat Float Float
    | PString String String
    | PBool Bool Bool
    | PChar Char Char
    | PBytes Bytes.Bytes Bytes.Bytes
    | PUnit
    | PTuple (Maybe Patch) (Maybe Patch)
    | PTriple (Maybe Patch) (Maybe Patch) (Maybe Patch)
    | PList ListPatch
    | PSet SetPatch
    | PDict DictPatch
    | PCustomSame String (List (Maybe Patch))
    | PCustomChange String String (List Evergreen.V114.Fusion.Value)
    | PRecord (Dict.Dict String Patch)
    | PSetCursor Int
