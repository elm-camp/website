module Camp exposing (Meta, elmCampBottomLine, elmCampTopLine)

{-| Shared definition for all camp years.
-}

import Theme
import Ui
import Ui.Font


type alias Meta =
    { logo : { src : String, description : String }
    , tag : String
    , location : String
    , dates : String
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
