module Camp24Uk exposing (view)

import Camp
import Formatting exposing (Formatting(..), Inline(..))
import Theme
import Types exposing (FrontendMsg, LoadedModel)
import Ui
import Ui.Font
import Ui.Prose


meta : Camp.Meta
meta =
    { logo = { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
    , tag = "Europe 2024"
    , location = "🇬🇧 Colehayes Park, Devon"
    , dates = "Tues 18th — Fri 21st June"
    , artifactPicture = { src = "/24-colehayes/artifacts-mark-skipper.png", description = "A watercolor drawing of Colehayes Park" }
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
                    , Camp.elmCampTopLine meta
                    , Camp.elmCampBottomLine meta
                    ]
                ]
            , Camp.viewArchive
                { organisers = organisers
                , sponsors = sponsors model.window
                , venue = venueAccessContent
                }
                model
            ]
        , Theme.footer
        ]


organisers : List Formatting
organisers =
    [ Section "Organisers"
        [ Paragraph
            [ Text "🇬🇧 Katja Mordaunt – Uses web tech to help improve the reach of charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of "
            , ExternalLink "codereading.club" "codereading.club/"
            ]
        , Paragraph
            [ Text "🇺🇸 Jim Carlson – Developer of "
            , ExternalLink "Scripta.io" "scripta.io"
            , Text ", a web publishing platform for technical documents in mathematics, physics, and the like. Currently working for "
            , ExternalLink "exosphere.app" "exosphere.app"
            , Text ", an all-Elm cloud-computing project"
            ]
        , Paragraph
            [ Text "🇬🇧 Mario Rogic – Organiser of the "
            , ExternalLink "Elm London" "meetdown.app/group/37aa26/Elm-London-Meetup"
            , Text " and "
            , ExternalLink "Elm Online" "meetdown.app/group/10561/Elm-Online-Meetup"
            , Text " meetups. Groundskeeper of "
            , ExternalLink "Elmcraft" "elmcraft.org/"
            , Text ", founder of "
            , ExternalLink "Lamdera" "lamdera.com/"
            , Text "."
            ]
        , Paragraph
            [ Text "🇺🇸 Wolfgang Schuster – Author of "
            , ExternalLink "Elm weekly" "www.elmweekly.nl/"
            , Text ", hobbyist and professional Elm developer. Currently working at "
            , ExternalLink "Vendr" "www.vendr.com/"
            , Text "."
            ]
        , Paragraph
            [ Text "🇬🇧 Hayleigh Thompson – Terminally online in the Elm community. Competitive person-help. Developer relations engineer at "
            , ExternalLink "xyflow" "www.xyflow.com/"
            , Text "."
            ]
        ]
    ]


