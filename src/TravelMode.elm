module TravelMode exposing (..)

import Codec exposing (Codec)
import List.Extra as List


type TravelMode
    = Flight
    | Bus
    | Car
    | Train
    | Boat
    | OtherTravelMode


all : List TravelMode
all =
    [ Flight, Bus, Car, Train, Boat, OtherTravelMode ]


toString : TravelMode -> String
toString mode =
    case mode of
        Flight ->
            "Flight"

        Bus ->
            "Bus"

        Car ->
            "Car"

        Train ->
            "Train"

        Boat ->
            "Boat"

        OtherTravelMode ->
            "Other"


codec : Codec TravelMode
codec =
    Codec.andThen
        (\text ->
            case List.find (\mode -> toString mode == text) all of
                Just mode ->
                    Codec.succeed mode

                Nothing ->
                    Codec.fail ("Invalid travel mode: " ++ text)
        )
        toString
        Codec.string
