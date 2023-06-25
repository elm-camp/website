module LiveSchedule exposing (..)

import Duration
import Element exposing (Element)
import Element.Background
import Element.Font
import List.Extra
import Quantity
import Time


day28 =
    Duration.subtractFrom day29 Duration.day


day29 =
    Time.millisToPosix 1687989600000


day30 =
    Duration.addTo day29 Duration.day


type alias EventAndTime =
    { start : Time.Posix, event : Event }


type Event
    = Presentation (List { speaker : String, title : String, room : String })
    | Other String


day28Schedule =
    [ { start = 15, event = Other "Arrivals and registration" }
    , { start = 16, event = Other "Coffee and snacks" }
    , { start = 17, event = Other "Socialize!" }
    , { start = 18, event = Other "Session planning" }
    , { start = 19, event = Other "Dinner" }
    , { start = 20.5, event = Other "Socialize!" }
    ]


day29Schedule =
    [ { start = 7, event = Other "Breakfast" }
    , { start = 9
      , event = Presentation [ { speaker = "Evan Czaplicki", title = "Opening keynote", room = "" } ]
      }
    , { start = 10
      , event =
            Presentation
                [ { speaker = "Martin Stewart", title = "Interactive GUIs in WebGL with zero html", room = "Room A" }
                , { speaker = "Mario Rogic", title = "The worst Elm code possible", room = "Room B" }
                , { speaker = "Evan Czaplicki", title = "Making a Five Year Plan", room = "Room C" }
                ]
      }
    , { start = 10.5
      , event =
            Presentation
                [ { speaker = "Martin Stewart", title = "Interactive GUIs in WebGL with zero html", room = "Room A" }
                , { speaker = "Mario Rogic", title = "The worst Elm code possible", room = "Room B" }
                , { speaker = "Evan Czaplicki", title = "Making a Five Year Plan", room = "Room C" }
                ]
      }
    , { start = 11, event = Presentation [] }
    , { start = 11.5, event = Presentation [] }
    , { start = 12, event = Other "Lunch" }
    , { start = 13.5, event = Other "Socialize!" }
    , { start = 14, event = Presentation [] }
    , { start = 14.5, event = Presentation [] }
    , { start = 15, event = Other "Coffee and snacks" }
    , { start = 15.5, event = Presentation [] }
    , { start = 16, event = Presentation [] }
    , { start = 16.5, event = Presentation [] }
    , { start = 17, event = Other "Socialize!" }
    , { start = 18, event = Other "Dinner" }
    , { start = 19.5, event = Other "Boardgames and chat" }
    ]


day30Schedule =
    [ { start = 7, event = Other "Breakfast" }
    , { start = 9, event = Presentation [] }
    , { start = 9.5, event = Presentation [] }
    , { start = 10, event = Other "Checkout of rooms" }
    , { start = 10.5, event = Presentation [] }
    , { start = 11, event = Presentation [] }
    , { start = 11.5, event = Presentation [] }
    , { start = 12, event = Other "Lunch" }
    , { start = 13.5, event = Other "Socialize!" }
    , { start = 14
      , event = Presentation [ { speaker = "", title = "Closing keynote", room = "" } ]
      }
    , { start = 15, event = Other "Socialize!" }
    , { start = 16, event = Other "Departure" }
    ]


offsetEvents day events =
    List.map
        (\{ start, event } -> { start = Duration.addTo day (Duration.hours start), event = event })
        ({ start = 0, event = Other "Early morning" } :: events)


fullSchedule : List { start : Time.Posix, event : Event }
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
            ( List.Extra.last past, future )

        Nothing ->
            ( Nothing, [] )


fontSize : Float -> { width : Int, height : Int } -> Element.Attribute msg
fontSize size window =
    size * toFloat window.width / 1920 |> round |> Element.Font.size


spacing : Float -> { width : Int, height : Int } -> Element.Attribute msg
spacing size window =
    size * toFloat window.width / 1920 |> round |> Element.spacing


padding : Float -> { width : Int, height : Int } -> Element.Attribute msg
padding size window =
    size * toFloat window.width / 1920 |> round |> Element.padding


view : { a | now : Time.Posix, window : { width : Int, height : Int } } -> Element msg
view { now, window } =
    let
        now2 =
            Duration.addTo day29 (Duration.hours 10.1)
    in
    Element.el
        [ Element.width Element.fill, Element.height Element.fill, padding 40 window ]
        (case remainingEvents now2 of
            ( Just current, next :: _ ) ->
                let
                    timeLeft : Int
                    timeLeft =
                        Duration.from now2 next.start |> Duration.inMinutes |> floor |> (+) -5
                in
                Element.column
                    [ Element.width Element.fill, Element.height Element.fill, spacing 40 window ]
                    [ Element.row
                        [ Element.width Element.fill, fontSize 80 window ]
                        [ Element.text "Currently: In-session"
                        , Element.el
                            [ Element.alignRight ]
                            (Element.text (String.fromInt timeLeft ++ "min left"))
                        ]
                    , Element.row
                        [ Element.width Element.fill, Element.height Element.fill, spacing 40 window ]
                        [ currentView window current, nextView window next ]
                    ]

            ( Just current, [] ) ->
                currentView window current

            ( Nothing, _ ) ->
                Element.none
        )


cardBackground : Element.Attr decorative msg
cardBackground =
    Element.Background.color (Element.rgb 0.85 0.85 0.85)


currentView : { width : Int, height : Int } -> EventAndTime -> Element msg
currentView window { start, event } =
    Element.el
        [ Element.width (Element.fillPortion 2)
        , Element.height Element.fill
        ]
        (case event of
            Presentation presentations ->
                List.map
                    (\presentation ->
                        Element.column
                            [ Element.width Element.fill
                            , Element.height Element.fill
                            , cardBackground
                            , padding 20 window
                            ]
                            [ roomText presentation.room window
                            , Element.paragraph [ fontSize 60 window, Element.centerY ] [ Element.text presentation.title ]
                            ]
                    )
                    presentations
                    |> Element.column
                        [ Element.width Element.fill
                        , Element.height Element.fill
                        , spacing 30 window
                        ]

            Other title ->
                Element.paragraph [] [ Element.text title ]
        )


roomText text window =
    Element.el [ fontSize 36 window ] (Element.text text)


nextView : { width : Int, height : Int } -> EventAndTime -> Element msg
nextView window { start, event } =
    case event of
        Presentation presentations ->
            List.map
                (\presentation ->
                    Element.column
                        [ Element.width Element.fill
                        , Element.height Element.fill
                        , padding 20 window
                        , cardBackground
                        ]
                        [ roomText presentation.room window
                        , Element.paragraph [ fontSize 40 window, Element.centerY ] [ Element.text presentation.title ]
                        ]
                )
                presentations
                |> Element.column
                    [ Element.width Element.fill
                    , Element.height Element.fill
                    , spacing 30 window
                    , Element.above (Element.el [ fontSize 30 window ] (Element.text "Up next:"))
                    ]

        Other title ->
            Element.paragraph [] [ Element.text title ]
