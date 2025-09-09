module Frontend exposing (app)

import Admin
import Audio exposing (Audio, AudioCmd)
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Camp23Denmark
import Camp23Denmark.Artifacts
import Camp24Uk
import Camp25US
import Camp25US.Inventory as Inventory
import Camp25US.Tickets as Tickets
import Dict
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import EmailAddress exposing (EmailAddress)
import Env
import ICalendar exposing (IcsFile)
import Json.Decode
import Json.Encode
import Lamdera
import LamderaRPC
import List.Extra as List
import LiveSchedule
import MarkdownThemed
import Page.UnconferenceFormat
import Ports
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated, SubmitStatus(..))
import Route exposing (Route(..), SubPage(..))
import SeqDict
import Stripe
import Task
import Theme exposing (normalButtonAttributes)
import Time
import Types exposing (FrontendModel, FrontendModel_(..), FrontendMsg_(..), LoadedModel, LoadingModel, TicketsEnabled(..), ToBackend(..), ToFrontend(..))
import Untrusted
import Url
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query
import View.Sales


app :
    { init : Url.Url -> Browser.Navigation.Key -> ( FrontendModel, Cmd (Audio.Msg FrontendMsg_) )
    , view : FrontendModel -> Browser.Document (Audio.Msg FrontendMsg_)
    , update : Audio.Msg FrontendMsg_ -> FrontendModel -> ( FrontendModel, Cmd (Audio.Msg FrontendMsg_) )
    , updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd (Audio.Msg FrontendMsg_) )
    , subscriptions : FrontendModel -> Sub (Audio.Msg FrontendMsg_)
    , onUrlRequest : UrlRequest -> Audio.Msg FrontendMsg_
    , onUrlChange : Url.Url -> Audio.Msg FrontendMsg_
    }
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


