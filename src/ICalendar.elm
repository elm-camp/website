module ICalendar exposing (Event, IcsFile, download, toText, toTextEvent)

import DateFormat
import File.Download
import Time


{-| An ICS file is a text file that follows the iCalendar format. It is used to store events and to-dos.
-}
type alias IcsFile =
    { name : String
    , prodid : { company : String, product : String }
    , events : List Event
    }


type alias Event =
    { uid : String
    , start : Time.Posix
    , summary : String
    , description : String
    }


download : IcsFile -> Cmd msg
download icsFile =
    File.Download.string (icsFile.name ++ ".ics") "text/calendar" (toText icsFile)


toText : IcsFile -> String
toText icsFile =
    [ "BEGIN:VCALENDAR"
    , "VERSION:2.0"
    , "PRODID:-//{company}//{product}//EN"
    , "{events}"
    , "END:VCALENDAR"
    ]
        |> String.join "\u{000D}\n"
        |> String.replace "{company}" icsFile.prodid.company
        |> String.replace "{product}" icsFile.prodid.product
        |> String.replace "{events}" (List.map toTextEvent icsFile.events |> String.concat)


toTextEvent : Event -> String
toTextEvent event =
    let
        format =
            -- Needs to be this format
            -- 20240330T100000Z
            DateFormat.format
                [ DateFormat.yearNumber
                , DateFormat.monthFixed
                , DateFormat.dayOfMonthFixed
                , DateFormat.text "T"
                , DateFormat.hourMilitaryFixed
                , DateFormat.minuteFixed
                , DateFormat.secondFixed
                , DateFormat.text "Z"
                ]
                Time.utc

        stamp =
            format
                event.start

        stampPlus =
            event.start |> Time.posixToMillis |> (+) (1000 * 60 * 60) |> Time.millisToPosix |> format
    in
    [ "BEGIN:VEVENT"
    , "UID:{uid}"
    , "DTSTART:{stamp}"
    , "DTEND:{stampPlus}"
    , "SUMMARY:{summary}"
    , "DESCRIPTION:{description}"
    , "END:VEVENT"
    ]
        |> String.join "\u{000D}\n"
        |> String.replace "{uid}" event.uid
        |> String.replace "{stamp}" stamp
        |> String.replace "{stampPlus}" stampPlus
        |> String.replace "{summary}" event.summary
        |> String.replace "{description}" event.description
