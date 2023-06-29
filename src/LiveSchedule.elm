module LiveSchedule exposing (..)

import Audio exposing (Audio)
import Duration exposing (Duration)
import Element exposing (Element)
import Element.Background
import Element.Font
import Element.Input
import List.Extra
import Quantity
import Theme
import Time


type Msg
    = PressedAllowAudio


presentationBreak : Duration
presentationBreak =
    Duration.minutes 5


audio : Audio.Source -> Audio
audio song =
    let
        playSong : Time.Posix -> Audio
        playSong startTime =
            Audio.audio
                song
                startTime
                |> Audio.scaleVolumeAt
                    [ ( startTime, 1 )
                    , ( Duration.addTo startTime (Duration.seconds 60), 1 )
                    , ( Duration.addTo startTime (Duration.seconds 61), 0.5 )
                    , ( Duration.addTo startTime (Duration.seconds 62), 0.25 )
                    , ( Duration.addTo startTime (Duration.seconds 63), 0.125 )
                    , ( Duration.addTo startTime (Duration.seconds 65), 0 )
                    ]
    in
    List.filterMap
        (\{ start, duration, event } ->
            case event of
                Presentation _ EndsWithShortBreak ->
                    playSong
                        (duration
                            |> Quantity.minus presentationBreak
                            |> Quantity.minus Duration.minute
                            |> Duration.addTo start
                        )
                        |> Just

                Presentation _ NoBreak ->
                    playSong
                        (duration
                            |> Quantity.minus Duration.minute
                            |> Duration.addTo start
                        )
                        |> Just

                Other _ ->
                    Nothing
        )
        fullSchedule
        |> Audio.group


day28 =
    Duration.subtractFrom day29 Duration.day


day29 =
    Time.millisToPosix 1687989600000


day30 =
    Duration.addTo day29 Duration.day


type alias EventAndTime =
    { start : Time.Posix, duration : Duration, event : Event }


type ShortBreak
    = EndsWithShortBreak
    | NoBreak


type Event
    = Presentation (List { speaker : String, title : String, room : Room }) ShortBreak
    | Other String


day28Schedule =
    [ { start = 15, duration = 1, event = Other "Arrivals and registration" }
    , { start = 16, duration = 1, event = Other "Coffee and snacks" }
    , { start = 18, duration = 1, event = Other "Session planning" }
    , { start = 19, duration = 1.5, event = Other "Dinner" }
    ]


type Room
    = West
    | Middle
    | East
    | Courtyard


