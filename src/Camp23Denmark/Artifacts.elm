module Camp23Denmark.Artifacts exposing (view)

import MarkdownThemed


view model =
    """
This page is [open to contributions on Github](https://github.com/elm-camp/website/edit/main/src/Camp23Denmark/Artifacts.elm).


## Posts

- [Elm Camp June 2023 Session Overview](https://discourse.elm-lang.org/t/elm-camp-june-2023-session-overview/9218) by @marcw (Discourse)

## Media

Coming soon!
"""
        |> MarkdownThemed.renderFull
