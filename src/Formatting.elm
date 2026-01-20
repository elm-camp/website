module Formatting exposing
    ( Formatting(..)
    , Inline(..)
    , Shared
    , h1
    , h2
    , view
    )

import Color exposing (Color)
import Html exposing (Html)
import Html.Attributes
import Html.Lazy
import Route exposing (Route)
import Theme
import Types exposing (Size)
import Ui
import Url


type Formatting
    = Paragraph (List Inline)
    | BulletList (List Inline) (List Formatting)
    | NumberList (List Inline) (List Formatting)
    | LetterList (List Inline) (List Formatting)
    | Group (List Formatting)
    | Section String (List Formatting)
    | Image { source : String, maxWidth : Maybe Int, caption : List Inline }
    | Images (List (List { source : String, maxWidth : Maybe Int, link : Maybe String, description : String }))
    | LegacyMap
    | QuoteBlock (List Inline)
    | HorizontalLine
    | YoutubeVideo String


type Inline
    = Bold String
    | Italic String
    | Link String Route
    | Code String
    | Text String
    | ExternalLink String String
    | Quote String


type alias Shared a =
    { a | window : Size }


view : Shared b -> List Formatting -> Ui.Element msg
view shared list =
    Html.div
        [ Html.Attributes.style "line-height" "1.5", Html.Attributes.style "white-space" "pre-wrap" ]
        (List.map (viewHelper shared []) list)
        |> Ui.html


noMargin : Html.Attribute msg
noMargin =
    Html.Attributes.style "margin" "0"


viewHelper : Shared b -> List String -> Formatting -> Html msg
viewHelper shared depth item =
    case item of
        Paragraph items ->
            Html.p [ noMargin ] (List.map (inlineView shared) items)

        HorizontalLine ->
            Html.hr
                [ Html.Attributes.style "border-color" (Color.toCssString Theme.lightTheme.elmText)
                , Html.Attributes.style "border-style" "solid"
                , noMargin
                ]
                []

        BulletList leading formattings ->
            Html.div
                []
                [ Html.p [ noMargin ] (List.map (inlineView shared) leading)
                , Html.ul
                    [ Html.Attributes.style "padding-left" "20px", noMargin ]
                    (List.map
                        (\item2 -> Html.li [ noMargin ] [ Html.Lazy.lazy3 viewHelper shared depth item2 ])
                        formattings
                    )
                ]

        NumberList leading formattings ->
            Html.div
                []
                [ Html.p [ noMargin ] (List.map (inlineView shared) leading)
                , Html.ol
                    [ Html.Attributes.style "padding-left" "20px", noMargin ]
                    (List.map
                        (\item2 -> Html.li [ noMargin ] [ Html.Lazy.lazy3 viewHelper shared depth item2 ])
                        formattings
                    )
                ]

        LetterList leading formattings ->
            Html.div
                []
                [ Html.p [ noMargin ] (List.map (inlineView shared) leading)
                , Html.ul
                    [ Html.Attributes.type_ "A", Html.Attributes.style "padding-left" "20px", noMargin ]
                    (List.map
                        (\item2 -> Html.li [ noMargin ] [ Html.Lazy.lazy3 viewHelper shared depth item2 ])
                        formattings
                    )
                ]

        Group formattings ->
            Html.div [] (List.map (viewHelper shared depth) formattings)

        Section title formattings ->
            let
                depth2 : List String
                depth2 =
                    title :: depth

                content : List (Html msg)
                content =
                    case formattings of
                        head :: rest ->
                            viewHelper shared depth2 head
                                :: List.map (\item2 -> Html.div [ paddingTop 16 ] [ viewHelper shared depth2 item2 ]) rest

                        [] ->
                            []

                id : String
                id =
                    List.reverse depth2 |> String.join "-" |> Url.percentEncode
            in
            Html.div
                []
                ((case depth of
                    [] ->
                        h1 id shared.window title

                    [ _ ] ->
                        h2 id title

                    _ ->
                        Html.h3
                            [ Html.Attributes.id (Url.percentEncode title)
                            , noMargin
                            ]
                            [ Html.a
                                [ Html.Attributes.href ("#" ++ id)
                                , Html.Attributes.style "text-decoration" "none"
                                , Html.Attributes.style "color" "black"
                                ]
                                [ Html.text title ]
                            ]
                 )
                    :: content
                )

        Image { source, maxWidth, caption } ->
            Html.figure
                [ noMargin ]
                [ Html.img
                    [ Html.Attributes.src source
                    , Html.Attributes.style
                        "max-width"
                        (case maxWidth of
                            Just maxWidth2 ->
                                String.fromInt maxWidth2 ++ "px"

                            Nothing ->
                                "100%"
                        )
                    , Html.Attributes.style "max-height" "500px"
                    , Html.Attributes.style "border-radius" "4px"
                    , noMargin
                    ]
                    []
                , Html.figcaption
                    [ Html.Attributes.style "font-size" "14px"
                    , Html.Attributes.style "padding" "0 8px 0 8px "
                    , noMargin
                    ]
                    (List.map (inlineView shared) caption)
                ]

        Images rows ->
            List.map
                (\row ->
                    let
                        count =
                            toFloat (List.length row)

                        width : String
                        width =
                            "calc(" ++ String.fromFloat (100 / count) ++ "% - " ++ spacing ++ ")"

                        addLink : Maybe String -> Html msg -> Html msg
                        addLink maybeLink content =
                            case maybeLink of
                                Just link ->
                                    Html.a [ Html.Attributes.href link ] [ content ]

                                Nothing ->
                                    content

                        spacing : String
                        spacing =
                            if Theme.isMobile shared.window then
                                "6px"

                            else
                                "10px"
                    in
                    case row of
                        [] ->
                            Html.text ""

                        head :: rest ->
                            addLink
                                head.link
                                (Html.img
                                    ((case head.maxWidth of
                                        Just maxWidth ->
                                            [ Html.Attributes.style "max-width" (String.fromInt maxWidth ++ "px") ]

                                        Nothing ->
                                            []
                                     )
                                        ++ [ Html.Attributes.src head.source
                                           , Html.Attributes.style "border-radius" "4px"
                                           , Html.Attributes.style "width" (String.fromFloat (100 / count) ++ "%")
                                           , Html.Attributes.style "vertical-align" "top"
                                           , Html.Attributes.style "margin" (spacing ++ " 0 0 0")
                                           ]
                                    )
                                    []
                                )
                                :: List.map
                                    (\image ->
                                        addLink
                                            image.link
                                            (Html.img
                                                ((case image.maxWidth of
                                                    Just maxWidth ->
                                                        [ Html.Attributes.style "max-width" (String.fromInt maxWidth ++ "px") ]

                                                    Nothing ->
                                                        []
                                                 )
                                                    ++ [ Html.Attributes.src image.source
                                                       , Html.Attributes.style "border-radius" "4px"
                                                       , Html.Attributes.style "margin" (spacing ++ " 0 0 " ++ spacing)
                                                       , Html.Attributes.style "width" width
                                                       , Html.Attributes.style "vertical-align" "top"
                                                       ]
                                                )
                                                []
                                            )
                                    )
                                    rest
                                |> Html.div []
                )
                rows
                |> Html.div []

        LegacyMap ->
            Html.iframe
                [ Html.Attributes.src "/map.html"
                , Html.Attributes.style "width" "100%"
                , Html.Attributes.style "height" "auto"
                , Html.Attributes.style "aspect-ratio" "21 / 9"
                , Html.Attributes.style "border" "none"
                , noMargin
                ]
                []

        QuoteBlock items ->
            Html.p
                [ Html.Attributes.style "padding-left" "16px"
                , colorAttribute Theme.lightTheme.mutedText
                , Html.Attributes.style "border-left" (Color.toCssString Theme.lightTheme.grey ++ " solid 4px")
                , noMargin
                ]
                (List.map (inlineView shared) items)

        YoutubeVideo url ->
            Html.iframe
                [ Html.Attributes.src url
                , noMargin
                ]
                []


