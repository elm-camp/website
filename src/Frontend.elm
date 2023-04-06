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
import Id exposing (Id)
import Json.Decode
import Lamdera
import List.Extra as List
import MarkdownThemed
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated(..), SubmitStatus(..))
import Route exposing (Route(..))
import String.Nonempty
import Stripe exposing (PriceId, ProductId(..))
import Task
import Tickets exposing (Ticket)
import TravelMode
import Types exposing (..)
import Untrusted
import Url
import W.InputSlider
import W.Styles


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
    ( Loading { key = key, windowSize = Nothing, prices = AssocList.empty, slotsRemaining = Nothing, route = route }
    , Cmd.batch
        [ Browser.Dom.getViewport
            |> Task.perform (\{ viewport } -> GotWindowSize (round viewport.width) (round viewport.height))
        , case route of
            PaymentCancelRoute ->
                Lamdera.sendToBackend CancelPurchaseRequest

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
    Maybe.map2
        (\windowSize slotsRemaining ->
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
                    , country = ""
                    , originCity = ""
                    , primaryModeOfTravel = Nothing
                    , diversityFundContribution = ""
                    }
                , route = loadingModel.route
                , showCarbonOffsetTooltip = False
                , slotsRemaining = slotsRemaining
                }
            , Cmd.none
            )
        )
        loadingModel.windowSize
        loadingModel.slotsRemaining
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )


updateLoaded : FrontendMsg -> LoadedModel -> ( LoadedModel, Cmd FrontendMsg )
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
            ( { model | showTooltip = False, showCarbonOffsetTooltip = False }, Cmd.none )

        PressedSelectTicket productId priceId ->
            case AssocList.get productId Tickets.dict of
                Just ticket ->
                    if purchaseable ticket.productId model then
                        ( { model | selectedTicket = Just ( productId, priceId ) }
                        , Browser.Dom.setViewport 0 0 |> Task.perform (\() -> SetViewport)
                        )

                    else
                        ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

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
            case AssocList.get productId Tickets.dict of
                Just ticket ->
                    if purchaseable ticket.productId model then
                        case ( form.submitStatus, PurchaseForm.validateForm productId form ) of
                            ( NotSubmitted _, Just validated ) ->
                                ( model, Lamdera.sendToBackend (SubmitFormRequest priceId (Untrusted.untrust validated)) )

                            ( NotSubmitted _, Nothing ) ->
                                ( { model | form = { form | submitStatus = NotSubmitted PressedSubmit } }
                                , Cmd.none
                                )

                            _ ->
                                ( model, Cmd.none )

                    else
                        ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        PressedCancelForm ->
            ( { model | selectedTicket = Nothing }
            , Browser.Dom.getElement ticketsHtmlId
                |> Task.andThen (\{ element } -> Browser.Dom.setViewport 0 element.y)
                |> Task.attempt (\_ -> SetViewport)
            )

        PressedShowCarbonOffsetTooltip ->
            ( { model | showCarbonOffsetTooltip = True }, Cmd.none )

        SetViewport ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    case model of
        Loading loading ->
            case msg of
                InitData { prices, slotsRemaining } ->
                    tryLoading { loading | prices = prices, slotsRemaining = Just slotsRemaining }

                _ ->
                    ( model, Cmd.none )

        Loaded loaded ->
            updateFromBackendLoaded msg loaded |> Tuple.mapFirst Loaded


updateFromBackendLoaded : ToFrontend -> LoadedModel -> ( LoadedModel, Cmd msg )
updateFromBackendLoaded msg model =
    case msg of
        InitData { prices, slotsRemaining } ->
            ( { model | prices = prices, slotsRemaining = slotsRemaining }, Cmd.none )

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

        SlotRemainingChanged slotsRemaining ->
            ( { model | slotsRemaining = slotsRemaining }, Cmd.none )


