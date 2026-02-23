module Camp25US exposing (view)

import Camp
import Helpers
import RichText exposing (Inline(..), RichText(..), Shared)
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
    }


view : LoadedModel -> Ui.Element FrontendMsg
view model =
    Ui.column
        [ Ui.height Ui.fill ]
        [ Ui.column
            (Ui.padding 20 :: Theme.contentAttributes ++ [ Ui.spacing 50 ])
            [ Theme.rowToColumnWhen
                model.window
                [ Ui.spacing 30, Ui.centerX, Ui.Font.center ]
                [ Ui.image [ Ui.width (Ui.px 300) ]
                    { source = "/24-colehayes/artifacts-mark-skipper.png"
                    , description = "A watercolour of an old tree in an English stately garden"
                    , onLoad = Nothing
                    }
                , Ui.column [ Ui.spacing 20 ]
                    [ Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.size 50, Ui.Font.center ] [ Ui.text "Archive" ]
                    , elmTopLine
                    , elmBottomLine
                    ]
                ]
            , RichText.view model content
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


content : List RichText
content =
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
    , Images
        [ [ { source = "/25-ronora/image1.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Ronora Lodge"
            , link = Nothing
            }
          , { source = "/25-ronora/image2.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Ronora Lodge"
            , link = Nothing
            }
          , { source = "/25-ronora/image3.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Ronora Lodge"
            , link = Nothing
            }
          ]
        , [ { source = "/25-ronora/image4.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Ronora Lodge"
            , link = Nothing
            }
          , { source = "/25-ronora/image5.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Ronora Lodge"
            , link = Nothing
            }
          , { source = "/25-ronora/image6.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Ronora Lodge"
            , link = Nothing
            }
          ]
        ]
    , Section "Travel & Venue"
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
            [ BulletList
                [ Text "If you have questions or concerns about this website or attending Elm Camp, please get in touch"
                ]
                [ Paragraph [ Text "Elmcraft Discord: ", ExternalLink "#elm-camp-24" Helpers.discordInviteLink, Text " channel or DM katjam_" ]
                , Paragraph [ Text "Email: ", ExternalLink "team@elm.camp" "mailto:team@elm.camp" ]
                , Paragraph [ Text "Elm Slack: @katjam" ]
                ]
            ]
        , LegacyMap
        ]
    , Section "Our sponsors"
        [ Images
            [ [ { source = "/sponsors/noredink-logo.svg", link = Just "https://www.noredink.com/", maxWidth = Just 220, description = "No red ink's logo" }
              , { source = "/sponsors/concentrichealthlogo.svg", link = Just "https://concentric.health", maxWidth = Just 235, description = "Concentric health's logo" }
              ]
            , [ { source = "/sponsors/lamdera-logo-black.svg", link = Just "https://lamdera.com/", maxWidth = Just 120, description = "Lamdera's logo" }
              , { source = "/sponsors/scripta.io.svg", link = Just "https://scripta.io", maxWidth = Just 120, description = "Scripta IO's logo" }
              , { source = "/sponsors/elm-weekly-new.svg", link = Just "https://www.elmweekly.nl", maxWidth = Just 120, description = "Elm weekly's logo" }
              ]
            ]
        ]
    , Section "Organisers"
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
