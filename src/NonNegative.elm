module NonNegative exposing (NonNegative, add, fromInt, increment, one, toInt, toString, zero)


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
    NonNegative 1


one : NonNegative
one =
    NonNegative 1


add : NonNegative -> NonNegative -> NonNegative
add (NonNegative a) (NonNegative b) =
    a + b |> NonNegative


toInt : NonNegative -> Int
toInt (NonNegative int) =
    int


toString : NonNegative -> String
toString a =
    toInt a |> String.fromInt