purchaseable productId model =
    if productId == Env.campfireTicketProductId then
        model.slotsRemaining.campfireTicket

    else if productId == Env.campTicketProductId then
        model.slotsRemaining.campTicket

    else
        model.slotsRemaining.couplesCampTicket


fontFace : Int -> String -> String
fontFace weight name =
    """
@font-face {
  font-family: 'Open Sans';
  font-style: normal;
  font-weight: """ ++ String.fromInt weight ++ """;
  font-stretch: normal;

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
            [ Element.padding 30, Element.spacing 20, Element.centerX ]
            [ Element.image
                [ Element.width (Element.maximum 523 Element.fill) ]
                { src = "/logo.webp", description = "Elm camp logo" }
            , Element.column
                [ Element.spacing 24, Element.centerX ]
                [ Element.el
                    [ Element.Font.size
                        (if windowWidth < 800 then
                            64

                         else
                            80
                        )
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

    else
        Element.row
            [ Element.padding 30, Element.spacing 40, Element.centerX ]
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
        , W.Styles.globalStyles
        , W.Styles.baseTheme
        , Element.layout
            [ Element.width Element.fill
            , Element.Font.color colors.defaultText
            , Element.Font.size 16
            , Element.Font.medium
            , Element.Background.color backgroundColor
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
                [ Element.width Element.fill, Element.height Element.fill ]
                [ Element.column
                    contentAttributes
                    [ accessibilityContent
                    ]
                , footer
                ]

        CodeOfConductRoute ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ Element.column
                    contentAttributes
                    [ codeOfConductContent
                    ]
                , footer
                ]

        PaymentSuccessRoute maybeEmailAddress ->
            Element.column
                [ Element.centerX, Element.centerY, Element.padding 24, Element.spacing 16 ]
                [ Element.paragraph [ Element.Font.size 20, Element.Font.center ] [ Element.text "Your ticket purchase was successful!" ]
                , Element.paragraph
                    [ Element.width (Element.px 420) ]
                    [ Element.text "An email has been sent to "
                    , case maybeEmailAddress of
                        Just emailAddress ->
                            EmailAddress.toString emailAddress
                                |> Element.text
                                |> Element.el [ Element.Font.semiBold ]

                        Nothing ->
                            Element.text "your email address"
                    , Element.text " with additional information."
                    ]
                , Element.link
                    normalButtonAttributes
                    { url = Route.encode HomepageRoute
                    , label = Element.el [ Element.centerX ] (Element.text "Return to homepage")
                    }
                ]

        PaymentCancelRoute ->
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


ticketsHtmlId =
    "tickets"


homepageView : LoadedModel -> Element FrontendMsg
homepageView model =
    let
        ( windowWidth, _ ) =
            model.windowSize

        padding =
            Element.paddingXY sidePadding 24

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
                        (Element.spacing 24 :: padding :: contentAttributes)
                        [ Element.row
                            [ Element.spacing 16, Element.width Element.fill ]
                            [ Element.image
                                [ Element.width (Element.px 50) ]
                                { src = ticket.image, description = "Illustration of camp" }
                            , Element.paragraph
                                [ Element.Font.size 24 ]
                                [ Element.el [ Element.Font.semiBold ] (Element.text ticket.name)
                                , case AssocList.get productId model.prices of
                                    Just { price } ->
                                        " - "
                                            ++ Tickets.priceText price
                                            |> Element.text

                                    Nothing ->
                                        Element.none
                                ]
                            ]
                        , Element.paragraph [] [ Element.text ticket.description ]
                        , formView model productId priceId ticket
                        ]

                Nothing ->
                    Element.text "Ticket not found"

        Nothing ->
            Element.column
                [ Element.width Element.fill ]
                [ Element.column
                    [ Element.spacing 50
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
                            [ Element.width Element.fill
                            , Element.spacing 24
                            , Element.htmlAttribute (Html.Attributes.id ticketsHtmlId)
                            ]
                            [ Element.row
                                (Element.spacing 16 :: contentAttributes)
                                [ Element.el
                                    [ Element.Font.size 36, Element.Font.semiBold ]
                                    (Element.text "Tickets")

                                -- , Element.el
                                --     [ Element.Font.size 24, Element.centerY, Element.alignRight ]
                                --     (Element.text (slotsLeftText model))
                                ]
                            , ticketCardsView model
                            ]
                        , Element.el contentAttributes content2
                        , Element.column
                            contentAttributes
                            [ MarkdownThemed.renderFull "# Our sponsors"
                            , sponsors model.windowSize
                            ]
                        , Element.el contentAttributes content3
                        ]
                    ]
                , footer
                ]



-- slotsLeftText : { a | slotsRemaining : Int } -> String
-- slotsLeftText model =
--     String.fromInt model.slotsRemaining
--         ++ "/"
--         ++ String.fromInt totalSlotsAvailable
--         ++ " slots left"


footer : Element msg
footer =
    Element.el
        [ Element.Background.color (Element.rgb255 12 109 82)
        , Element.paddingXY 24 16
        , Element.width Element.fill
        , Element.alignBottom
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
                { url = Route.encode AccessibilityRoute, label = Element.text "Venue & Accessibility" }
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


errorText : String -> Element msg
errorText error =
    Element.paragraph [ Element.Font.color (Element.rgb255 150 0 0) ] [ Element.text error ]


formView : LoadedModel -> Id ProductId -> Id PriceId -> Ticket -> Element FrontendMsg
formView model productId priceId ticket =
    let
        form =
            model.form

        ( windowWidth, _ ) =
            model.windowSize

        textInput : (String -> msg) -> String -> (String -> Result String value) -> String -> Element msg
        textInput onChange title validator text =
            Element.column
                [ Element.spacing 4, Element.width Element.fill ]
                [ Element.Input.text
                    [ Element.Border.rounded 8 ]
                    { text = text
                    , onChange = onChange
                    , placeholder = Nothing
                    , label = Element.Input.labelAbove [ Element.Font.semiBold ] (Element.text title)
                    }
                , case ( form.submitStatus, validator text ) of
                    ( NotSubmitted PressedSubmit, Err error ) ->
                        errorText error

                    _ ->
                        Element.none
                ]

        submitButton =
            Element.Input.button
                (Tickets.submitButtonAttributes (purchaseable ticket.productId model))
                { onPress = Just (PressedSubmitForm productId priceId)
                , label =
                    Element.el
                        [ Element.centerX ]
                        (Element.text
                            (if purchaseable ticket.productId model then
                                "Purchase ticket"

                             else
                                "Sold out!"
                            )
                        )
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
        [ Element.column
            [ Element.width Element.fill
            , Element.spacing 24
            , Element.padding 16
            ]
            [ textInput (\a -> FormChanged { form | attendee1Name = a }) "Your name" PurchaseForm.validateName form.attendee1Name
            , if productId == Id.fromString Env.couplesCampTicketProductId then
                textInput
                    (\a -> FormChanged { form | attendee2Name = a })
                    "Person you're sharing a room with"
                    PurchaseForm.validateName
                    form.attendee2Name

              else
                Element.none
            , textInput
                (\a -> FormChanged { form | billingEmail = a })
                "Billing email address"
                PurchaseForm.validateEmailAddress
                form.billingEmail
            ]
        , carbonOffsetForm textInput model.showCarbonOffsetTooltip form
        , Element.el [ Element.Font.size 20 ] (Element.text "\u{1FAF6} Diversity fund")
        , Element.paragraph [] [ Element.text "Optional contributions to our diversity fund allow us to allocate resources to assist underrepresented and marginalised community members in attending Elm Camp." ]
        , Element.row [ Element.width Element.fill ]
            [ textInput (\a -> FormChanged { form | diversityFundContribution = a }) "Contribution" PurchaseForm.validateInt form.diversityFundContribution
            , Element.column [ Element.width (Element.fillPortion 3), Element.padding 30 ]
                [ W.InputSlider.view []
                    { min = 0
                    , max = 500
                    , step = 10
                    , value = String.toFloat form.diversityFundContribution |> Maybe.withDefault 0
                    , onInput = \a -> FormChanged { form | diversityFundContribution = String.fromFloat a }
                    }
                    |> Element.html
                    |> Element.el [ Element.width (Element.fillPortion 3), Element.height (Element.px 20) ]
                , Element.row [ Element.width (Element.fillPortion 3) ]
                    [ Element.el [ Element.padding 10 ] <| Element.text "No thanks"
                    , Element.el [ Element.padding 10, Element.alignRight ] <| Element.text "Full ticket"
                    ]
                ]
            ]
        , if windowWidth > 600 then
            Element.row [ Element.width Element.fill, Element.spacing 16 ] [ cancelButton, submitButton ]

          else
            Element.column [ Element.width Element.fill, Element.spacing 16 ] [ submitButton, cancelButton ]
        ]


backgroundColor : Element.Color
backgroundColor =
    Element.rgb255 255 244 225


carbonOffsetForm textInput showCarbonOffsetTooltip form =
    Element.column
        [ Element.width Element.fill
        , Element.spacing 24
        , Element.paddingEach { left = 16, right = 16, top = 32, bottom = 16 }
        , Element.Border.width 2
        , Element.Border.color (Element.rgb255 94 176 125)
        , Element.Border.rounded 12
        , Element.el
            [ (if showCarbonOffsetTooltip then
                tooltip "We collect this info so we can estimate the carbon footprint of your trip. We pay Ecologi to offset some of the environmental impact (this is already priced in and doesn't change the shown ticket price)"

               else
                Element.none
              )
                |> Element.below
            , Element.moveUp 20
            , Element.moveRight 8
            , Element.Background.color backgroundColor
            ]
            (Element.Input.button
                [ Element.padding 8 ]
                { onPress = Just PressedShowCarbonOffsetTooltip
                , label =
                    Element.row
                        []
                        [ Element.el [ Element.Font.size 20 ] (Element.text "🌲 Carbon offsetting ")
                        , Element.el [ Element.Font.size 12 ] (Element.text "ℹ️")
                        ]
                }
            )
            |> Element.inFront
        ]
        [ textInput
            (\a -> FormChanged { form | country = a })
            "Country you live in"
            (\text ->
                case String.Nonempty.fromString text of
                    Just nonempty ->
                        Ok nonempty

                    Nothing ->
                        Err "Please type in the name of the country you live in"
            )
            form.country
        , textInput
            (\a -> FormChanged { form | originCity = a })
            "City you live in (or nearest city to you)"
            (\text ->
                case String.Nonempty.fromString text of
                    Just nonempty ->
                        Ok nonempty

                    Nothing ->
                        Err "Please type in the name of city nearest to you"
            )
            form.originCity
        , Element.column
            [ Element.spacing 8 ]
            [ Element.paragraph
                [ Element.Font.semiBold ]
                [ Element.text "What will be your primary method of travelling to the event?" ]
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


ticketCardsView : LoadedModel -> Element FrontendMsg
ticketCardsView model =
    let
        ( windowWidth, _ ) =
            model.windowSize
    in
    if windowWidth < 950 then
        List.map
            (\( productId, ticket ) ->
                case AssocList.get productId model.prices of
                    Just price ->
                        Tickets.viewMobile (purchaseable ticket.productId model) (PressedSelectTicket productId price.priceId) price.price ticket

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
                        Tickets.viewDesktop (purchaseable ticket.productId model) (PressedSelectTicket productId price.priceId) price.price ticket

                    Nothing ->
                        Element.none
            )
            (AssocList.toList Tickets.dict)
            |> Element.row (Element.spacing 16 :: contentAttributes)


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
            tooltip "This is our first Elm Unconference, so we're starting small and working backwards from a venue. We understand that this might mean some folks miss out this year – we plan to take what we learn & apply it to the next event. If you know of a bigger venue that would be suitable for future years, please let the team know!"

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

🇺🇸 James Carlson – Developer of [Scripta.io](https://scripta.io), a web publishing platform for technical documents in mathematics, physics, and the like. Currently working for [exosphere.app](https://exosphere.app), an all-Elm cloud-computing project

🇸🇪 Martin Stewart – Makes games and apps using Lamdera. Also runs the state-of-elm survey every year.

🇨🇿 Martin Janiczek – Loves to start things and one-off experiments, has a drive for teaching and unblocking others. Regularly races for the first answer in Elm Slack #beginners and #help.

🇬🇧 Mario Rogic – Organiser of the Elm London and Elm Online meetups. Groundskeeper of Elmcraft, founder of Lamdera.

🇩🇪 Johannes Emerich – Works at Dividat, making a console with small games and a large controller. Remembers when Elm demos were about the intricacies of how high Super Mario jumps."""
        |> MarkdownThemed.renderFull


