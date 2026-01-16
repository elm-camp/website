module View.Countdown exposing (asTimeToGo, detailedCountdown, ticketSalesLive, ui)

import Date
import DateFormat
import Effect.Time as Time
import Theme
import TimeFormat exposing (Zoned)
import Ui
import Ui.Anim
import Ui.Font as Font
import Ui.Layout
import Ui.Prose


ui : String -> String -> { model | now : Time.Posix } -> Ui.Element msg
ui t description model =
    let
        target =
            TimeFormat.certain t Time.utc

        now =
            model.now
                |> Time.posixToMillis
    in
    Ui.el
        -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
        Theme.contentAttributes
        (Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Theme.h2 (asTimeToGo target model.now)))


ticketSalesLive : Time.Posix -> { model | now : Time.Posix } -> Bool
ticketSalesLive t model =
    let
        target =
            t |> Time.posixToMillis

        now =
            model.now
                |> Time.posixToMillis

        secondsRemaining =
            (target - now) // 1000
    in
    (Time.posixToMillis model.now == 0) || secondsRemaining < 0


detailedCountdown : Time.Posix -> String -> { model | now : Time.Posix } -> Ui.Element msg
detailedCountdown t description model =
    let
        target =
            t |> Time.posixToMillis

        now =
            model.now
                |> Time.posixToMillis

        secondsRemaining =
            (target - now) // 1000

        days =
            secondsRemaining // (60 * 60 * 24)

        hours =
            modBy 24 (secondsRemaining // (60 * 60))

        minutes =
            modBy 60 (secondsRemaining // 60)

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
    if (Time.posixToMillis model.now == 0) || secondsRemaining < 0 then
        Ui.none

    else
        Ui.Prose.paragraph
            -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
            (Theme.contentAttributes ++ [ Ui.Font.center ])
            [ Theme.h2 (output ++ " " ++ description) ]



-- String.fromInt (target - now)
--     ++ " "
--     ++ description


asTimeToGo : Zoned -> Time.Posix -> String
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

    else
        DateFormat.format
            [ DateFormat.hourMilitaryFixed
            , DateFormat.text ":"
            , DateFormat.minuteFixed
            ]
            zoned.zone
            zoned.time
            ++ " today"
