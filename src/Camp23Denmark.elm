module Camp23Denmark exposing (elmCampDenmarkBottomLine, elmCampDenmarkTopLine, view)

import Camp23Denmark.Archive
import Camp23Denmark.Artifacts
import Element
import Element.Font
import MarkdownThemed
import Route exposing (SubPage(..))
import Theme


view model subpage =
    Element.column
        [ Element.width Element.fill, Element.height Element.fill ]
        [ Element.column
            (Element.padding 20 :: Theme.contentAttributes ++ [ Element.spacing 50 ])
            [ Theme.rowToColumnWhen 700
                model
                [ Element.spacing 30, Element.centerX, Element.Font.center ]
                [ Element.image
                    [ Element.width (Element.px 300) ]
                    { src = "/23-denmark/artifacts.png", description = "A suitcase full of artifacts in the middle of a danish forest" }
                , Element.column [ Element.width Element.fill, Element.spacing 20 ]
                    [ Element.paragraph [ Element.Font.size 50, Element.Font.center ] [ Element.text "Archive" ]
                    , elmCampDenmarkTopLine
                    , elmCampDenmarkBottomLine
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


elmCampDenmarkTopLine =
    Element.row
        [ Element.centerX, Element.spacing 13 ]
        [ Element.image
            [ Element.width (Element.px 49) ]
            { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
        , Element.column
            [ Element.spacing 2, Element.Font.size 24, Element.moveUp 1 ]
            [ Element.el [ Theme.glow ] (Element.text "Unconference")
            , Element.el [ Element.Font.extraBold, Element.Font.color Theme.lightTheme.elmText ] (Element.text "Europe 2023")
            ]
        ]


elmCampDenmarkBottomLine =
    Element.column
        [ Theme.glow, Element.Font.size 16, Element.centerX, Element.spacing 2 ]
        [ Element.el [ Element.Font.bold, Element.centerX ] (Element.text "Wed 28th - Fri 30th June")
        , Element.text "🇩🇰 Dallund Castle, Denmark"
        ]
