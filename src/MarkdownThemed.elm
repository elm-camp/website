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
import Ui.Font
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
    Ui.row
        [ Ui.spacing 5
        , Ui.contentTop
        , Ui.wrap
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
                , Ui.paddingWith { left = 10, right = 10, top = 18, bottom = 0 }
                ]
                children
    , html =
        Markdown.Html.oneOf
            [ Markdown.Html.tag "img"
                (\src width_ maxWidth bg_ content ->
                    let
                        attrs =
                            case maxWidth of
                                Just maxWidth2 ->
                                    [ case String.toInt maxWidth2 of
                                        Just maxWidth3 ->
                                            Ui.widthMax maxWidth3

                                        Nothing ->
                                            Ui.noAttr
                                    , Ui.width Ui.fill
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
                                    { source = src, description = "", onLoad = Nothing }
                                )

                        Nothing ->
                            Ui.image
                                -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
                                attrs
                                { source = src, description = "", onLoad = Nothing }
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
    , text = Ui.text
    , codeSpan =
        \content -> Ui.html (Html.code [] [ Html.text content ])
    , strong = \list -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.bold ] list
    , emphasis = \list -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.italic ] list
    , hardLineBreak = Ui.html (Html.br [] [])
    , link =
        \{ title, destination } list ->
            Ui.Prose.paragraph
                [ Ui.link destination
                , Ui.Font.underline
                , Ui.Font.color theme.link
                , Ui.width Ui.shrink
                ]
                (case title of
                    Maybe.Just title_ ->
                        [ Ui.text title_ ]

                    Maybe.Nothing ->
                        list
                )
    , image =
        \{ alt, src, title } ->
            Ui.image
                (case title of
                    Just title2 ->
                        [ Ui.htmlAttribute (Html.Attributes.attribute "title" title2) ]

                    Nothing ->
                        []
                )
                { source = src
                , description = alt
                , onLoad = Nothing
                }
    , unorderedList =
        \items ->
            Ui.column
                [ Ui.spacing 15
                , Ui.paddingWith { top = 0, right = 0, bottom = 40, left = 8 }
                ]
                (List.map
                    (\listItem ->
                        case listItem of
                            ListItem _ children ->
                                Ui.Prose.paragraph
                                    []
                                    (Ui.text " • " :: children)
                    )
                    items
                )
    , orderedList =
        \startingIndex items ->
            Ui.column [ Ui.spacing 15 ]
                (items
                    |> List.indexedMap
                        (\index itemBlocks ->
                            Ui.row
                                [ Ui.wrap
                                , Ui.contentTop
                                , Ui.spacing 5
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
                , Ui.scrollableX
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
        ((case level of
            Markdown.Block.H1 ->
                Theme.heading1Attrs theme

            Markdown.Block.H2 ->
                Theme.heading2Attrs theme

            Markdown.Block.H3 ->
                Theme.heading3Attrs theme

            Markdown.Block.H4 ->
                Theme.heading4Attrs theme

            Markdown.Block.H5 ->
                [ Ui.Font.size 12
                , Ui.Font.weight 500
                , Ui.Font.center
                , Ui.paddingXY 0 20
                , Ui.Accessibility.h5
                ]

            Markdown.Block.H6 ->
                [ Ui.Font.size 12
                , Ui.Font.weight 500
                , Ui.Font.center
                , Ui.paddingXY 0 20
                , Ui.Accessibility.h6
                ]
         )
            ++ [ Ui.htmlAttribute (Html.Attributes.attribute "name" (rawTextToId rawText))
               , Ui.htmlAttribute (Html.Attributes.id (rawTextToId rawText))
               ]
        )
        children


rawTextToId : String -> String
rawTextToId rawText =
    rawText
        |> String.toLower
        |> String.replace " " "-"
        |> String.replace "." ""
