module Camp25US exposing (..)

import Camp25US.Archive
import Camp25US.Artifacts
import Element exposing (..)
import Element.Font as Font
import Html
import Html.Attributes
import MarkdownThemed
import Route exposing (..)
import Theme


meta =
    { logo = { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
    , tag = "Michigan, US 2025"
    , location = "🇺🇸 Watervliet, Michigan"
    , dates = "Tues 24th - Fri 27th June 2025"
    , artifactPicture = { src = "/24-colehayes/artifacts-mark-skipper.png", description = "A watercolour of an old tree in an English stately garden" }
    }


view model subpage =
    Element.column
        [ Element.width Element.fill, Element.height Element.fill ]
        [ Element.column
            (Element.padding 20 :: Theme.contentAttributes ++ [ Element.spacing 50 ])
            [ Theme.rowToColumnWhen 700
                model
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
                    Camp25US.Archive.view model

                Artifacts ->
                    Camp25US.Artifacts.view model
            ]
        , Theme.footer
        ]


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


venuePictures model =
    let
        prefix =
            "25-ronora/"
    in
    if model.window.width > 950 then
        [ "image1.webp", "image2.webp", "image3.webp", "image4.webp", "image5.webp", "image6.webp" ]
            |> List.map (\image -> venueImage (px 288) (prefix ++ image))
            |> wrappedRow
                [ spacing 10, width (px 900), centerX ]

    else
        [ [ "image1.webp", "image2.webp" ]
        , [ "image3.webp", "image4.webp" ]
        , [ "image5.webp", "image6.webp" ]
        ]
            |> List.map
                (\paths ->
                    row
                        [ spacing 10, width fill ]
                        (List.map (\image -> venueImage fill (prefix ++ image)) paths)
                )
            |> column [ spacing 10, width fill ]


venueImage : Length -> String -> Element msg
venueImage width path =
    image
        [ Element.width width ]
        { src = "/" ++ path, description = "Photo of part of Ronora Lodge" }


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
    column
        []
        [ """
# The venue and access

## The venue

**Colehayes Park**<br/>
Haytor Road<br/>
Bovey Tracey<br/>
South Devon<br/>
TQ13 9LD<br/>
England

[Google Maps](https://goo.gl/maps/Q44YiJCJ79apMmQ8A)

[https://www.colehayes.co.uk/](https://www.colehayes.co.uk/)

## Getting there

### via train & cab/Elm Camp shuttle

* The closest train station is ([Newton Abbot station](https://www.gwr.com/stations-and-destinations/stations/Newton-Abbot))
  * Express direct trains from London Paddington take 2.5 – 3.5 hours (best for all London Airports)
  * Express direct trains from Bristol Temple Meads take 1.5 hours (best for Bristol Airport, take A1 Airport Flyer bus)
  * From Exeter Airport a 30 minute cab/rideshare directly to the venue is best
* Colehayes Park is then a 20 minute cab from Newton Abbot station.
* Elm Camp will organise shuttles between Exeter or Newton Abbot and the venue at key times

### via car

* There is ample parking on site

### via plane

* The closest airport is Exeter, with [flight connections to the UK, Dublin, and Southern Spain](https://www.flightsfrom.com/EXT)
* The next closest major airports in order of travel time are:
  * [Bristol](https://www.flightsfrom.com/explorer/BRS?mapview) (Europe & Northern Africa)
  * [London Heathrow](https://www.flightsfrom.com/explorer/LHR?mapview) (best International coverage)
  * [London Gatwick](https://www.flightsfrom.com/explorer/LGW?mapview) (International)
  * [London Stanstead](https://www.flightsfrom.com/explorer/STN?mapview) (Europe)
  * [London Luton](https://www.flightsfrom.com/explorer/LTN?mapview)  (Europe)

[Rome2Rio](https://www.rome2rio.com/s/Exeter-UK) is a useful tool for finding possible routes from your location.

## Local amenities

Food and drinks are available on site, but if you forgot to pack a toothbrush or need that gum you like, nearby Bovey Tracey offers a few shops.

### Supermarkets

- [Tesco Express](https://www.tesco.com/store-locator/newton-abbot/47-fore-st) (7 am—11 pm), 47 Fore St

### Health

- Pharmacy ([Bovey Tracey Pharmacy](https://www.nhs.uk/services/pharmacy/bovey-tracey-pharmacy/FFL40)) (9 am—5:30 pm), near Tesco Express supermarket

## Accessibility


Attendees will be able to camp in the grounds or book a variety of rooms in the main house or the cottage.

Please let us know if you have specific needs so that we can work with the venue to accommodate you.

### Floor plans

* [The main house](https://www.colehayes.co.uk/wp-content/uploads/2018/10/Colehayes-Park-Floor-Plans.pdf)
* [The cottage](https://www.colehayes.co.uk/wp-content/uploads/2019/02/Colehayes-Park-Cottage-Floor-Plan.pdf)


### Partially step free.
Please ask if you require step free accommodation. There is one bedroom on the ground floor.

* Toilets, dining rooms and conference talk / workshop rooms can be accessed from ground level.

### It's an old manor house

* The house has been renovated to a high standard but there are creaky bits. We ask that you be sensible when exploring
* There are plenty of spaces to hang out in private or in a small quiet group
* There are a variety of seating options

### Toilets

* All toilets are gender neutral
* There are blocks of toilets and showers on each floor and a couple of single units
* There is at least one bath in the house
* The level of accessibility of toilets needs to be confirmed (please ask if you have specific needs)
* There are also toilet and shower blocks in the garden for campers

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
            |> html
        ]


contactDetails : String
contactDetails =
    """
* Elmcraft Discord: [#elm-camp-24](https://discord.gg/QeZDXJrN78) channel or DM katjam_
* Email: [team@elm.camp](mailto:team@elm.camp)
* Elm Slack: @katjam
"""


sponsors : { window | width : Int } -> Element msg
sponsors window =
    let
        asImg { image, url, width } =
            newTabLink
                [ Element.width fill ]
                { url = url
                , label =
                    Element.image
                        [ Element.width
                            (px
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
    column [ centerX, spacing 32 ]
        [ [ asImg { image = "noredink-logo.svg", url = "https://www.noredink.com/", width = 220 }
          , asImg { image = "concentrichealthlogo.svg", url = "https://concentric.health", width = 235 }
          ]
            |> wrappedRow [ centerX, spacing 32 ]
        , [ asImg { image = "lamdera-logo-black.svg", url = "https://lamdera.com/", width = 120 }
          , asImg { image = "scripta.io.svg", url = "https://scripta.io", width = 120 }
          , newTabLink
                [ width fill ]
                { url = "https://www.elmweekly.nl"
                , label =
                    row [ spacing 10, width (px 180) ]
                        [ image
                            [ width
                                (px
                                    (if window.width < 800 then
                                        toFloat 50 * 0.7 |> round

                                     else
                                        50
                                    )
                                )
                            ]
                            { src = "/sponsors/" ++ "elm-weekly.svg", description = "https://www.elmweekly.nl" }
                        , el [ Font.size 24 ] <| text "Elm Weekly"
                        ]
                }
          ]
            |> wrappedRow [ centerX, spacing 32 ]
        ]
