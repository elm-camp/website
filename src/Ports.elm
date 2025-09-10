port module Ports exposing
    ( stripe_from_js
    , stripe_to_js
    )

import Json.Decode as D
import Json.Encode as E


port stripe_to_js : E.Value -> Cmd msg


port stripe_from_js : ({ msg : String, value : D.Value } -> msg) -> Sub msg
