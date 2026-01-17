module Camp26Czech exposing
    ( conferenceSummary
    , elmBottomLine
    , elmTopLine
    , location
    , meta
    , organisers
    , sponsors
    , venueAccessContent
    , venueImage
    , venuePictures
    , view
    )

import Camp
import Camp26Czech.Archive
import Camp26Czech.Artifacts
import Formatting exposing (Formatting(..), Inline(..))
import Helpers
import Html
import Html.Attributes
import MarkdownThemed
import Route exposing (SubPage(..))
import Theme
import Types exposing (FrontendMsg, LoadedModel)
import Ui
import Ui.Anim
import Ui.Font
import Ui.Layout
import Ui.Prose


meta : Camp.Meta
meta =
    { logo = { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
    , tag = "Michigan, US 2026"
    , location = location
    , dates = "Mon 15th - Thur 18th June 2026"
    , artifactPicture = { src = "/24-colehayes/artifacts-mark-skipper.png", description = "A watercolour of an old tree in an English stately garden" }
    }


location : String
location =
    "🇨🇿 Olomouc, Czechia"


view : LoadedModel -> SubPage -> Ui.Element FrontendMsg
view model subpage =
    Ui.column
        [ Ui.height Ui.fill ]
        [ Ui.column
            -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
            (Ui.padding 20 :: Theme.contentAttributes ++ [ Ui.spacing 50 ])
            [ Theme.rowToColumnWhen 700
                model.window
                [ Ui.spacing 30, Ui.centerX, Ui.Font.center ]
                [ Ui.image
                    [ Ui.width (Ui.px 300) ]
                    { source = meta.artifactPicture.src, description = meta.artifactPicture.description, onLoad = Nothing }
                , Ui.column [ Ui.spacing 20 ]
                    [ Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.size 50, Ui.Font.center ] [ Ui.text "Archive" ]
                    , elmTopLine
                    , elmBottomLine
                    ]
                ]
            , case subpage of
                Home ->
                    Camp26Czech.Archive.view model

                Artifacts ->
                    Camp26Czech.Artifacts.view model
            ]
        , Theme.footer
        ]


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


conferenceSummary : Ui.Element msg
conferenceSummary =
    """

# The Unconference

## Ronora Lodge and Retreat Center - Watervliet, Michigan
### Arrive anytime on Tues 24th June 2026
### Depart 10am on Fri 27th June 2026
#### 2 full days of talks
#### 40+ attendees

---
## Prospective Schedule:

### Tue 24th June
  - 3pm arrivals & halls officially open
  - Opening of session board
  - Informal dinner
  - Evening stroll

### Wed 25th June
  - Breakfast
  - Unconference sessions
  - Lunch
  - Unconference sessions
  - Dinner
  - Board Games and informal chats

### Thu 26th June
  - Breakfast
  - Unconference sessions
  - Lunch
  - Unconference Sessions
  - Dinner
  - Unconference wrap-up & party

### Fri 27th June
  - Grab and go breakfast
  - Depart by 10am

"""
        |> MarkdownThemed.renderFull


venuePictures : LoadedModel -> Ui.Element msg
venuePictures model =
    let
        prefix =
            "/26-park-hotel/"
    in
    [ [ "image1.jpg" ]
    , [ "image3.jpg", "image2.jpg" ]
    ]
        |> List.map
            (\paths ->
                Ui.row
                    [ Ui.spacing 10 ]
                    (List.map (\image -> venueImage Ui.fill (prefix ++ image)) paths)
            )
        |> Ui.column [ Ui.spacing 10 ]


venueImage : Ui.Length -> String -> Ui.Element msg
venueImage width path =
    Ui.image [ Ui.width width ] { source = path, description = "Photo of Park Hotel", onLoad = Nothing }


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
            , Paragraph [ ExternalLink "https://www.hotel-pracharna.cz/" "https://www.hotel-pracharna.cz/" ]
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
    ]



--"""
--    ++ contactDetails
--    |> MarkdownThemed.renderFull
--
----
----, Html.iframe
----    [ Html.Attributes.src "/map.html"
----    , Html.Attributes.style "width" "100%"
----    , Html.Attributes.style "height" "auto"
----    , Html.Attributes.style "aspect-ratio" "21 / 9"
----    , Html.Attributes.style "border" "none"
----    ]
----    []
----    |> Element.html
--]"""


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
