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
import Formatting exposing (Formatting(..), Inline(..), Shared)
import Helpers
import MarkdownThemed
import Theme
import Types exposing (FrontendMsg, LoadedModel)
import Ui
import Ui.Font
import Ui.Prose


meta : Camp.Meta
meta =
    { logo = { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
    , tag = "Michigan, US 2025"
    , location = "🇺🇸 Watervliet, Michigan"
    , dates = "Tues 24th - Fri 27th June 2025"
    , artifactPicture = { src = "/24-colehayes/artifacts-mark-skipper.png", description = "A watercolour of an old tree in an English stately garden" }
    }


view : LoadedModel -> Ui.Element FrontendMsg
view model =
    Ui.column
        [ Ui.height Ui.fill ]
        [ Ui.column
            -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
            (Ui.padding 20 :: Theme.contentAttributes ++ [ Ui.spacing 50 ])
            [ Theme.rowToColumnWhen 700
                model.window
                [ Ui.spacing 30, Ui.centerX, Ui.Font.center ]
                [ Ui.image [ Ui.width (Ui.px 300) ] { source = meta.artifactPicture.src, description = meta.artifactPicture.description, onLoad = Nothing }
                , Ui.column [ Ui.spacing 20 ]
                    [ Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.size 50, Ui.Font.center ] [ Ui.text "Archive" ]
                    , elmTopLine
                    , elmBottomLine
                    ]
                ]
            , Camp.viewArchive
                { images = images
                , organisers = organisers
                , sponsors = sponsors model.window
                , conferenceSummary = conferenceSummary
                , venue = venueAccessContent
                }
                model
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


conferenceSummary : List Formatting
conferenceSummary =
    [ Section "Unconference"
        [ Section "Ronora Lodge and Retreat Center - Watervliet, Michigan"
            [ Paragraph [ Text "Arrive anytime on Tues 24th June 2025" ]
            , BulletList
                [ Text "Depart 10am on Fri 27th June 2025" ]
                [ Paragraph [ Text "2 full days of talks" ]
                , Paragraph [ Text "40+ attendees" ]
                ]
            ]
        , Section "Prospective Schedule:"
            [ BulletList
                [ Bold "Tue 24th June" ]
                [ Paragraph [ Text "3pm arrivals & halls officially open" ]
                , Paragraph [ Text "Opening of session board" ]
                , Paragraph [ Text "Informal dinner" ]
                , Paragraph [ Text "Evening stroll" ]
                ]
            , BulletList
                [ Bold "Wed 25th June" ]
                [ Paragraph [ Text "Breakfast" ]
                , Paragraph [ Text "Unconference sessions" ]
                , Paragraph [ Text "Lunch" ]
                , Paragraph [ Text "Unconference sessions" ]
                , Paragraph [ Text "Dinner" ]
                , Paragraph [ Text "Board Games and informal chats" ]
                ]
            , BulletList
                [ Bold "Thu 26th June" ]
                [ Paragraph [ Text "Breakfast" ]
                , Paragraph [ Text "Unconference sessions" ]
                , Paragraph [ Text "Lunch" ]
                , Paragraph [ Text "Unconference sessions" ]
                , Paragraph [ Text "Dinner" ]
                , Paragraph [ Text "Unconference wrap-up & party" ]
                ]
            , BulletList
                [ Bold "Thu 26th June" ]
                [ Paragraph [ Text "Grab and go breakfast" ]
                , Paragraph [ Text "Depart by 10am" ]
                ]
            ]
        ]
    ]


images : List { src : String, description : String }
images =
    [ "image1.webp", "image2.webp", "image3.webp", "image4.webp", "image5.webp", "image6.webp" ]
        |> List.map
            (\image ->
                { src = "/" ++ prefix ++ image
                , description = "Photo of part of Ronora Lodge"
                }
            )


prefix : String
prefix =
    "25-ronora/"


venuePictures : LoadedModel -> Ui.Element msg
venuePictures model =
    if model.window.width > 950 then
        [ "image1.webp", "image2.webp", "image3.webp", "image4.webp", "image5.webp", "image6.webp" ]
            |> List.map (\image -> venueImage (Ui.px 288) (prefix ++ image))
            |> Ui.row [ Ui.wrap, Ui.contentTop, Ui.spacing 10, Ui.width (Ui.px 900), Ui.centerX ]

    else
        [ [ "image1.webp", "image2.webp" ]
        , [ "image3.webp", "image4.webp" ]
        , [ "image5.webp", "image6.webp" ]
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
    Ui.image
        [ Ui.width width ]
        { source = "/" ++ path, description = "Photo of part of Ronora Lodge", onLoad = Nothing }


organisers : List Formatting
organisers =
    [ Section "Organisers"
        [ Paragraph [ Text "🇧🇪 Hayleigh Thompson – Competitive person-helper in the Elm Slack. Author of Lustre, an Elm port written in Gleam." ]
        , Paragraph [ Text "🇺🇸 James Carlson – Worked for many years as a math professor. Trying to learn type theory, which combines philosophy, logic, mathematics, and functional programming." ]
        , Paragraph [ Text "🇺🇸 John Pavlick – Professional combinator enthusiast at AppyPeople. Mostly harmless." ]
        , Paragraph [ Text "🇬🇧 Katja Mordaunt – Uses web tech to help improve the reach of charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of ", ExternalLink "codereading.club" "https://codereading.club" ]
        , Paragraph [ Text "🇦🇺 Mario Rogic – Organiser of the Elm London and Elm Online meetups. Groundskeeper of Elmcraft, founder of Lamdera." ]
        , Paragraph [ Text "🇨🇿 Martin Janiczek – Loves to start things and one-off experiments, has a drive for teaching and unblocking others. Regularly races for the first answer in Elm Slack #beginners and #help." ]
        , Paragraph [ Text "🇺🇸 Tristan Pendergrass – Frontend developer at Dropbox, and Elm enthusiast in his spare time who likes to write apps for his friends and family." ]
        , Paragraph [ Text "🇺🇸 Wolfgang Schuster – Author of Elm Weekly, builds with Elm at Vendr." ]
        ]
    ]


venueAccessContent : List Formatting
venueAccessContent =
    --## The venue
    --
    --**Ronora Lodge & Retreat Center**<br/>
    --9325 Dwight Boyer Road<br/>
    --Watervliet, Michigan 49098<br/>
    --USA
    --
    --[Google Maps](https://maps.app.goo.gl/ijj1F5Th3JWJt2p16)
    --
    --[https://www.ronoralodge.com](https://www.ronoralodge.com/)
    --
    --### Open water & rough ground
    --
    --* The house is set in landscaped grounds, there are paths and rough bits.
    --* There is a lake with a pier for swimming and fishing off of, right next to the house that is NOT fenced
    --
    --## Participating in conversations
    --
    --* The official conference language will be English. We ask that attendees conduct as much of their conversations in English in order to include as many people as possible
    --* We do not have facility for captioning or signing, please get in touch as soon as possible if you would benefit from something like that and we'll see what we can do
    --* We aim to provide frequent breaks of a decent length, so if this feels lacking to you at any time, let an organiser know
    --
    --## Contacting the organisers
    --
    --If you have questions or concerns about this website or attending Elm Camp, please get in touch
    --
    --    """
    --            ++ contactDetails
    --            |> MarkdownThemed.renderFull
    [ Section "Travel & Venue"
        [ Section "The venue"
            [ Paragraph
                [ Bold "Ronora Lodge & Retreat Center"
                , Text "\n9325 Dwight Boyer Road\nWatervliet, Michigan 49098\nUSA"
                ]
            , Paragraph
                [ ExternalLink "Google Maps" "https://maps.app.goo.gl/ijj1F5Th3JWJt2p16"
                ]
            , Paragraph
                [ ExternalLink "https://www.ronoralodge.com" "https://www.ronoralodge.com/"
                ]
            , BulletList
                [ Bold "Open water & rough ground" ]
                [ Paragraph [ Text "The house is set in landscaped grounds, there are paths and rough bits." ]
                , Paragraph [ Text "There is a lake with a pier for swimming and fishing off of, right next to the house that is NOT fenced" ]
                ]
            ]
        , BulletList
            [ Bold "Participating in conversations" ]
            [ Paragraph [ Text "The official conference language will be English. We ask that attendees conduct as much of their conversations in English in order to include as many people as possible" ]
            , Paragraph [ Text "We do not have facility for captioning or signing, please get in touch as soon as possible if you would benefit from something like that and we'll see what we can do" ]
            , Paragraph [ Text "We aim to provide frequent breaks of a decent length, so if this feels lacking to you at any time, let an organiser know" ]
            ]
        , Section "Contacting the organisers"
            [ Paragraph
                [ Text "If you have questions or concerns about this website or attending Elm Camp, please get in touch"
                ]
            ]
        , LegacyMap
        ]
    ]


contactDetails : String
contactDetails =
    """
* Elmcraft Discord: [#elm-camp-24](""" ++ Helpers.discordInviteLink ++ """) channel or DM katjam_
* Email: [team@elm.camp](mailto:team@elm.camp)
* Elm Slack: @katjam
"""


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
            |> Ui.row [ Ui.wrap, Ui.contentTop, Ui.width Ui.shrink, Ui.centerX, Ui.spacing 32 ]
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
                        { description = "https://www.elmweekly.nl", source = "/sponsors/" ++ "elm-weekly.svg", onLoad = Nothing }
                    , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 24 ] (Ui.text "Elm Weekly")
                    ]
                )
          ]
            |> Ui.row [ Ui.wrap, Ui.contentTop, Ui.width Ui.shrink, Ui.centerX, Ui.spacing 32 ]
        ]
