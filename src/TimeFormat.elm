module TimeFormat exposing (..)

-- import Date
-- import DateFormat
-- import Dict exposing (Dict)
-- import Round

import Iso8601
import Time



-- import Time.Distance exposing (inWordsWithConfig)
-- import Time.Distance.Types exposing (..)
-- import Time.Extra
-- import TimeZone exposing (..)


type alias Zoned =
    { time : Time.Posix, zone : Time.Zone }


zonedZero =
    { time = Time.millisToPosix 0, zone = Time.utc }


certain s zone =
    case Iso8601.toTime s of
        Err deadEnds ->
            -- let
            --     x =
            --         Debug.log ("deadends for " ++ s) deadEnds
            -- in
            Zoned (Time.millisToPosix 0) Time.utc

        Ok t ->
            Zoned t zone
