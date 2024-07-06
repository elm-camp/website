module Camp24Uk exposing (..)

import Camp24Uk.Archive
import Camp24Uk.Artifacts
import Element
import Element.Font
import MarkdownThemed
import Route exposing (..)
import Theme


meta =
    { logo = { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
    , tag = "Europe 2024"
    , location = "🇬🇧 Colehayes Park, Devon"
    , dates = "Tues 18th — Fri 21st June"
    , artifactPicture = { src = "/24-colehayes/artifacts-mark-skipper.png", description = "A suitcase full of artifacts in the middle of a danish forest" }
    }


view model subpage =
    Element.column
        [ Element.width Element.fill, Element.height Element.fill ]
        [ Element.column
            (Element.padding 20 :: Theme.contentAttributes ++ [ Element.spacing 50 ])
            [ Theme.rowToColumnWhen 700
                model
                [ Element.spacing 30, Element.centerX, Element.Font.center ]
                [ Element.image [ Element.width (Element.px 300) ] meta.artifactPicture
                , Element.column [ Element.width Element.fill, Element.spacing 20 ]
                    [ Element.paragraph [ Element.Font.size 50, Element.Font.center ] [ Element.text "Archive" ]
                    , elmCampDenmarkTopLine
                    , elmCampDenmarkBottomLine
                    ]
                ]
            , case subpage of
                Home ->
                    Camp24Uk.Archive.view model

                Artifacts ->
                    Camp24Uk.Artifacts.view model
            ]
        , Theme.footer
        ]


elmCampDenmarkTopLine =
    Element.row
        [ Element.centerX, Element.spacing 13 ]
        [ Element.image [ Element.width (Element.px 49) ] meta.logo
        , Element.column
            [ Element.spacing 2, Element.Font.size 24, Element.moveUp 1 ]
            [ Element.el [ Theme.glow ] (Element.text "Unconference")
            , Element.el [ Element.Font.extraBold, Element.Font.color Theme.lightTheme.elmText ] (Element.text meta.tag)
            ]
        ]


elmCampDenmarkBottomLine =
    Element.column
        [ Theme.glow, Element.Font.size 16, Element.centerX, Element.spacing 2 ]
        [ Element.el [ Element.Font.bold, Element.centerX ] (Element.text meta.dates)
        , Element.text meta.location
        ]
