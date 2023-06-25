module LiveSchedule exposing (..)

import Duration
import Element exposing (Element)
import Element.Background
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


view : Time.Posix -> Element msg
view time =
    case remainingEvents (Duration.addTo day29 (Duration.hours 10.1)) of
        ( Just current, next :: _ ) ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ Element.row
                    [ Element.width Element.fill ]
                    [ Element.text "Currently: In-session"
                    , Element.text "4min left"
                    ]
                , Element.row
                    [ Element.width Element.fill ]
                    [ currentView current, nextView next ]
                ]

        ( Just current, [] ) ->
            currentView current

        ( Nothing, _ ) ->
            Element.none


cardBackground : Element.Attr decorative msg
cardBackground =
    Element.Background.color (Element.rgb 0.7 0.7 0.7)


currentView : EventAndTime -> Element msg
currentView { start, event } =
    case event of
        Presentation presentations ->
            List.map
                (\presentation ->
                    Element.column
                        [ Element.height (Element.fillPortion 5), cardBackground ]
                        [ Element.text presentation.room
                        , Element.text presentation.title
                        ]
                )
                presentations
                |> List.intersperse (Element.el [ Element.height Element.fill ] Element.none)
                |> Element.column [ Element.width Element.fill ]

        Other title ->
            Element.paragraph [] [ Element.text title ]


nextView : EventAndTime -> Element msg
nextView { start, event } =
    case event of
        Presentation presentations ->
            List.map
                (\presentation ->
                    Element.column
                        [ Element.height (Element.fillPortion 5), cardBackground ]
                        [ Element.text presentation.room
                        , Element.text presentation.title
                        ]
                )
                presentations
                |> List.intersperse (Element.el [ Element.height Element.fill ] Element.none)
                |> Element.column [ Element.width Element.fill ]

        Other title ->
            Element.paragraph [] [ Element.text title ]