content3 =
    """
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


sponsors : ( Int, Int ) -> Element msg
sponsors ( windowWidth, _ ) =
    [ { image = "concentrichealthlogo.svg", url = "https://concentric.health/", width = 250 }
    , { image = "cookiewolf-logo.png", url = "", width = 220 }
    , { image = "logo-dividat.svg", url = "https://dividat.com", width = 170 }
    , { image = "lamdera-logo-black.svg", url = "https://lamdera.com/", width = 200 }
    , { image = "scripta.io.svg", url = "https://scripta.io", width = 200 }
    ]
        |> List.map
            (\{ image, url, width } ->
                Element.newTabLink
                    []
                    { url = url
                    , label =
                        Element.image
                            [ Element.width
                                (Element.px
                                    (if windowWidth < 800 then
                                        toFloat width * 0.7 |> round

                                     else
                                        width
                                    )
                                )
                            ]
                            { src = "/sponsors/" ++ image, description = url }
                    }
            )
        |> Element.wrappedRow [ Element.spacing 32 ]


codeOfConductContent : Element msg
codeOfConductContent =
    """
# Code of Conduct

Elm Camp welcomes people with a wide range of backgrounds, experiences and knowledge. We can learn a lot from each other. It's important for us to make sure the environment where these discussions happen is inclusive and supportive. Everyone should feel comfortable to participate! The following guidelines are meant to codify these intentions.

