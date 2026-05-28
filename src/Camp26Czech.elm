module Camp26Czech exposing
    ( TicketType
    , campfireTicket
    , detailedCountdown
    , header
    , maxAttendees
    , maxRooms
    , scheduleSection
    , sharedRoomTicket
    , singleRoomTicket
    , ticketSalesOpenAt
    , ticketSalesOpenCountdown
    , ticketTypes
    , view
    , viewTravel
    )

import Camp
import Effect.Browser.Dom as Dom
import Helpers
import Logo
import NonNegative exposing (NonNegative)
import PurchaseForm exposing (PurchaseForm, PurchaseFormValidated, TicketTypes)
import RichText exposing (Inline(..), RichText(..))
import Route
import Theme exposing (Size)
import Time
import Types exposing (CompletedOrder, FrontendMsg(..), LoadedModel)
import Ui exposing (Element)
import Ui.Font
import Ui.Prose
import Ui.Shadow


meta : Camp.Meta
meta =
    { logo = { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
    , tag = "Olomouc, Czech Republic 2026"
    , location = location
    , dates = "Mon 15th - Thur 18th June 2026"
    }


location : String
location =
    "🇨🇿 Olomouc, Czech Republic"


view : LoadedModel -> Element FrontendMsg
view model =
    Ui.column
        [ Ui.spacing 32 ]
        [ Ui.column
            []
            [ header model
            , ticketSalesOpenCountdown model
            , Ui.el Theme.contentAttributes (RichText.view model content)
            , Ui.el Theme.contentAttributes (organisers model.window)
            , sponsors model.window
            ]
        , Theme.footer
        ]


viewTravel : LoadedModel -> Element FrontendMsg
viewTravel model =
    Ui.column
        [ Ui.spacing 32 ]
        [ Ui.column
            []
            [ header model
            , Ui.el Theme.contentAttributes (RichText.view model [ travel ])
            , sponsors model.window
            ]
        , Theme.footer
        ]


ticketSalesOpenCountdown : LoadedModel -> Element FrontendMsg
ticketSalesOpenCountdown model =
    Ui.column
        (Ui.spacing 20 :: Theme.contentAttributes)
        (case detailedCountdown model.now of
            Nothing ->
                if Theme.isMobile model.window then
                    [ Ui.column
                        [ Ui.spacing 16 ]
                        [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.centerX ] goToTicketSales
                        , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.centerX ] goToOpportunityGrant
                        ]
                    ]

                else
                    [ Ui.row
                        []
                        [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.centerX ] goToTicketSales
                        , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.centerX ] goToOpportunityGrant
                        ]
                    ]

            Just countdownElement ->
                [ countdownElement

                --, DateFormat.format
                --    [ DateFormat.yearNumber
                --    , DateFormat.text "-"
                --    , DateFormat.monthFixed
                --    , DateFormat.text "-"
                --    , DateFormat.dayOfMonthFixed
                --    , DateFormat.text " "
                --    , DateFormat.hourMilitaryFixed
                --    , DateFormat.text ":"
                --    , DateFormat.minuteFixed
                --    ]
                --    timeZone
                --    ticketSalesOpenAt
                --    |> (\t ->
                --            Ui.el
                --                [ Ui.width Ui.shrink
                --                , Ui.centerX
                --                , Ui.paddingWith { bottom = 10, top = 10, left = 0, right = 0 }
                --                ]
                --                (Ui.text t)
                --       )
                , Ui.el
                    (Theme.submitButtonAttributes (Dom.id "downloadTicketSalesReminder") DownloadTicketSalesReminder True
                        ++ [ Ui.width (Ui.px 200)
                           , Ui.centerX
                           , Ui.Font.size 20
                           ]
                    )
                    (Ui.el [ Ui.width Ui.shrink, Ui.Font.center, Ui.centerX ] (Ui.text "Add to calendar"))
                , Ui.text " "
                ]
        )


