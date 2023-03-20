module Frontend exposing (app)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Element)
import Element.Font
import Html exposing (Html)
import Html.Attributes as Attr
import Lamdera
import MarkdownThemed
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , message = "Welcome to Lamdera! You're looking at the auto-generated base implementation. Check out src/Frontend.elm to start coding!"
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


fontFace : Int -> String -> String
fontFace weight name =
    """
@font-face {
  font-family: 'Open Sans';
  font-style: normal;
  font-weight: """ ++ String.fromInt weight ++ """;
  font-stretch: normal;
  font-display: swap;
  src: url(/fonts/""" ++ name ++ """.ttf) format('truetype');
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD, U+2192, U+2713;
}"""


css : Html msg
css =
    Html.node "style"
        []
        [ Html.text <|
            fontFace 800 "Figtree-ExtraBold"
                ++ fontFace 700 "Figtree-Bold"
                ++ fontFace 600 "Figtree-SemiBold"
                ++ fontFace 500 "Figtree-Medium"
                ++ fontFace 400 "Figtree-Regular"
                ++ fontFace 300 "Figtree-Light"
        ]


colors =
    MarkdownThemed.lightTheme


colorWithAlpha : Float -> Element.Color -> Element.Color
colorWithAlpha alpha color =
    let
        { red, green, blue } =
            Element.toRgb color
    in
    Element.rgba red green blue alpha


header : Element msg
header =
    let
        glow =
            Element.Font.glow (colorWithAlpha 0.25 colors.defaultText) 4
    in
    Element.row
        [ Element.width Element.fill, Element.spacing 40 ]
        [ Element.image
            [ Element.width (Element.px 523) ]
            { src = "/logo.webp", description = "Elm camp logo" }
        , Element.column
            [ Element.spacing 24 ]
            [ Element.el
                [ Element.Font.size 80
                , glow
                ]
                (Element.text "Elm Camp")
            , Element.row
                [ Element.centerX, Element.spacing 13 ]
                [ Element.image
                    [ Element.width (Element.px 49) ]
                    { src = "/elm-camp-tangram.webp", description = "Elm camp logo" }
                , Element.column
                    [ Element.spacing 2, Element.Font.size 24, Element.moveUp 1 ]
                    [ Element.el [ glow ] (Element.text "Unconference")
                    , Element.el [ Element.Font.extraBold, Element.Font.color colors.elmText ] (Element.text "Europe 2023")
                    ]
                ]
            , Element.column
                [ glow, Element.Font.size 16, Element.centerX, Element.spacing 2 ]
                [ Element.el [ Element.Font.bold, Element.centerX ] (Element.text "Wed 28th - Fri 30th June")
                , Element.text "🇩🇰 Dallund Castle, Denmark"
                ]
            ]
        ]


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ css
        , Element.layout
            [ Element.width Element.fill
            , Element.Font.color colors.defaultText
            , Element.Font.size 16
            , Element.Font.medium
            ]
            (Element.column
                [ Element.width (Element.maximum 1000 Element.fill), Element.centerX ]
                [ header
                , content1
                , stripe
                , content2
                ]
            )
        ]
    }


stripe : Element msg
stripe =
    Html.node "stripe-pricing-table"
        [ Attr.attribute "pricing-table-id" "prctbl_1MlWUcHHD80VvsjKINsykCtd"
        , Attr.attribute "publishable-key" "pk_live_dIdCQ17pxxCWIeRJ5ZuJ4Ynm00FgRhZ4jR"
        ]
        []
        |> Element.html
        |> Element.el [ Element.width Element.fill ]


content1 =
    """
Elm Camp brings an opportunity for Elm makers & tool builders to gather, communicate and collaborate. Our goal is to strengthen and sustain the Elm ecosystem and community.

Elm Camp is an event geared towards reconnecting in-person and collaborating on the current and future community landscape of the Elm ecosystem that surrounds the Elm core language.

Over the last few years Elm has seen community-driven tools and libraries expanding the potential and utility of the Elm language, stemming from a steady pace of continued commercial and hobbyist adoption.

There is great potential for progress and innovation in a creative, focussed, in-person gathering. It’s been a long while since we’ve had this opportunity for folks who are investing in the future of Elm. We expect the wider community and practitioners to benefit from this collaborative exploration of our problems and goals.

Elm Camp is the first Elm Unconference. Our intention is to debut as a small, casual and low-stress event, paving the way for future Elm Camps across the world.

# The Unconference

* Arrive 3pm Wed 28 June
* Depart 4pm Fri 30 June
* Dallund Castle, Denmark
* Daily opener un-keynote
* Collaborative session creation throughout
* Countless hallway conversations and mealtime connections
* Access to full castle grounds including lake swimming
* 40 attendees ℹ️
"""
        |> MarkdownThemed.renderFull


