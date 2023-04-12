module Countdown exposing (..)


secondsAsText : Int -> String
secondsAsText secondsAgo =
    let
        seconds =
            remainderBy 60 secondsAgo

        minutes =
            remainderBy 60 ((secondsAgo - seconds) // 60)

        hours =
            (secondsAgo - seconds - (minutes * 60)) // 3600

        padZero i =
            if i >= 0 && i < 10 then
                "0" ++ String.fromInt i

            else
                String.fromInt i

        parts =
            [ -- padZero seconds ++ "s"
              if hours == 0 && minutes == 0 then
                ""

              else
                String.fromInt minutes
            , if hours == 0 then
                ""

              else
                String.fromInt hours
            ]
                |> List.filter (\a -> a /= "")

        partsString =
            List.map2 Tuple.pair parts [ "m ", "h " ]
                |> List.map (\( a, b ) -> a ++ b)
                |> List.reverse
    in
    String.concat partsString
