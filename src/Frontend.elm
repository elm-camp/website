module Frontend exposing (app)

import AssocList
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import EmailAddress exposing (EmailAddress)
import Env
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode
import Lamdera
import List.Extra as List
import MarkdownThemed
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated(..), SubmitStatus(..))
import Route exposing (Route(..))
import Stripe exposing (PriceId, ProductId(..))
import Task
import Tickets
import TravelMode
import Types exposing (..)
import Untrusted
import Url


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


subscriptions : FrontendModel -> Sub FrontendMsg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize GotWindowSize
        , Browser.Events.onMouseUp (Json.Decode.succeed MouseDown)
        ]


init : Url.Url -> Browser.Navigation.Key -> ( FrontendModel, Cmd FrontendMsg )
init url key =
    let
        route =
            Route.decode url
    in
    ( Loading { key = key, windowSize = Nothing, prices = AssocList.empty, route = route }
    , Cmd.batch
        [ Browser.Dom.getViewport
            |> Task.perform (\{ viewport } -> GotWindowSize (round viewport.width) (round viewport.height))
        , case route of
            PaymentCancelRoute (Just stripeSessionId) ->
                Lamdera.sendToBackend (CancelPurchaseRequest stripeSessionId)

            _ ->
                Cmd.none
        ]
    )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    case model of
        Loading loading ->
            case msg of
                GotWindowSize width height ->
                    tryLoading { loading | windowSize = Just ( width, height ) }

                _ ->
                    ( model, Cmd.none )

        Loaded loaded ->
            updateLoaded msg loaded |> Tuple.mapFirst Loaded


tryLoading : LoadingModel -> ( FrontendModel, Cmd FrontendMsg )
tryLoading loadingModel =
    Maybe.map
        (\windowSize ->
            ( Loaded
                { key = loadingModel.key
                , windowSize = windowSize
                , showTooltip = False
                , prices = loadingModel.prices
                , selectedTicket = Nothing
                , form =
                    { submitStatus = NotSubmitted NotPressedSubmit
                    , attendee1Name = ""
                    , attendee2Name = ""
                    , billingEmail = ""
                    , originCity = ""
                    , primaryModeOfTravel = Nothing
                    }
                , route = loadingModel.route
                }
            , Cmd.none
            )
        )
        loadingModel.windowSize
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )


