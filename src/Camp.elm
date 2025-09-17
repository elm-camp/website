module Camp exposing (Meta, viewArchive)

{-| Shared definition for all camp years.
-}

import Element exposing (Element)
import MarkdownThemed
import Theme

type alias Meta =
    { logo : { src : String, description : String }
    , tag : String
    , location : String
    , dates : String
    , artifactPicture : { src : String, description : String }
    }

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
