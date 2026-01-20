module Camp26Czech exposing
    ( elmBottomLine
    , elmTopLine
    , location
    , meta
    , organisers
    , sponsors
    , venueAccessContent
    )

import Camp
import Formatting exposing (Formatting(..), Inline(..))
import Helpers
import Theme
import Types exposing (FrontendMsg, LoadedModel)
import Ui
import Ui.Font
import Ui.Prose


meta : Camp.Meta
meta =
    { logo = { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
    , tag = "Michigan, US 2026"
    , location = location
    , dates = "Mon 15th - Thur 18th June 2026"
    }


location : String
location =
    "🇨🇿 Olomouc, Czechia"


elmTopLine : Ui.Element msg
elmTopLine =
    Ui.row
        [ Ui.width Ui.shrink, Ui.centerX, Ui.spacing 13 ]
        [ Ui.image [ Ui.width (Ui.px 49) ] { source = meta.logo.src, description = meta.logo.description, onLoad = Nothing }
        , Ui.column
            [ Ui.width Ui.shrink, Ui.spacing 2, Ui.Font.size 24, Ui.move { x = 0, y = -1, z = 0 } ]
            [ Ui.el [ Ui.width Ui.shrink, Theme.glow ] (Ui.text "Unconference")
            , Ui.el [ Ui.width Ui.shrink, Ui.Font.weight 800, Ui.Font.color Theme.lightTheme.elmText ] (Ui.text meta.tag)
            ]
        ]


elmBottomLine : Ui.Element msg
elmBottomLine =
    Ui.column
        [ Ui.width Ui.shrink, Theme.glow, Ui.Font.size 16, Ui.centerX, Ui.spacing 2 ]
        [ Ui.el [ Ui.width Ui.shrink, Ui.Font.bold, Ui.centerX ] (Ui.text meta.dates)
        , Ui.text meta.location
        ]


organisers : Int -> Ui.Element msg
organisers windowWidth =
    [ [ { country = "🇧🇪", name = "Hayleigh Thompson", description = "Competitive person-helper in the Elm Slack. Author of Lustre, an Elm port written in Gleam." }
      , { country = "🇺🇸", name = "James Carlson", description = "Worked for many years as a math professor. Trying to learn type theory, which combines philosophy, logic, mathematics, and functional programming." }
      , { country = "🇩🇪", name = "Johannes Emerich", description = "Works at Dividat, making a console with small games and a large controller. Remembers when Elm demos were about the intricacies of how high Super Mario jumps." }
      , { country = "🇺🇸", name = "John Pavlick", description = "Professional combinator enthusiast at AppyPeople. Mostly harmless." }
      , { country = "🇬🇧", name = "Katja Mordaunt", description = "Uses web tech to help charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of codereading.club" }
      ]
    , [ { country = "🇦🇺", name = "Mario Rogic", description = "Organizer of the Elm London and Elm Online meetups. Groundskeeper of Elmcraft, founder of Lamdera." }
      , { country = "🇨🇿", name = "Martin Janiczek", description = "Loves to start things and one-off experiments, has a drive for teaching and unblocking others. Regularly races for the first answer in Elm Slack #beginners and #help." }
      , { country = "🇸🇪", name = "Martin Stewart", description = "Likes making games and apps using Lamdera. Currently trying to recreate Discord in Elm." }
      , { country = "🇺🇸", name = "Wolfgang Schuster", description = "Author of Elm Weekly." }
      , { country = "🇨🇿", name = "Tomáš Látal", description = "Author of elm-debug-helper and several unfinished projects. Don’t ask him about Elm or Coderetreat, he will be talking about it for hours." }
      ]
    ]
        |> (\list2 ->
                if windowWidth < 1000 then
                    [ List.concat list2 ]

                else
                    list2
           )
        |> List.map
            (\column ->
                List.map
                    (\person ->
                        Ui.column
                            [ Ui.width Ui.shrink, Ui.spacing 4 ]
                            [ Ui.row
                                [ Ui.width Ui.shrink, Ui.spacing 8 ]
                                [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 32 ] (Ui.text person.country)
                                , Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.Font.color Theme.greenTheme.elmText ] [ Ui.text person.name ]
                                ]
                            , Ui.Prose.paragraph [ Ui.width Ui.shrink ] [ Ui.text person.description ]
                            ]
                    )
                    column
                    |> Ui.column [ Ui.alignTop, Ui.spacing 24 ]
            )
        |> Ui.row [ Ui.width Ui.shrink, Ui.spacing 32 ]