## Help everyone feel welcome at Elm Camp

Everyone at Elm Camp is part of Elm Camp. There are a few staff on call and preparing food, but there are no other guests at the hotel.

We expect everyone here to ensure that our community is harrassment-free for everyone.

### Examples of behaviours that help us to provide an an open, welcoming, diverse, inclusive, and healthy community:

* Demonstrating empathy and kindness toward other people
* Being respectful of differing opinions, viewpoints, and experiences
* Giving and gracefully accepting constructive feedback
* Accepting responsibility and apologising to those affected by our mistakes
* Learning from our and others' mistakes and not repeating negative behaviour
* Focusing on what is best for the overall community, not just ourselves as individuals
* Consider sharing your pronouns when introducing yourself, even if you think they are obvious
* Respect the name and pronouns others introduce themselves with
* When discussing code, avoid criticising the person who wrote the code or referring to the quality of the code in a negative way
* Leave silences to allow everyone a chance to speak
* When standing around talking, leave space for new people to join your converation (sometimes referred to pacman shape)
* If you think something you are about to say might be offensive, consider not saying it. If you need to say it, please warn people beforehand.


### Examples of unacceptable behavior include:

* Public or private harassment of any kind including offensive comments related to gender, sexual orientation, disability, physical appearance, body size, race, politics, or religion
* The use of sexualised language or imagery, and sexual attention or advances of any kind
* interrupting people when they are speaking
* Sharing others' private information, such as a physical or email address, without their explicit permission
* Other conduct which could reasonably be considered inappropriate in a professional setting


