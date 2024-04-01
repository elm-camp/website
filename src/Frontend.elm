module Frontend exposing (app)

import Admin
import AssocList
import Audio exposing (Audio, AudioCmd)
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Camp23Denmark
import Camp23Denmark.Artifacts
import Camp24Devon.Inventory as Inventory
import Camp24Devon.Product as Product
import Camp24Devon.Tickets as Tickets
import DateFormat
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import EmailAddress exposing (EmailAddress)
import Env
import Html exposing (Html)
import Html.Attributes
import Html.Events
import ICalendar exposing (IcsFile)
import Id exposing (Id)
import Json.Decode
import Lamdera
import List.Extra as List
import LiveSchedule
import MarkdownThemed
import Ports
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated, SubmitStatus(..))
import Route exposing (Route(..), SubPage(..))
import String.Nonempty
import Stripe exposing (PriceId, ProductId(..))
import Task
import Theme exposing (normalButtonAttributes, showyButtonAttributes)
import Time
import TimeFormat
import TravelMode
import Types exposing (..)
import Untrusted
import Url
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query
import View.Countdown


app =
    Audio.lamderaFrontendWithAudio
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update =
            \_ msg model ->
                let
                    ( newModel, cmd ) =
                        update msg model
                in
                ( newModel, cmd, Audio.cmdNone )
        , updateFromBackend =
            \_ toFrontend model ->
                let
                    ( newModel, cmd ) =
                        updateFromBackend toFrontend model
                in
                ( newModel, cmd, Audio.cmdNone )
        , subscriptions = \_ model -> subscriptions model
        , view = \_ model -> view model
        , audio = audio
        , audioPort = { toJS = Ports.audioPortToJS, fromJS = Ports.audioPortFromJS }
        }


audio : a -> FrontendModel_ -> Audio
audio _ model =
    case model of
        Loading _ ->
            Audio.silence

        Loaded loaded ->
            case ( loaded.route, loaded.audio ) of
                ( LiveScheduleRoute, Just song ) ->
                    if loaded.pressedAudioButton then
                        LiveSchedule.audio song

                    else
                        Audio.silence

                _ ->
                    Audio.silence


subscriptions : FrontendModel_ -> Sub FrontendMsg_
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize GotWindowSize
        , Browser.Events.onMouseUp (Json.Decode.succeed MouseDown)
        , Time.every 1000 Tick
        ]


queryBool name =
    Query.enum name (Dict.fromList [ ( "true", True ), ( "false", False ) ])


init : Url.Url -> Browser.Navigation.Key -> ( FrontendModel_, Cmd FrontendMsg_, AudioCmd FrontendMsg_ )
init url key =
    let
        route =
            Route.decode url

        isOrganiser =
            case url |> Url.Parser.parse (Url.Parser.top <?> queryBool "organiser") of
                Just (Just isOrganiser_) ->
                    isOrganiser_

                _ ->
                    False
    in
    ( Loading
        { key = key
        , now = Time.millisToPosix 0
        , zone = Nothing
        , window = Nothing
        , initData = Nothing
        , route = route
        , isOrganiser = isOrganiser
        , audio = Nothing
        }
    , Cmd.batch
        [ Browser.Dom.getViewport
            |> Task.perform (\{ viewport } -> GotWindowSize (round viewport.width) (round viewport.height))
        , Time.now |> Task.perform Tick
        , Time.here |> Task.perform GotZone
        , case route of
            PaymentCancelRoute ->
                Lamdera.sendToBackend CancelPurchaseRequest

            AdminRoute passM ->
                case passM of
                    Just pass ->
                        Lamdera.sendToBackend (AdminInspect pass)

                    Nothing ->
                        Cmd.none

            _ ->
                Cmd.none
        ]
    , case route of
        Route.LiveScheduleRoute ->
            Audio.loadAudio LoadedMusic "cowboy bebob - elm.mp3"

        _ ->
            Audio.cmdNone
    )


update : FrontendMsg_ -> FrontendModel_ -> ( FrontendModel_, Cmd FrontendMsg_ )
update msg model =
    case model of
        Loading loading ->
            case msg of
                GotWindowSize width height ->
                    tryLoading { loading | window = Just { width = width, height = height } }

                LoadedMusic result ->
                    tryLoading { loading | audio = Just result }

                Tick now ->
                    ( Loading { loading | now = now }, Cmd.none )

                GotZone zone ->
                    ( Loading { loading | zone = Just zone }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Loaded loaded ->
            updateLoaded msg loaded |> Tuple.mapFirst Loaded


tryLoading : LoadingModel -> ( FrontendModel_, Cmd FrontendMsg_ )
tryLoading loadingModel =
    Maybe.map2
        (\window { slotsRemaining, prices, ticketsEnabled } ->
            case ( loadingModel.audio, loadingModel.route ) of
                ( Just (Ok song), LiveScheduleRoute ) ->
                    ( Loaded
                        { key = loadingModel.key
                        , now = loadingModel.now
                        , zone = loadingModel.zone
                        , window = window
                        , showTooltip = False
                        , prices = prices
                        , selectedTicket = Nothing
                        , form = PurchaseForm.init
                        , route = loadingModel.route
                        , showCarbonOffsetTooltip = False
                        , slotsRemaining = slotsRemaining
                        , isOrganiser = loadingModel.isOrganiser
                        , ticketsEnabled = ticketsEnabled
                        , backendModel = Nothing
                        , audio = Just song
                        , pressedAudioButton = False
                        }
                    , Cmd.none
                    )

                ( _, LiveScheduleRoute ) ->
                    ( Loading loadingModel, Cmd.none )

                _ ->
                    ( Loaded
                        { key = loadingModel.key
                        , now = loadingModel.now
                        , zone = loadingModel.zone
                        , window = window
                        , showTooltip = False
                        , prices = prices
                        , selectedTicket = Nothing
                        , form = PurchaseForm.init
                        , route = loadingModel.route
                        , showCarbonOffsetTooltip = False
                        , slotsRemaining = slotsRemaining
                        , isOrganiser = loadingModel.isOrganiser
                        , ticketsEnabled = ticketsEnabled
                        , backendModel = Nothing
                        , audio = Nothing
                        , pressedAudioButton = False
                        }
                    , Cmd.none
                    )
        )
        loadingModel.window
        loadingModel.initData
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )


