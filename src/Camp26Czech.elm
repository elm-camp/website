module Camp26Czech exposing
    ( campfireTicket
    , header
    , sharedRoomTicket
    , singleRoomTicket
    , ticketSalesOpenAt
    , ticketTypes
    , view
    )

import Camp
import Helpers
import Id exposing (Id)
import List.Nonempty exposing (Nonempty(..))
import NonNegative exposing (NonNegative)
import PurchaseForm exposing (PurchaseForm, PurchaseFormValidated)
import RichText exposing (Inline(..), RichText(..))
import Route
import SeqDict exposing (SeqDict)
import Stripe exposing (Price, ProductId)
import Theme exposing (Size)
import Time
import Types exposing (CompletedOrder, FrontendMsg, LoadedModel)
import Ui exposing (Element)
import Ui.Font
import Ui.Prose
import View.Logo
import View.Sales exposing (TicketType, TicketTypes)


meta : Camp.Meta
meta =
    { logo = { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
    , tag = "Michigan, US 2026"
    , location = location
    , dates = "Mon 15th - Thur 18th June 2026"
    }


location : String
location =
    "🇨🇿 Olomouc, Czech Republic"


ticket :
    { attendanceTicket : String
    , offsite : String
    , campingSpot : String
    , singleRoom : String
    , doubleRoom : String
    , groupRoom : String
    }
ticket =
    { attendanceTicket = ""
    , offsite = ""
    , campingSpot = "prod_TmIy0Mltqmgzg5"
    , singleRoom = "prod_TmJ0n8liux9A3d"
    , doubleRoom = "prod_TmIzrbSouU0bYE"
    , groupRoom = ""
    }


sponsorship : { bronze : String, silver : String, gold : String }
sponsorship =
    { bronze = ""
    , silver = "prod_RzWTill7eglkFc"
    , gold = "prod_RzWVRbQ0spItOf"
    }


type alias Sponsorship =
    { name : String, price : Int, productId : String, description : String, features : List String }


sponsorshipItems : List Sponsorship
sponsorshipItems =
    [ { name = "Bronze"
      , price = 50000
      , productId = sponsorship.bronze
      , description = "You will be a minor supporter of Elm Camp 2026."
      , features =
            [ "Thank you tweet"
            , "Logo on website"
            , "Small logo on shared slide during the opening and closing sessions"
            ]
      }
    , { name = "Silver"
      , price = 100000
      , productId = sponsorship.silver
      , description = "You will be a major supporter of Elm Camp 2026."
      , features =
            [ "Thank you tweet"
            , "Logo on website"
            , "Small logo on shared slide during the opening and closing sessions"
            , "Small logo on a slide displayed between sessions throughout the event"
            , "One campfire ticket"
            ]
      }
    , { name = "Gold"
      , price = 250000
      , productId = sponsorship.gold
      , description = "You will be a pivotal supporter of Elm Camp 2026."
      , features =
            [ "Thank you tweet"
            , "Dedicated \"thank you\" slide during the opening and closing sessions"
            , "Large logo on a slide displayed between sessions throughout the event"
            , "Two campfire tickets or one single room ticket"
            , "A self-written snippet on the website about your use of Elm and an optional CTA if you are hiring"
            , "A rollup or poster (provided by you) visible inside the venue during the event"
            ]
      }
    ]


view : LoadedModel -> Element FrontendMsg
view model =
    Ui.column
        [ Ui.spacing 32 ]
        [ Ui.column
            (Ui.paddingXY 16 0 :: Theme.contentAttributes)
            [ header model
            , View.Sales.ticketSalesOpenCountdown ticketSalesOpenAt model.now
            , RichText.view model intro
            , View.Sales.view ticketTypes ticketSalesOpenAt model
            , RichText.view model venueAndAccess
            , organisers model.window
            , RichText.view model sponsors
            ]
        , Theme.footer
        ]


sponsors : List RichText
sponsors =
    [ Section
        "Our sponsors"
        [ Images
            [ [ { source = "/sponsors/scrive-logo.svg"
                , maxWidth = Just 400
                , link = Just "https://www.scrive.com/"
                , description = "Scrive's logo"
                }
              ]
            , [ { source = "/sponsors/concentrichealthlogo.svg"
                , link = Just "https://concentric.health/"
                , maxWidth = Just 250
                , description = "Concentric health's logo"
                }
              ]
            , [ { source = "/sponsors/scripta.io.svg", link = Just "https://scripta.io", maxWidth = Just 120, description = "Scripta IO's logo" }
              , { source = "/sponsors/elm-weekly-new.svg", link = Just "https://www.elmweekly.nl", maxWidth = Just 120, description = "Elm weekly's logo" }
              , { source = "/sponsors/lamdera-logo-black.svg", link = Just "https://lamdera.com/", maxWidth = Just 180, description = "Lamdera's logo" }
              ]
            ]
        ]
    ]


intro : List RichText
intro =
    [ Section "Elm Camp 2026 - Olomouc, Czechia"
        [ Paragraph [ Text "Elm Camp returns for its 4th year, this time in Olomouc, Czech Republic!" ]
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
    ]


currencyConversionAttribution : Element msg
currencyConversionAttribution =
    Ui.el [ Ui.link "https://www.exchangerate-api.com" ] (Ui.text "Rates By Exchange Rate API")


venueAndAccess : List RichText
venueAndAccess =
    [ Section
        "The venue and access"
        [ Section
            "The venue"
            [ Paragraph [ Bold "Hotel Prachárna", Text "\nKřelovská 91, 779 00 Olomouc 9\nŘepčín, Česko\nCzech Republic" ]
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


ticketSalesOpenAt : Time.Posix
ticketSalesOpenAt =
    -- 2025 Feb 28 12:00 GMT
    Time.millisToPosix 1772280000000


header : LoadedModel -> Element FrontendMsg
header config =
    let
        elmCampNextTopLine : Element FrontendMsg
        elmCampNextTopLine =
            Ui.column
                [ Ui.spacing 30 ]
                [ Ui.column
                    [ Ui.spacing 0 ]
                    [ Ui.el
                        [ Ui.width Ui.shrink
                        , Ui.Font.bold
                        , Ui.Font.color Theme.lightTheme.defaultText
                        , Ui.centerX
                        , Ui.Font.size 18
                        ]
                        (Ui.text location)
                    , Ui.el
                        [ Ui.width Ui.shrink
                        , Ui.Font.bold
                        , Ui.linkNewTab "https://www.hotel-pracharna.cz/en/"
                        , Ui.Font.color Theme.lightTheme.link
                        , Ui.Font.underline
                        , Ui.centerX
                        , Ui.Font.size 18
                        ]
                        (Ui.text "Park Hotel Prachárna")
                    ]
                , Ui.el
                    [ Ui.width Ui.shrink
                    , Ui.Font.bold
                    , Ui.Font.color Theme.lightTheme.defaultText
                    , Ui.centerX
                    , Ui.Font.size 18
                    ]
                    (Ui.text "Monday 15th - Thursday 18th June 2026")
                ]
    in
    if Theme.isMobile config.window then
        Ui.column
            [ Ui.width Ui.shrink, Ui.paddingXY 8 30, Ui.spacing 20, Ui.centerX ]
            [ Ui.column
                [ Ui.width Ui.shrink, Ui.spacing 24, Ui.centerX ]
                [ Ui.column
                    [ Ui.spacing 8 ]
                    [ Ui.html (View.Logo.view 200 config.logoModel)
                        |> Ui.el [ Ui.centerX, Ui.move { x = -10, y = 0, z = 0 } ]
                        |> Ui.map Types.LogoMsg
                    , Ui.column
                        [ Ui.width Ui.shrink
                        , Ui.centerX
                        , Ui.Font.size 54
                        , Theme.glow
                        , Ui.Font.lineHeight 1
                        , Ui.spacing 8
                        , Ui.alignTop
                        , Ui.link (Route.encode Nothing Route.HomepageRoute)
                        ]
                        [ Ui.text "Elm Camp"
                        , Ui.row
                            [ Ui.width Ui.shrink, Ui.Font.size 27, Ui.contentCenterY, Ui.paddingXY 4 0 ]
                            [ Ui.el
                                [ Ui.width Ui.shrink, Theme.glow, Ui.Font.lineHeight 1, Ui.Font.exactWhitespace ]
                                (Ui.text "Unconference ")
                            , year
                            ]
                        ]
                    ]
                , elmCampNextTopLine
                ]
            ]

    else
        Ui.row
            [ Ui.width Ui.shrink, Ui.padding 30, Ui.spacing 40, Ui.centerX ]
            [ Ui.column
                [ Ui.width Ui.shrink, Ui.spacing 24 ]
                [ Ui.row
                    []
                    [ Ui.html (View.Logo.view 150 config.logoModel) |> Ui.el [ Ui.move { x = 0, y = -2, z = 0 } ] |> Ui.map Types.LogoMsg
                    , Ui.column
                        [ Ui.width Ui.shrink
                        , Ui.Font.size 64
                        , Theme.glow
                        , Ui.Font.lineHeight 1
                        , Ui.spacing 8
                        , Ui.paddingXY 16 0
                        , Ui.alignTop
                        , Ui.link (Route.encode Nothing Route.HomepageRoute)
                        ]
                        [ Ui.text "Elm Camp"
                        , Ui.row
                            [ Ui.width Ui.shrink, Ui.Font.size 32, Ui.contentCenterY, Ui.paddingXY 4 0 ]
                            [ Ui.el
                                [ Ui.width Ui.shrink, Theme.glow, Ui.Font.lineHeight 1, Ui.Font.exactWhitespace ]
                                (Ui.text "Unconference ")
                            , year
                            ]
                        ]
                    ]
                , elmCampNextTopLine
                ]
            ]


year : Element msg
year =
    Ui.el
        [ Ui.width Ui.shrink
        , Ui.Font.weight 800
        , Ui.Font.color Theme.lightTheme.elmText
        ]
        (Ui.text "2026")


organisers : Size -> Element msg
organisers window =
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
      , { country = "🇨🇿", name = "Tomas Latal", description = "Author of elm-debug-helper and several unfinished projects. Don’t ask him about Elm or Coderetreat, he will be talking about it for hours." }
      ]
    ]
        |> (\list2 ->
                if Theme.isMobile window then
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


maxAttendees : number
maxAttendees =
    80



--
--maxForAccommodationType : Accommodation -> number
--maxForAccommodationType t =
--    case t of
--        Offsite ->
--            -- Effectively no limit, the attendee limit should hit first
--            80
--
--        Campsite ->
--            20
--
--        Single ->
--            6
--
--        Double ->
--            15
--
--        Group ->
--            4


ticketTypes : TicketTypes
ticketTypes =
    { campfireTicket = campfireTicket
    , singleRoomTicket = singleRoomTicket
    , sharedRoomTicket = sharedRoomTicket
    }


campfireTicket : TicketType
campfireTicket =
    { name = "Camping Spot"
    , description = "Bring your own tent or campervan and stay on site. Showers & toilets provided."
    , image = ""
    , productId = Id.fromString "prod_TmIy0Mltqmgzg5"
    , getter = .campfireTicket
    , setter = \v m -> { m | campfireTicket = v }
    }


singleRoomTicket : TicketType
singleRoomTicket =
    { name = "Single Room"
    , description = "Private room for a single attendee for 3 nights."
    , image = ""
    , productId = Id.fromString "prod_TmJ0n8liux9A3d"
    , getter = .singleRoomTicket
    , setter = \v m -> { m | singleRoomTicket = v }
    }


sharedRoomTicket : TicketType
sharedRoomTicket =
    { name = "Shared Room"
    , description = "Suitable for a couple or twin share for 3 nights."
    , image = ""
    , productId = Id.fromString "prod_TmIzrbSouU0bYE"
    , getter = .sharedRoomTicket
    , setter = \v m -> { m | sharedRoomTicket = v }
    }
