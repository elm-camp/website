module Archive exposing (content)

import Formatting exposing (Formatting(..), Inline(..))
import Route


content : List Formatting
content =
    [ Section "Archive"
        [ Paragraph
            [ Text "Here we keep track of what has come out of past Elm Camp events. Feel free to add stuff, this page is "
            , ExternalLink "open to contributions on Github" "https://github.com/elm-camp/website/edit/main/src/Archive.elm"
            ]
        , Section "Elm Camp 2025"
            [ BulletList
                [ Bold "Posts" ]
                [ Paragraph [ ExternalLink "Elm Camp 2025" "https://jaredmsmith.com/dev/elm-camp-2025", Text " by @absynce (Blog)" ] ]
            , BulletList
                [ Bold "Podcasts" ]
                [ Paragraph [ ExternalLink "Elm Town 85" "https://elm.town/episodes/elm-town-85-wander-elm-camp-2025" ] ]
            , BulletList
                [ Bold "Media" ]
                [ Paragraph [ ExternalLink "Photos taken during the event" "https://drive.google.com/drive/folders/1pEXG2UULRSUkYSYA7olhx6iREJ1veJHY" ] ]
            , Paragraph [ Link "Click here" Route.Camp25US, Text " to view the 2025 website" ]
            ]
        , Section "Elm Camp 2024"
            [ Image { source = "/24-colehayes/elm-camp-24-attendees.jpg", maxWidth = Nothing, caption = [] }
            , BulletList
                [ Bold "Posts" ]
                [ Paragraph [ ExternalLink "Notes from Elm Camp 2024" "https://martin.janiczek.cz/2024/06/22/notes-from-elm-camp-2024.html", Text " by @janiczek (Blog)" ]
                , Paragraph [ ExternalLink "Elm Camp 2024 Reflections" "https://wolfgangschuster.wordpress.com/2024/06/23/elm-camp-2024-reflections/", Text "  by @wolfadex (Blog)" ]
                , Paragraph [ ExternalLink "Elm Camp 2024" "https://jfmengels.net/elm-camp-2024/", Text " by @jfmengels (Blog)" ]
                ]
            , BulletList
                [ Bold "Podcasts" ]
                [ Paragraph [ ExternalLink "Elm Town 78: Elm Camp 2024 with Katja Mordaunt and Wolfgang Schuster" "https://elm.town/episodes/elm-town-78-elm-camp-2024-with-katja-mordaunt-and-wolfgang-schuster" ]
                ]
            , Paragraph [ Bold "Media" ]
            , YoutubeVideo "https://www.youtube.com/embed/cBXrfI2bxnA?si=qw0ozEtDVWnRFglk"
            , Paragraph [ Link "Click here" Route.Camp24Uk, Text " to view the 2024 website" ]
            ]
        , HorizontalLine
        , Section "Elm Camp 2023"
            [ Image
                { source = "/23-denmark/elm-camp-23-attendees.jpeg"
                , maxWidth = Nothing
                , caption = [ Text "Denmark attendees standing in the courtyard" ]
                }
            , BulletList
                [ Bold "Posts" ]
                [ Paragraph
                    [ ExternalLink "Elm Camp June 2023 Session Overview" "https://discourse.elm-lang.org/t/elm-camp-june-2023-session-overview/9218"
                    , Text " by @marcw (Discourse)"
                    ]
                , Paragraph
                    [ ExternalLink "Elm Camp experience" "https://wolfgangschuster.wordpress.com/2023/07/10/elm-camp-%f0%9f%8f%95%ef%b8%8f/"
                    , Text " by @wolfadex (Blog)"
                    ]
                , Paragraph
                    [ ExternalLink "Elm Camp session about editors and IDE plugins" "https://discourse.elm-lang.org/t/elm-camp-session-about-editors-and-ide-plugins/9230"
                    , Text " by @lydell (Discourse)"
                    ]
                , Paragraph
                    [ ExternalLink "Worst Elm Code Possible – Or, the checklist for good Elm, and the one thing to be careful to avoid" "https://discourse.elm-lang.org/t/the-worst-elm-code-possible/9380"
                    , Text " by @supermario (Discourse/Post)"
                    ]
                ]
            , Paragraph [ Link "Click here" Route.Camp23Denmark, Text " to view the 2023 website" ]
            ]
        ]
    ]