updateLoaded : FrontendMsg_ -> LoadedModel -> ( LoadedModel, Cmd FrontendMsg_ )
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
            ( { model | route = Route.decode url }, scrollToTop )

        Tick now ->
            ( { model | now = now }, Cmd.none )

        GotZone zone ->
            ( { model | zone = Just zone }, Cmd.none )

        GotWindowSize width height ->
            ( { model | window = { width = width, height = height } }, Cmd.none )

        PressedShowTooltip ->
            ( { model | showTooltip = True }, Cmd.none )

        MouseDown ->
            ( { model | showTooltip = False, showCarbonOffsetTooltip = False }, Cmd.none )

        DownloadTicketSalesReminder ->
            ( model, downloadTicketSalesReminder )

        PressedSelectTicket productId priceId ->
            case ( AssocList.get productId Tickets.accommodationOptions, model.ticketsEnabled ) of
                ( Just ( accom, ticket ), TicketsEnabled ) ->
                    if Inventory.purchaseable ticket.productId model.slotsRemaining then
                        ( { model | selectedTicket = Just ( productId, priceId ) }
                        , scrollToTop
                        )

                    else
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        AddAccom accom ->
            let
                form =
                    model.form

                newForm =
                    { form | accommodationBookings = model.form.accommodationBookings ++ [ accom ] }
            in
            ( { model | form = newForm }, Cmd.none )

        RemoveAccom accom ->
            let
                form =
                    model.form

                newForm =
                    { form | accommodationBookings = List.remove accom model.form.accommodationBookings }
            in
            ( { model | form = newForm }, Cmd.none )

        FormChanged form ->
            case model.form.submitStatus of
                NotSubmitted _ ->
                    ( { model | form = form }, Cmd.none )

                Submitting ->
                    ( model, Cmd.none )

                SubmitBackendError str ->
                    ( { model | form = form }, Cmd.none )

        PressedSubmitForm ->
            let
                form =
                    model.form
            in
            case ( form.submitStatus, PurchaseForm.validateForm form ) of
                ( NotSubmitted _, Just purchaseFormValidated ) ->
                    ( { model | form = { form | submitStatus = Submitting } }
                    , Lamdera.sendToBackend (SubmitFormRequest (Untrusted.untrust purchaseFormValidated))
                    )

                ( NotSubmitted _, Nothing ) ->
                    let
                        _ =
                            Debug.log "form invalid" ()
                    in
                    ( { model | form = { form | submitStatus = NotSubmitted PressedSubmit } }
                    , Cmd.none
                    )

                _ ->
                    let
                        _ =
                            Debug.log "Form already submitted" "Form already submitted"
                    in
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

        LoadedMusic _ ->
            ( model, Cmd.none )

        LiveScheduleMsg liveScheduleMsg ->
            case liveScheduleMsg of
                LiveSchedule.PressedAllowAudio ->
                    ( { model | pressedAudioButton = True }, Cmd.none )

        SetViewPortForElement elmentId ->
            ( model, jumpToId elmentId )

        Noop ->
            ( model, Cmd.none )


scrollToTop : Cmd FrontendMsg_
scrollToTop =
    Browser.Dom.setViewport 0 0 |> Task.perform (\() -> SetViewport)


updateFromBackend : ToFrontend -> FrontendModel_ -> ( FrontendModel_, Cmd FrontendMsg_ )
updateFromBackend msg model =
    case model of
        Loading loading ->
            case msg of
                InitData initData ->
                    tryLoading { loading | initData = Just initData }

                _ ->
                    ( model, Cmd.none )

        Loaded loaded ->
            updateFromBackendLoaded msg loaded |> Tuple.mapFirst Loaded


updateFromBackendLoaded : ToFrontend -> LoadedModel -> ( LoadedModel, Cmd msg )
updateFromBackendLoaded msg model =
    case msg of
        InitData { prices, slotsRemaining, ticketsEnabled } ->
            ( { model | prices = prices, slotsRemaining = slotsRemaining, ticketsEnabled = ticketsEnabled }, Cmd.none )

        SubmitFormResponse result ->
            case result of
                Ok stripeSessionId ->
                    ( model
                    , Stripe.loadCheckout Env.stripePublicApiKey stripeSessionId
                    )

                Err str ->
                    let
                        form =
                            model.form
                    in
                    ( { model | form = { form | submitStatus = SubmitBackendError str } }, Cmd.none )

        SlotRemainingChanged slotsRemaining ->
            ( { model | slotsRemaining = slotsRemaining }, Cmd.none )

        TicketsEnabledChanged ticketsEnabled ->
            ( { model | ticketsEnabled = ticketsEnabled }, Cmd.none )

        AdminInspectResponse backendModel ->
            ( { model | backendModel = Just backendModel }, Cmd.none )