day29Schedule : List { start : Float, duration : Float, event : Event }
day29Schedule =
    [ { start = 7, duration = 2, event = Other "Breakfast" }
    , { start = 9
      , duration = 1
      , event = Other "Opening keynote"
      }
    , { start = 10
      , duration = 35 / 60
      , event =
            Presentation
                [ { speaker = "Evan", title = "5 years for Elm", room = West } ]
                EndsWithShortBreak
      }
    , { start = 10 + 35 / 60
      , duration = 35 / 60
      , event =
            Presentation
                [ { speaker = "Jim", title = "Elm in Business", room = West }
                , { speaker = "Othman", title = "Error messages using LLM", room = Middle }
                , { speaker = "Mario", title = "Worst Elm code possible", room = East }
                ]
                EndsWithShortBreak
      }
    , { start = 11 + 10 / 60
      , duration = 20 / 60
      , event =
            Presentation
                [ { speaker = "Martin", title = "Debugger for Lamdera backend", room = West }
                , { speaker = "John", title = "Elm Store pattern", room = Middle }
                , { speaker = "Evan", title = "Reflecting on last few years", room = Courtyard }
                ]
                EndsWithShortBreak
      }
    , { start = 11.5
      , duration = 30 / 60
      , event =
            Presentation
                [ { speaker = "Jeroen", title = "Write an elm-review rule together", room = West }
                , { speaker = "Wolfgang", title = "Games with Elm", room = East }
                ]
                NoBreak
      }
    , { start = 12, duration = 1.5, event = Other "Lunchtime" }
    , { start = 14
      , duration = 35 / 60
      , event =
            Presentation
                [ { speaker = "Matt", title = "elm-dev", room = West }
                , { speaker = "Martin", title = "Lamdera at work", room = Middle }
                , { speaker = "Tomaz", title = "elm-csg, 3d objects in Elm", room = East }
                ]
                EndsWithShortBreak
      }
    , { start = 14 + 35 / 60
      , duration = 30 / 60
      , event =
            Presentation
                [ { speaker = "Casper", title = "Elm for beautiful art and music", room = West }
                , { speaker = "Johannes", title = "Handling Github renames", room = Middle }
                , { speaker = "Ryan", title = "Live elm-land app", room = East }
                ]
                NoBreak
      }
    , { start = 15 + 5 / 60, duration = 0.5, event = Other "Coffee and snacks" }
    , { start = 15 + 35 / 60
      , duration = 35 / 60
      , event =
            Presentation
                [ { speaker = "Leonardo", title = "Debugger needs and wants", room = West }
                , { speaker = "Othman", title = "TEA with LLM/AI (actor pattern)", room = Middle }
                , { speaker = "Simon", title = "Future Elm IDE plugins", room = East }
                ]
                EndsWithShortBreak
      }
    , { start = 16 + 10 / 60
      , duration = 20 / 60
      , event =
            Presentation
                [ { speaker = "Martyn", title = "JS mutation observer", room = West }
                , { speaker = "Georges", title = "elm-book V2", room = Middle }
                , { speaker = "Rupert", title = "Elm Janitor PRs", room = East }
                ]
                EndsWithShortBreak
      }
    , { start = 16.5
      , duration = 0.5
      , event =
            Presentation
                [ { speaker = "Marc", title = "Elm init GUI", room = West }
                , { speaker = "Georges", title = "New exciting not-elm bubble", room = Middle }
                , { speaker = "Martin", title = "WebGL UI (no HTML)", room = East }
                ]
                NoBreak
      }
    , { start = 18, duration = 1.5, event = Other "Dinner" }
    ]


day30Schedule : List { start : Float, duration : Float, event : Event }
day30Schedule =
    [ { start = 7, duration = 2, event = Other "Breakfast" }
    , { start = 9, duration = 0.5, event = Presentation [] EndsWithShortBreak }
    , { start = 9.5, duration = 0.5, event = Presentation [] EndsWithShortBreak }
    , { start = 10, duration = 0.5, event = Other "Checkout of rooms" }
    , { start = 10.5, duration = 0.5, event = Presentation [] EndsWithShortBreak }
    , { start = 11, duration = 0.5, event = Presentation [] EndsWithShortBreak }
    , { start = 11.5, duration = 0.5, event = Presentation [] EndsWithShortBreak }
    , { start = 12, duration = 1.5, event = Other "Lunchtime" }
    , { start = 14, duration = 1, event = Other "Closing keynote" }
    ]


offsetEvents day events =
    List.map
        (\{ start, duration, event } ->
            { start = Duration.addTo day (Duration.hours start)
            , duration = Duration.hours duration
            , event = event
            }
        )
        events


fullSchedule : List EventAndTime
fullSchedule =
    offsetEvents day28 day28Schedule
        ++ offsetEvents day29 day29Schedule
        ++ offsetEvents day30 day30Schedule


remainingEvents :
    Time.Posix
    -> ( Maybe EventAndTime, List EventAndTime )
remainingEvents time =
    case List.Extra.splitWhen (\{ start } -> Duration.from time start |> Quantity.greaterThanZero) fullSchedule of
        Just ( past, future ) ->
            ( case List.Extra.last past of
                Just current ->
                    if
                        Duration.addTo current.start current.duration
                            |> Duration.from time
                            |> Quantity.greaterThanZero
                    then
                        Just current

                    else
                        Nothing

                Nothing ->
                    Nothing
            , future
            )

        Nothing ->
            ( Nothing, [] )


