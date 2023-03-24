module Route exposing (Route(..), decode, encode)

import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), (<?>))


type Route
    = HomepageRoute
    | AccessibilityRoute
    | CodeOfConductRoute


decode : Url -> Route
decode url =
    Url.Parser.oneOf
        [ Url.Parser.top |> Url.Parser.map HomepageRoute
        , Url.Parser.s "accessibility" |> Url.Parser.map AccessibilityRoute
        , Url.Parser.s "code-of-conduct" |> Url.Parser.map CodeOfConductRoute
        ]
        |> (\a -> Url.Parser.parse a url |> Maybe.withDefault HomepageRoute)


encode : Route -> String
encode route =
    Url.Builder.absolute
        (case route of
            HomepageRoute ->
                []

            AccessibilityRoute ->
                [ "accessibility" ]

            CodeOfConductRoute ->
                [ "code-of-conduct" ]
        )
        []
