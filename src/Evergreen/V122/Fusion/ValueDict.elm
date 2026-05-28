module Evergreen.V122.Fusion.ValueDict exposing (..)

import Evergreen.V122.Fusion


type NColor
    = Red
    | Black


type ValueDict v
    = RBNode_elm_builtin NColor Evergreen.V122.Fusion.Value v (ValueDict v) (ValueDict v)
    | RBEmpty_elm_builtin