queryBool : String -> Query.Parser (Maybe Bool)
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
            case ( SeqDict.get productId Tickets.accommodationOptions, model.ticketsEnabled ) of
                ( Just ( _, ticket ), TicketsEnabled ) ->
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

                SubmitBackendError _ ->
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
                    , jumpToId View.Sales.errorHtmlId 110
                    )

                _ ->
                    let
                        _ =
                            Debug.log "Form already submitted" "Form already submitted"
                    in
                    ( model, Cmd.none )

        PressedCancelForm ->
            ( { model | selectedTicket = Nothing }
            , Browser.Dom.getElement View.Sales.ticketsHtmlId
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
            ( model, jumpToId elmentId 40 )

        AdminPullBackendModel ->
            ( model
            , LamderaRPC.postJsonBytes
                Types.w3_decode_BackendModel
                -- (Json.Encode.string Env.adminPassword)
                (Json.Encode.string "adjust me when developing locally")
                "http://localhost:8001/https://elm.camp/_r/backend-model"
                |> Task.attempt AdminPullBackendModelResponse
            )

        AdminPullBackendModelResponse res ->
            case res of
                Ok backendModel ->
                    ( { model | backendModel = Just backendModel }, Cmd.none )

                Err err ->
                    let
                        _ =
                            Debug.log "Failed to pull backend model" err
                    in
                    ( model, Cmd.none )

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
            Element.link
                []
                { url = Route.encode HomepageRoute
                , label = Element.el [ Font.size titleSize, Theme.glow, Element.paddingXY 0 8 ] (Element.text "Elm Camp")
                }

        elmCampNextTopLine =
            Element.column [ Element.spacing 30 ]
                [ Element.row
                    [ Element.centerX, Element.spacing 13 ]
                    [ Element.image
                        [ Element.width (Element.px 49) ]
                        { src = "/elm-camp-tangram.webp", description = "The logo of Elm Camp, a tangram in green forest colors" }
                    , Element.column []
                        [ Element.column
                            [ Element.spacing 2, Font.size 24, Element.moveUp 1 ]
                            [ Element.el [ Theme.glow ] (Element.text "Unconference")
                            , Element.el [ Font.extraBold, Font.color Theme.lightTheme.elmText ] (Element.text "2025")
                            ]
                        ]
                    ]
                , Element.column
                    [ Element.moveRight 0, Element.spacing 2, Font.size 18, Element.moveUp 1 ]
                    [ Element.el [ Font.bold, Font.color Theme.lightTheme.defaultText ] (Element.text "")
                    , Element.el [ Font.bold, Font.color Theme.lightTheme.defaultText ] (Element.text "🇺🇸 Watervliet, Michigan")
                    , Element.el [ Font.bold, Font.color Theme.lightTheme.defaultText ] ("[Ronora Lodge & Retreat Center](https://www.ronoralodge.com)" |> MarkdownThemed.renderFull)
                    , Element.el [ Font.bold, Font.color Theme.lightTheme.defaultText ] (Element.text "Tuesday 24th - Friday 27th June 2025")
                    ]
                ]

        imageMaxWidth =
            300

        eventImage =
            Element.image
                [ Element.width (Element.maximum imageMaxWidth Element.fill), Theme.attr "fetchpriority" "high" ]
                { src = "/logo-25.webp", description = illustrationAltText }
    in
    if config.window.width < 1000 || config.isCompact then
        Element.column
            [ Element.padding 30, Element.spacing 20, Element.centerX ]
            [ if config.isCompact then
                Element.none

              else
                eventImage
            , Element.column
                [ Element.spacing 24, Element.centerX ]
                [ elmCampTitle
                , elmCampNextTopLine
                ]
            ]

    else
        Element.row
            [ Element.padding 30, Element.spacing 40, Element.centerX ]
            [ eventImage
            , Element.column
                [ Element.spacing 24 ]
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
            , Background.color View.Sales.backgroundColor
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
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ Page.UnconferenceFormat.view
                    ]
                , Theme.footer
                ]

        VenueAndAccessRoute ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ Camp25US.venueAccessContent
                    ]
                , Theme.footer
                ]

        CodeOfConductRoute ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ codeOfConductContent
                    ]
                , Theme.footer
                ]

        OrganisersRoute ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ View.Sales.organisersInfo
                    , Camp25US.organisers |> MarkdownThemed.renderFull
                    ]
                , Theme.footer
                ]

        ElmCampArchiveRoute ->
            Element.column
                [ Element.width Element.fill, Element.height Element.fill ]
                [ header { window = model.window, isCompact = True }
                , Element.column
                    (Element.padding 20 :: Theme.contentAttributes)
                    [ elmCampArchiveContent model ]
                , Theme.footer
                ]

        AdminRoute _ ->
            Admin.view model

        PaymentSuccessRoute maybeEmailAddress ->
            Element.column
                [ Element.centerX, Element.centerY, Element.padding 24, Element.spacing 16 ]
                [ Element.paragraph [ Font.size 20, Font.center ] [ Element.text "Your ticket purchase was successful!" ]
                , Element.paragraph
                    [ Element.width (Element.px 420) ]
                    [ Element.text "An email has been sent to "
                    , case maybeEmailAddress of
                        Just emailAddress ->
                            EmailAddress.toString emailAddress
                                |> Element.text
                                |> Element.el [ Font.semiBold ]

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
                    [ Font.size 20 ]
                    [ Element.text "You cancelled your ticket purchase" ]
                , Element.link
                    normalButtonAttributes
                    { url = Route.encode HomepageRoute
                    , label = Element.el [ Element.centerX ] (Element.text "Return to homepage")
                    }
                ]

        LiveScheduleRoute ->
            LiveSchedule.view model |> Element.map LiveScheduleMsg

        Camp23Denmark subpage ->
            Camp23Denmark.view model subpage

        Camp24Uk subpage ->
            Camp24Uk.view model subpage

        Camp25US subpage ->
            Camp25US.view model subpage


downloadTicketSalesReminder : Cmd msg
downloadTicketSalesReminder =
    ICalendar.download
        { name = "elm-camp-ticket-sale-starts"
        , prodid = { company = "elm-camp", product = "website" }
        , events =
            [ { uid = "elm-camp-ticket-sale-starts"
              , start = View.Sales.ticketSalesOpen
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
    Element.column
        [ Element.width Element.fill ]
        [ Element.column
            [ Element.spacing 50
            , Element.width Element.fill
            , Element.paddingEach { left = sidePadding, right = sidePadding, top = 0, bottom = 24 }
            ]
            [ header { window = model.window, isCompact = False }
            , Element.column
                [ Element.width Element.fill, Element.spacing 40 ]
                [ --View.Sales.ticketSalesOpenCountdown model
                  Element.column Theme.contentAttributes [ elmCampOverview ]
                , Element.column Theme.contentAttributes
                    [ Camp25US.venuePictures model
                    , Camp25US.conferenceSummary
                    ]
                , Element.column Theme.contentAttributes [ MarkdownThemed.renderFull "# Our sponsors", Camp25US.sponsors model.window ]

                --, View.Sales.view model
                ]
            ]
        , Theme.footer
        ]


jumpToId : String -> Float -> Cmd FrontendMsg_
jumpToId id offset =
    Browser.Dom.getElement id
        |> Task.andThen (\el -> Browser.Dom.setViewport 0 (el.element.y - offset))
        |> Task.attempt
            (\_ -> Noop)


elmCampOverview : Element msg
elmCampOverview =
    """
# Elm Camp 2025 - Michigan, US

Elm Camp returns for its 3rd year, this time in Watervliet, Michigan!

---

Elm Camp brings an opportunity for Elm makers & tool builders to gather, communicate and collaborate. Our goal is to strengthen and sustain the Elm ecosystem and community. Anyone with an interest in Elm is welcome.

Elm Camp is an event geared towards reconnecting in-person and collaborating on the current and future community landscape of the Elm ecosystem that surrounds the Elm core language.

Over the last few years, Elm has seen community-driven tools and libraries expanding the potential and utility of the Elm language, stemming from a steady pace of continued commercial and hobbyist adoption.

We find great potential for progress and innovation in a creative, focused, in-person gathering. We expect the wider community and practitioners to benefit from this collaborative exploration of our shared problems and goals.

"""
        |> MarkdownThemed.renderFull


codeOfConductContent : Element msg
codeOfConductContent =
    """
# Code of Conduct

Elm Camp welcomes people with a wide range of backgrounds, experiences and knowledge. We can learn a lot from each other. It's important for us to make sure the environment where these discussions happen is inclusive and supportive. Everyone should feel comfortable to participate! The following guidelines are meant to codify these intentions.
<br/>
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
<br/>

## Talk to us

If you experience any behaviours or atmosphere at Elm Camp that feels contrary to these values, please let us know. We want everyone to feel safe, equal and welcome.

* Email the organiser team: [team@elm.camp](mailto:team@elm.camp)
* Contact Katja on [Elm slack](https://elm-lang.org/community/slack): @katjam or [Elmcraft Discord](https://discord.gg/QeZDXJrN78): katjam_

## How we handle Code of Conduct issues

If someone makes you or anyone else feel unsafe or unwelcome, please report it as soon as possible. You can make a report personally, anonymously or ask someone to do it on your behalf.

The Code of Conduct is in place to protect everyone at Elm Camp. If any participant violates these rules the organisers will take action.

We prefer to resolve things collaboratively and listening to everyone involved. We can all learn things from each other if we discuss issues openly.

However, if you feel you want help resolving something more privately, please ask an organiser. We are here to support you. The organisers will never disclose who brought the matter to our attention, in the case that they prefer to remain anonymous.

Where appropriate, we aim to be forgiving: if it seems like someone has made a good-natured mistake, we want to give space to grow and learn and a chance to apologise.

Where deemed necessary, the organisers will ask participants who harm the Elm Camp community to leave. This Code of Conduct is a guide, and since we can't possibly write down all the ways you can hurt people, we may ask participants to leave for reasons that we didn't write down explicitly here.

If you have any questions, concerns or suggestions regarding this policy, please get in touch.

This code of conduct was inspired by the [!!Con code of conduct](https://bangbangcon.com/conduct.html) and drafted with the guidance of the [Geek Feminism Wiki](https://geekfeminism.fandom.com/wiki/Conference_anti-harassment/Policy_resources)
    """
        |> MarkdownThemed.renderFull


elmCampArchiveContent : LoadedModel -> Element msg
elmCampArchiveContent model =
    Element.column []
        [ """
# What happened at Elm Camp 2023

Last year we ran a 3-day event in Odense, Denmark. Here are some of the memories folks have shared:

"""
            ++ Camp23Denmark.Artifacts.posts
            ++ Camp23Denmark.Artifacts.media
            ++ """
Did you attend Elm Camp 2023? We're [open to contributions on Github](https://github.com/elm-camp/website/edit/main/src/Camp23Denmark/Artifacts.elm)!

[Archive: Elm Camp 2023 - Denmark website](/23-denmark)

[Archive: Elm Camp 2024 - UK website](/24-uk)

        """
            |> MarkdownThemed.renderFull
        ]
