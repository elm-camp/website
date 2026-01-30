module Camp23Denmark exposing (view)

import Camp
import Formatting exposing (Inline(..), RichText(..))
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
                [ Ui.image
                    [ Ui.width (Ui.px 300) ]
                    { source = "/23-denmark/artifacts.png"
                    , description = "A suitcase full of artifacts in the middle of a danish forest"
                    , onLoad = Nothing
                    }
                , Ui.column [ Ui.spacing 20 ]
                    [ Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.size 50, Ui.Font.center ] [ Ui.text "Archive" ]
                    , Camp.elmCampTopLine meta
                    , Camp.elmCampBottomLine meta
                    ]
                ]
            , Formatting.view model content
            ]
        , Theme.footer
        ]


content : List RichText
content =
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
    , Images
        [ [ { source = "/23-denmark/image1.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Dallund Castle"
            , link = Nothing
            }
          , { source = "/23-denmark/image2.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Dallund Castle"
            , link = Nothing
            }
          , { source = "/23-denmark/image3.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Dallund Castle"
            , link = Nothing
            }
          ]
        , [ { source = "/23-denmark/image4.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Dallund Castle"
            , link = Nothing
            }
          , { source = "/23-denmark/image5.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Dallund Castle"
            , link = Nothing
            }
          , { source = "/23-denmark/image6.webp"
            , maxWidth = Nothing
            , description = "Photo of part of Dallund Castle"
            , link = Nothing
            }
          ]
        ]
    , Section "Schedule"
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
    , Section "Travel & Venue"
        [ Paragraph [ Text "Elm Camp takes place at Dallund Castle near Odense in Denmark." ]
        , Paragraph [ Text "Odense can be reached directly by train from Hamburg, Copenhagen and other locations in Denmark. Denmark has multiple airports for attendants arriving from distant locations." ]
        , Paragraph [ Text "Dallund Castle itself offers 24 rooms, additional accommodation can be found in Odense." ]
        , Paragraph [ Text "All meals are organic or biodynamic and the venue can accommodate individual allergies & intolerances. Lunches will be vegetarian, dinners will include free-range & organic meat with a vegetarian option." ]
        ]
    , Section "Our sponsors"
        [ Images
            [ [ { source = "/sponsors/vendr.png", link = Just "https://www.vendr.com/", maxWidth = Just 250, description = "Vendr's logo" }
              , { source = "/sponsors/concentrichealthlogo.svg", link = Just "https://concentric.health/", maxWidth = Just 250, description = "Concentric health's logo" }
              , { source = "/sponsors/logo-dividat.svg", link = Just "https://dividat.com", maxWidth = Just 170, description = "Dividat's logo" }
              ]
            , [ { source = "/sponsors/lamdera-logo-black.svg", link = Just "https://lamdera.com/", maxWidth = Just 200, description = "Lamdera's logo" }
              , { source = "/sponsors/scripta.io.svg", link = Just "https://scripta.io", maxWidth = Just 200, description = "Scripta IO's logo" }
              , { source = "/sponsors/bekk.svg", link = Just "https://www.bekk.no/", maxWidth = Just 200, description = "Bekk's logo" }
              , { source = "/sponsors/cookiewolf-logo.png", link = Nothing, maxWidth = Just 220, description = "Cookie wolf's logo" }
              ]
            ]
        ]
    , Section
        "Organisers"
        [ Paragraph [ Text "Elm Camp is a community-driven non-profit initiative, organised by enthusiastic members of the Elm community." ]
        , Paragraph [ Text "🇬🇧 Katja Mordaunt – Uses web tech to help improve the reach of charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of ", ExternalLink "codereading.club" "https://codereading.club" ]
        , Paragraph [ Text "🇺🇸 James Carlson – Developer of [Scripta.io](https://scripta.io), a web publishing platform for technical documents in mathematics, physics, and the like. Currently working for [exosphere.app](https://exosphere.app), an all-Elm cloud-computing project" ]
        , Paragraph [ Text "🇸🇪 Martin Stewart – Makes games and apps using Lamdera. Also runs the state-of-elm survey every year." ]
        , Paragraph [ Text "🇨🇿 Martin Janiczek – Loves to start things and one-off experiments, has a drive for teaching and unblocking others. Regularly races for the first answer in Elm Slack #beginners and #help." ]
        , Paragraph [ Text "🇬🇧 Mario Rogic – Organiser of the Elm London and Elm Online meetups. Groundskeeper of Elmcraft, founder of Lamdera." ]
        , Paragraph [ Text "🇩🇪 Johannes Emerich – Works at Dividat, making a console with small games and a large controller. Remembers when Elm demos were about the intricacies of how high Super Mario jumps." ]
        ]
    ]