fontSize : Float -> { width : Int, height : Int } -> Element.Attribute msg
fontSize size window =
    size * toFloat window.width / 1920 |> round |> Element.Font.size


moveUp : Float -> { width : Int, height : Int } -> Element.Attribute msg
moveUp size window =
    size * toFloat window.width / 1920 |> Element.moveUp


spacing : Float -> { width : Int, height : Int } -> Element.Attribute msg
spacing size window =
    size * toFloat window.width / 1920 |> round |> Element.spacing


height : Float -> { width : Int, height : Int } -> Element.Attribute msg
height size window =
    size * toFloat window.width / 1920 |> round |> Element.px |> Element.height


padding : Float -> { width : Int, height : Int } -> Element.Attribute msg
padding size window =
    size * toFloat window.width / 1920 |> round |> Element.padding


view :
    { a | now : Time.Posix, window : { width : Int, height : Int }, pressedAudioButton : Bool }
    -> Element Msg
view { now, window, pressedAudioButton } =
    let
        now2 =
            now

        --Duration.addTo day29 (Duration.hours 11.917)
    in
    if pressedAudioButton then
        Element.el
            [ Element.width Element.fill
            , Element.height Element.fill
            , padding 30 window
            ]
            (case remainingEvents now2 of
                ( Just current, next :: _ ) ->
                    Element.row
                        [ Element.width Element.fill, Element.height Element.fill, spacing 40 window ]
                        [ currentView window now2 current
                        , nextView window next
                        ]

                ( Just current, [] ) ->
                    Element.row
                        [ Element.width Element.fill, Element.height Element.fill, spacing 40 window ]
                        [ currentView window now2 current
                        , Element.el [ Element.width Element.fill ] Element.none
                        ]

                ( Nothing, next :: _ ) ->
                    Element.row
                        [ Element.width Element.fill, Element.height Element.fill, spacing 40 window ]
                        [ Element.el
                            [ Element.width (Element.fillPortion 2)
                            , Element.height Element.fill
                            ]
                            Element.none
                        , nextView window next
                        ]

                ( Nothing, [] ) ->
                    Element.none
            )

    else
        Element.Input.button
            [ Element.padding 36
            , Element.Background.color (Element.rgb 0.8 0.8 0.8)
            , Element.centerX
            , Element.centerY
            ]
            { onPress = Just PressedAllowAudio
            , label = Element.text "Click to enable audio"
            }


cardBackground : Element.Attr decorative msg
cardBackground =
    Element.Background.color (Element.rgb 0.85 0.85 0.85)


currentView : { width : Int, height : Int } -> Time.Posix -> EventAndTime -> Element msg
currentView window now { start, duration, event } =
    let
        durationLeft =
            Duration.from now (Duration.addTo start duration)

        minutes =
            Duration.inMinutes presentationBreak |> round

        timeLeft : Int
        timeLeft =
            durationLeft
                |> Duration.inMinutes
                |> ceiling
                |> (\a ->
                        case event of
                            Presentation _ EndsWithShortBreak ->
                                a - minutes

                            _ ->
                                a
                   )
    in
    case event of
        Presentation presentations _ ->
            Element.column
                [ spacing 60 window, Element.width (Element.fillPortion 2), Element.height Element.fill ]
                [ Element.row
                    [ Element.width Element.fill, fontSize 80 window, height 80 window ]
                    [ case event of
                        Presentation _ _ ->
                            if timeLeft <= 0 then
                                Element.text "Short break"

                            else
                                Element.text "In-session"

                        _ ->
                            Element.none
                    , Element.el
                        [ Element.alignRight ]
                        (Element.text
                            (String.fromInt
                                (if timeLeft <= 0 then
                                    timeLeft + minutes

                                 else
                                    timeLeft
                                )
                                ++ "min left"
                            )
                        )
                    ]
                , List.map
                    (\presentation ->
                        Element.column
                            [ Element.width Element.fill
                            , Element.height Element.fill
                            , cardBackground
                            , padding 20 window
                            , if timeLeft <= 0 then
                                Element.alpha 0.6

                              else
                                Element.alpha 1
                            ]
                            [ roomText presentation.room window
                            , Element.column
                                [ Element.centerY, spacing 10 window ]
                                [ Element.paragraph
                                    [ fontSize 60 window ]
                                    [ Element.text presentation.title ]
                                , Element.paragraph
                                    [ fontSize 40 window ]
                                    [ Element.text presentation.speaker ]
                                ]
                            ]
                    )
                    presentations
                    |> padList window
                    |> Element.column
                        [ Element.width Element.fill
                        , Element.height Element.fill
                        , spacing 30 window
                        ]
                ]

        Other title ->
            Element.el
                [ Element.centerY, Element.width (Element.fillPortion 2) ]
                (Element.column
                    [ padding 80 window, spacing 10 window ]
                    [ Element.el [ fontSize 30 window ] (Element.text "Currently")
                    , Element.paragraph [ fontSize 80 window ] [ Element.text title ]
                    , Element.el [ fontSize 30 window ] (Element.text (timeLeftText durationLeft))
                    ]
                )


