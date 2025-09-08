module Camp24Uk.Artifacts exposing (view)

import Element exposing (Element)
import MarkdownThemed


view : a -> Element msg
view model =
    """

# Artifacts

This page is [open to contributions on Github](https://github.com/elm-camp/website/edit/main/src/Camp24Uk/Artifacts.elm).

## Posts

- [Notes from Elm Camp 2024](https://martin.janiczek.cz/2024/06/22/notes-from-elm-camp-2024.html) by @janiczek (Blog)
- [Elm Camp 2024 Reflections](https://wolfgangschuster.wordpress.com/2024/06/23/elm-camp-2024-reflections/) by @wolfadex (Blog)
- [Elm Camp 2024](https://jfmengels.net/elm-camp-2024/) by @jfmengels (Blog)

## Podcasts

- [Elm Town 78: Elm Camp 2024 with Katja Mordaunt and Wolfgang Schuster](https://elm.town/episodes/elm-town-78-elm-camp-2024-with-katja-mordaunt-and-wolfgang-schuster)

## Media

<img src="/24-colehayes/elm-camp-24-attendees.jpg" width="100%" />

<br/>

<iframe ratio="56.25%" src="https://www.youtube.com/embed/cBXrfI2bxnA?si=qw0ozEtDVWnRFglk" title="Elm Camp 2024 - YouTube video player"></iframe>

<br/>

([watch on Youtube for the nice HD version](https://www.youtube.com/embed/cBXrfI2bxnA?si=qw0ozEtDVWnRFglk&vq=hd1080))

"""
        |> MarkdownThemed.renderFull
