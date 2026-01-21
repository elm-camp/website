module View.Countdown exposing (detailedCountdown)

import Theme
import Time exposing (Month(..))
import Ui
import Ui.Font
import Ui.Prose


detailedCountdown : Time.Posix -> Time.Posix -> Maybe (Ui.Element msg)
detailedCountdown target now =
    let
        target2 =
            Time.posixToMillis target

        now2 =
            Time.posixToMillis now

        secondsRemaining =
            (target2 - now2) // 1000

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
    if secondsRemaining < 0 then
        Nothing

    else
        Ui.Prose.paragraph
            (Theme.contentAttributes ++ [ Ui.Font.center ])
            [ Theme.h2 (output ++ " until ticket sales open") ]
            |> Just
