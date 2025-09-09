module View.Countdown exposing (asTimeToGo, detailedCountdown, ticketSalesLive, ui)

import Date
import DateFormat
import Effect.Time
import Element exposing (Element)
import Element.Font as Font
import Theme
import TimeFormat exposing (Zoned)


ui : String -> String -> { model | now : Effect.Time.Posix } -> Element msg
ui t description model =
    let
        target =
            TimeFormat.certain t Effect.Time.utc

        now =
            model.now
                |> Effect.Time.posixToMillis
    in
    Element.el Theme.contentAttributes (Element.el [ Element.centerX ] (Theme.h2 (asTimeToGo target model.now)))


ticketSalesLive : Effect.Time.Posix -> { model | now : Effect.Time.Posix } -> Bool
ticketSalesLive t model =
    let
        target =
            t |> Effect.Time.posixToMillis

        now =
            model.now
                |> Effect.Time.posixToMillis

        secondsRemaining =
            (target - now) // 1000
    in
    (Effect.Time.posixToMillis model.now == 0) || secondsRemaining < 0


detailedCountdown : Effect.Time.Posix -> String -> { model | now : Effect.Time.Posix } -> Element msg
detailedCountdown t description model =
    let
        target =
            t |> Effect.Time.posixToMillis

        now =
            model.now
                |> Effect.Time.posixToMillis

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
    if (Effect.Time.posixToMillis model.now == 0) || secondsRemaining < 0 then
        Element.none

    else
        Element.paragraph (Theme.contentAttributes ++ [ Font.center ]) [ Theme.h2 (output ++ " " ++ description) ]



-- String.fromInt (target - now)
--     ++ " "
--     ++ description


asTimeToGo : Zoned -> Effect.Time.Posix -> String
asTimeToGo zoned now =
    let
        days =
            Date.diff Date.Days (Date.fromPosix Effect.Time.utc now) (Date.fromPosix Effect.Time.utc zoned.time)
    in
    if zoned.time == Effect.Time.millisToPosix 0 then
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
