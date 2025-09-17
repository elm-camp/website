module Camp exposing (Meta, elmCampTopLine, elmCampBottomLine, ArchiveContents, viewArchive)

{-| Shared definition for all camp years.
-}

import Element exposing (Element)
import Element.Font as Font
import MarkdownThemed
import Theme

type alias Meta =
    { logo : { src : String, description : String }
    , tag : String
    , location : String
    , dates : String
    , artifactPicture : { src : String, description : String }
    }


elmCampTopLine : Meta -> Element msg
elmCampTopLine meta =
    Element.row
        [ Element.centerX, Element.spacing 13 ]
        [ Element.image [ Element.width (Element.px 49) ] meta.logo
        , Element.column
            [ Element.spacing 2, Font.size 24, Element.moveUp 1 ]
            [ Element.el [ Theme.glow ] (Element.text "Unconference")
            , Element.el [ Font.extraBold, Font.color Theme.lightTheme.elmText ] (Element.text meta.tag)
            ]
        ]


elmCampBottomLine : Meta -> Element msg
elmCampBottomLine meta =
    Element.column
        [ Theme.glow, Font.size 16, Element.centerX, Element.spacing 2 ]
        [ Element.el [ Font.bold, Element.centerX ] (Element.text meta.dates)
        , Element.text meta.location
        ]



type alias ArchiveContents msg =
    { conferenceSummary : Element msg
    , organisers : Element msg
    , sponsors : Element msg
    , images : List { src : String, description : String }
    }

viewArchive : ArchiveContents msg -> { a | width : Int } -> Element msg
viewArchive contents window =
    Element.column
        [ Element.width Element.fill, Element.spacing 40 ]
        [ Element.column
            Theme.contentAttributes
            [ contents.conferenceSummary ]
        , if window.width > 950 then
            contents.images
                |> List.map (Element.image [ Element.width (Element.px 288) ])
                |> Element.wrappedRow
                    [ Element.spacing 10, Element.width (Element.px 900), Element.centerX ]

          else
            groupsOfTwo contents.images
                |> List.map
                    (\row ->
                        Element.row
                            [ Element.spacing 10, Element.width Element.fill ]
                            (List.map (Element.image [ Element.width Element.fill ]) row)
                    )
                |> Element.column [ Element.spacing 10, Element.width Element.fill ]
        , Element.column
            Theme.contentAttributes
            [ MarkdownThemed.renderFull "# Our sponsors"
            , contents.sponsors
            ]
        , Element.column
            [ Element.width Element.fill
            , Element.spacing 24
            ]
            [ MarkdownThemed.renderFull "# Organisers"
            , Element.el Theme.contentAttributes contents.organisers
            ]
        ]

groupsOfTwo : List a -> List (List a)
groupsOfTwo list =
    case list of
        x :: y :: rest ->
            [ x, y ] :: groupsOfTwo rest

        [ x ] ->
            [ [ x ] ]

        [] ->
            []
