module Camp26Czech exposing
    ( conferenceSummary
    , contactDetails
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
import Element exposing (Element, Length)
import Element.Font as Font
import Helpers
import Html
import Html.Attributes
import MarkdownThemed
import Route exposing (SubPage(..))
import Theme
import Types exposing (FrontendMsg, LoadedModel)


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


view : LoadedModel -> SubPage -> Element FrontendMsg
view model subpage =
    Element.column
        [ Element.width Element.fill, Element.height Element.fill ]
        [ Element.column
            (Element.padding 20 :: Theme.contentAttributes ++ [ Element.spacing 50 ])
            [ Theme.rowToColumnWhen 700
                model.window
                [ Element.spacing 30, Element.centerX, Font.center ]
                [ Element.image [ Element.width (Element.px 300) ] meta.artifactPicture
                , Element.column [ Element.width Element.fill, Element.spacing 20 ]
                    [ Element.paragraph [ Font.size 50, Font.center ] [ Element.text "Archive" ]
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


elmTopLine : Element msg
elmTopLine =
    Element.row
        [ Element.centerX, Element.spacing 13 ]
        [ Element.image [ Element.width (Element.px 49) ] meta.logo
        , Element.column
            [ Element.spacing 2, Font.size 24, Element.moveUp 1 ]
            [ Element.el [ Theme.glow ] (Element.text "Unconference")
            , Element.el [ Font.extraBold, Font.color Theme.lightTheme.elmText ] (Element.text meta.tag)
            ]
        ]


elmBottomLine : Element msg
elmBottomLine =
    Element.column
        [ Theme.glow, Font.size 16, Element.centerX, Element.spacing 2 ]
        [ Element.el [ Font.bold, Element.centerX ] (Element.text meta.dates)
        , Element.text meta.location
        ]


conferenceSummary : Element msg
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


venuePictures : LoadedModel -> Element msg
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
                Element.row
                    [ Element.spacing 10, Element.width Element.fill ]
                    (List.map (\image -> venueImage Element.fill (prefix ++ image)) paths)
            )
        |> Element.column [ Element.spacing 10, Element.width Element.fill ]


venueImage : Length -> String -> Element msg
venueImage width path =
    Element.image [ Element.width width ] { src = path, description = "Photo of Park Hotel" }


organisers : Element msg
organisers =
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
        |> List.map
            (\column ->
                List.map
                    (\person ->
                        Element.column
                            [ Element.spacing 4 ]
                            [ Element.row
                                [ Element.spacing 8 ]
                                [ Element.el [ Font.size 32 ] (Element.text person.country)
                                , Element.paragraph [ Font.size 20, Font.color Theme.greenTheme.elmText ] [ Element.text person.name ]
                                ]
                            , Element.paragraph [] [ Element.text person.description ]
                            ]
                    )
                    column
                    |> Element.column [ Element.width Element.fill, Element.alignTop, Element.spacing 24 ]
            )
        |> Element.row [ Element.spacing 32 ]



--        """
--🇧🇪 Hayleigh Thompson – Competitive person-helper in the Elm Slack. Author of Lustre, an Elm port written in Gleam.
--
--🇺🇸 James Carlson – Worked for many years as a math professor. Trying to learn type theory, which combines philosophy, logic, mathematics, and functional programming.
--
--🇩🇪 Johannes Emerich – Works at Dividat, making a console with small games and a large controller. Remembers when Elm demos were about the intricacies of how high Super Mario jumps.
--
--🇺🇸 John Pavlick – Professional combinator enthusiast at AppyPeople. Mostly harmless.
--
--🇬🇧 Katja Mordaunt – Uses web tech to help charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of codereading.club
--
--🇦🇺 Mario Rogic – Organizer of the Elm London and Elm Online meetups. Groundskeeper of Elmcraft, founder of Lamdera.
--
--🇨🇿 Martin Janiczek – Loves to start things and one-off experiments, has a drive for teaching and unblocking others. Regularly races for the first answer in Elm Slack #beginners and #help.
--
--🇸🇪 Martin Stewart – Likes making games and apps using Lamdera. Currently trying to recreate Discord in Elm.
--
--🇺🇸 Wolfgang Schuster – Author of Elm Weekly."""
--        |> MarkdownThemed.renderFull


venueAccessContent : Element msg
venueAccessContent =
    Element.column
        []
        [ """
# The venue and access

## The venue

**Hotel Prachárna**<br/>
Křelovská 91, 779 00 Olomouc 9<br/>
Řepčín, Česko<br/>
Czechia

[https://www.hotel-pracharna.cz/](https://www.hotel-pracharna.cz/)

## Participating in conversations

* The official conference language will be English. We ask that attendees conduct as much of their conversations in English in order to include as many people as possible
* We do not have facility for captioning or signing, please get in touch as soon as possible if you would benefit from something like that and we'll see what we can do
* We aim to provide frequent breaks of a decent length, so if this feels lacking to you at any time, let an organiser know

## Contacting the organisers

If you have questions or concerns about this website or attending Elm Camp, please get in touch

    """
            ++ contactDetails
            |> MarkdownThemed.renderFull

        --
        --, Html.iframe
        --    [ Html.Attributes.src "/map.html"
        --    , Html.Attributes.style "width" "100%"
        --    , Html.Attributes.style "height" "auto"
        --    , Html.Attributes.style "aspect-ratio" "21 / 9"
        --    , Html.Attributes.style "border" "none"
        --    ]
        --    []
        --    |> Element.html
        ]


contactDetails : String
contactDetails =
    """
* Elmcraft Discord: [#elm-camp-26](""" ++ Helpers.discordInviteLink ++ """) channel or DM katjam_
* Email: [team@elm.camp](mailto:team@elm.camp)
* Elm Slack: @katjam"""


sponsors : { window | width : Int } -> Element msg
sponsors window =
    let
        asImg { image, url, width } =
            Element.newTabLink
                [ Element.width Element.fill ]
                { url = url
                , label =
                    Element.image
                        [ Element.width
                            (Element.px
                                (if window.width < 800 then
                                    toFloat width * 0.7 |> round

                                 else
                                    width
                                )
                            )
                        ]
                        { src = "/sponsors/" ++ image, description = url }
                }
    in
    Element.column [ Element.centerX, Element.spacing 32 ]
        [ [ asImg { image = "noredink-logo.svg", url = "https://www.noredink.com/", width = 220 }
          , asImg { image = "concentrichealthlogo.svg", url = "https://concentric.health", width = 235 }
          ]
            |> Element.wrappedRow [ Element.centerX, Element.spacing 32 ]
        , [ asImg { image = "lamdera-logo-black.svg", url = "https://lamdera.com/", width = 120 }
          , asImg { image = "scripta.io.svg", url = "https://scripta.io", width = 120 }
          , Element.newTabLink
                [ Element.width Element.fill ]
                { url = "https://www.elmweekly.nl"
                , label =
                    Element.row [ Element.spacing 10, Element.width (Element.px 180) ]
                        [ Element.image
                            [ Element.width
                                (Element.px
                                    (if window.width < 800 then
                                        50 * 0.7 |> round

                                     else
                                        50
                                    )
                                )
                            ]
                            { src = "/sponsors/" ++ "elm-weekly.svg", description = "https://www.elmweekly.nl" }
                        , Element.el [ Font.size 24 ] (Element.text "Elm Weekly")
                        ]
                }
          ]
            |> Element.wrappedRow [ Element.centerX, Element.spacing 32 ]
        ]