## Guidelines for running a camp session

As a facilitator it's important that you not only follow our code of conduct, but also help to enforce it.

If you have any concerns when planning, during or after your session, please get in touch with one of the organisers so we can help you.


## Talk to us

### hello@elm.camp

If you experience any behaviours or atmosphere at Elm Camp that feels contrary to these values, please let us know. We want everyone to feel safe, equal and welcome.

## How we handle Code of Conduct issues

If someone makes you or anyone else feel unsafe or unwelcome, please report it as soon as possible. You can make a report personally, anonymously or ask someone to do it on your behalf.

The Code of Conduct is in place to protect everyone at Elm Camp. If any participant violates these rules the organisers will take action.

We prefer to resolve things collaboratively and listening to everyone involved. We can all learn things from each other if we discuss issues openly.

However, if you feel you want help resolving something more privately, please ask an organiser. We are here to support you. The organisers will never disclose who brought the matter to our attention, in that case that they prefer to remain anonymous.

Where appropriate, we aim to be forgiving: if it seems like someone has made a good-natured mistake, we want to give space to grow and learn and a chance to apologise.

Where deemed necessary, the organisers will ask participants who harm the Elm Camp community to leave. This Code of Conduct is a guide, and since we can’t possibly write down all the ways you can hurt people, we may ask participants to leave for reasons that we didn’t write down explicitly here.

