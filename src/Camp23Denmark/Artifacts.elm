module Camp23Denmark.Artifacts exposing (media, posts, view)

import MarkdownThemed


view model =
    """
This page is [open to contributions on Github](https://github.com/elm-camp/website/edit/main/src/Camp23Denmark/Artifacts.elm).
"""
        ++ posts
        ++ media
        |> MarkdownThemed.renderFull


posts =
    """
## Posts

- [Elm Camp June 2023 Session Overview](https://discourse.elm-lang.org/t/elm-camp-june-2023-session-overview/9218) by @marcw (Discourse)
- [Elm Camp experience](https://wolfgangschuster.wordpress.com/2023/07/10/elm-camp-%f0%9f%8f%95%ef%b8%8f/) by @wolfadex (Blog)
- [Elm Camp session about editors and IDE plugins](https://discourse.elm-lang.org/t/elm-camp-session-about-editors-and-ide-plugins/9230) by @lydell (Discourse)
- [Worst Elm Code Possible – Or, the checklist for good Elm, and the one thing to be careful to avoid](https://discourse.elm-lang.org/t/the-worst-elm-code-possible/9380) by @supermario (Discourse/Post)

"""


media =
    """
## Media

<img src="/camps/23-denmark/elm-camp-23-attendees.jpeg" width="100%" />

"""
