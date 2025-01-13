module Camp25US.Archive exposing (view)

import Browser exposing (UrlRequest(..))
import Element exposing (Element)
import Element.Background
import Element.Border
import MarkdownThemed
import Route exposing (Route(..), SubPage(..))
import Theme
import Types exposing (..)


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


unconferenceBulletPoints : LoadedModel -> Element FrontendMsg_
unconferenceBulletPoints model =
    []
        |> List.map (\point -> MarkdownThemed.bulletPoint [ point ])
        |> Element.column [ Element.spacing 15 ]
