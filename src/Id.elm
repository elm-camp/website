module Id exposing
    ( Id(..)
    , decoder
    , encode
    , fromString
    , toString
    )

import Json.Decode
import Json.Encode


type Id a
    = Id String


toString : Id a -> String
toString (Id hash) =
    hash


fromString : String -> Id a
fromString =
    Id


decoder : Json.Decode.Decoder (Id a)
decoder =
    Json.Decode.map Id Json.Decode.string


encode : Id a -> Json.Encode.Value
encode (Id id) =
    Json.Encode.string id