If you have any questions, concerns or suggestions regarding this policy, please get in touch.

This code of conduct was inspired by the [!!Con code of conduct](https://bangbangcon.com/conduct.html) and drafted with the guidance of the [Geek Feminism Wiki](https://geekfeminism.fandom.com/wiki/Conference_anti-harassment/Policy_resources)
    """
        |> MarkdownThemed.renderFull


accessibilityContent : Element msg
accessibilityContent =
    """
# The venue and access

## Getting here

### via train, bus & 2k walk or Elm Camp shuttle

* Travel to Odense Train station
* From here there is a bus from Odense Train Station to Søndersø which is 2k from the venue
* You can walk but note that there is a short section of unpaved road on this route
* Elm Camp will be organising shuttles at key times (details nearer the time)

### via car

* There is ample parking on site

## The venue

### Not step free.

* Bedrooms, toilets, dining rooms and conference talk / workshop rooms can all be accessed via a lift which is 3 steps from ground level

### It's an old manor house

* The house has been renovated to a high standard but there are creaky bits, be sensible when exploring
* There are plenty of spaces to hang out in private or in a small quiet group
* There are a variety of seating options

### Toilets

* All toilets are gender neutral
* There is one public toilet on each of the 3 floors
* All attendees staying at the hotel have ensuites
* The level of accessibility of toilets needs to be confirmed (please ask if you have specific needs)

### Open water & rough ground

* The house is set in landscaped grounds, there are paths and rough bits.
* There is a lake with a pier for swimming and fishing off of, right next to the house that is NOT fenced

## Participating in conversations

* The official conference language will be English. We ask that attendees conduct as much of their conversations in English in order to include as many people as possible
* We do not have facility for captioning or signing, please get in touch as soon as possible if you would benefit from something like that and we'll see what we can do
* We hope to stream or record at least some of the content
* We aim to provide frequent breaks of a decent length, so if this feels lacking to you at any time, let an organiser know

## Contacting the organisers

If you have questions or concerns about this website or attending Elm Camp, please get in touch

* email: [hello@elm.camp](mailto:hello@elm.camp)
* Elm slack: @katjam
* Elmcraft Discord: Katja#0091
    """
        |> MarkdownThemed.renderFull