header : { window : { width : Int, height : Int }, isCompact : Bool } -> Element FrontendMsg_
header config =
    let
        illustrationAltText =
            "Illustration of a small camp site in a richly green forest"

        titleSize =
            if config.window.width < 800 then
                64

            else
                80

        elmCampTitle =
            link
                []
                { url = Route.encode HomepageRoute
                , label = el [ Font.size titleSize, Theme.glow, paddingXY 0 8 ] (text "Elm Camp")
                }

        elmCampNextTopLine =
            column [ spacing 30 ]
                [ row
                    [ centerX, spacing 13 ]
                    [ image
                        [ width (px 49) ]
                        { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
                    , column []
                        [ column
                            [ spacing 2, Font.size 24, moveUp 1 ]
                            [ el [ Theme.glow ] (text "Unconference")
                            , el [ Font.extraBold, Font.color Theme.lightTheme.elmText ] (text "UK 2024")
                            ]
                        ]
                    ]
                , column
                    [ moveRight 0, spacing 2, Font.size 18, moveUp 1 ]
                    [ el [ Font.bold, Font.color Theme.lightTheme.defaultText ] (text "Tues 18th — Fri 21st June")
                    , el [ Font.bold, Font.color Theme.lightTheme.defaultText ] (text "🇬🇧 Colehayes Park, Devon")
                    ]

                -- vvv ADDED BY JC vvv
                , el [ Font.size 20 ] goToTicketSales
                ]
    in
    if config.window.width < 1000 || config.isCompact then
        column
            [ padding 30, spacing 20, centerX ]
            [ if config.isCompact then
                none

              else
                image
                    [ width (maximum 523 fill), Theme.attr "fetchpriority" "high" ]
                    { src = "/logo-24.webp", description = illustrationAltText }
            , column
                [ spacing 24, centerX ]
                [ elmCampTitle
                , elmCampNextTopLine
                ]
            ]

    else
        row
            [ padding 30, spacing 40, centerX ]
            [ image
                [ width (px 523), Theme.attr "fetchpriority" "high" ]
                { src = "/logo-24.webp", description = illustrationAltText }
            , column
                [ spacing 24 ]
                [ elmCampTitle
                , elmCampNextTopLine
                ]
            ]


view : FrontendModel_ -> Browser.Document FrontendMsg_
view model =
    { title = "Elm Camp"
    , body =
        [ Theme.css

        -- , W.Styles.globalStyles
        -- , W.Styles.baseTheme
        , Element.layout
            [ Element.width Element.fill
            , Font.color Theme.lightTheme.defaultText
            , Font.size 16
            , Font.medium
            , Background.color backgroundColor
            , (case model of
                Loading _ ->
                    Element.none

                Loaded loaded ->
                    case loaded.ticketsEnabled of
                        TicketsEnabled ->
                            Element.none

                        TicketsDisabled { adminMessage } ->
                            Element.paragraph
                                [ Font.color (Element.rgb 1 1 1)
                                , Font.medium
                                , Font.size 20
                                , Background.color (Element.rgb 0.5 0 0)
                                , Element.padding 8
                                , Element.width Element.fill
                                ]
                                [ Element.text adminMessage ]
              )
                |> Element.inFront
            ]
            (case model of
                Loading loading ->
                    Element.column [ Element.width Element.fill, Element.padding 20 ]
                        [ (case loading.audio of
                            Just (Err error) ->
                                case error of
                                    Audio.FailedToDecode ->
                                        "Failed to decode song"

                                    Audio.NetworkError ->
                                        "Network error"

                                    Audio.UnknownError ->
                                        "Unknown error"

                                    Audio.ErrorThatHappensWhenYouLoadMoreThan1000SoundsDueToHackyWorkAroundToMakeThisPackageBehaveMoreLikeAnEffectPackage ->
                                        "Unknown error"

                            _ ->
                                "Loading..."
                          )
                            |> Element.text
                            |> Element.el [ Element.centerX ]
                        ]

                Loaded loaded ->
                    loadedView loaded
            )
        ]
    }


loadedView : LoadedModel -> Element FrontendMsg_
loadedView model =
    case model.route of
        HomepageRoute ->
            homepageView model

        UnconferenceFormatRoute ->
            column
                [ width fill, height fill ]
                [ header { window = model.window, isCompact = True }
                , column
                    (padding 20 :: Theme.contentAttributes)
                    [ unconferenceFormatContent
                    ]
                , Theme.footer
                ]

        VenueAndAccessRoute ->
            column
                [ width fill, height fill ]
                [ header { window = model.window, isCompact = True }
                , column
                    (padding 20 :: Theme.contentAttributes)
                    [ venueAccessContent
                    ]
                , Theme.footer
                ]

        CodeOfConductRoute ->
            column
                [ width fill, height fill ]
                [ header { window = model.window, isCompact = True }
                , column
                    (padding 20 :: Theme.contentAttributes)
                    [ codeOfConductContent
                    ]
                , Theme.footer
                ]

        ElmCampArchiveRoute ->
            column
                [ width fill, height fill ]
                [ header { window = model.window, isCompact = True }
                , column
                    (padding 20 :: Theme.contentAttributes)
                    [ elmCampArchiveContent model
                    ]
                , Theme.footer
                ]

        AdminRoute passM ->
            Admin.view model

        PaymentSuccessRoute maybeEmailAddress ->
            column
                [ centerX, centerY, padding 24, spacing 16 ]
                [ paragraph [ Font.size 20, Font.center ] [ text "Your ticket purchase was successful!" ]
                , paragraph
                    [ width (px 420) ]
                    [ text "An email has been sent to "
                    , case maybeEmailAddress of
                        Just emailAddress ->
                            EmailAddress.toString emailAddress
                                |> text
                                |> el [ Font.semiBold ]

                        Nothing ->
                            text "your email address"
                    , text " with additional information."
                    ]
                , link
                    normalButtonAttributes
                    { url = Route.encode HomepageRoute
                    , label = el [ centerX ] (text "Return to homepage")
                    }
                ]

        PaymentCancelRoute ->
            column
                [ centerX, centerY, padding 24, spacing 16 ]
                [ paragraph
                    [ Font.size 20 ]
                    [ text "You cancelled your ticket purchase" ]
                , link
                    normalButtonAttributes
                    { url = Route.encode HomepageRoute
                    , label = el [ centerX ] (text "Return to homepage")
                    }
                ]

        LiveScheduleRoute ->
            LiveSchedule.view model |> map LiveScheduleMsg

        Camp23Denmark subpage ->
            Camp23Denmark.view model subpage


ticketsHtmlId =
    "tickets"


ticketSalesOpen =
    (TimeFormat.certain "2024-04-04T19:00" Time.utc).time


downloadTicketSalesReminder =
    ICalendar.download
        { name = "elm-camp-ticket-sale-starts"
        , prodid = { company = "elm-camp", product = "website" }
        , events =
            [ { uid = "elm-camp-ticket-sale-starts"
              , start = ticketSalesOpen
              , summary = "Elm Camp Ticket Sale Starts"
              , description = "Can't wait to see you there!"
              }
            ]
        }


homepageView : LoadedModel -> Element FrontendMsg_
homepageView model =
    let
        sidePadding =
            if model.window.width < 800 then
                24

            else
                60
    in
    column
        [ width fill ]
        [ column
            [ spacing 50
            , width fill
            , paddingEach { left = sidePadding, right = sidePadding, top = 0, bottom = 24 }
            ]
            [ header { window = model.window, isCompact = False }
            , column
                [ width fill, spacing 40 ]
                [ column Theme.contentAttributes
                    [ View.Countdown.detailedCountdown ticketSalesOpen "until ticket sales open" model
                    , Input.button
                        (Theme.submitButtonAttributes True ++ [ width (px 200), centerX ])
                        { onPress = Just DownloadTicketSalesReminder
                        , label = el [ Font.center, centerX ] <| text "Add to calendar"
                        }
                    , text " "
                    , case model.zone of
                        Just zone ->
                            DateFormat.format
                                [ DateFormat.yearNumber
                                , DateFormat.text "-"
                                , DateFormat.monthFixed
                                , DateFormat.text "-"
                                , DateFormat.dayOfMonthFixed
                                , DateFormat.text " "
                                , DateFormat.hourFixed
                                , DateFormat.text ":"
                                , DateFormat.minuteFixed
                                ]
                                zone
                                ticketSalesOpen
                                |> (\t -> el [ centerX ] <| text t)

                        _ ->
                            el [ centerX ] <| text "nozone"
                    ]
                , column Theme.contentAttributes [ content1 ]
                , let
                    prefix =
                        "24-colehayes/colehayes-"
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
                , column Theme.contentAttributes [ MarkdownThemed.renderFull "# Our sponsors", sponsors model.window ]
                , text " ---------------------------------------------- START OF BEFORE TICKET SALES GO LIVE CONTENT ------------------"
                , column Theme.contentAttributes [ ticketInfo ]
                , column
                    [ width fill
                    , spacing 60
                    , htmlAttribute (Html.Attributes.id ticketsHtmlId)
                    ]
                    [ el Theme.contentAttributes content2
                    , text "-------------------------------------------- START OF TICKETS LIVE CONTENT ---------------"
                    , grantApplicationCopy
                        |> MarkdownThemed.renderFull
                        |> el Theme.contentAttributes
                    , ticketsView model
                    , accommodationView model
                    , formView model
                        (Id.fromString Product.ticket.campingSpot)
                        (Id.fromString "testing")
                        Tickets.attendanceTicket

                    -- , Element.el Theme.contentAttributes content3
                    ]
                ]
            ]
        , Theme.footer
        ]


ticketsView model =
    column Theme.contentAttributes
        [ row [ width fill, htmlId "ticket-sales" ]
            [ column [ width fill ]
                [ """
## 🎟️ Attendance Ticket - £200

Attendance for Elm Camp's 4 day / 3 night event.

- Full accees to the venue grounds and activities
- All meals (Breakfast, Lunch, Dinner) included as per schedule
                """
                    |> MarkdownThemed.renderFull
                ]
            , column []
                [ Theme.numericField
                    "Tickets"
                    (List.length model.form.attendees)
                    (\_ ->
                        -- Remove last attendee from the list
                        model.form.attendees
                            |> List.init
                            |> Maybe.withDefault []
                            |> (\attendees ->
                                    let
                                        form =
                                            model.form
                                    in
                                    FormChanged { form | attendees = attendees }
                               )
                    )
                    (\_ ->
                        -- Add a new attendee to the list
                        model.form.attendees
                            |> (\attendees ->
                                    let
                                        form =
                                            model.form
                                    in
                                    FormChanged { form | attendees = attendees ++ [ PurchaseForm.defaultAttendee ] }
                               )
                    )
                ]
            ]
        , case model.form.attendees of
            [] ->
                none

            _ ->
                column [ width fill, spacing 20 ]
                    [ el [ Font.size 20 ] (text "Attendees")
                    , column
                        [ spacing 16, width fill ]
                        (List.indexedMap (\i attendee -> attendeeForm model i attendee) model.form.attendees)
                    ]
        ]


attendeeForm model i attendee =
    let
        form =
            model.form

        removeButton =
            Input.button
                (normalButtonAttributes ++ [ width (px 100) ])
                { onPress =
                    Just
                        (FormChanged { form | attendees = List.removeIfIndex (\j -> i == j) model.form.attendees })
                , label = el [ centerX ] (text "Remove")
                }
    in
    column
        [ width fill, spacing 16 ]
        [ row
            [ width fill, spacing 16 ]
            [ textInput
                model.form
                (\a -> FormChanged { form | attendees = List.setAt i { attendee | name = a } model.form.attendees })
                "Name"
                PurchaseForm.validateName
                attendee.name
            , textInput
                model.form
                (\a -> FormChanged { form | attendees = List.setAt i { attendee | email = a } model.form.attendees })
                "Email"
                PurchaseForm.validateEmailAddress
                attendee.email
            , textInput
                model.form
                (\a -> FormChanged { form | attendees = List.setAt i { attendee | country = a } model.form.attendees })
                "Country you live in"
                (\text ->
                    case String.Nonempty.fromString text of
                        Just nonempty ->
                            Ok nonempty

                        Nothing ->
                            Err "Please type in the name of the country you live in"
                )
                attendee.country
            , textInput
                model.form
                (\a -> FormChanged { form | attendees = List.setAt i { attendee | originCity = a } model.form.attendees })
                "City you live in (or nearest city to you)"
                (\text ->
                    case String.Nonempty.fromString text of
                        Just nonempty ->
                            Ok nonempty

                        Nothing ->
                            Err "Please type in the name of city nearest to you"
                )
                attendee.originCity
            , removeButton
            ]
        ]


errorText : String -> Element msg
errorText error =
    paragraph [ Font.color (rgb255 150 0 0) ] [ text error ]


formView : LoadedModel -> Id ProductId -> Id PriceId -> Tickets.Ticket -> Element FrontendMsg_
formView model productId priceId ticket =
    let
        form =
            model.form

        submitButton =
            Input.button
                (Theme.submitButtonAttributes (Inventory.purchaseable ticket.productId model.slotsRemaining))
                { onPress = Just PressedSubmitForm
                , label =
                    paragraph
                        [ Font.center ]
                        [ text
                            (if Inventory.purchaseable ticket.productId model.slotsRemaining then
                                "Purchase "

                             else
                                "Waitlist"
                            )
                        , case form.submitStatus of
                            NotSubmitted pressedSubmit ->
                                none

                            Submitting ->
                                el [ moveDown 5 ] Theme.spinnerWhite

                            SubmitBackendError err ->
                                none
                        ]
                }

        cancelButton =
            Input.button
                normalButtonAttributes
                { onPress = Just PressedCancelForm
                , label = el [ centerX ] (text "Cancel")
                }

        includedAccommodationNote =
            """
Please note: your selected options ***${accommodationStatus} accommodation***.
"""
                |> String.replace "${accommodationStatus}"
                    (if Tickets.formIncludesAccom form then
                        "include"

                     else
                        "do not include"
                    )
    in
    column
        [ width fill, spacing 60 ]
        [ none

        -- , carbonOffsetForm textInput model.showCarbonOffsetTooltip form
        , opportunityGrant form
        , sponsorships model form
        , summary model
        , column
            (Theme.contentAttributes
                ++ [ spacing 24

                   --    , padding 16
                   ]
            )
            [ none
            , MarkdownThemed.renderFull includedAccommodationNote
            , textInput
                model.form
                (\a -> FormChanged { form | billingEmail = a })
                "Billing email address"
                PurchaseForm.validateEmailAddress
                form.billingEmail
            , case form.submitStatus of
                NotSubmitted pressedSubmit ->
                    none

                Submitting ->
                    -- @TODO spinner
                    none

                SubmitBackendError err ->
                    paragraph [] [ text err ]
            , """
Your order will be processed by Elm Camp's fiscal host: <img src="/sponsors/cofoundry.png" width="100" />.

By purchasing you agree to the event [Code of Conduct](/code-of-conduct).
""" |> MarkdownThemed.renderFull
            , if model.window.width > 600 then
                row [ width fill, spacing 16 ] [ cancelButton, submitButton ]

              else
                column [ width fill, spacing 16 ] [ submitButton, cancelButton ]
            , """Problem with something above? Get in touch with the team at [team@elm.camp](mailto:team@elm.camp)."""
                |> MarkdownThemed.renderFull
            ]
        ]


textInput : PurchaseForm -> (String -> msg) -> String -> (String -> Result String value) -> String -> Element msg
textInput form onChange title validator text =
    column
        [ spacing 4, width fill ]
        [ Input.text
            [ Border.rounded 8 ]
            { text = text
            , onChange = onChange
            , placeholder = Nothing
            , label = Input.labelAbove [ Font.semiBold ] (Element.text title)
            }
        , case ( form.submitStatus, validator text ) of
            ( NotSubmitted PressedSubmit, Err error ) ->
                errorText error

            _ ->
                none
        ]


opportunityGrant form =
    column (Theme.contentAttributes ++ [ spacing 20 ])
        [ Theme.h2 "\u{1FAF6} Opportunity grants"
        , paragraph [] [ text "We want Elm Camp to reflect the diverse community of Elm users and benefit from the contribution of anyone, irrespective of financial background. We therefore rely on the support of sponsors and individual participants to lessen the financial impact on those who may otherwise have to abstain from attending." ]
        , Theme.panel []
            [ column []
                [ paragraph [] [ text "All amounts are helpful and 100% of the donation (less payment processing fees) will be put to good use supporting expenses for our grantees!" ]
                , row [ width fill, spacing 30 ]
                    [ textInput form (\a -> FormChanged { form | grantContribution = a }) "" PurchaseForm.validateInt form.grantContribution
                    , column [ width (fillPortion 3) ]
                        [ row [ width (fillPortion 3) ]
                            [ el [ paddingXY 0 10 ] <| text "0"
                            , el [ paddingXY 0 10, alignRight ] <| text "600"
                            ]
                        , Input.slider
                            [ behindContent
                                (el
                                    [ width fill
                                    , height (px 5)
                                    , centerY
                                    , Background.color (rgb255 94 176 125)
                                    , Border.rounded 2
                                    ]
                                    none
                                )
                            ]
                            { onChange = \a -> FormChanged { form | grantContribution = String.fromFloat a }
                            , label = Input.labelHidden "Opportunity grant contribution value selection slider"
                            , min = 0
                            , max = 600
                            , value = String.toFloat form.grantContribution |> Maybe.withDefault 0
                            , thumb = Input.defaultThumb
                            , step = Just 10
                            }
                        , row [ width (fillPortion 3) ]
                            [ el [ paddingXY 0 10 ] <| text "No contribution"
                            , el [ paddingXY 0 10, alignRight ] <| text "Donate full attendance"
                            ]
                        ]
                    ]
                ]
            ]
        ]


grantApplicationCopy =
    """

## 🤗 Opportunity grant applications

If you would like to attend but are unsure about how to cover the combination of ticket, accommodations and travel expenses, please get in touch with a brief paragraph about what motivates you to attend Elm Camp and how an opportunity grant could help.

Please apply by sending an email to [team@elm.camp](mailto:team@elm.camp). The final date for applications is the 1st of May. Decisions will be communicated directly to each applicant by 7th of May. Elm Camp grant decisions are made by the Elm Camp organizers using a blind selection process.

All applicants and grant recipients will remain confidential. In the unlikely case that there are unused funds, the amount will be publicly communicated and saved for future Elm Camp grants.
"""


sponsorships model form =
    column (Theme.contentAttributes ++ [ spacing 20 ])
        [ Theme.h2 "🤝 Sponsor Elm Camp"
        , paragraph [] [ text <| "Position your company as a leading supporter of the Elm community and help Elm Camp " ++ year ++ " achieve a reasonable ticket offering." ]
        , Product.sponsorshipItems
            |> List.map (sponsorshipOption form)
            |> Theme.rowToColumnWhen 700 model [ spacing 20, width fill ]
        ]


sponsorshipOption form s =
    let
        selected =
            form.sponsorship == Just s.productId

        attrs =
            if selected then
                [ Border.color (rgb255 94 176 125), Border.width 3 ]

            else
                [ Border.color (rgba255 0 0 0 0), Border.width 3 ]
    in
    Theme.panel attrs
        [ el [ Font.size 20, Font.bold ] (text s.name)
        , el [ Font.size 30, Font.bold ] (text <| "£" ++ String.fromInt s.price)
        , paragraph [] [ text s.description ]
        , s.features
            |> List.map (\point -> paragraph [ Font.size 12 ] [ text <| "• " ++ point ])
            |> column [ spacing 5 ]
        , Input.button
            (Theme.submitButtonAttributes True)
            { onPress =
                Just <|
                    FormChanged
                        { form
                            | sponsorship =
                                if selected then
                                    Nothing

                                else
                                    Just s.productId
                        }
            , label =
                el
                    [ centerX, Font.semiBold, Font.color (rgb 1 1 1) ]
                    (text
                        (if selected then
                            "Un-select"

                         else
                            "Select"
                        )
                    )
            }
        ]


summary : LoadedModel -> Element msg
summary model =
    let
        grantTotal =
            model.form.grantContribution |> String.toFloat |> Maybe.withDefault 0

        accomTotal =
            model.form.accommodationBookings
                |> List.map
                    (\accom ->
                        let
                            t =
                                Tickets.accomToTicket accom
                        in
                        model.prices
                            |> AssocList.get (Id.fromString t.productId)
                            |> Maybe.map (\price -> Theme.priceAmount price.price)
                            |> Maybe.withDefault 0
                    )
                |> List.sum

        sponsorshipTotal =
            model.form.sponsorship
                |> Maybe.andThen
                    (\productId ->
                        model.prices
                            |> AssocList.get (Id.fromString productId)
                            |> Maybe.map (\price -> Theme.priceAmount price.price)
                    )
                |> Maybe.withDefault 0

        total =
            accomTotal + grantTotal + sponsorshipTotal
    in
    column (Theme.contentAttributes ++ [ spacing 10 ])
        [ Theme.h2 "Summary"
        , model.form.attendees |> List.length |> (\num -> text <| "Attendance tickets x " ++ String.fromInt num ++ " – £" ++ String.fromFloat accomTotal)
        , if List.length model.form.accommodationBookings == 0 then
            text "No accommodation bookings"

          else
            model.form.accommodationBookings
                |> List.group
                |> List.map
                    (\group -> summaryAccommodation model group)
                |> column []
        , Theme.viewIf (model.form.grantContribution /= "0") <|
            text <|
                "Opportunity grant: £"
                    ++ model.form.grantContribution
        , Theme.viewIf (sponsorshipTotal > 0) <|
            text <|
                "Sponsorship: £"
                    ++ String.fromFloat sponsorshipTotal
        , Theme.h3 <| "Total: £" ++ String.fromFloat total
        ]


summaryAccommodation model ( accom, items ) =
    model.form.accommodationBookings
        |> List.filter ((==) accom)
        |> List.length
        |> (\num ->
                let
                    total =
                        model.prices
                            |> AssocList.get (Id.fromString (Tickets.accomToTicket accom).productId)
                            |> Maybe.map (\price -> Theme.priceAmount price.price)
                            |> Maybe.withDefault 0
                            |> (\price -> price * toFloat num)
                in
                Tickets.accomToString accom ++ " x " ++ String.fromInt num ++ " – £" ++ String.fromFloat total
           )
        |> text


backgroundColor : Color
backgroundColor =
    rgb255 255 244 225


carbonOffsetForm showCarbonOffsetTooltip form =
    column
        [ width fill
        , spacing 24
        , paddingEach { left = 16, right = 16, top = 32, bottom = 16 }
        , Border.width 2
        , Border.color (rgb255 94 176 125)
        , Border.rounded 12
        , el
            [ (if showCarbonOffsetTooltip then
                tooltip "We collect this info so we can estimate the carbon footprint of your trip. We pay Ecologi to offset some of the environmental impact (this is already priced in and doesn't change the shown ticket price)"

               else
                none
              )
                |> below
            , moveUp 20
            , moveRight 8
            , Background.color backgroundColor
            ]
            (Input.button
                [ padding 8 ]
                { onPress = Just PressedShowCarbonOffsetTooltip
                , label =
                    row
                        []
                        [ el [ Font.size 20 ] (text "🌲 Carbon offsetting ")
                        , el [ Font.size 12 ] (text "ℹ️")
                        ]
                }
            )
            |> inFront
        ]
        [ none
        , column
            [ spacing 8 ]
            [ paragraph
                [ Font.semiBold ]
                [ text "What will be your primary method of travelling to the event?" ]

            -- , TravelMode.all
            --     |> List.map
            --         (\choice ->
            --             radioButton "travel-mode" (TravelMode.toString choice) (Just choice == form.primaryModeOfTravel)
            --                 |> map
            --                     (\() ->
            --                         if Just choice == form.primaryModeOfTravel then
            --                             FormChanged { form | primaryModeOfTravel = Nothing }
            --                         else
            --                             FormChanged { form | primaryModeOfTravel = Just choice }
            --                     )
            --         )
            --     |> column []
            , case ( form.submitStatus, form.primaryModeOfTravel ) of
                ( NotSubmitted PressedSubmit, Nothing ) ->
                    errorText "Please select one of the above"

                _ ->
                    none
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
        |> html
        |> el []


venueImage : Length -> String -> Element msg
venueImage width path =
    image
        [ Element.width width ]
        { src = "/" ++ path, description = "Photo of part of Colehayes Park" }


accommodationView : LoadedModel -> Element FrontendMsg_
accommodationView model =
    column [ width fill, spacing 20 ]
        [ column Theme.contentAttributes
            [ Theme.h2 "🏕️ Accommodation"
            , """
You can upgrade a camp ticket with any of the below on-site accommodation options, or organise your own off-site accommodation.

The facilities for those who wish to bring a tent or campervan and camp are excellent. The surrounding grounds and countryside are beautiful and include woodland, a swimming lake and a firepit.
"""
                |> MarkdownThemed.renderFull
            ]
        , AssocList.toList Tickets.accommodationOptions
            |> List.reverse
            |> List.map
                (\( productId, ( accom, ticket ) ) ->
                    case AssocList.get productId model.prices of
                        Just price ->
                            Tickets.viewAccom model.form
                                accom
                                (Inventory.purchaseable ticket.productId model.slotsRemaining)
                                (PressedSelectTicket productId price.priceId)
                                (RemoveAccom accom)
                                (AddAccom accom)
                                price.price
                                ticket

                        Nothing ->
                            text "No ticket prices found"
                )
            |> Theme.rowToColumnWhen 1200 model [ spacing 16 ]
        ]



-- ADDED BY JC


goToTicketSales =
    Input.button showyButtonAttributes { onPress = Just (SetViewPortForElement "🎟️-attendance-ticket---£200"), label = text "Tickets on sale now!" }


jumpToId : String -> Cmd FrontendMsg_
jumpToId id =
    Browser.Dom.getElement id
        |> Task.andThen (\el -> Browser.Dom.setViewport 0 (el.element.y - 40))
        |> Task.attempt
            (\_ -> Noop)


htmlId : String -> Element.Attribute msg
htmlId str =
    Element.htmlAttribute (Html.Attributes.id str)



-- END OF ADDED BY JC


content1 : Element msg
content1 =
    """
Elm Camp brings an opportunity for Elm makers & tool builders to gather, communicate and collaborate. Our goal is to strengthen and sustain the Elm ecosystem and community.

Elm Camp is an event geared towards reconnecting in-person and collaborating on the current and future community landscape of the Elm ecosystem that surrounds the Elm core language.

Over the last few years, Elm has seen community-driven tools and libraries expanding the potential and utility of the Elm language, stemming from a steady pace of continued commercial and hobbyist adoption.

We find great potential for progress and innovation in a creative, focused, in-person gathering. We expect the wider community and practitioners to benefit from this collaborative exploration of our shared problems and goals.

Elm Camp is now in its second year! Following last year’s delightful debut in Denmark, we’re heading to the UK. Our plan is to keep it small, casual and low-stress but we’ve added a day and found a venue that will accommodate more people. This time we’re serious about the camping too!


# Unconference

- Arrive anytime on Tue 18th June 2024

- Depart 10am Fri 21st June 2024

- 🇬🇧 Colehayes Park, Devon UK

- Collaborative session creation throughout

- Periodic collective scheduling sessions

- At least 3 tracks, sessions in both short and long blocks

- Countless hallway conversations and mealtime connections

- Full and exclusive access to the Park grounds and facilities

- 60+ attendees

"""
        |> MarkdownThemed.renderFull


ticketInfo =
    """
# Tickets

There is a mix of room types — singles, doubles, dorm style rooms
suitable for up to four people. Attendees will self-organize
to distribute among the rooms and share bathrooms.
The facilities for those who wish to bring a tent or campervan and camp
are excellent. The surrounding grounds and countryside are
beautiful and include woodland, a swimming lake and a firepit.

Each attendee will need to purchase a campfire ticket and (1)
 plan to camp or (2) purchase a
a single room ticket (limited availability), or (3) organize
with others for a shared double room ticket or a shared  dorm room ticket.
See the example ticket combinations below for more details.

## Campfire Ticket – £200
- Attendee ticket, full access to the event 18th - 21st June 2024
- Breakfast, lunch, tea & dinner included as per schedule

## Room Add-ons
You can upgrade a camp ticket with any of the below on-site accommodation options, or organise your own off-site accommodation.

### Outdoor camping space – Free
- Bring your own tent or campervan and stay on site
- Showers & toilets provided

### Dorm room - £600
- Suitable for up to 4 people

### Double room – £500
- Suitable for couple or twin beds

### Single room – £400
- Limited availability


**Example ticket combinations:**
- Purchase 3 campfire tickets (£600) and 1 dorm room (£600) to share for £1200 (£400 per person)
- Purchase 1 campfire ticket (£200) and a single room (£400) for £600

This year’s venue has capacity for 75 attendees. Our plan is to maximise opportunity to attend by encouraging folks to share rooms.
"""
        |> MarkdownThemed.renderFull


tooltip : String -> Element msg
tooltip text =
    paragraph
        [ paddingXY 12 8
        , Background.color (rgb 1 1 1)
        , width (px 300)
        , Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = rgba 0 0 0 0.25 }
        ]
        [ Element.text text ]


content2 : Element msg
content2 =
    """

# \u{1FAF6} Opportunity grant

Last year, we were able to offer opportunity grants to cover both ticket and travel costs for a number of attendees who would otherwise not have been able to attend. This year we will be offering the same opportunity again.

**Thanks to Concentric and generous individual sponsors for making the Elm Camp 2023 opportunity grants possible**.

# Organisers

Elm Camp is a community-driven non-profit initiative, organised by enthusiastic members of the Elm community.

"""
        -- ++ organisers2024
        |> MarkdownThemed.renderFull


organisers2024 =
    """
🇬🇧 Katja Mordaunt – Uses web tech to help improve the reach of charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of [codereading.club](https://codereading.club/)

🇺🇸 Jim Carlson – Developer of [Scripta.io](https://scripta.io), a web publishing platform for technical documents in mathematics, physics, and the like. Currently working for [exosphere.app](https://exosphere.app), an all-Elm cloud-computing project

🇬🇧 Mario Rogic – Organiser of the [Elm London](https://meetdown.app/group/37aa26/Elm-London-Meetup) and [Elm Online](https://meetdown.app/group/10561/Elm-Online-Meetup) meetups. Groundskeeper of [Elmcraft](https://elmcraft.org/), founder of [Lamdera](https://lamdera.com/).

🇺🇸 Wolfgang Schuster – Author of [Elm weekly](https://www.elmweekly.nl/), hobbyist and professional Elm developer. Currently working at [Vendr](https://www.vendr.com/).

🇬🇧 Hayleigh Thompson – Terminally online in the Elm community. Competitive person-help. Developer relations engineer at [xyflow](https://www.xyflow.com/).
"""


content3 =
    """
# Sponsorship options

Sponsoring Elm Camp gives your company the opportunity to support and connect with the Elm community. Your contribution helps members of the community to get together by keeping individual ticket prices at a reasonable level.

If you're interested in sponsoring please get in touch with the team at [team@elm.camp](mailto:team@elm.camp).


## Bronze - less than £750

You will be an appreciated supporter of Elm Camp 2024.
- Listed as additional supporter on webpage

## Silver - £750 (€875 EUR / $1000 USD)

You will be a major supporter of Elm Camp 2024.
- Thank you tweet
- Logo on webpage
- Small logo on shared slide, displayed during breaks

##  Gold - £1500 (€1750 EUR / $1900 USD)

You will be a pivotal supporter of Elm Camp 2024.
- Thank you tweet
- Logo on webpage
- Medium logo on shared slide, displayed during breaks
- Rollup or poster inside the venue (provided by you)
- 1 free campfire ticket

## Platinum - £3000 (€3500 EUR / $3800 USD)

You will be principal sponsor and guarantee that Elm Camp 2024 is a success.
- Thank you tweet
- Logo on webpage
- Big logo on shared slide, displayed during breaks
- Rollup or poster inside the venue (provided by you)
- Self-written snippet on shared web page about use of Elm at your company
- 2 free campfire tickets or 1 free camp-bed reservation
- Honorary mention in opening and closing talks

# Something else?

Problem with something above? Get in touch with the team at [team@elm.camp](mailto:team@elm.camp)."""
        |> MarkdownThemed.renderFull


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
        [ [ asImg { image = "vendr.png", url = "https://www.vendr.com/", width = 350 }
          ]
            |> wrappedRow [ centerX, spacing 32 ]
        , [ asImg { image = "ambue-logo.png", url = "https://www.ambue.com/", width = 220 }
          , asImg { image = "nlx_logo.png", url = "https://nlx.ai", width = 150 }
          ]
            |> wrappedRow [ centerX, spacing 32 ]
        , [ asImg { image = "concentrichealthlogo.svg", url = "https://concentric.health/", width = 200 }
          , asImg { image = "logo-dividat.svg", url = "https://dividat.com", width = 160 }
          ]
            |> wrappedRow [ centerX, spacing 32 ]
        , [ asImg { image = "lamdera-logo-black.svg", url = "https://lamdera.com/", width = 100 }
          , asImg { image = "scripta.io.svg", url = "https://scripta.io", width = 100 }
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
          , asImg { image = "cookiewolf-logo.png", url = "", width = 120 }
          ]
            |> wrappedRow [ centerX, spacing 32 ]
        ]


unconferenceFormatContent : Element msg
unconferenceFormatContent =
    """
# Unconference Format

## First and foremost, there are no unchangeable rules, with the exception of the "rule of two feet":
### It is expected that people move freely between sessions at any time. If you are no longer interested in listening or contributing to the conversation, find another one.

<br/>

> <br/>
> You know how at a conference, the best discussions often occur when people are relaxed during coffee breaks? That's the whole idea of an unconference: it's like a long, informal coffee break where everyone can contribute to the conversation. The participants drive the agenda. Any structure that exists at an unconference is just there to kick things off and to help the conversations flow smoothly, not to restrict or dictate the topics.

<br/>
<br/>

## We are doing this together.
## The following is intended as a collective starting point.

# Plan

## Before Elm Camp

- People can start proposing presentations before Elm camp in the form of cards on a Trello board which will be a place for conversations and serve as a schedule during the unconference and an archive after.
- There are 2 pre-planned sessions (the unkeynotes at the start and end of Elm Camp)
- We'll start with 3 tracks. If needed, more concurrent sessions may be scheduled during the unconference.
- Sessions will be offered in 15 and 30 minute blocks.
- We encourage attendees to think about how they might like to document or share our discussions with the community after Elm Camp. e.g. blog posts, graphics, videos

## During Elm Camp

- We'll arrange collective scheduling sessions every morning, where together we pitch, vote for and schedule sessions.
- All tracks will run in sync to allow for easy switching between sessions.
- We'll have reserved time for public announcements. You'll have a couple minutes on stage if needed.
- The schedule will be clearly displayed both online and at the venue for easy reference.
- Session locations will have distinctive names for effortless navigation.
- Session endings will be made clear to prevent overruns.
- Doors will be kept open to make moving along easy.
- Breaks are scheduled to provide downtime.
- The organisers will be readily available and identifiable for any assistance needed.

# Guidelines

## Be inclusive

- There is no restriction or theme on the subject for proposed topics, except that they should be with positive intent. Think do no harm and don't frame your session negatively. A simple, open question is best.
- If you want to talk about something and someone here wants to talk with you about it, grab some space and make it happen. You don't need permission, but keep it open to everyone and don't disrupt running sessions.
- Think of it as a gathering of people having open conversations
- Think discussion: talk _with_, not talk _at_. Share a 20-second description of what you think would be interesting to talk about and why.
- As much as possible, the organisers want to be normal session participants. We're one of you.
- People will be freely moving in and out of sessions. If you find yourself in an empty room, migrate.
- The event has some fixed infrastructure to keep the environment positive. But outside of that if you want to change something, feel free to make it happen.

## What happens here, stays here, by default.

- Assume people are comfortable saying stuff here because it's not going on twitter, so if you do want to quote someone during or after Elm Camp, please get their permission.
- Any outputs from the event should focus on the ideas, initiatives and projects discussed, as opposed to personal opinons or statements by individuals.
    """
        |> MarkdownThemed.renderFull


codeOfConductContent : Element msg
codeOfConductContent =
    """
# Code of Conduct

Elm Camp welcomes people with a wide range of backgrounds, experiences and knowledge. We can learn a lot from each other. It's important for us to make sure the environment where these discussions happen is inclusive and supportive. Everyone should feel comfortable to participate! The following guidelines are meant to codify these intentions.

## Help everyone feel welcome at Elm Camp

Everyone at Elm Camp is part of Elm Camp. There are a few staff on call and caterers preparing food, but there are no other guests on the grounds.

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
* Interrupting people when they are speaking
* Sharing others' private information, such as a physical or email address, without their explicit permission
* Other conduct which could reasonably be considered inappropriate in a professional setting


## Guidelines for running a camp session

As a facilitator it's important that you not only follow our code of conduct, but also help to enforce it.

If you have any concerns when planning, during or after your session, please get in touch with one of the organisers so we can help you.


## Talk to us

If you experience any behaviours or atmosphere at Elm Camp that feels contrary to these values, please let us know. We want everyone to feel safe, equal and welcome.

* Email the organiser team: [team@elm.camp](mailto:team@elm.camp)
* Contact Katja on [Elm slack](https://elm-lang.org/community/slack): @katjam or [Elmcraft Discord](https://discord.gg/QeZDXJrN78): Katja#0091

## How we handle Code of Conduct issues

If someone makes you or anyone else feel unsafe or unwelcome, please report it as soon as possible. You can make a report personally, anonymously or ask someone to do it on your behalf.

The Code of Conduct is in place to protect everyone at Elm Camp. If any participant violates these rules the organisers will take action.

We prefer to resolve things collaboratively and listening to everyone involved. We can all learn things from each other if we discuss issues openly.

However, if you feel you want help resolving something more privately, please ask an organiser. We are here to support you. The organisers will never disclose who brought the matter to our attention, in the case that they prefer to remain anonymous.

Where appropriate, we aim to be forgiving: if it seems like someone has made a good-natured mistake, we want to give space to grow and learn and a chance to apologise.

Where deemed necessary, the organisers will ask participants who harm the Elm Camp community to leave. This Code of Conduct is a guide, and since we can’t possibly write down all the ways you can hurt people, we may ask participants to leave for reasons that we didn’t write down explicitly here.

If you have any questions, concerns or suggestions regarding this policy, please get in touch.

This code of conduct was inspired by the [!!Con code of conduct](https://bangbangcon.com/conduct.html) and drafted with the guidance of the [Geek Feminism Wiki](https://geekfeminism.fandom.com/wiki/Conference_anti-harassment/Policy_resources)
    """
        |> MarkdownThemed.renderFull


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
* Elmcraft Discord: [#elm-camp-24](https://discord.gg/QeZDXJrN78) channel or DM Katja#0091
* Email: [team@elm.camp](mailto:team@elm.camp)
* Elm Slack: @katjam
"""


elmCampArchiveContent : LoadedModel -> Element msg
elmCampArchiveContent model =
    column []
        [ """
# What happened at Elm Camp 2023

Last year we ran a 3-day event in Odense, Denmark. Here are some of the memories folks have shared:

"""
            ++ Camp23Denmark.Artifacts.posts
            ++ Camp23Denmark.Artifacts.media
            ++ """
Did you attend Elm Camp 2023? We're [open to contributions on Github](https://github.com/elm-camp/website/edit/main/src/Camp23Denmark/Artifacts.elm)!

[Archive: Elm Camp 2023 - Denmark website](/23-denmark)
        """
            |> MarkdownThemed.renderFull
        ]


year =
    "2024"
