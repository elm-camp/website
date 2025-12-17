module Helpers exposing (discordInviteLink, isJust, justs)


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


isJust : Maybe a -> Bool
isJust r =
    case r of
        Just _ ->
            True

        _ ->
            False


discordInviteLink : String
discordInviteLink =
    "https://discord.gg/QeZDXJrN78"
