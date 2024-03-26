module Camp23Denmark.Archive exposing (view)

import Browser exposing (UrlRequest(..))
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import MarkdownThemed
import PurchaseForm exposing (PressedSubmit(..), PurchaseFormValidated, SubmitStatus(..))
import Route exposing (Route(..), SubPage(..))
import Stripe exposing (ProductId(..))
import Theme
import Types exposing (..)


view model =
    Element.column
        [ Element.width Element.fill, Element.spacing 40 ]
        [ Element.column
            Theme.contentAttributes
            [ content1, unconferenceBulletPoints model ]
        , if model.window.width > 950 then
            [ "image1.webp", "image2.webp", "image3.webp", "image4.webp", "image5.webp", "image6.webp" ]
                |> List.map (dallundCastleImage (Element.px 288))
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
                            (List.map (dallundCastleImage Element.fill) paths)
                    )
                |> Element.column [ Element.spacing 10, Element.width Element.fill ]
        , Element.column
            Theme.contentAttributes
            [ MarkdownThemed.renderFull "# Our sponsors"
            , sponsors model.window
            ]
        , Element.column
            [ Element.width Element.fill
            , Element.spacing 24
            ]
            [ Element.el Theme.contentAttributes content2
            , Element.el Theme.contentAttributes content3
            ]
        ]


dallundCastleImage : Element.Length -> String -> Element msg
dallundCastleImage width path =
    Element.image
        [ Element.width width ]
        { src = "/23-denmark/" ++ path, description = "Photo of part of the Dallund Castle" }


content1 : Element msg
content1 =
    """
Elm Camp brings an opportunity for Elm makers & tool builders to gather, communicate and collaborate. Our goal is to strengthen and sustain the Elm ecosystem and community.

Elm Camp is an event geared towards reconnecting in-person and collaborating on the current and future community landscape of the Elm ecosystem that surrounds the Elm core language.

Over the last few years, Elm has seen community-driven tools and libraries expanding the potential and utility of the Elm language, stemming from a steady pace of continued commercial and hobbyist adoption.

There is great potential for progress and innovation in a creative, focused, in-person gathering. It’s been a long while since we’ve had this opportunity for folks who are investing in the future of Elm. We expect the wider community and practitioners to benefit from this collaborative exploration of our problems and goals.

Elm Camp is the first Elm Unconference. Our intention is to debut as a small, casual and low-stress event, paving the way for future Elm Camps across the world.

# The Unconference

"""
        |> MarkdownThemed.renderFull


unconferenceBulletPoints : LoadedModel -> Element FrontendMsg_
unconferenceBulletPoints model =
    [ Element.text "Arrive 3pm Wed 28 June"
    , Element.text "Depart 4pm Fri 30 June"
    , Element.text "Dallund Castle, Denmark"
    , Element.text "Daily opener un-keynote"
    , Element.text "Collaborative session creation throughout"
    , Element.text "Countless hallway conversations and mealtime connections"
    , Element.text "Access to full castle grounds including lake swimming"
    , Element.el
        [ (if model.showTooltip then
            tooltip "This is our first Elm Unconference, so we're starting small and working backwards from a venue. We understand that this might mean some folks miss out this year – we plan to take what we learn & apply it to the next event. If you know of a bigger venue that would be suitable for future years, please let the team know!"

           else
            Element.none
          )
            |> Element.below
        ]
        (Element.Input.button
            []
            { onPress = Just PressedShowTooltip, label = Element.text "50 attendees ℹ️" }
        )
    ]
        |> List.map (\point -> MarkdownThemed.bulletPoint [ point ])
        |> Element.column [ Element.spacing 15 ]


tooltip : String -> Element msg
tooltip text =
    Element.paragraph
        [ Element.paddingXY 12 8
        , Element.Background.color (Element.rgb 1 1 1)
        , Element.width (Element.px 300)
        , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = Element.rgba 0 0 0 0.25 }
        ]
        [ Element.text text ]


content2 : Element msg
content2 =
    """
# Opportunity grants

**Thanks to Concentric and generous individual sponsors for making the opportunity grants possible**.


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
* 2pm Closing Unkeynote
* 3pm unconference wrap-up
* 4pm - Departure

# Travel and Accommodation

Elm Camp takes place at Dallund Castle near Odense in Denmark.

Odense can be reached directly by train from Hamburg, Copenhagen and other locations in Denmark. Denmark has multiple airports for attendants arriving from distant locations.

Dallund Castle itself offers 24 rooms, additional accommodation can be found in Odense.

All meals are organic or biodynamic and the venue can accommodate individual allergies & intolerances. Lunches will be vegetarian, dinners will include free-range & organic meat with a vegetarian option.

More details can be found on our [venue & access page](/venue-and-access).

# Organisers

Elm Camp is a community-driven non-profit initiative, organised by enthusiastic members of the Elm community.

🇬🇧 Katja Mordaunt – Uses web tech to help improve the reach of charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of codereading.club

🇺🇸 James Carlson – Developer of [Scripta.io](https://scripta.io), a web publishing platform for technical documents in mathematics, physics, and the like. Currently working for [exosphere.app](https://exosphere.app), an all-Elm cloud-computing project

🇸🇪 Martin Stewart – Makes games and apps using Lamdera. Also runs the state-of-elm survey every year.

🇨🇿 Martin Janiczek – Loves to start things and one-off experiments, has a drive for teaching and unblocking others. Regularly races for the first answer in Elm Slack #beginners and #help.

🇬🇧 Mario Rogic – Organiser of the Elm London and Elm Online meetups. Groundskeeper of Elmcraft, founder of Lamdera.

🇩🇪 Johannes Emerich – Works at Dividat, making a console with small games and a large controller. Remembers when Elm demos were about the intricacies of how high Super Mario jumps."""
        |> MarkdownThemed.renderFull


content3 =
    """
# Something else?

Problem with something above? Get in touch with the team at [team@elm.camp](mailto:team@elm.camp)."""
        |> MarkdownThemed.renderFull


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
    [ asImg { image = "vendr.png", url = "https://www.vendr.com/", width = 250 }
    , asImg { image = "concentrichealthlogo.svg", url = "https://concentric.health/", width = 250 }
    , asImg { image = "logo-dividat.svg", url = "https://dividat.com", width = 170 }
    , asImg { image = "lamdera-logo-black.svg", url = "https://lamdera.com/", width = 200 }
    , asImg { image = "scripta.io.svg", url = "https://scripta.io", width = 200 }
    , asImg { image = "bekk.svg", url = "https://www.bekk.no/", width = 200 }
    , Element.newTabLink
        [ Element.width Element.fill ]
        { url = "https://www.elmweekly.nl"
        , label =
            Element.row [ Element.spacing 10, Element.width (Element.px 200) ]
                [ Element.image
                    [ Element.width
                        (Element.px
                            (if window.width < 800 then
                                toFloat 60 * 0.7 |> round

                             else
                                60
                            )
                        )
                    ]
                    { src = "/sponsors/" ++ "elm-weekly.svg", description = "https://www.elmweekly.nl" }
                , Element.el [ Element.Font.size 24 ] <| Element.text "Elm Weekly"
                ]
        }
    , asImg { image = "cookiewolf-logo.png", url = "", width = 220 }
    ]
        -- |> List.map asImg
        |> Element.wrappedRow [ Element.spacing 32 ]