content2 =
    """
# Tickets

## Camp Ticket: €550

* 2 nights on-site accommodation in private room with ensuite
* One 2-day attendee ticket
* Breakfast, lunch, tea & dinner included

## Couple’s Camp Tickets: €950

* 2 nights on-site accommodation in private room with ensuite
* Two 2-day attendee tickets
* Breakfast, lunch, tea & dinner included

## Campfire Ticket: €300

* 2 day attendee ticket
* Lunch, tea & dinner included
* Up to 16 available


The venue has a capacity of 24 rooms, and 50 total attendees (i.e. on-site + external). Our plan is to prioritise ticket sales in the following order: Couple’s Camp tickets, Camp tickets, Campfire attendee tickets.

# Schedule

## Wed 28th June

* 3pm - Arrivals & halls officially open
* 6pm - Opening of session board
* 7pm - Informal dinner
* 8:30pm+ Evening stroll and informal chats
* 9:57pm - 🌅Sunset

## Thu 29th June

* 7am-9am - Breakfast
* 9am - Opening Unkeynote
* 10am-12pm - Unconference sessions
* 12-1:30pm - Lunch
* 2pm-5pm Unconference sessions
* 6-7:30pm Dinner
* Onwards - Board Games and informal chats

## Fri 30th June

* 7am-9am - Breakfast
* 9am - 12pm Unconference sessions
* 12-1:30pm - Lunch
* 2- Closing Unkeynote
* 3pm unconfernce wrap-up
* 4pm - Departure


All meals are organic or biodynamic and the venue can accommodate individual allergies & intolerances. Lunches will be vegetarian, dinners will include free ranging & organic meat with a vegetarian option.

# Organisers

Elm Camp is a community-driven non-profit initiative, organised by enthusiastic members of the Elm community.

🇬🇧 Katja Mordaunt – Uses web tech to help improve the reach of charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of codereading.club

🇺🇸 James Carlson – Worked for many years as a math professor. Trying to learn type theory, which combines philosophy, logic, mathematics, and functional programming.

🇸🇪 Martin Stewart – Makes games and apps using Lamdera. Also runs the state-of-elm survey every year.

🇨🇿 Martin Janiczek – Loves to start things and one-off experiments, has a drive for teaching and unblocking others. Regularly races for the first answer in Elm Slack #beginners and #help.

🇬🇧 Mario Rogic – Organiser of the Elm London and Elm Online meetups. Groundskeeper of Elmcraft, founder of Lamdera.

🇩🇪 Johannes Emerich – Works at Dividat, making a console with small games and a large controller. Remembers when Elm demos were about the intricacies of how high Super Mario jumps.


# Sponsorship options

Sponsors will position themselves as leading supporters of the Elm community and help Elm Camp Europe 2023 achieve a reasonable ticket offering so that people can attend regardless of their financial circumstance.

## Bronze - less than €1000 EUR

You will be an appreciated supporter of Elm Camp Europe 2023.

* Listed as additional supporter on webpage

## Silver - €1000 EUR  (£880 / USD$1100)
You will be a major supporter of Elm Camp Europe 2023.

* Thank you tweet
* Logo on webpage
* Small logo on shared slide, displayed during breaks

## Gold - €2500 EUR  (£2200 / USD$2700)

You will be a pivotal supporter of Elm Camp Europe 2023.

* Thank you tweet
* Rollup or poster inside the venue (provided by you)
* Logo on webpage
* Medium logo on shared slide, displayed during breaks
* 1 free camp ticket

## Platinum - €5000 EUR  (£4500 / USD$5300)
You will be principal sponsor and guarantee that Elm Camp Europe 2023 is a success.

* Thank you tweet
* Rollup or poster inside the venue (provided by you)
* Self-written snippet on shared web page about use of Elm at your company
* Logo on webpage
* 2 free camp tickets
* Big logo on shared slide, displayed during breaks
* Honorary mention in opening and closing talks

## Addon: Attendee Sponsor – €500
You will make it possible for a student and/or underprivileged community member to attend Elm Camp Europe 2023.

# Something else?

Problem with something above? Get in touch with the team at [hello@elm.camp](hello@elm.camp).

"""
        |> MarkdownThemed.renderFull
