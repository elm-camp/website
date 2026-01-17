module Formatting exposing
    ( Formatting(..)
    , Inline(..)
    , contentWidthMax
    , downloadLink
    , externalLink
    , sidePaddingMobile
    , sidePaddingNotMobile
    , view
    )

import Color exposing (Color)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Html.Lazy
import Json.Decode
import Route exposing (Route)
import Set exposing (Set)
import Theme
import Ui
import Ui.Font
import Url


type Formatting
    = Paragraph (List Inline)
    | BulletList (List Inline) (List Formatting)
    | NumberList (List Inline) (List Formatting)
    | LetterList (List Inline) (List Formatting)
    | Group (List Formatting)
    | Section String (List Formatting)
    | Image String (List Inline)


type Inline
    = Bold String
    | Italic String
    | Link String Route
    | Code String
    | Text String
    | ExternalLink String String
    | Quote String


type alias Shared a =
    { a | window : { width : Int, height : Int } }


view : Shared b -> List Formatting -> Ui.Element msg
view shared list =
    Html.div
        [ Html.Attributes.style "line-height" "1.5", Html.Attributes.style "white-space" "pre-wrap" ]
        (List.map (viewHelper shared 0) list)
        |> Ui.html


contentWidthMax : number
contentWidthMax =
    800


viewHelper : Shared b -> Int -> Formatting -> Html msg
viewHelper shared depth item =
    case item of
        Paragraph items ->
            Html.p [] (List.map (inlineView shared) items)

        BulletList leading formattings ->
            Html.div
                []
                [ Html.p
                    []
                    (List.map (inlineView shared) leading)
                , Html.ul
                    [ Html.Attributes.style "padding-left" "20px" ]
                    (List.map
                        (\item2 -> Html.li [] [ Html.Lazy.lazy3 viewHelper shared depth item2 ])
                        formattings
                    )
                ]

        NumberList leading formattings ->
            Html.div
                []
                [ Html.p
                    []
                    (List.map (inlineView shared) leading)
                , Html.ol
                    [ Html.Attributes.style "padding-left" "20px" ]
                    (List.map
                        (\item2 -> Html.li [] [ Html.Lazy.lazy3 viewHelper shared depth item2 ])
                        formattings
                    )
                ]

        LetterList leading formattings ->
            Html.div
                []
                [ Html.p
                    []
                    (List.map (inlineView shared) leading)
                , Html.ul
                    [ Html.Attributes.type_ "A", Html.Attributes.style "padding-left" "20px" ]
                    (List.map
                        (\item2 -> Html.li [] [ Html.Lazy.lazy3 viewHelper shared depth item2 ])
                        formattings
                    )
                ]

        Group formattings ->
            Html.div [] (List.map (viewHelper shared depth) formattings)

        Section title formattings ->
            let
                content =
                    List.map (viewHelper shared (depth + 1)) formattings

                id =
                    Url.percentEncode title
            in
            case depth of
                0 ->
                    Html.div
                        [ Html.Attributes.style "padding-top" "16px" ]
                        (Html.h1
                            [ Html.Attributes.id id
                            , Html.Attributes.style "size" "36px"
                            , Html.Attributes.style "font-weight" "600"
                            ]
                            [ Html.a
                                [ Html.Attributes.href ("#" ++ id)
                                , Html.Attributes.style "text-decoration" "none"
                                , colorAttribute Theme.lightTheme.defaultText
                                ]
                                [ Html.text title ]
                            ]
                            :: content
                        )

                1 ->
                    Html.div
                        [ Html.Attributes.style "padding-top" "16px" ]
                        (Html.h2
                            [ Html.Attributes.id id
                            , Html.Attributes.style "size" "24px"
                            , Html.Attributes.style "font-weight" "800"
                            ]
                            [ Html.a
                                [ Html.Attributes.href ("#" ++ id)
                                , Html.Attributes.style "text-decoration" "none"
                                , colorAttribute Theme.lightTheme.elmText
                                ]
                                [ Html.text title ]
                            ]
                            :: content
                        )

                _ ->
                    Html.div
                        [ Html.Attributes.style "padding-top" "8px" ]
                        (Html.h3
                            [ Html.Attributes.id (Url.percentEncode title) ]
                            [ Html.a
                                [ Html.Attributes.href ("#" ++ id)
                                , Html.Attributes.style "text-decoration" "none"
                                , Html.Attributes.style "color" "black"
                                ]
                                [ Html.text title ]
                            ]
                            :: content
                        )

        Image url altText ->
            Html.figure
                [ Html.Attributes.style "padding-bottom" "16px", Html.Attributes.style "margin" "0" ]
                [ Html.img
                    [ Html.Attributes.src url
                    , Html.Attributes.style "max-width" "100%"
                    , Html.Attributes.style "max-height" "500px"
                    , Html.Attributes.style "border-radius" "4px"
                    ]
                    []
                , Html.figcaption
                    [ Html.Attributes.style "font-size" "14px"
                    , Html.Attributes.style "padding" "0 8px 0 8px "
                    ]
                    (List.map (inlineView shared) altText)
                ]


sidePaddingMobile : number
sidePaddingMobile =
    8


sidePaddingNotMobile : number
sidePaddingNotMobile =
    16


inlineView : Shared b -> Inline -> Html msg
inlineView shared inline =
    case inline of
        Bold text ->
            Html.b []
                [ Html.text text
                ]

        Italic text ->
            Html.i []
                [ Html.text text
                ]

        Link text url ->
            Html.a
                [ Html.Attributes.href (Route.encode url)
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
        [ Html.Attributes.href ("https://" ++ url)
        , Html.Attributes.target "_blank"
        , Html.Attributes.rel "noopener noreferrer"
        , colorAttribute Theme.lightTheme.link
        ]
        [ Html.text text
        ]


externalLink : Int -> String -> String -> Ui.Element msg
externalLink fontSize text url =
    Ui.row
        [ Ui.linkNewTab ("https://" ++ url)
        , Ui.Font.color (Ui.rgb 20 100 255)
        , Ui.Font.size fontSize
        ]
        [ Ui.text text
        ]


downloadLink : String -> String -> Ui.Element msg
downloadLink text url =
    Html.a
        [ Html.Attributes.href url
        , String.split "/" url
            |> List.reverse
            |> List.head
            |> Maybe.withDefault url
            |> Html.Attributes.download
        ]
        [ Html.text text
        ]
        |> Ui.html
