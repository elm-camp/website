module Camp23Denmark exposing (view)

import Camp
import Formatting exposing (Formatting(..), Inline(..))
import MarkdownThemed
import Theme
import Types exposing (FrontendMsg, LoadedModel)
import Ui
import Ui.Font
import Ui.Prose


meta : Camp.Meta
meta =
    { logo = { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
    , tag = "Europe 2023"
    , location = "🇩🇰 Dallund Castle, Denmark"
    , dates = "Wed 28th - Fri 30th June"
    , artifactPicture = { src = "/23-denmark/artifacts.png", description = "A suitcase full of artifacts in the middle of a danish forest" }
    }


images : List { src : String, description : String }
images =
    List.range 1 6
        |> List.map
            (\ix ->
                { src = "/23-denmark/image" ++ String.fromInt ix ++ ".webp"
                , description = "Photo of part of Dallund Castle"
                }
            )


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
                [ Ui.image
                    [ Ui.width (Ui.px 300) ]
                    { source = meta.artifactPicture.src, description = meta.artifactPicture.description, onLoad = Nothing }
                , Ui.column [ Ui.spacing 20 ]
                    [ Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.size 50, Ui.Font.center ] [ Ui.text "Archive" ]
                    , Camp.elmCampTopLine meta
                    , Camp.elmCampBottomLine meta
                    ]
                ]
            , Camp.viewArchive
                { images = images
                , conferenceSummary = unconferenceBulletPoints
                , sponsors = sponsors model.window
                , schedule = Just schedule
                , venue = venue
                , organisers = organisers
                }
                model
            ]
        , Theme.footer
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
    [ asImg { image = "vendr.png", url = "https://www.vendr.com/", width = 250 }
    , asImg { image = "concentrichealthlogo.svg", url = "https://concentric.health/", width = 250 }
    , asImg { image = "logo-dividat.svg", url = "https://dividat.com", width = 170 }
    , asImg { image = "lamdera-logo-black.svg", url = "https://lamdera.com/", width = 200 }
    , asImg { image = "scripta.io.svg", url = "https://scripta.io", width = 200 }
    , asImg { image = "bekk.svg", url = "https://www.bekk.no/", width = 200 }
    , Ui.el
        [ Ui.linkNewTab "https://www.elmweekly.nl", Ui.width Ui.fill ]
        (Ui.row [ Ui.spacing 10, Ui.width (Ui.px 200) ]
            [ Ui.image
                [ Ui.width
                    (Ui.px
                        (if window.width < 800 then
                            60 * 0.7 |> Basics.round

                         else
                            60
                        )
                    )
                ]
                { description = "https://www.elmweekly.nl", source = "/sponsors/" ++ "elm-weekly.svg", onLoad = Nothing }
            , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 24 ] (Ui.text "Elm Weekly")
            ]
        )
    , asImg { image = "cookiewolf-logo.png", url = "", width = 220 }
    ]
        -- |> List.map asImg
        |> Ui.row [ Ui.wrap, Ui.contentTop, Ui.width Ui.shrink, Ui.spacing 32 ]


unconferenceBulletPoints : List Formatting
unconferenceBulletPoints =
    [ Section "Unconference"
        [ BulletList
            []
            [ Paragraph [ Text "Arrive 3pm Wed 28 June" ]
            , Paragraph [ Text "Depart 4pm Fri 30 June" ]
            , Paragraph [ Text "Dallund Castle, Denmark" ]
            , Paragraph [ Text "Daily opener un-keynote" ]
            , Paragraph [ Text "Collaborative session creation throughout" ]
            , Paragraph [ Text "Countless hallway conversations and mealtime connections" ]
            , Paragraph [ Text "Access to full castle grounds including lake swimming" ]
            , Paragraph [ Text "50 attendees" ]
            ]
        ]
    ]


schedule : List Formatting
schedule =
    [ Section "Schedule"
        [ Section "Wed 28th June"
            [ BulletList
                []
                [ Paragraph [ Text "3pm - Arrivals & halls officially open" ]
                , Paragraph [ Text "6pm - Opening of session board" ]
                , Paragraph [ Text "7pm - Informal dinner" ]
                , Paragraph [ Text "8:30pm+ Evening stroll and informal chats" ]
                , Paragraph [ Text "9:57pm - 🌅Sunset" ]
                ]
            ]
        , Section "Thu 29th June"
            [ BulletList
                []
                [ Paragraph [ Text "7am-9am - Breakfast" ]
                , Paragraph [ Text "9am - Opening Unkeynote" ]
                , Paragraph [ Text "10am-12pm - Unconference sessions" ]
                , Paragraph [ Text "12-1:30pm - Lunch" ]
                , Paragraph [ Text "2pm-5pm Unconference sessions" ]
                , Paragraph [ Text "6-7:30pm Dinner" ]
                , Paragraph [ Text "Onwards - Board Games and informal chats" ]
                ]
            ]
        , Section "Fri 30th June"
            [ BulletList
                []
                [ Paragraph [ Text "7am-9am - Breakfast" ]
                , Paragraph [ Text "9am - 12pm Unconference sessions" ]
                , Paragraph [ Text "12-1:30pm - Lunch" ]
                , Paragraph [ Text "2pm Closing Unkeynote" ]
                , Paragraph [ Text "3pm unconference wrap-up" ]
                , Paragraph [ Text "4pm - Departure" ]
                ]
            ]
        ]
    ]


venue : List Formatting
venue =
    [ Section "Travel & Venue"
        [ Paragraph [ Text "Elm Camp takes place at Dallund Castle near Odense in Denmark." ]
        , Paragraph [ Text "Odense can be reached directly by train from Hamburg, Copenhagen and other locations in Denmark. Denmark has multiple airports for attendants arriving from distant locations." ]
        , Paragraph [ Text "Dallund Castle itself offers 24 rooms, additional accommodation can be found in Odense." ]
        , Paragraph [ Text "All meals are organic or biodynamic and the venue can accommodate individual allergies & intolerances. Lunches will be vegetarian, dinners will include free-range & organic meat with a vegetarian option." ]
        ]
    ]


organisers : Ui.Element msg
organisers =
    """
Elm Camp is a community-driven non-profit initiative, organised by enthusiastic members of the Elm community.

🇬🇧 Katja Mordaunt – Uses web tech to help improve the reach of charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of codereading.club

🇺🇸 James Carlson – Developer of [Scripta.io](https://scripta.io), a web publishing platform for technical documents in mathematics, physics, and the like. Currently working for [exosphere.app](https://exosphere.app), an all-Elm cloud-computing project

🇸🇪 Martin Stewart – Makes games and apps using Lamdera. Also runs the state-of-elm survey every year.

🇨🇿 Martin Janiczek – Loves to start things and one-off experiments, has a drive for teaching and unblocking others. Regularly races for the first answer in Elm Slack #beginners and #help.

🇬🇧 Mario Rogic – Organiser of the Elm London and Elm Online meetups. Groundskeeper of Elmcraft, founder of Lamdera.

🇩🇪 Johannes Emerich – Works at Dividat, making a console with small games and a large controller. Remembers when Elm demos were about the intricacies of how high Super Mario jumps."""
        |> MarkdownThemed.renderFull
