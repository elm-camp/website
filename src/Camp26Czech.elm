module Camp26Czech exposing
    ( Config
    , header
    , view
    )

import Camp
import Formatting exposing (Formatting(..), Inline(..))
import Helpers
import Route
import Theme
import Types exposing (FrontendMsg, LoadedModel, Size)
import Ui exposing (Element)
import Ui.Font
import Ui.Prose
import View.Logo


type alias Config a =
    { a | window : Size, logoModel : View.Logo.Model }


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


view : Config a -> Element FrontendMsg
view model =
    let
        sidePadding =
            if model.window.width < 800 then
                24

            else
                60
    in
    Ui.column
        []
        [ Ui.column
            [ Ui.spacing 50
            , Ui.paddingWith { left = sidePadding, right = sidePadding, top = 0, bottom = 24 }
            ]
            [ header False model
            , Ui.column
                (Ui.spacing 16 :: Theme.contentAttributes)
                [ Formatting.view model content
                , organisers model.window.width
                ]

            --, Element.column Theme.contentAttributes [ MarkdownThemed.renderFull "# Our sponsors", Camp26Czech.sponsors model.window ]
            --, View.Sales.view model
            ]
        , Theme.footer
        ]


content : List Formatting
content =
    [ Section "Elm Camp 2026 - Olomouc, Czechia"
        [ Paragraph [ Text "Elm Camp returns for its 4th year, this time in Olomouc, Czechia!" ]
        , HorizontalLine
        , Paragraph [ Text "Elm Camp brings an opportunity for Elm makers & tool builders to gather, communicate and collaborate. Our goal is to strengthen and sustain the Elm ecosystem and community. Anyone with an interest in Elm is welcome." ]
        , Paragraph [ Text "Elm Camp is an event geared towards reconnecting in-person and collaborating on the current and future community landscape of the Elm ecosystem that surrounds the Elm core language." ]
        , Paragraph [ Text "Over the last few years, Elm has seen community-driven tools and libraries expanding the potential and utility of the Elm language, stemming from a steady pace of continued commercial and hobbyist adoption." ]
        , Paragraph [ Text "We find great potential for progress and innovation in a creative, focused, in-person gathering. We expect the wider community and practitioners to benefit from this collaborative exploration of our shared problems and goals." ]
        ]
    , Images
        [ [ { source = "/26-park-hotel/image1.jpg"
            , maxWidth = Nothing
            , description = "Ariel view of the hotel"
            , link = Nothing
            }
          ]
        , [ { source = "/26-park-hotel/image3.jpg"
            , maxWidth = Nothing
            , description = "Photo of a conference room in the hotel"
            , link = Nothing
            }
          , { source = "/26-park-hotel/image2.jpg"
            , maxWidth = Nothing
            , description = "Photo of a bed room in the hotel"
            , link = Nothing
            }
          ]
        ]
    , Section
        "The venue and access"
        [ Section
            "The venue"
            [ Paragraph [ Bold "Hotel Prachárna", Text "\nKřelovská 91, 779 00 Olomouc 9\nŘepčín, Česko\nCzechia" ]
            , Paragraph [ ExternalLink "https://www.hotel-pracharna.cz/en/" "https://www.hotel-pracharna.cz/en/" ]
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
        ]
    , Section "Organisers"
        [ Paragraph [ Text "Elm Camp is a community-driven non-profit initiative, organised by enthusiastic members of the Elm community." ]
        ]
    ]


header : Bool -> Config a -> Ui.Element FrontendMsg
header isCompact config =
    let
        titleSize =
            if config.window.width < 800 then
                64

            else
                80

        elmCampTitle =
            Ui.el
                [ Ui.link (Route.encode Nothing Route.HomepageRoute) ]
                (Ui.el
                    [ Ui.width Ui.shrink
                    , Ui.Font.size titleSize
                    , Theme.glow
                    , Ui.paddingXY 0 8
                    , Ui.Font.lineHeight 1.1
                    ]
                    (Ui.text "Elm Camp")
                )

        elmCampNextTopLine =
            Ui.column [ Ui.width Ui.shrink, Ui.spacing 30 ]
                [ Ui.row
                    [ Ui.width Ui.shrink, Ui.centerX, Ui.spacing 13 ]
                    [ Ui.html (View.Logo.view config.logoModel) |> Ui.map Types.LogoMsg
                    , Ui.column
                        [ Ui.width Ui.shrink, Ui.Font.size 24, Ui.contentCenterY ]
                        [ Ui.el [ Ui.width Ui.shrink, Theme.glow, Ui.Font.lineHeight 1 ] (Ui.text "Unconference")
                        , Ui.el
                            [ Ui.width Ui.shrink
                            , Ui.Font.weight 800
                            , Ui.Font.color Theme.lightTheme.elmText
                            , Ui.Font.lineHeight 1
                            ]
                            (Ui.text "2026")
                        ]
                    ]
                , Ui.column
                    [ Ui.width Ui.shrink, Ui.spacing 8, Ui.Font.size 18 ]
                    [ Ui.el
                        [ Ui.width Ui.shrink
                        , Ui.Font.bold
                        , Ui.Font.color Theme.lightTheme.defaultText
                        ]
                        (Ui.text location)
                    , Ui.el
                        [ Ui.width Ui.shrink
                        , Ui.Font.bold
                        , Ui.linkNewTab "https://www.hotel-pracharna.cz/en/"
                        , Ui.Font.color Theme.lightTheme.link
                        , Ui.Font.underline
                        ]
                        (Ui.text "Park Hotel Prachárna")
                    , Ui.el
                        [ Ui.width Ui.shrink, Ui.Font.bold, Ui.Font.color Theme.lightTheme.defaultText ]
                        (Ui.text "Monday 15th - Thursday 18th June 2026")
                    ]
                ]
    in
    if config.window.width < 1000 || isCompact then
        Ui.column
            [ Ui.width Ui.shrink, Ui.paddingXY 8 30, Ui.spacing 20, Ui.centerX ]
            [ Ui.column
                [ Ui.width Ui.shrink, Ui.spacing 24, Ui.centerX ]
                [ elmCampTitle
                , elmCampNextTopLine
                ]
            ]

    else
        Ui.row
            [ Ui.width Ui.shrink, Ui.padding 30, Ui.spacing 40, Ui.centerX ]
            [ Ui.column
                [ Ui.width Ui.shrink, Ui.spacing 24 ]
                [ elmCampTitle
                , elmCampNextTopLine
                ]
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
