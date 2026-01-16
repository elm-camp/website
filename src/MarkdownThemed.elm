module MarkdownThemed exposing (bulletPoint, newThemeRenderFull, renderFull)

import Helpers exposing (justs)
import Html
import Html.Attributes
import Markdown.Block exposing (HeadingLevel, ListItem(..))
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Theme
import Ui
import Ui.Accessibility
import Ui.Anim
import Ui.Font as Font
import Ui.Layout
import Ui.Prose


renderFull : String -> Ui.Element msg
renderFull markdownBody =
    render (renderer Theme.lightTheme) markdownBody


newThemeRenderFull : String -> Ui.Element msg
newThemeRenderFull markdownBody =
    render (renderer Theme.greenTheme) markdownBody


render : Markdown.Renderer.Renderer (Ui.Element msg) -> String -> Ui.Element msg
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
                                    [ Ui.text "Something went wrong rendering this page"
                                    , Ui.text err
                                    ]
                       )
                    |> Ui.column
                        []
           )


bulletPoint : List (Ui.Element msg) -> Ui.Element msg
bulletPoint children =
    Ui.Layout.row { wrap = True, align = ( Ui.Layout.left, Ui.Layout.top ) }
        [ Ui.spacing 5
        , Ui.paddingWith { top = 0, right = 0, bottom = 0, left = 20 }
        ]
        [ Ui.Prose.paragraph
            [ Ui.width Ui.shrink, Ui.alignTop ]
            (Ui.text " • " :: children)
        ]