timeLeftText : Duration -> String
timeLeftText duration =
    let
        hours =
            Duration.inHours duration |> floor

        minutes =
            duration |> Quantity.minus (Duration.hours (toFloat hours)) |> Duration.inMinutes |> ceiling
    in
    String.fromInt hours ++ "h" ++ String.fromInt minutes ++ "min left"


padList : { width : Int, height : Int } -> List (Element msg) -> List (Element msg)
padList window list =
    list ++ List.repeat (3 - List.length list) (Element.el [ Element.height Element.fill, padding 20 window ] Element.none)


roomText : Room -> { width : Int, height : Int } -> Element msg
roomText room window =
    Element.el [ fontSize 36 window ]
        (Element.text
            (case room of
                East ->
                    "East Elm room"

                West ->
                    "West Elm room"

                Middle ->
                    "Middle Elm room"

                Courtyard ->
                    "Courtyard"
            )
        )


denmarkTimezone =
    Time.customZone 120 []


nextTimeText : Time.Posix -> String
nextTimeText start =
    "Next: @ "
        ++ String.fromInt (Time.toHour denmarkTimezone start)
        ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt (Time.toMinute denmarkTimezone start))


nextView : { width : Int, height : Int } -> EventAndTime -> Element msg
nextView window { start, event } =
    case event of
        Presentation presentations _ ->
            Element.column
                [ spacing 60 window, Element.width Element.fill, Element.height Element.fill ]
                [ Element.row
                    [ Element.width Element.fill
                    , fontSize 60 window
                    , height 80 window
                    , Element.Font.family [ Element.Font.typeface "Fredoka" ]
                    ]
                    [ Element.text (nextTimeText start) ]
                , List.map
                    (\presentation ->
                        Element.column
                            [ Element.width Element.fill
                            , Element.height Element.fill
                            , padding 20 window
                            , cardBackground
                            ]
                            [ roomText presentation.room window
                            , Element.column
                                [ Element.centerY, spacing 10 window ]
                                [ Element.paragraph [ fontSize 40 window ] [ Element.text presentation.title ]
                                , Element.paragraph [ fontSize 30 window ] [ Element.text presentation.speaker ]
                                ]
                            ]
                    )
                    presentations
                    |> padList window
                    |> Element.column
                        [ Element.width Element.fill
                        , Element.height Element.fill
                        , spacing 30 window
                        ]
                ]

        Other title ->
            Element.el
                [ Element.width Element.fill
                , Element.height Element.fill
                ]
                (Element.column
                    [ Element.centerX, Element.centerY ]
                    [ Element.el
                        [ fontSize 40 window
                        , Element.Font.family [ Element.Font.typeface "Fredoka" ]
                        ]
                        (Element.text (nextTimeText start))
                    , Element.paragraph [ fontSize 80 window ] [ Element.text title ]
                    ]
                )
