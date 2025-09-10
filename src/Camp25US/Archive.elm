module Camp25US.Archive exposing (view)

import Element exposing (Element)
import MarkdownThemed
import Theme
import Types exposing (FrontendMsg, LoadedModel)


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column
        [ Element.width Element.fill, Element.spacing 40 ]
        [ Element.column
            Theme.contentAttributes
            [ content1, unconferenceBulletPoints model ]
        , []
            |> Element.column [ Element.spacing 10, Element.width Element.fill ]
        ]


content1 : Element msg
content1 =
    "# Archive"
        |> MarkdownThemed.renderFull


unconferenceBulletPoints : LoadedModel -> Element FrontendMsg
unconferenceBulletPoints model =
    []
        |> Element.column [ Element.spacing 15 ]