paddingTop : Int -> Html.Attribute msg
paddingTop px =
    Html.Attributes.style "padding-top" (String.fromInt px ++ "px")


h1 : String -> Size -> String -> Html msg
h1 id window title =
    Html.h1
        [ Html.Attributes.id id
        , Html.Attributes.style
            "font-size"
            (if Theme.isMobile window then
                "36px"

             else
                "44px"
            )
        , Html.Attributes.style "line-height" "1.2"
        , Html.Attributes.style "font-weight" "600"
        , Html.Attributes.style "padding" "24px 0 8px 0"
        , noMargin
        ]
        [ Html.a
            [ Html.Attributes.href ("#" ++ id)
            , Html.Attributes.style "text-decoration" "none"
            , colorAttribute Theme.lightTheme.defaultText
            ]
            [ Html.text title ]
        ]


h2 : String -> String -> Html msg
h2 id title =
    Html.h2
        [ Html.Attributes.id id
        , Html.Attributes.style "font-size" "24px"
        , Html.Attributes.style "font-weight" "800"
        , Html.Attributes.style "padding" "4px 0 4px 0"
        , Html.Attributes.style "line-height" "1.3"
        , noMargin
        ]
        [ Html.a
            [ Html.Attributes.href ("#" ++ id)
            , Html.Attributes.style "text-decoration" "none"
            , colorAttribute Theme.lightTheme.elmText
            ]
            [ Html.text title ]
        ]


inlineView : Shared b -> Inline -> Html msg
inlineView shared inline =
    case inline of
        Bold text ->
            Html.b [] [ Html.text text ]

        Italic text ->
            Html.i [] [ Html.text text ]

        Link text url ->
            Html.a
                [ Html.Attributes.href (Route.encode Nothing url)
                , colorAttribute Theme.lightTheme.link
                ]
                [ Html.text text ]

        Code text ->
            Html.code
                [ Html.Attributes.style "border" "1px rgb(210,210,210) solid"
                , Html.Attributes.style "padding" "0 4px 1px 4px"
                , Html.Attributes.style "border-radius" "4px"
                , Html.Attributes.style "font-size" "16px"
                ]
                [ Html.text text
                ]

        Text text ->
            Html.text text

        ExternalLink text url ->
            externalLinkHtml text url

        Quote text ->
            Html.q [] [ Html.text text ]


colorAttribute : Color -> Html.Attribute msg
colorAttribute color =
    Html.Attributes.style "color" (Color.toCssString color)


externalLinkHtml : String -> String -> Html msg
externalLinkHtml text url =
    Html.a
        [ Html.Attributes.href url
        , Html.Attributes.target "_blank"
        , Html.Attributes.rel "noopener noreferrer"
        , colorAttribute Theme.lightTheme.link
        ]
        [ Html.text text
        ]
