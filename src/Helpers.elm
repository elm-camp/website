module Helpers exposing (isJust, justs)


justs : List (Maybe a) -> List a
justs =
    List.foldl
        (\v acc ->
            case v of
                Just el ->
                    el :: acc

                Nothing ->
                    acc
        )
        []


isJust r =
    case r of
        Just _ ->
            True

        _ ->
            False
