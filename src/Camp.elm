module Camp exposing (ArchiveContents, Meta, elmCampBottomLine, elmCampTopLine, viewArchive)

{-| Shared definition for all camp years.
-}

import Formatting exposing (Formatting)
import Theme
import Ui
import Ui.Font


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
    { venue : List Formatting
    , organisers : List Formatting
    , sponsors : Ui.Element msg
    }


{-| View an archive page for a past year of Elm Camp.
-}
viewArchive : ArchiveContents msg -> { a | window : { width : Int, height : Int } } -> Ui.Element msg
viewArchive contents config =
    Ui.column
        [ Ui.spacing 40 ]
        [ Ui.column
            Theme.contentAttributes
            [ Formatting.view config contents.venue
            ]
        , Ui.column
            Theme.contentAttributes
            [ contents.sponsors
            ]
        , Ui.column
            Theme.contentAttributes
            [ Formatting.view config contents.organisers
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
