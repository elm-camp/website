module Camp25US exposing
    ( conferenceSummary
    , contactDetails
    , elmBottomLine
    , elmTopLine
    , meta
    , organisers
    , sponsors
    , venueAccessContent
    , venueImage
    , venuePictures
    , view
    )

import Camp
import Camp25US.Archive
import Camp25US.Artifacts
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
    , tag = "Michigan, US 2025"
    , location = "🇺🇸 Watervliet, Michigan"
    , dates = "Tues 24th - Fri 27th June 2025"
    , artifactPicture = { src = "/24-colehayes/artifacts-mark-skipper.png", description = "A watercolour of an old tree in an English stately garden" }
    }


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
                    Camp.viewArchive
                        { images = images
                        , organisers = organisers |> MarkdownThemed.renderFull
                        , sponsors = sponsors model.window
                        , conferenceSummary = conferenceSummary
                        , schedule = Nothing
                        , venue = Just venueAccessContent
                        }
                        model.window

                --Camp25US.Archive.view model
                Artifacts ->
                    Camp25US.Artifacts.view model
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
### Arrive anytime on Tues 24th June 2025
### Depart 10am on Fri 27th June 2025
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


images : List { src : String, description : String }
images =
    [ "image1.webp", "image2.webp", "image3.webp", "image4.webp", "image5.webp", "image6.webp" ]
        |> List.map
            (\image ->
                { src = "/23-denmark/" ++ image
                , description = ""
                }
            )


venuePictures : LoadedModel -> Element msg
venuePictures model =
    let
        prefix =
            "25-ronora/"
    in
    if model.window.width > 950 then
        [ "image1.webp", "image2.webp", "image3.webp", "image4.webp", "image5.webp", "image6.webp" ]
            |> List.map (\image -> venueImage (Element.px 288) (prefix ++ image))
            |> Element.wrappedRow
                [ Element.spacing 10, Element.width (Element.px 900), Element.centerX ]

    else
        [ [ "image1.webp", "image2.webp" ]
        , [ "image3.webp", "image4.webp" ]
        , [ "image5.webp", "image6.webp" ]
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
    Element.image
        [ Element.width width ]
        { src = "/" ++ path, description = "Photo of part of Ronora Lodge" }


organisers : String
organisers =
    """
🇧🇪 Hayleigh Thompson – Competitive person-helper in the Elm Slack. Author of Lustre, an Elm port written in Gleam.

🇺🇸 James Carlson – Worked for many years as a math professor. Trying to learn type theory, which combines philosophy, logic, mathematics, and functional programming.

🇺🇸 John Pavlick – Professional combinator enthusiast at AppyPeople. Mostly harmless.

🇬🇧 Katja Mordaunt – Uses web tech to help improve the reach of charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of codereading.club

🇦🇺 Mario Rogic – Organiser of the Elm London and Elm Online meetups. Groundskeeper of Elmcraft, founder of Lamdera.

🇨🇿 Martin Janiczek – Loves to start things and one-off experiments, has a drive for teaching and unblocking others. Regularly races for the first answer in Elm Slack #beginners and #help.

🇺🇸 Tristan Pendergrass – Frontend developer at Dropbox, and Elm enthusiast in his spare time who likes to write apps for his friends and family.

🇺🇸 Wolfgang Schuster – Author of Elm Weekly, builds with Elm at Vendr.
"""


venueAccessContent : Element msg
venueAccessContent =
    Element.column
        []
        [ """
# The venue and access

## The venue

**Ronora Lodge & Retreat Center**<br/>
9325 Dwight Boyer Road<br/>
Watervliet, Michigan 49098<br/>
USA

[Google Maps](https://maps.app.goo.gl/ijj1F5Th3JWJt2p16)

[https://www.ronoralodge.com](https://www.ronoralodge.com/)

### Open water & rough ground

* The house is set in landscaped grounds, there are paths and rough bits.
* There is a lake with a pier for swimming and fishing off of, right next to the house that is NOT fenced

## Participating in conversations

* The official conference language will be English. We ask that attendees conduct as much of their conversations in English in order to include as many people as possible
* We do not have facility for captioning or signing, please get in touch as soon as possible if you would benefit from something like that and we'll see what we can do
* We aim to provide frequent breaks of a decent length, so if this feels lacking to you at any time, let an organiser know

## Contacting the organisers

If you have questions or concerns about this website or attending Elm Camp, please get in touch

    """
            ++ contactDetails
            |> MarkdownThemed.renderFull
        , Html.iframe
            [ Html.Attributes.src "/map.html"
            , Html.Attributes.style "width" "100%"
            , Html.Attributes.style "height" "auto"
            , Html.Attributes.style "aspect-ratio" "21 / 9"
            , Html.Attributes.style "border" "none"
            ]
            []
            |> Element.html
        ]


contactDetails : String
contactDetails =
    """
* Elmcraft Discord: [#elm-camp-24](""" ++ Helpers.discordInviteLink ++ """) channel or DM katjam_
* Email: [team@elm.camp](mailto:team@elm.camp)
* Elm Slack: @katjam
"""


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
