module Camp26Czech.Archive exposing (view)

import MarkdownThemed
import Theme
import Types exposing (FrontendMsg, LoadedModel)
import Ui
import Ui.Anim
import Ui.Layout
import Ui.Prose


view : LoadedModel -> Ui.Element FrontendMsg
view model =
    Ui.column
        [ Ui.spacing 40 ]
        [ Ui.column
            -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
            Theme.contentAttributes
            [ content1, unconferenceBulletPoints model ]
        , []
            |> Ui.column [ Ui.spacing 10 ]
        ]


content1 : Ui.Element msg
content1 =
    "# Archive"
        |> MarkdownThemed.renderFull


unconferenceBulletPoints : LoadedModel -> Ui.Element FrontendMsg
unconferenceBulletPoints model =
    []
        |> Ui.column [ Ui.width Ui.shrink, Ui.spacing 15 ]