renderer : Theme.Theme -> Markdown.Renderer.Renderer (Ui.Element msg)
renderer theme =
    { heading = \data -> Ui.row [ Ui.width Ui.shrink ] [ heading theme data ]
    , paragraph = Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.paddingWith { left = 0, right = 0, top = 0, bottom = 20 } ]
    , blockQuote =
        \children ->
            Ui.column
                [ Ui.width Ui.shrink
                , Ui.Font.size 20
                , Ui.Font.italic
                , Ui.borderWith { bottom = 0, left = 4, right = 0, top = 0 }
                , Ui.borderColor theme.grey
                , Ui.Font.color theme.mutedText
                , Ui.padding 10
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
                                        |> Maybe.map (\w -> Ui.width (Ui.fill |> Ui.maximum w))
                                        |> Maybe.withDefault (Ui.width Ui.fill)
                                    , Ui.centerX
                                    ]

                                Nothing ->
                                    [ width_
                                        |> Maybe.andThen String.toInt
                                        |> Maybe.map (\w -> Ui.width (Ui.px w))
                                        |> Maybe.withDefault (Ui.width Ui.fill)
                                    ]
                    in
                    case bg_ of
                        Just _ ->
                            Ui.el
                                [ Ui.width Ui.shrink, Ui.rounded 10, Ui.padding 20 ]
                                (Ui.image
                                    -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
                                    attrs
                                    { src = src, description = "" }
                                )

                        Nothing ->
                            Ui.image
                                -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
                                attrs
                                { src = src, description = "" }
                )
                |> Markdown.Html.withAttribute "src"
                |> Markdown.Html.withOptionalAttribute "width"
                |> Markdown.Html.withOptionalAttribute "maxwidth"
                |> Markdown.Html.withOptionalAttribute "bg"
            , Markdown.Html.tag "iframe"
                (\src ratio title_ content ->
                    Ui.html
                        (Html.div
                            [ Html.Attributes.style "position" "relative"
                            , Html.Attributes.style "width" "100%"
                            , Html.Attributes.style "padding-bottom" ratio
                            , Html.Attributes.style "height" "0"
                            , Html.Attributes.style "overflow" "hidden"
                            ]
                            [ Html.iframe
                                [ Html.Attributes.src src
                                , Html.Attributes.title title_
                                , Html.Attributes.style "position" "absolute"
                                , Html.Attributes.style "top" "0"
                                , Html.Attributes.style "left" "0"
                                , Html.Attributes.style "width" "100%"
                                , Html.Attributes.style "height" "100%"
                                , Html.Attributes.style "border" "0"
                                ]
                                []
                            ]
                        )
                )
                |> Markdown.Html.withAttribute "src"
                |> Markdown.Html.withAttribute "ratio"
                |> Markdown.Html.withAttribute "title"
            , Markdown.Html.tag "br" (\_ -> Ui.html (Html.br [] []))
            , Markdown.Html.tag "red" (\children -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.color Theme.colors.red ] children)
            ]
    , text = \s -> Ui.el [ Ui.width Ui.shrink ] (Ui.text s)
    , codeSpan =
        \content -> Ui.html (Html.code [] [ Html.text content ])
    , strong = \list -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.bold ] list
    , emphasis = \list -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.italic ] list
    , hardLineBreak = Ui.html (Html.br [] [])
    , link =
        \{ title, destination } list ->
            Ui.el
                [ Ui.link destination
                , Font.underline
                , Font.color theme.link
                ]
                (case title of
                    Maybe.Just title_ ->
                        Ui.text title_

                    Maybe.Nothing ->
                        Ui.Prose.paragraph [ Ui.width Ui.shrink ] list
                )
    , image =
        \{ alt, src, title } ->
            let
                attrs =
                    [ title |> Maybe.map (\title_ -> Ui.htmlAttribute (Html.Attributes.attribute "title" title_)) ]
                        |> justs
            in
            Ui.image
                -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
                attrs
                { src = src
                , description = alt
                }
    , unorderedList =
        \items ->
            Ui.column
                [ Ui.spacing 15
                , Ui.paddingWith { top = 0, right = 0, bottom = 40, left = 0 }
                ]
                (items
                    |> List.map
                        (\listItem ->
                            case listItem of
                                ListItem _ children ->
                                    Ui.Layout.row { wrap = True, align = ( Ui.Layout.left, Ui.Layout.top ) }
                                        [ Ui.spacing 5
                                        , Ui.paddingWith { top = 0, right = 0, bottom = 0, left = 20 }
                                        ]
                                        [ Ui.Prose.paragraph
                                            [ Ui.width Ui.shrink, Ui.alignTop ]
                                            (Ui.text " • " :: children)
                                        ]
                        )
                )
    , orderedList =
        \startingIndex items ->
            Ui.column [ Ui.spacing 15 ]
                (items
                    |> List.indexedMap
                        (\index itemBlocks ->
                            Ui.Layout.row { wrap = True, align = ( Ui.Layout.left, Ui.Layout.top ) }
                                [ Ui.spacing 5
                                , Ui.paddingWith { top = 0, right = 0, bottom = 0, left = 20 }
                                ]
                                [ Ui.Prose.paragraph
                                    [ Ui.width Ui.shrink, Ui.alignTop ]
                                    (Ui.text (String.fromInt (startingIndex + index) ++ ". ") :: itemBlocks)
                                ]
                        )
                )
    , codeBlock =
        \{ body } ->
            Ui.column
                [ Ui.Font.family [ Ui.Font.monospace ]
                , Ui.background theme.lightGrey
                , Ui.rounded 5
                , Ui.padding 10
                , Ui.htmlAttribute (Html.Attributes.class "preserve-white-space")
                , Ui.scrollbarX
                ]
                [ Ui.html (Html.text body)
                ]
    , thematicBreak =
        Ui.el
            [ Ui.paddingWith { top = 0, left = 0, right = 0, bottom = 20 } ]
            (Ui.el
                [ Ui.height (Ui.px 2), Ui.background Theme.colors.green ]
                Ui.none
            )
    , table = \children -> Ui.column [] children
    , tableHeader = \children -> Ui.column [ Ui.width Ui.shrink ] children
    , tableBody = \children -> Ui.column [ Ui.width Ui.shrink ] children
    , tableRow = \children -> Ui.row [] children
    , tableCell = \_ children -> Ui.column [] children
    , tableHeaderCell = \_ children -> Ui.column [] children
    , strikethrough = \children -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.strike ] children
    }


heading : Theme.Theme -> { level : HeadingLevel, rawText : String, children : List (Ui.Element msg) } -> Ui.Element msg
heading theme { level, rawText, children } =
    Ui.Prose.paragraph
        -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
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
                [ Ui.Font.size 12
                , Ui.Font.medium
                , Ui.Font.center
                , Ui.paddingXY 0 20
                ]
         )
            ++ [ Ui.Accessibility.heading (Markdown.Block.headingLevelToInt level)
               , Ui.htmlAttribute
                    (Html.Attributes.attribute "name" (rawTextToId rawText))
               , Ui.htmlAttribute
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
