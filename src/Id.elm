module Id exposing
    ( Id(..)
    , decoder
    , encode
    , fromString
    , toString
    )

import Json.Decode as D
import Json.Encode as E


type Id a
    = Id String


toString : Id a -> String
toString (Id hash) =
    hash


fromString : String -> Id a
fromString =
    Id


decoder : D.Decoder (Id a)
decoder =
    D.map Id D.string


encode : Id a -> E.Value
encode (Id id) =
    E.string id
