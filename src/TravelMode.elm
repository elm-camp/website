module TravelMode exposing (..)


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
