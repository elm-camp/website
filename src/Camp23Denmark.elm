module Camp23Denmark exposing (view)

import Camp
import Camp23Denmark.Archive
import Camp23Denmark.Artifacts
import Element exposing (Element)
import Element.Font
import Route exposing (SubPage(..))
import Theme
import Types exposing (FrontendMsg, LoadedModel)

meta : Camp.Meta
meta =
    { logo = { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
    , tag = "Europe 2023"
    , location = "🇩🇰 Dallund Castle, Denmark"
    , dates = "Wed 28th - Fri 30th June"
    , artifactPicture = { src = "/23-denmark/artifacts.png", description = "A suitcase full of artifacts in the middle of a danish forest" }
    }

view : LoadedModel -> SubPage -> Element FrontendMsg
view model subpage =
    Element.column
        [ Element.width Element.fill, Element.height Element.fill ]
        [ Element.column
            (Element.padding 20 :: Theme.contentAttributes ++ [ Element.spacing 50 ])
            [ Theme.rowToColumnWhen 700
                model.window
                [ Element.spacing 30, Element.centerX, Element.Font.center ]
                [ Element.image
                    [ Element.width (Element.px 300) ]
                    { src = "/23-denmark/artifacts.png", description = "A suitcase full of artifacts in the middle of a danish forest" }
                , Element.column [ Element.width Element.fill, Element.spacing 20 ]
                    [ Element.paragraph [ Element.Font.size 50, Element.Font.center ] [ Element.text "Archive" ]
                    , Camp.elmCampTopLine meta
                    , Camp.elmCampBottomLine meta
                    ]
                ]
            , case subpage of
                Home ->
                    Camp23Denmark.Archive.view model

                Artifacts ->
                    Camp23Denmark.Artifacts.view model
            ]
        , Theme.footer
        ]