venueAccessContent : List Formatting
venueAccessContent =
    [ Section
        "The venue and access"
        [ Section
            "The venue"
            [ Paragraph [ Bold "Hotel Prachárna", Text "\nKřelovská 91, 779 00 Olomouc 9\nŘepčín, Česko\nCzechia" ]
            ]
        , Section
            "Participating in conversations"
            [ BulletList
                []
                [ Paragraph [ Text "The official conference language will be English. We ask that attendees conduct as much of their conversations in English in order to include as many people as possible" ]
                , Paragraph [ Text "We do not have facility for captioning or signing, please get in touch as soon as possible if you would benefit from something like that and we'll see what we can do" ]
                , Paragraph [ Text "We aim to provide frequent breaks of a decent length, so if this feels lacking to you at any time, let an organiser know" ]
                ]
            ]
        , Section
            "Contacting the organisers"
            [ BulletList
                [ Text "If you have questions or concerns about this website or attending Elm Camp, please get in touch" ]
                [ Paragraph
                    [ Text "Elmcraft Discord: "
                    , ExternalLink "#elm-camp-26" Helpers.discordInviteLink
                    , Text " channel or DM katjam_"
                    ]
                , Paragraph
                    [ Text "Email: "
                    , ExternalLink "team@elm.camp" "mailto:team@elm.camp)"
                    ]
                , Paragraph [ Text "Elm Slack: @katjam" ]
                ]
            ]
        , Paragraph [ ExternalLink "https://www.hotel-pracharna.cz/en/" "https://www.hotel-pracharna.cz/en/" ]
        ]
    ]


sponsors : { window | width : Int } -> Ui.Element msg
sponsors window =
    let
        asImg { image, url, width } =
            Ui.el
                [ Ui.linkNewTab url, Ui.width Ui.fill ]
                (Ui.image
                    [ Ui.width
                        (Ui.px
                            (if window.width < 800 then
                                Basics.toFloat width * 0.7 |> Basics.round

                             else
                                width
                            )
                        )
                    ]
                    { description = url, source = "/sponsors/" ++ image, onLoad = Nothing }
                )
    in
    Ui.column [ Ui.width Ui.shrink, Ui.centerX, Ui.spacing 32 ]
        [ [ asImg { image = "noredink-logo.svg", url = "https://www.noredink.com/", width = 220 }
          , asImg { image = "concentrichealthlogo.svg", url = "https://concentric.health", width = 235 }
          ]
            |> Ui.row [ Ui.contentTop, Ui.wrap, Ui.width Ui.shrink, Ui.centerX, Ui.spacing 32 ]
        , [ asImg { image = "lamdera-logo-black.svg", url = "https://lamdera.com/", width = 120 }
          , asImg { image = "scripta.io.svg", url = "https://scripta.io", width = 120 }
          , Ui.el
                [ Ui.linkNewTab "https://www.elmweekly.nl", Ui.width Ui.fill ]
                (Ui.row [ Ui.spacing 10, Ui.width (Ui.px 180) ]
                    [ Ui.image
                        [ Ui.width
                            (Ui.px
                                (if window.width < 800 then
                                    50 * 0.7 |> Basics.round

                                 else
                                    50
                                )
                            )
                        ]
                        { description = "https://www.elmweekly.nl"
                        , source = "/sponsors/" ++ "elm-weekly.svg"
                        , onLoad = Nothing
                        }
                    , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 24 ] (Ui.text "Elm Weekly")
                    ]
                )
          ]
            |> Ui.row [ Ui.wrap, Ui.contentTop, Ui.width Ui.shrink, Ui.centerX, Ui.spacing 32 ]
        ]