updateLoaded : FrontendMsg -> LoadedModel -> ( LoadedModel, Cmd msg )
updateLoaded msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        UrlChanged url ->
            ( { model | route = Route.decode url }, Cmd.none )

        GotWindowSize width height ->
            ( { model | windowSize = ( width, height ) }, Cmd.none )

        PressedShowTooltip ->
            ( { model | showTooltip = True }, Cmd.none )

        MouseDown ->
            ( { model | showTooltip = False }, Cmd.none )

        PressedBuy productId priceId ->
            ( { model | selectedTicket = Just ( productId, priceId ) }, Cmd.none )

        FormChanged form ->
            case model.form.submitStatus of
                NotSubmitted _ ->
                    ( { model | form = form }, Cmd.none )

                Submitting ->
                    ( model, Cmd.none )

                SubmitBackendError ->
                    ( model, Cmd.none )

        PressedSubmitForm productId priceId ->
            let
                form =
                    model.form
            in
            case ( form.submitStatus, PurchaseForm.validateForm productId form ) of
                ( NotSubmitted _, Just validated ) ->
                    ( model, Lamdera.sendToBackend (SubmitFormRequest priceId (Untrusted.untrust validated)) )

                ( NotSubmitted _, Nothing ) ->
                    ( { model | form = { form | submitStatus = NotSubmitted PressedSubmit } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        PressedCancelForm ->
            ( { model | selectedTicket = Nothing }, Cmd.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    case model of
        Loading loading ->
            case msg of
                PricesToFrontend prices ->
                    ( Loading { loading | prices = prices }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Loaded loaded ->
            updateFromBackendLoaded msg loaded |> Tuple.mapFirst Loaded


updateFromBackendLoaded : ToFrontend -> LoadedModel -> ( LoadedModel, Cmd msg )
updateFromBackendLoaded msg model =
    case msg of
        PricesToFrontend prices ->
            ( { model | prices = prices }, Cmd.none )

        SubmitFormResponse result ->
            case result of
                Ok stripeSessionId ->
                    ( model
                    , Stripe.loadCheckout Env.stripePublicApiKey stripeSessionId
                    )

                Err () ->
                    let
                        form =
                            model.form
                    in
                    ( { model | form = { form | submitStatus = SubmitBackendError } }, Cmd.none )


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


header : LoadedModel -> Element msg
header model =
    let
        glow =
            Element.Font.glow (colorWithAlpha 0.25 colors.defaultText) 4

        ( windowWidth, _ ) =
            model.windowSize
    in
    if windowWidth < 1000 then
        Element.column
            [ Element.spacing 20, Element.centerX ]
            [ Element.image
                [ Element.width (Element.maximum 523 Element.fill) ]
                { src = "/logo.webp", description = "Elm camp logo" }
            , Element.column
                [ Element.spacing 24, Element.centerX ]
                [ Element.el
                    [ Element.Font.size 80
                    , glow
                    , Element.paddingXY 0 8
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
                ]
            ]

    else
        Element.row
            [ Element.spacing 40, Element.centerX ]
            [ Element.image
                [ Element.width (Element.px 523) ]
                { src = "/logo.webp", description = "Elm camp logo" }
            , Element.column
                [ Element.spacing 24 ]
                [ Element.el
                    [ Element.Font.size 80
                    , glow
                    , Element.paddingXY 0 8
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


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "Elm Camp"
    , body =
        [ css
        , Element.layout
            [ Element.width Element.fill
            , Element.Font.color colors.defaultText
            , Element.Font.size 16
            , Element.Font.medium
            ]
            (case model of
                Loading _ ->
                    Element.text "Loading..."

                Loaded loaded ->
                    loadedView loaded
            )
        ]
    }


loadedView : LoadedModel -> Element FrontendMsg
loadedView model =
    case model.route of
        HomepageRoute ->
            homepageView model

        AccessibilityRoute ->
            Element.column
                contentAttributes
                [ MarkdownThemed.renderFull "accessibility text here please!"
                ]

        CodeOfConductRoute ->
            Element.column
                contentAttributes
                [ MarkdownThemed.renderFull "code of conduct text here please!"
                ]

        PaymentSuccessRoute maybeEmailAddress ->
            Element.column
                [ Element.centerX, Element.centerY, Element.padding 24 ]
                [ Element.paragraph
                    []
                    [ "Your ticket purchase was successful! "
                        ++ "An email has been sent to "
                        ++ (case maybeEmailAddress of
                                Just emailAddress ->
                                    EmailAddress.toString emailAddress

                                Nothing ->
                                    "your email address"
                           )
                        ++ " with additional information."
                        |> Element.text
                    ]
                ]

        PaymentCancelRoute _ ->
            Element.column
                [ Element.centerX, Element.centerY, Element.padding 24, Element.spacing 16 ]
                [ Element.paragraph
                    [ Element.Font.size 20 ]
                    [ Element.text "You cancelled your ticket purchase" ]
                , Element.link
                    normalButtonAttributes
                    { url = Route.encode HomepageRoute
                    , label = Element.el [ Element.centerX ] (Element.text "Return to homepage")
                    }
                ]


homepageView model =
    let
        ( windowWidth, _ ) =
            model.windowSize

        padding =
            Element.paddingXY sidePadding 0

        sidePadding =
            if windowWidth < 800 then
                24

            else
                60
    in
    case model.selectedTicket of
        Just ( productId, priceId ) ->
            case AssocList.get productId Tickets.dict of
                Just ticket ->
                    Element.column
                        (padding :: contentAttributes)
                        [ Element.row
                            [ Element.spacing 16, Element.width Element.fill ]
                            [ Element.paragraph [] [ Element.text ticket.name ]
                            , Element.image [ Element.width (Element.px 50) ] { src = ticket.image, description = "Illustration of camp" }
                            ]
                        , formView model.windowSize productId priceId model.form
                        ]

                Nothing ->
                    Element.text "Ticket not found"

        Nothing ->
            Element.column
                [ Element.width Element.fill ]
                [ Element.column
                    [ Element.spacing 80
                    , Element.width Element.fill
                    , Element.paddingEach { left = sidePadding, right = sidePadding, top = 0, bottom = 24 }
                    ]
                    [ header model
                    , Element.column
                        [ Element.width Element.fill, Element.spacing 40 ]
                        [ Element.column
                            contentAttributes
                            [ content1, unconferenceBulletPoints model ]
                        , if windowWidth > 950 then
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
                            [ Element.width Element.fill ]
                            [ Element.paragraph (contentAttributes ++ MarkdownThemed.heading1) [ Element.text "Tickets" ]
                            , stripe model
                            ]
                        , Element.el contentAttributes content2
                        ]
                    ]
                , footer
                ]


footer : Element msg
footer =
    Element.el
        [ Element.Background.color (Element.rgb255 12 109 82)
        , Element.paddingXY 24 16
        , Element.width Element.fill
        ]
        (Element.wrappedRow
            ([ Element.spacing 32
             , Element.Background.color (Element.rgb255 12 109 82)
             , Element.width Element.fill
             , Element.Font.color (Element.rgb 1 1 1)
             ]
                ++ contentAttributes
            )
            [ Element.link
                []
                { url = Route.encode CodeOfConductRoute, label = Element.text "Code of Conduct" }
            , Element.link
                []
                { url = Route.encode AccessibilityRoute, label = Element.text "Accessibility" }
            ]
        )


normalButtonAttributes =
    [ Element.width Element.fill
    , Element.Background.color (Element.rgb255 255 255 255)
    , Element.padding 16
    , Element.Border.rounded 8
    , Element.alignBottom
    , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 2, color = Element.rgba 0 0 0 0.1 }
    , Element.Font.semiBold
    ]


formView : ( Int, Int ) -> ProductId -> PriceId -> PurchaseForm -> Element FrontendMsg
formView ( windowWidth, _ ) productId priceId form =
    let
        errorText : String -> Element msg
        errorText error =
            Element.paragraph [ Element.Font.color (Element.rgb255 150 0 0) ] [ Element.text error ]

        textInput : (String -> msg) -> String -> (String -> Result String value) -> String -> Element msg
        textInput onChange title validator text =
            Element.column
                [ Element.spacing 4, Element.width Element.fill ]
                [ Element.Input.text
                    []
                    { text = text
                    , onChange = onChange
                    , placeholder = Nothing
                    , label = Element.Input.labelAbove [] (Element.text title)
                    }
                , case ( form.submitStatus, validator text ) of
                    ( NotSubmitted PressedSubmit, Err error ) ->
                        errorText error

                    _ ->
                        Element.none
                ]

        submitButton =
            Element.Input.button
                Tickets.submitButtonAttributes
                { onPress = Just (PressedSubmitForm productId priceId)
                , label = Element.el [ Element.centerX ] (Element.text "Purchase ticket")
                }

        cancelButton =
            Element.Input.button
                normalButtonAttributes
                { onPress = Just PressedCancelForm
                , label = Element.el [ Element.centerX ] (Element.text "Cancel")
                }
    in
    Element.column
        [ Element.width Element.fill, Element.spacing 24 ]
        [ textInput (\a -> FormChanged { form | attendee1Name = a }) "Your name" PurchaseForm.validateName form.attendee1Name
        , if productId == ProductId Env.couplesCampTicketProductId then
            textInput
                (\a -> FormChanged { form | attendee2Name = a })
                "Name of the person you're sharing a room with"
                PurchaseForm.validateName
                form.attendee2Name

          else
            Element.none
        , textInput
            (\a -> FormChanged { form | billingEmail = a })
            "Billing email address"
            PurchaseForm.validateEmailAddress
            form.billingEmail
        , Element.column
            [ Element.spacing 8 ]
            [ Element.paragraph [] [ Element.text "What will be your primary method of travelling to the event?" ]
            , TravelMode.all
                |> List.map
                    (\choice ->
                        radioButton "travel-mode" (TravelMode.toString choice) (Just choice == form.primaryModeOfTravel)
                            |> Element.map
                                (\() ->
                                    if Just choice == form.primaryModeOfTravel then
                                        FormChanged { form | primaryModeOfTravel = Nothing }

                                    else
                                        FormChanged { form | primaryModeOfTravel = Just choice }
                                )
                    )
                |> Element.column []
            , case ( form.submitStatus, form.primaryModeOfTravel ) of
                ( NotSubmitted PressedSubmit, Nothing ) ->
                    errorText "Please select one of the above"

                _ ->
                    Element.none
            ]
        , if windowWidth > 600 then
            Element.row [ Element.width Element.fill, Element.spacing 16 ] [ cancelButton, submitButton ]

          else
            Element.column [ Element.width Element.fill, Element.spacing 16 ] [ submitButton, cancelButton ]
        ]


radioButton : String -> String -> Bool -> Element ()
radioButton groupName text isChecked =
    Html.label
        [ Html.Attributes.style "padding" "6px"
        , Html.Attributes.style "white-space" "normal"
        , Html.Attributes.style "line-height" "24px"
        ]
        [ Html.input
            [ Html.Attributes.type_ "radio"
            , Html.Attributes.checked isChecked
            , Html.Attributes.name groupName
            , Html.Events.onClick ()
            , Html.Attributes.style "transform" "translateY(-2px)"
            , Html.Attributes.style "margin" "0 8px 0 0"
            ]
            []
        , Html.text text
        ]
        |> Element.html
        |> Element.el []


dallundCastleImage : Element.Length -> String -> Element msg
dallundCastleImage width path =
    Element.image
        [ Element.width width ]
        { src = "/" ++ path, description = "Photo of part of the Dallund Castle" }


contentAttributes : List (Element.Attribute msg)
contentAttributes =
    [ Element.width (Element.maximum 800 Element.fill), Element.centerX ]


stripe : LoadedModel -> Element FrontendMsg
stripe model =
    let
        ( windowWidth, _ ) =
            model.windowSize
    in
    if windowWidth < 950 then
        List.map
            (\( productId, ticket ) ->
                case AssocList.get productId model.prices of
                    Just price ->
                        Tickets.viewMobile (PressedBuy productId price.priceId) price.price ticket

                    Nothing ->
                        Element.none
            )
            (AssocList.toList Tickets.dict)
            |> Element.column [ Element.spacing 16 ]

    else
        List.map
            (\( productId, ticket ) ->
                case AssocList.get productId model.prices of
                    Just price ->
                        Tickets.viewDesktop (PressedBuy productId price.priceId) price.price ticket

                    Nothing ->
                        Element.none
            )
            (AssocList.toList Tickets.dict)
            |> Element.row (Element.spacing 16 :: contentAttributes)



--Html.node "stripe-pricing-table"
--    [ Attr.attribute "pricing-table-id" "prctbl_1MlWUcHHD80VvsjKINsykCtd"
--    , Attr.attribute "publishable-key" "pk_live_dIdCQ17pxxCWIeRJ5ZuJ4Ynm00FgRhZ4jR"
--    ]
--    []
--    |> Element.html
--    |> Element.el [ Element.width Element.fill ]


content1 : Element msg
content1 =
    """
Elm Camp brings an opportunity for Elm makers & tool builders to gather, communicate and collaborate. Our goal is to strengthen and sustain the Elm ecosystem and community.

Elm Camp is an event geared towards reconnecting in-person and collaborating on the current and future community landscape of the Elm ecosystem that surrounds the Elm core language.

Over the last few years Elm has seen community-driven tools and libraries expanding the potential and utility of the Elm language, stemming from a steady pace of continued commercial and hobbyist adoption.

There is great potential for progress and innovation in a creative, focussed, in-person gathering. It’s been a long while since we’ve had this opportunity for folks who are investing in the future of Elm. We expect the wider community and practitioners to benefit from this collaborative exploration of our problems and goals.

Elm Camp is the first Elm Unconference. Our intention is to debut as a small, casual and low-stress event, paving the way for future Elm Camps across the world.

# The Unconference

"""
        |> MarkdownThemed.renderFull


unconferenceBulletPoints : LoadedModel -> Element FrontendMsg
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
            tooltip

           else
            Element.none
          )
            |> Element.below
        ]
        (Element.Input.button
            []
            { onPress = Just PressedShowTooltip, label = Element.text "40 attendees ℹ️" }
        )
    ]
        |> List.map (\point -> MarkdownThemed.bulletPoint [ point ])
        |> Element.column [ Element.spacing 15 ]


tooltip =
    Element.paragraph
        [ Element.paddingXY 12 8
        , Element.Background.color (Element.rgb 1 1 1)
        , Element.width (Element.px 300)
        , Element.Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = Element.rgba 0 0 0 0.25 }
        ]
        [ Element.text "This is our first Elm Unconference, so we're starting small and working backwards from a venue. We understand that this might mean some folks miss out this year – we plan to take what we learn & apply it to the next event. If you know of a bigger venue that would be suitable for future years, please let the team know!"
        ]


content2 : Element msg
content2 =
    """
The venue has a capacity of 24 rooms, and 50 total attendees (i.e. on-site + external). Our plan is to prioritise ticket sales in the following order: """
        ++ String.join ", " [ Tickets.couplesCampTicket.name, Tickets.campTicket.name, Tickets.campfireTicket.name ]
        ++ """.

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

## Silver - €1000 EUR  (£880 / $1100 USD)
You will be a major supporter of Elm Camp Europe 2023.

* Thank you tweet
* Logo on webpage
* Small logo on shared slide, displayed during breaks

## Gold - €2500 EUR  (£2200 / $2700 USD)

You will be a pivotal supporter of Elm Camp Europe 2023.

* Thank you tweet
* Rollup or poster inside the venue (provided by you)
* Logo on webpage
* Medium logo on shared slide, displayed during breaks
* 1 free camp ticket

## Platinum - €5000 EUR  (£4500 / $5300 USD)
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

Problem with something above? Get in touch with the team at [hello@elm.camp](mailto:hello@elm.camp)."""
        |> MarkdownThemed.renderFull
