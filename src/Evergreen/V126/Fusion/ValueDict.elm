module Evergreen.V126.Fusion.ValueDict exposing (..)

import Evergreen.V126.Fusion


type NColor
    = Red
    | Black


type ValueDict v
    = RBNode_elm_builtin NColor Evergreen.V126.Fusion.Value v (ValueDict v) (ValueDict v)
    | RBEmpty_elm_builtin
