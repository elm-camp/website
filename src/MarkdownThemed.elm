module MarkdownThemed exposing (bulletPoint, renderFull)

import Element exposing (..)
import Element.Background
import Element.Border
import Element.Font as Font
import Element.Region
import Helpers exposing (justs)
import Html
import Html.Attributes
import Markdown.Block exposing (HeadingLevel, ListItem(..))
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Theme


renderFull : String -> Element msg
renderFull markdownBody =
    render (renderer Theme.lightTheme) markdownBody


render : Markdown.Renderer.Renderer (Element msg) -> String -> Element msg
render chosenRenderer markdownBody =
    Markdown.Parser.parse markdownBody
        -- @TODO show markdown parsing errors, i.e. malformed html?
        |> Result.withDefault []
        |> (\parsed ->
                parsed
                    |> Markdown.Renderer.render chosenRenderer
                    |> (\res ->
                            case res of
                                Ok elements ->
                                    elements

                                Err err ->
                                    [ Element.text "Something went wrong rendering this page"
                                    , Element.text err
                                    ]
                       )
                    |> Element.column
                        [ Element.width Element.fill
                        ]
           )


bulletPoint : List (Element msg) -> Element msg
bulletPoint children =
    Element.wrappedRow
        [ Element.spacing 5
        , Element.paddingEach { top = 0, right = 0, bottom = 0, left = 20 }
        , Element.width Element.fill
        ]
        [ Element.paragraph
            [ Element.alignTop ]
            (Element.text " • " :: children)
        ]


renderer : Theme.Theme -> Markdown.Renderer.Renderer (Element msg)
renderer theme =
    { heading = \data -> Element.row [] [ heading theme data ]
    , paragraph = Element.paragraph [ Element.paddingEach { left = 0, right = 0, top = 0, bottom = 20 } ]
    , blockQuote =
        \children ->
            Element.column
                [ Font.size 20
                , Font.italic
                , Element.Border.widthEach { bottom = 0, left = 4, right = 0, top = 0 }
                , Element.Border.color theme.grey
                , Font.color theme.mutedText
                , Element.padding 10
                ]
                children
    , html =
        Markdown.Html.oneOf
            [ Markdown.Html.tag "img"
                (\src width_ maxWidth_ bg_ content ->
                    let
                        attrs =
                            case maxWidth_ of
                                Just maxWidth ->
                                    [ maxWidth
                                        |> String.toInt
                                        |> Maybe.map (\w -> width (fill |> maximum w))
                                        |> Maybe.withDefault (width fill)
                                    , centerX
                                    ]

                                Nothing ->
                                    [ width_
                                        |> Maybe.andThen String.toInt
                                        |> Maybe.map (\w -> width (px w))
                                        |> Maybe.withDefault (width fill)
                                    ]
                    in
                    case bg_ of
                        Just bg ->
                            el [ Element.Border.rounded 10, padding 20 ] <| image attrs { src = src, description = "" }

                        Nothing ->
                            image attrs { src = src, description = "" }
                )
                |> Markdown.Html.withAttribute "src"
                |> Markdown.Html.withOptionalAttribute "width"
                |> Markdown.Html.withOptionalAttribute "maxwidth"
                |> Markdown.Html.withOptionalAttribute "bg"
            , Markdown.Html.tag "br" (\_ -> html <| Html.br [] [])
            , Markdown.Html.tag "red" (\children -> paragraph [ Font.color Theme.colors.red ] children)
            ]
    , text = \s -> Element.el [] (Element.text s)
    , codeSpan =
        \content -> Element.html (Html.code [] [ Html.text content ])
    , strong = \list -> Element.paragraph [ Font.bold ] list
    , emphasis = \list -> Element.paragraph [ Font.italic ] list
    , hardLineBreak = Element.html (Html.br [] [])
    , link =
        \{ title, destination } list ->
            Element.link
                [ Font.underline
                , Font.color theme.link
                ]
                { url = destination
                , label =
                    case title of
                        Just title_ ->
                            Element.text title_

                        Nothing ->
                            Element.paragraph [] list
                }
    , image =
        \{ alt, src, title } ->
            let
                attrs =
                    [ title |> Maybe.map (\title_ -> Element.htmlAttribute (Html.Attributes.attribute "title" title_)) ]
                        |> justs
            in
            Element.image
                attrs
                { src = src
                , description = alt
                }
    , unorderedList =
        \items ->
            Element.column
                [ Element.spacing 15
                , Element.width Element.fill
                , Element.paddingEach { top = 0, right = 0, bottom = 40, left = 0 }
                ]
                (items
                    |> List.map
                        (\listItem ->
                            case listItem of
                                ListItem _ children ->
                                    Element.wrappedRow
                                        [ Element.spacing 5
                                        , Element.paddingEach { top = 0, right = 0, bottom = 0, left = 20 }
                                        , Element.width Element.fill
                                        ]
                                        [ Element.paragraph
                                            [ Element.alignTop ]
                                            (Element.text " • " :: children)
                                        ]
                        )
                )
    , orderedList =
        \startingIndex items ->
            Element.column [ Element.spacing 15, Element.width Element.fill ]
                (items
                    |> List.indexedMap
                        (\index itemBlocks ->
                            Element.wrappedRow
                                [ Element.spacing 5
                                , Element.paddingEach { top = 0, right = 0, bottom = 0, left = 20 }
                                , Element.width Element.fill
                                ]
                                [ Element.paragraph
                                    [ Element.alignTop ]
                                    (Element.text (String.fromInt (startingIndex + index) ++ ". ") :: itemBlocks)
                                ]
                        )
                )
    , codeBlock =
        \{ body } ->
            Element.column
                [ Font.family [ Font.monospace ]
                , Element.Background.color theme.lightGrey
                , Element.Border.rounded 5
                , Element.padding 10
                , Element.width Element.fill
                , Element.htmlAttribute (Html.Attributes.class "preserve-white-space")
                , Element.scrollbarX
                ]
                [ Element.html (Html.text body)
                ]
    , thematicBreak = Element.none
    , table = \children -> Element.column [ Element.width Element.fill ] children
    , tableHeader = \children -> Element.column [] children
    , tableBody = \children -> Element.column [] children
    , tableRow = \children -> Element.row [ Element.width Element.fill ] children
    , tableCell = \_ children -> Element.column [ Element.width Element.fill ] children
    , tableHeaderCell = \_ children -> Element.column [ Element.width Element.fill ] children
    , strikethrough = \children -> Element.paragraph [ Font.strike ] children
    }


heading : Theme.Theme -> { level : HeadingLevel, rawText : String, children : List (Element msg) } -> Element msg
heading theme { level, rawText, children } =
    Element.paragraph
        ((case Markdown.Block.headingLevelToInt level of
            1 ->
                Theme.heading1Attrs theme

            2 ->
                Theme.heading2Attrs theme

            3 ->
                Theme.heading3Attrs theme

            4 ->
                Theme.heading4Attrs theme

            _ ->
                [ Font.size 12
                , Font.medium
                , Font.center
                , Element.paddingXY 0 20
                ]
         )
            ++ [ Element.Region.heading (Markdown.Block.headingLevelToInt level)
               , Element.htmlAttribute
                    (Html.Attributes.attribute "name" (rawTextToId rawText))
               , Element.htmlAttribute
                    (Html.Attributes.id (rawTextToId rawText))
               ]
        )
        children


rawTextToId : String -> String
rawTextToId rawText =
    rawText
        |> String.toLower
        |> String.replace " " "-"
        |> String.replace "." ""