detailedCountdown : Time.Posix -> Maybe (Element msg)
detailedCountdown now =
    let
        target2 =
            Time.posixToMillis ticketSalesOpenAt

        now2 =
            Time.posixToMillis now

        secondsRemaining =
            (target2 - now2) // 1000

        days =
            secondsRemaining // (60 * 60 * 24)

        hours =
            modBy 24 (secondsRemaining // (60 * 60))

        minutes =
            modBy 60 (secondsRemaining // 60)

        formatDays =
            if days > 1 then
                Just (String.fromInt days ++ " days")

            else if days == 1 then
                Just "1 day"

            else
                Nothing

        formatHours =
            if hours > 0 then
                Just (String.fromInt hours ++ "h")

            else
                Nothing

        formatMinutes =
            if minutes > 0 then
                Just (String.fromInt minutes ++ "m")

            else
                Nothing

        output =
            String.join " "
                (List.filterMap identity [ formatDays, formatHours, formatMinutes ])
    in
    if secondsRemaining < 0 then
        Nothing

    else
        Ui.Prose.paragraph
            (Theme.contentAttributes ++ [ Ui.Font.center ])
            [ Theme.h2 (output ++ " until\u{00A0}ticket\u{00A0}sales\u{00A0}open") ]
            |> Just


goToTicketSales : Element FrontendMsg
goToTicketSales =
    Ui.el
        [ Ui.width Ui.fill
        , Ui.background (Ui.rgb 255 172 98)
        , Ui.paddingXY 24 16
        , Ui.rounded 8
        , Ui.Font.color (Ui.rgb 0 0 0)
        , Ui.alignBottom
        , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 2, color = Ui.rgba 0 0 0 0.1 } ]
        , Ui.Font.weight 600
        , Ui.link (Route.encode Nothing Route.TicketPurchaseRoute)
        ]
        (Ui.text "Tickets now on sale!")


goToOpportunityGrant : Element FrontendMsg
goToOpportunityGrant =
    Ui.el
        [ Ui.width Ui.fill
        , Ui.background (Ui.rgb 92 176 126)
        , Ui.paddingXY 24 16
        , Ui.rounded 8
        , Ui.Font.color (Ui.rgb 255 255 255)
        , Ui.alignBottom
        , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 2, color = Ui.rgba 0 0 0 0.1 } ]
        , Ui.Font.weight 600
        , Ui.link (Route.encode Nothing Route.OpportunityGrantRoute)
        ]
        (Ui.text "Opportunity grants available!")


sponsors : Size -> Element FrontendMsg
sponsors windowSize =
    Ui.column
        (Ui.spacing 16 :: Theme.contentAttributes)
        [ Ui.html (RichText.h1 windowSize "Our sponsors")
        , Ui.column
            [ Ui.spacing 24 ]
            [ sponsorImage
                { source = "/sponsors/scrive-logo.svg"
                , maxWidth = 400
                , link = "https://www.scrive.com/"
                , description = "Scrive's logo"
                }
            , Ui.row
                [ Ui.spacing 16 ]
                [ sponsorImage
                    { source = "/sponsors/concentrichealthlogo.svg"
                    , link = "https://concentric.health/"
                    , maxWidth = 250
                    , description = "Concentric health's logo"
                    }
                , sponsorImage
                    { source = "/sponsors/logo-dividat.svg"
                    , link = "https://dividat.com/"
                    , maxWidth = 250
                    , description = "Dividat's logo"
                    }
                ]
            , Ui.row
                [ Ui.spacing 8 ]
                [ sponsorImage
                    { source = "/sponsors/scripta.io.svg"
                    , link = "https://scripta.io"
                    , maxWidth = 120
                    , description = "Scripta IO's logo"
                    }
                , sponsorImage
                    { source = "/sponsors/elm-weekly-new.svg"
                    , link = "https://www.elmweekly.nl"
                    , maxWidth = 120
                    , description = "Elm weekly's logo"
                    }
                , sponsorImage
                    { source = "/sponsors/lamdera-logo-black.svg"
                    , link = "https://lamdera.com/"
                    , maxWidth = 180
                    , description = "Lamdera's logo"
                    }
                ]
            ]
        ]


