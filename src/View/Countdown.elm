module View.Countdown exposing (..)

import Date
import DateFormat
import Element exposing (..)
import Theme
import Time
import TimeFormat


ui : String -> String -> { model | now : Time.Posix } -> Element msg
ui t description model =
    let
        target =
            TimeFormat.certain t Time.utc

        now =
            model.now
                |> Time.posixToMillis
                |> Debug.log "now"
    in
    el Theme.contentAttributes <|
        el [ centerX ] <|
            Theme.h2 <|
                asTimeToGo target model.now


detailedCountdown : String -> String -> { model | now : Time.Posix } -> Element msg
detailedCountdown t description model =
    let
        target =
            TimeFormat.certain t Time.utc
                |> .time
                |> Time.posixToMillis

        now =
            model.now
                |> Time.posixToMillis

        totalSeconds =
            (target - now) // 1000

        days =
            totalSeconds // (60 * 60 * 24)

        hours =
            modBy totalSeconds (60 * 60 * 24) // (60 * 60)

        minutes =
            modBy totalSeconds (60 * 60) // 60

        formatDays =
            if days > 1 then
                Just (String.fromInt days ++ " days")

            else if days == 1 then
                Just "1 day"

            else
                Nothing

        formatHours =
            if hours > 0 then
                Just (String.fromInt hours ++ "h")

            else
                Nothing

        formatMinutes =
            if minutes > 0 then
                Just (String.fromInt minutes ++ "m")

            else
                Nothing

        output =
            String.join " "
                (List.filterMap identity [ formatDays, formatHours, formatMinutes ])
    in
    if Time.posixToMillis model.now == 0 then
        none

    else
        el Theme.contentAttributes <| el [ centerX ] <| Theme.h2 <| output ++ " " ++ description



-- String.fromInt (target - now)
--     ++ " "
--     ++ description


asTimeToGo zoned now =
    let
        days =
            Date.diff Date.Days (Date.fromPosix Time.utc now) (Date.fromPosix Time.utc zoned.time)
    in
    if zoned.time == Time.millisToPosix 0 then
        "Never"

    else if days > 84 then
        let
            months =
                days // 30

            days_ =
                modBy 30 days
        in
        String.fromInt months ++ " months " ++ String.fromInt days_ ++ " days"

    else if days > 28 then
        let
            weeks =
                days // 7

            days_ =
                modBy 7 days
        in
        String.fromInt weeks ++ " weeks " ++ (days_ |> String.fromInt) ++ "d"

    else if days == 1 then
        DateFormat.format
            [ DateFormat.hourMilitaryFixed
            , DateFormat.text ":"
            , DateFormat.minuteFixed
            ]
            zoned.zone
            zoned.time
            ++ " Tomorrow"

    else if days == 0 then
        DateFormat.format
            [ DateFormat.hourMilitaryFixed
            , DateFormat.text ":"
            , DateFormat.minuteFixed
            ]
            zoned.zone
            zoned.time
            ++ " today"

    else
        -- String.fromInt days ++ " days"
        DateFormat.format
            [ DateFormat.hourMilitaryFixed
            , DateFormat.text ":"
            , DateFormat.minuteFixed
            ]
            zoned.zone
            zoned.time
            ++ " today"
