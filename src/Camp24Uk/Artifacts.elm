module Camp24Uk.Artifacts exposing (view)

import MarkdownThemed


view model =
    """

# Artifacts

This page is [open to contributions on Github](https://github.com/elm-camp/website/edit/main/src/Camp24Uk/Artifacts.elm).

## Posts

- [Notes from Elm Camp 2024](https://martin.janiczek.cz/2024/06/22/notes-from-elm-camp-2024.html) by @janiczek (Blog)
- [Elm Camp 2024 Reflections](https://wolfgangschuster.wordpress.com/2024/06/23/elm-camp-2024-reflections/) by @wolfadex (Blog)
- [Elm Camp 2024](https://jfmengels.net/elm-camp-2024/) by @jfmengels (Blog)

## Media

<img src="/24-colehayes/elm-camp-24-attendees.jpg" width="100%" />

"""
        |> MarkdownThemed.renderFull