sponsorImage : { source : String, maxWidth : Int, link : String, description : String } -> Element b
sponsorImage { source, maxWidth, link, description } =
    Ui.image
        [ Ui.linkNewTab link, Ui.widthMax maxWidth ]
        { source = source
        , description = description
        , onLoad = Nothing
        }
        |> Ui.el []


scheduleSection : String
scheduleSection =
    "Prospective Schedule"


content : List RichText
content =
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
    , Section scheduleSection
        [ BulletList
            [ Bold "Mon 15th June" ]
            [ Paragraph [ Text "3pm arrivals & halls officially open" ]
            , Paragraph [ Text "Settle into accomodation" ]
            , Paragraph [ Text "Opening of session board" ]
            , Paragraph [ Text "Dinner" ]
            , Paragraph [ Text "Evening stroll" ]
            ]
        , BulletList
            [ Bold "Tue 16th June" ]
            [ Paragraph [ Text "Breakfast" ]
            , Paragraph [ Text "Unconference sessions" ]
            , Paragraph [ Text "Lunch" ]
            , Paragraph [ Text "Unconference sessions" ]
            , Paragraph [ Text "Dinner" ]
            , Paragraph [ Text "Activities and informal chats" ]
            ]
        , BulletList
            [ Bold "Wed 17th June" ]
            [ Paragraph [ Text "Breakfast" ]
            , Paragraph [ Text "Unconference sessions" ]
            , Paragraph [ Text "Lunch" ]
            , Paragraph [ Text "Unconference sessions" ]
            , Paragraph [ Text "Dinner" ]
            , Paragraph [ Text "Unconference wrap-up & party" ]
            ]
        , BulletList
            [ Bold "Thu 18th June" ]
            [ Paragraph [ Text "Grab and go breakfast" ]
            , Paragraph [ Text "Depart hotel by 10am" ]
            , Paragraph [ Text "Activities around Olomouc" ]
            ]
        ]
    , Section
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
        , Section
            "Travel guide"
            [ Paragraph
                [ Text "See our "
                , Link "travel guide" Route.TravelRoute
                , Text " for travel options and information about the location."
                ]
            ]
        ]
    , Section "Organisers"
        [ Paragraph [ Text "Elm Camp is a community-driven non-profit initiative, organised by enthusiastic members of the Elm community." ]
        ]
    ]


