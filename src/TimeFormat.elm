module TimeFormat exposing (Zoned, certain, zonedZero)

-- import Date
-- import Dict exposing (Dict)
-- import Round

import DateFormat
import Effect.Time as Time
import Iso8601



-- import Time.Distance exposing (inWordsWithConfig)
-- import Time.Distance.Types exposing (..)
-- import Time.Extra
-- import TimeZone exposing (..)


type alias Zoned =
    { time : Time.Posix, zone : Time.Zone }


zonedZero : Zoned
zonedZero =
    { time = Time.millisToPosix 0, zone = Time.utc }


certain : String -> Time.Zone -> Zoned
certain s zone =
    case Iso8601.toTime s of
        Err _ ->
            -- let
            --     x =
            --         Debug.log ("deadends for " ++ s) deadEnds
            -- in
            Zoned (Time.millisToPosix 0) Time.utc

        Ok t ->
            Zoned t zone