venueAccessContent : List Formatting
venueAccessContent =
    --    """
    --**Colehayes Park**<br/>
    --Haytor Road<br/>
    --Bovey Tracey<br/>
    --South Devon<br/>
    --TQ13 9LD<br/>
    --England
    --
    --[Google Maps](goo.gl/maps/Q44YiJCJ79apMmQ8A)
    --
    --[www.colehayes.co.uk/](www.colehayes.co.uk/)
    --
    --## Getting there
    --
    --### via train & cab/Elm Camp shuttle
    --
    --* The closest train station is ([Newton Abbot station](www.gwr.com/stations-and-destinations/stations/Newton-Abbot))
    --  * Express direct trains from London Paddington take 2.5 – 3.5 hours (best for all London Airports)
    --  * Express direct trains from Bristol Temple Meads take 1.5 hours (best for Bristol Airport, take A1 Airport Flyer bus)
    --  * From Exeter Airport a 30 minute cab/rideshare directly to the venue is best
    --* Colehayes Park is then a 20 minute cab from Newton Abbot station.
    --* Elm Camp will organise shuttles between Exeter or Newton Abbot and the venue at key times
    --
    --### via car
    --
    --* There is ample parking on site
    --
    --### via plane
    --
    --* The closest airport is Exeter, with [flight connections to the UK, Dublin, and Southern Spain](www.flightsfrom.com/EXT)
    --* The next closest major airports in order of travel time are:
    --  * [Bristol](www.flightsfrom.com/explorer/BRS?mapview) (Europe & Northern Africa)
    --  * [London Heathrow](www.flightsfrom.com/explorer/LHR?mapview) (best International coverage)
    --  * [London Gatwick](www.flightsfrom.com/explorer/LGW?mapview) (International)
    --  * [London Stanstead](www.flightsfrom.com/explorer/STN?mapview) (Europe)
    --  * [London Luton](www.flightsfrom.com/explorer/LTN?mapview)  (Europe)
    --
    --[Rome2Rio](www.rome2rio.com/s/Exeter-UK) is a useful tool for finding possible routes from your location.
    --
    --## Local amenities
    --
    --Food and drinks are available on site, but if you forgot to pack a toothbrush or need that gum you like, nearby Bovey Tracey offers a few shops.
    --
    --### Supermarkets
    --
    --- [Tesco Express](www.tesco.com/store-locator/newton-abbot/47-fore-st) (7 am—11 pm), 47 Fore St
    --
    --### Health
    --
    --- Pharmacy ([Bovey Tracey Pharmacy](www.nhs.uk/services/pharmacy/bovey-tracey-pharmacy/FFL40)) (9 am—5:30 pm), near Tesco Express supermarket
    --
    --## Accessibility
    --
    --
    --Attendees will be able to camp in the grounds or book a variety of rooms in the main house or the cottage.
    --
    --Please let us know if you have specific needs so that we can work with the venue to accommodate you.
    --
    --### Floor plans
    --
    --* [The main house](www.colehayes.co.uk/wp-content/uploads/2018/10/Colehayes-Park-Floor-Plans.pdf)
    --* [The cottage](www.colehayes.co.uk/wp-content/uploads/2019/02/Colehayes-Park-Cottage-Floor-Plan.pdf)
    --
    --
    --### Partially step free.
    --Please ask if you require step free accommodation. There is one bedroom on the ground floor.
    --
    --* Toilets, dining rooms and conference talk / workshop rooms can be accessed from ground level.
    --
    --### It's an old manor house
    --
    --* The house has been renovated to a high standard but there are creaky bits. We ask that you be sensible when exploring
    --* There are plenty of spaces to hang out in private or in a small quiet group
    --* There are a variety of seating options
    --
    --### Toilets
    --
    --* All toilets are gender neutral
    --* There are blocks of toilets and showers on each floor and a couple of single units
    --* There is at least one bath in the house
    --* The level of accessibility of toilets needs to be confirmed (please ask if you have specific needs)
    --* There are also toilet and shower blocks in the garden for campers
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
    --    """
    --        |> MarkdownThemed.renderFull
    [ Section "Unconference"
        [ BulletList
            []
            [ Paragraph [ Text "Arrive anytime on Tue 18th June 2024" ]
            , Paragraph [ Text "Depart 10am Fri 21st June 2024" ]
            , Paragraph [ Text "🇬🇧 Colehayes Park, Devon UK" ]
            , Paragraph [ Text "Collaborative session creation throughout" ]
            , Paragraph [ Text "Periodic collective scheduling sessions" ]
            , Paragraph [ Text "At least 3 tracks, sessions in both short and long blocks" ]
            , Paragraph [ Text "Countless hallway conversations and mealtime connections" ]
            , Paragraph [ Text "Full and exclusive access to the Park grounds and facilities" ]
            , Paragraph [ Text "60+ attendees" ]
            ]
        ]
    , Images
        [ [ { source = "/24-colehayes/image1.webp"
            , description = "Photo of part of Colehayes Park"
            }
          , { source = "/24-colehayes/image2.webp"
            , description = "Photo of part of Colehayes Park"
            }
          , { source = "/24-colehayes/image3.webp"
            , description = "Photo of part of Colehayes Park"
            }
          ]
        , [ { source = "/24-colehayes/image4.webp"
            , description = "Photo of part of Colehayes Park"
            }
          , { source = "/24-colehayes/image5.webp"
            , description = "Photo of part of Colehayes Park"
            }
          , { source = "/24-colehayes/image6.webp"
            , description = "Photo of part of Colehayes Park"
            }
          ]
        ]
    , Section "Travel & Venue"
        [ Paragraph
            [ Bold "Colehayes Park"
            , Text "\nHaytor Road\nBovey Tracey\nSouth Devon\nTQ13 9LD\nEngland"
            ]
        , Paragraph
            [ ExternalLink "Google Maps" "goo.gl/maps/Q44YiJCJ79apMmQ8A"
            ]
        , Paragraph
            [ ExternalLink "https://www.colehayes.co.uk/" "www.colehayes.co.uk/"
            ]
        , Section "Getting there"
            [ BulletList
                [ Bold "via train & cab/Elm Camp shuttle" ]
                [ BulletList
                    [ Text "The closest train station is ("
                    , ExternalLink "Newton Abbot station" "www.gwr.com/stations-and-destinations/stations/Newton-Abbot"
                    , Text ")"
                    ]
                    [ Paragraph
                        [ Text "Express direct trains from London Paddington take 2.5 – 3.5 hours (best for all London Airports)" ]
                    , Paragraph
                        [ Text "Express direct trains from Bristol Temple Meads take 1.5 hours (best for Bristol Airport, take A1 Airport Flyer bus)" ]
                    , Paragraph
                        [ Text "From Exeter Airport a 30 minute cab/rideshare directly to the venue is best" ]
                    ]
                , Paragraph [ Text "Colehayes Park is then a 20 minute cab from Newton Abbot station." ]
                , Paragraph [ Text "Elm Camp will organise shuttles between Exeter or Newton Abbot and the venue at key times" ]
                ]
            , BulletList
                [ Bold "via car" ]
                [ Paragraph [ Text "There is ample parking on site" ] ]
            , BulletList
                [ Bold "via plane" ]
                [ Paragraph
                    [ Text "The closest airport is Exeter, with "
                    , ExternalLink "flight connections to the UK, Dublin, and Southern Spain" "www.flightsfrom.com/EXT"
                    ]
                , BulletList
                    [ Text "The next closest major airports in order of travel time are:" ]
                    [ Paragraph
                        [ ExternalLink "Bristol" "www.flightsfrom.com/explorer/BRS?mapview"
                        , Text " (Europe & Northern Africa)"
                        ]
                    , Paragraph
                        [ ExternalLink "London Heathrow" "www.flightsfrom.com/explorer/LHR?mapview"
                        , Text " (best International coverage)"
                        ]
                    , Paragraph
                        [ ExternalLink "London Gatwick" "www.flightsfrom.com/explorer/LGW?mapview"
                        , Text " (International)"
                        ]
                    , Paragraph
                        [ ExternalLink "London Stanstead" "www.flightsfrom.com/explorer/STN?mapview"
                        , Text " (Europe)"
                        ]
                    , Paragraph
                        [ ExternalLink "London Luton" "www.flightsfrom.com/explorer/LTN?mapview"
                        , Text " (Europe)"
                        ]
                    ]
                ]
            , Paragraph
                [ ExternalLink "Rome2Rio" "www.rome2rio.com/s/Exeter-UK"
                , Text " is a useful tool for finding possible routes from your location."
                ]
            ]
        , Section "Local amenities"
            [ Paragraph
                [ Text "Food and drinks are available on site, but if you forgot to pack a toothbrush or need that gum you like, nearby Bovey Tracey offers a few shops." ]
            , BulletList
                [ Bold "Supermarkets" ]
                [ Paragraph
                    [ ExternalLink "Tesco Express" "www.tesco.com/store-locator/newton-abbot/47-fore-st"
                    , Text " (7 am—11 pm), 47 Fore St"
                    ]
                ]
            , BulletList [ Bold "Health" ]
                [ Paragraph
                    [ Text "Pharmacy ("
                    , ExternalLink "Bovey Tracey Pharmacy" "www.nhs.uk/services/pharmacy/bovey-tracey-pharmacy/FFL40"
                    , Text ") (9 am—5:30 pm), near Tesco Express supermarket"
                    ]
                ]
            ]
        , Section "Accessibility"
            [ Paragraph
                [ Text "Attendees will be able to camp in the grounds or book a variety of rooms in the main house or the cottage." ]
            , Paragraph
                [ Text "Please let us know if you have specific needs so that we can work with the venue to accommodate you." ]
            , BulletList
                [ Bold "Floor plans" ]
                [ Paragraph
                    [ ExternalLink "The main house" "www.colehayes.co.uk/wp-content/uploads/2018/10/Colehayes-Park-Floor-Plans.pdf" ]
                , Paragraph
                    [ ExternalLink "The cottage" "www.colehayes.co.uk/wp-content/uploads/2019/02/Colehayes-Park-Cottage-Floor-Plan.pdf" ]
                ]
            , BulletList
                [ Text "Partially step free." ]
                [ Paragraph [ Text "Please ask if you require step free accommodation. There is one bedroom on the ground floor." ]
                , Paragraph [ Text "Toilets, dining rooms and conference talk / workshop rooms can be accessed from ground level." ]
                ]
            , BulletList
                [ Bold "It's an old manor house" ]
                [ Paragraph
                    [ Text "The house has been renovated to a high standard but there are creaky bits. We ask that you be sensible when exploring" ]
                , Paragraph
                    [ Text "There are plenty of spaces to hang out in private or in a small quiet group" ]
                , Paragraph
                    [ Text "There are a variety of seating options" ]
                ]
            , BulletList
                [ Bold "Toilets" ]
                [ Paragraph [ Text "All toilets are gender neutral" ]
                , Paragraph [ Text "There are blocks of toilets and showers on each floor and a couple of single units" ]
                , Paragraph [ Text "There is at least one bath in the house" ]
                , Paragraph [ Text "The level of accessibility of toilets needs to be confirmed (please ask if you have specific needs)" ]
                , Paragraph [ Text "There are also toilet and shower blocks in the garden for campers" ]
                ]
            , BulletList
                [ Bold "Open water & rough ground" ]
                [ Paragraph [ Text "The house is set in landscaped grounds, there are paths and rough bits." ]
                , Paragraph [ Text "There is a lake with a pier for swimming and fishing off of, right next to the house that is NOT fenced" ]
                ]
            ]
        , BulletList
            [ Bold "Participating in conversations" ]
            [ Paragraph
                [ Text "The official conference language will be English. We ask that attendees conduct as much of their conversations in English in order to include as many people as possible" ]
            , Paragraph
                [ Text "We do not have facility for captioning or signing, please get in touch as soon as possible if you would benefit from something like that and we'll see what we can do" ]
            , Paragraph
                [ Text "We aim to provide frequent breaks of a decent length, so if this feels lacking to you at any time, let an organiser know" ]
            ]
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
        [ [ asImg { image = "vendr.png", url = "https://www.vendr.com/", width = 350 }
          ]
            |> Ui.row [ Ui.wrap, Ui.contentTop, Ui.width Ui.shrink, Ui.centerX, Ui.spacing 32 ]
        , [ asImg { image = "ambue-logo.png", url = "https://www.ambue.com/", width = 220 }
          , asImg { image = "nlx-logo.svg", url = "https://nlx.ai", width = 110 }
          ]
            |> Ui.row [ Ui.wrap, Ui.contentTop, Ui.width Ui.shrink, Ui.centerX, Ui.spacing 32 ]
        , [ asImg { image = "concentrichealthlogo.svg", url = "https://concentric.health/", width = 200 }
          , asImg { image = "logo-dividat.svg", url = "https://dividat.com", width = 160 }
          ]
            |> Ui.row [ Ui.wrap, Ui.contentTop, Ui.width Ui.shrink, Ui.centerX, Ui.spacing 32 ]
        , [ asImg { image = "lamdera-logo-black.svg", url = "https://lamdera.com/", width = 100 }
          , asImg { image = "scripta.io.svg", url = "https://scripta.io", width = 100 }
          , asImg { image = "elm-weekly.svg", url = "https://www.elmweekly.nl", width = 100 }
          , asImg { image = "cookiewolf-logo.png", url = "", width = 120 }
          ]
            |> Ui.row [ Ui.wrap, Ui.contentTop, Ui.width Ui.shrink, Ui.centerX, Ui.spacing 32 ]
        ]