travel : RichText
travel =
    Section "How to get there"
        [ Paragraph
            [ Text "Elm Camp 2026 is happening at "
            , Bold "Park Hotel Prachárna"
            , Text " on the leafy north-western edge of Olomouc, Czechia, "
            , Bold "15–18 June 2026"
            , Text ". Most of you will arrive on "
            , Bold "Monday, 15 June"
            , Text ". This page should help you plan the last leg of your journey."
            ]
        , Paragraph
            [ Text "Olomouc sits right on the main rail corridor between Prague, Vienna, Bratislava and Krakow. Using your preferred mode of transport for "
            , Bold "arriving to one of those four cities and continuing by train is by far the most pleasant option"
            , Text " — fast, scenic, no airport queues, and you arrive in the middle of town."
            ]
        , HorizontalLine
        , Section "1. Pick your gateway airport"
            [ Paragraph
                [ Text "Any of these work well; pick whichever has the best/cheapest flight for you."
                ]
            , Section "From Prague (PRG) — easiest, most frequent"
                [ BulletList []
                    [ Paragraph
                        [ Bold "Prague Airport → Praha hlavní nádraží (Prague main station)"
                        , Text ": the cheapest way is "
                        , Bold "city bus 119"
                        , Text " to "
                        , Italic "Nádraží Veleslavín"
                        , Text ", then "
                        , Bold "Metro line A (green)"
                        , Text " to "
                        , Italic "Hlavní nádraží"
                        , Text ". The whole ride takes ~45 min and a single 90-min PID public-transport ticket (~40 CZK / "
                        , Bold "€1.60"
                        , Text ") covers it all. There's also the Airport Express bus (AE) straight to the main station for ~100 CZK / €4 if you prefer fewer transfers."
                        ]
                    , Paragraph
                        [ Bold "Praha hl.n. → Olomouc hl.n."
                        , Text ": 2h ~20m on a direct train, "
                        , Bold "multiple departures per hour"
                        , Text " from morning until late evening, run by "
                        , Bold "České dráhy (ČD)"
                        , Text ", "
                        , Bold "RegioJet"
                        , Text " and "
                        , Bold "Leo Express"
                        , Text ". Tickets typically "
                        , Bold "€8–25"
                        , Text " depending on how far ahead you book."
                        ]
                    ]
                ]
            , Section "From Vienna (VIE)"
                [ BulletList []
                    [ Paragraph
                        [ Bold "VIE Airport → Wien Hauptbahnhof"
                        , Text ": take the S7 S-Bahn (~25 min, ~€4) or the CAT/Railjet (faster, ~€12)."
                        ]
                    , Paragraph
                        [ Bold "Wien Hbf → Olomouc hl.n."
                        , Text ": roughly "
                        , Bold "2h 30m–3h"
                        , Text ", with departures roughly hourly. "
                        , Bold "Most connections involve one change"
                        , Text " — usually at "
                        , Bold "Břeclav"
                        , Text " or "
                        , Bold "Přerov"
                        , Text " — and are run by ČD or ÖBB. There are also a few direct services (e.g. RegioJet). Tickets typically "
                        , Bold "€12–30"
                        , Text "."
                        ]
                    ]
                ]
            , Section "From Bratislava (BTS)"
                [ BulletList []
                    [ Paragraph
                        [ Bold "BTS Airport → Bratislava hl. st."
                        , Text ": city bus 61 to the main station (~25 min, ~€1)."
                        ]
                    , Paragraph
                        [ Bold "Bratislava hl. st. → Olomouc hl.n."
                        , Text ": ~2h 50m–3h 30m. "
                        , Bold "Leo Express"
                        , Text " runs a direct service; ČD and RegioJet options usually involve a single change at Břeclav or Přerov. Tickets typically "
                        , Bold "€10–25"
                        , Text "."
                        ]
                    ]
                ]
            , Section "From Krakow (KRK)"
                [ BulletList []
                    [ Paragraph
                        [ Bold "KRK Airport → Kraków Główny"
                        , Text ": there's a direct train running every ~30 min, ~20 min journey (~€4)."
                        ]
                    , Paragraph
                        [ Bold "Kraków Główny → Olomouc hl.n."
                        , Text ": ~3h 30m. "
                        , Bold "České dráhy (ČD)"
                        , Text ", "
                        , Bold "Leo Express"
                        , Text " and "
                        , Bold "RegioJet"
                        , Text " all run direct services on this route. There's also a more frequent option with one change at Bohumín or Ostrava. Tickets typically "
                        , Bold "€10–25"
                        , Text "."
                        ]
                    ]
                ]
            ]
        , Section "2. Buying train tickets"
            [ Paragraph
                [ Text "You don't need to book months in advance — Czech domestic trains are usually fine to buy on the day — but for international legs and for the cheaper fare buckets, "
                , Bold "booking a few days ahead is worth it"
                , Text "."
                ]
            , Paragraph
                [ Text "The three operators on the routes above are all good. Pick whichever has the time/price you prefer:"
                ]
            , BulletList []
                [ Paragraph
                    [ ExternalLink "cd.cz" "https://www.cd.cz/en/"
                    , Text " — Czech Railways (ČD). The widest network and the only operator you can rely on for everything. Tickets are flexible and refundable for a small fee. Good English site."
                    ]
                , Paragraph
                    [ ExternalLink "regiojet.com" "https://regiojet.com"
                    , Text " — comfortable seats, free water/coffee on board, on-board WiFi. Tickets are tied to a specific train."
                    ]
                , Paragraph
                    [ ExternalLink "leoexpress.com" "https://www.leoexpress.com/en/"
                    , Text " — also comfortable, good for the Krakow and Bratislava direct routes, but on the pricey side."
                    ]
                ]
            , Paragraph
                [ Text "You can also compare/book via "
                , ExternalLink "Omio" "https://www.omio.com"
                , Text " or "
                , ExternalLink "Trainline" "https://www.thetrainline.com"
                , Text " if you prefer a single interface."
                ]
            , Paragraph
                [ Text "The Olomouc station name is "
                , Bold "Olomouc hlavní nádraží"
                , Text " (\"hl.n.\" for short)."
                ]
            ]
        , Section "3. Buses (a fine plan B)"
            [ Paragraph
                [ Text "If a train doesn't suit you, long-distance coaches into Olomouc are cheap, comfortable and have WiFi. Two operators serve Olomouc directly from all four gateway cities:"
                ]
            , BulletList []
                [ Paragraph
                    [ ExternalLink "RegioJet" "https://regiojet.com"
                    , Text " (formerly known as Student Agency)"
                    ]
                , Paragraph
                    [ ExternalLink "FlixBus" "https://www.flixbus.com"
                    ]
                ]
            , Paragraph
                [ Text "Both stop at the "
                , Bold "Olomouc central bus station (autobusové nádraží)"
                , Text ", which is a short ~5 min walk from the main train station — not the same building, but very close."
                ]
            ]
        , Section "4. Arriving in Olomouc — meeting point"
            [ Paragraph
                [ Text "Once you reach "
                , Bold "Olomouc hlavní nádraží"
                , Text " on Monday 15 June, head to:"
                ]
            , QuoteBlock
                [ Bold "Love Coffee"
                , Text " — Masarykova třída 56, ~3 min walk from the station along Masarykova třída.\nopening hours on Monday: 7:00 - 18:00"
                ]
            , Paragraph
                [ Text "It's a small, friendly café on the way from the station to the city centre. We'll be there for a good chunk of the day and we'll be running a "
                , Bold "taxi shuttle from Love Coffee to Park Hotel Prachárna"
                , Text " throughout the afternoon. Just turn up, grab a coffee, and we'll get you to the venue.\nPersonel would know about you, so just say that you are an Elm Camp attendee."
                ]
            , Paragraph
                [ Text "We'll try to be at the cafe around the times of your arrivals that you specify in the survey, so please fill them in."
                ]
            ]
        , Section "5. Getting yourself to the venue"
            [ Paragraph
                [ Text "If you arrive outside the shuttle hours, miss us, or just prefer to make your own way, the venue is at:"
                ]
            , QuoteBlock
                [ Bold "Park Hotel Prachárna"
                , Text "\nKřelovská 91, 779 00 Olomouc\n"
                , ExternalLink "hotel-pracharna.cz" "https://hotel-pracharna.cz/"
                ]
            , Paragraph
                [ Text "It's about "
                , Bold "5 km north-west of the centre"
                , Text ". You have three options:"
                ]
            , Paragraph
                [ Bold "Option A — Bolt or taxi (easiest)."
                , Text " Both "
                , ExternalLink "Bolt" "https://bolt.eu"
                , Text " and local taxis work fine in Olomouc. Bolt is usually cheaper; expect "
                , Bold "~150–250 CZK / €6–10"
                , Text " from the train station to the hotel. There's also a taxi rank right outside the station on the right side."
                ]
            , Paragraph
                [ Bold "Option B — DPMO city bus 302 or 392 to "
                , Italic "Motel Prachárna"
                , Text " (cheapest, direct). Both lines stop right outside the hotel at the "
                , Bold "Motel Prachárna"
                , Text " stop. The journey is ~15 min and a single ticket is just "
                , Bold "25 CZK / ~€1"
                , Text " (zone 71 tariff). Buy tickets at the yellow vending machines at major stops, in the "
                , ExternalLink "DPMO app" "https://www.dpmo.cz/"
                , Text ", or contactless on board. Check live departures on "
                , ExternalLink "idos.cz" "https://idos.cz"
                , Text "."
                ]
            , Paragraph
                [ Bold "Option C — Tram or city bus to "
                , Italic "Hřbitovy"
                , Text ", then walk. Take a DPMO tram or bus toward the "
                , Bold "Hřbitovy"
                , Text " stop (north-west of the centre), then walk ~10–15 min to the hotel. Same fare as Option B (~€1). You can also Bolt the last stretch if you prefer."
                ]
            ]
        , Section "A few practical notes"
            [ BulletList []
                [ Paragraph
                    [ Bold "Currency"
                    , Text ": Czechia uses the "
                    , Bold "Czech koruna (CZK)"
                    , Text ", not the euro. ATMs are everywhere; cards are accepted nearly everywhere too. Avoid the Euronet ATMs at the station — their rates are bad. Use a bank-branded ATM (KB, ČSOB, Česká spořitelna, Raiffeisenbank)."
                    ]
                , Paragraph
                    [ Bold "Language"
                    , Text ": Czech, but English will get you by easily in cafés, taxis, and at the hotel. A \"dobrý den\" (hello) and \"děkuju\" (thanks) will earn you smiles."
                    ]
                , Paragraph
                    [ Bold "Phone & data"
                    , Text ": Czechia is in the EU roaming zone, so EU SIMs work without surcharges."
                    ]
                , Paragraph
                    [ Bold "Power"
                    , Text ": "
                    , ExternalLink "Type E sockets" "https://www.worldstandards.eu/electricity/plugs-and-sockets/e/"
                    , Text " (same as most of continental Europe), 230V."
                    ]
                ]
            , Paragraph
                [ Text "If anything is unclear or your route isn't covered above, "
                , Bold "drop us a line"
                , Text " — we're happy to help you figure out the best way in."
                ]
            , Paragraph
                [ Text "See you at Camp! 🌲"
                ]
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
            [ Ui.width Ui.shrink, Ui.paddingXY 24 30, Ui.spacing 20, Ui.centerX ]
            [ Ui.column
                [ Ui.width Ui.shrink, Ui.spacing 24, Ui.centerX ]
                [ Ui.column
                    [ Ui.spacing 8 ]
                    [ Ui.html (Logo.view 200 config.logoModel)
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
                    [ Ui.html (Logo.view 150 config.logoModel) |> Ui.el [ Ui.move { x = 0, y = -2, z = 0 } ] |> Ui.map Types.LogoMsg
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


maxRooms : number
maxRooms =
    40


maxAttendees : number
maxAttendees =
    80


ticketTypes : TicketTypes TicketType
ticketTypes =
    { campfireTicket = campfireTicket
    , singleRoomTicket = singleRoomTicket
    , sharedRoomTicket = sharedRoomTicket
    }


type alias TicketType =
    { name : String
    , description : String
    , image : String
    , available : TicketTypes NonNegative -> TicketTypes NonNegative -> Bool
    }


campfireTicket : TicketType
campfireTicket =
    { name = "Attendance only"
    , description = "Book a room offsite or bring your own tent or campervan and stay on site. Showers & toilets provided."
    , image = ""
    , available = attendeesAreValid
    }


singleRoomTicket : TicketType
singleRoomTicket =
    { name = "Single Room with en-suite"
    , description = "Private room for a single attendee for 3 nights."
    , image = ""
    , available =
        \alreadyPurchased count ->
            attendeesAreValid alreadyPurchased count && roomsAreValid alreadyPurchased count
    }


attendeesAreValid : TicketTypes NonNegative -> TicketTypes NonNegative -> Bool
attendeesAreValid ticketsAlreadyPurchased count =
    PurchaseForm.totalTickets ticketsAlreadyPurchased + PurchaseForm.totalTickets count <= maxAttendees


roomsAreValid : TicketTypes NonNegative -> TicketTypes NonNegative -> Bool
roomsAreValid ticketsAlreadyPurchased count =
    List.sum
        [ NonNegative.toInt count.singleRoomTicket * 2
        , NonNegative.toInt count.sharedRoomTicket
        , NonNegative.toInt ticketsAlreadyPurchased.singleRoomTicket * 2
        , NonNegative.toInt ticketsAlreadyPurchased.sharedRoomTicket
        ]
        <= (maxRooms * 2)


sharedRoomTicket : TicketType
sharedRoomTicket =
    { name = "Shared Room with en-suite"
    , description = "Suitable for couples or up to 4 individuals sharing for 3 nights. Both twin and double beds available. If you are booking separately, please let us know who you expect to be sharing with."
    , image = ""
    , available =
        \alreadyPurchased count ->
            attendeesAreValid alreadyPurchased count && roomsAreValid alreadyPurchased count
    }
