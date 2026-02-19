module NonNegative exposing (NonNegative, fromInt, increment, one, plus, sum, toInt, toString, zero)


type NonNegative
    = NonNegative Int


fromInt : Int -> Result String NonNegative
fromInt int =
    if int < 0 then
        Err "Can't be negative"

    else
        Ok (NonNegative int)


increment : NonNegative -> NonNegative
increment (NonNegative a) =
    NonNegative (a + 1)


zero : NonNegative
zero =
    NonNegative 0


one : NonNegative
one =
    NonNegative 1


plus : NonNegative -> NonNegative -> NonNegative
plus (NonNegative a) (NonNegative b) =
    a + b |> NonNegative


sum : List NonNegative -> NonNegative
sum list =
    List.foldl plus zero list


toInt : NonNegative -> Int
toInt (NonNegative int) =
    int


toString : NonNegative -> String
toString a =
    toInt a |> String.fromInt
