module Camp exposing (ArchiveContents, Meta, elmCampBottomLine, elmCampTopLine, viewArchive)

{-| Shared definition for all camp years.
-}

import Formatting exposing (Formatting)
import MarkdownThemed
import Theme
import Ui
import Ui.Anim
import Ui.Font
import Ui.Layout
import Ui.Prose


type alias Meta =
    { logo : { src : String, description : String }
    , tag : String
    , location : String
    , dates : String
    , artifactPicture : { src : String, description : String }
    }


elmCampTopLine : Meta -> Ui.Element msg
elmCampTopLine meta =
    Ui.row
        [ Ui.width Ui.shrink, Ui.centerX, Ui.spacing 13 ]
        [ Ui.image [ Ui.width (Ui.px 49) ] { source = meta.logo.src, description = meta.logo.description, onLoad = Nothing }
        , Ui.column
            [ Ui.width Ui.shrink, Ui.spacing 2, Ui.Font.size 24, Ui.move { x = 0, y = -1, z = 0 } ]
            [ Ui.el [ Ui.width Ui.shrink, Theme.glow ] (Ui.text "Unconference")
            , Ui.el [ Ui.width Ui.shrink, Ui.Font.weight 800, Ui.Font.color Theme.lightTheme.elmText ] (Ui.text meta.tag)
            ]
        ]


elmCampBottomLine : Meta -> Ui.Element msg
elmCampBottomLine meta =
    Ui.column
        [ Ui.width Ui.shrink, Theme.glow, Ui.Font.size 16, Ui.centerX, Ui.spacing 2 ]
        [ Ui.el [ Ui.width Ui.shrink, Ui.Font.bold, Ui.centerX ] (Ui.text meta.dates)
        , Ui.text meta.location
        ]


type alias ArchiveContents msg =
    { conferenceSummary : List Formatting
    , schedule : Maybe (List Formatting)
    , venue : List Formatting
    , organisers : Ui.Element msg
    , sponsors : Ui.Element msg
    , images : List { src : String, description : String }
    }


{-| View an archive page for a past year of Elm Camp.
-}
viewArchive : ArchiveContents msg -> { a | window : { width : Int, height : Int } } -> Ui.Element msg
viewArchive contents config =
    Ui.column
        [ Ui.spacing 40 ]
        [ Ui.column
            Theme.contentAttributes
            [ Formatting.view config contents.conferenceSummary
            ]
        , if config.window.width > 950 then
            contents.images
                |> List.map
                    (\image ->
                        Ui.image
                            [ Ui.width (Ui.px 288) ]
                            { source = image.src, description = image.description, onLoad = Nothing }
                    )
                |> Ui.row [ Ui.wrap, Ui.contentTop, Ui.spacing 10, Ui.width (Ui.px 900), Ui.centerX ]

          else
            groupsOfTwo contents.images
                |> List.map
                    (\row ->
                        Ui.row
                            [ Ui.spacing 10 ]
                            (List.map
                                (\image ->
                                    Ui.image [] { source = image.src, description = image.description, onLoad = Nothing }
                                )
                                row
                            )
                    )
                |> Ui.column [ Ui.spacing 10 ]
        , contents.schedule
            |> Maybe.map
                (\schedule ->
                    Ui.column
                        Theme.contentAttributes
                        [ Formatting.view config schedule
                        ]
                )
            |> Maybe.withDefault Ui.none
        , Ui.column
            Theme.contentAttributes
            [ Formatting.view config contents.venue
            ]
        , Ui.column
            Theme.contentAttributes
            [ MarkdownThemed.renderFull "# Our sponsors"
            , contents.sponsors
            ]
        , Ui.column
            [ Ui.spacing 24
            ]
            [ MarkdownThemed.renderFull "# Organisers"
            , Ui.el
                Theme.contentAttributes
                contents.organisers
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
