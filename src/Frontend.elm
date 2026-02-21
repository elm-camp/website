module Frontend exposing (app, app_)

import Admin
import Archive
import Browser
import Browser.Navigation exposing (Key)
import Camp23Denmark
import Camp24Uk
import Camp25US
import Camp26Czech
import Dict
import Duration
import Effect.Browser
import Effect.Browser.Dom as Dom exposing (HtmlId)
import Effect.Browser.Events
import Effect.Browser.Navigation as Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Http as Http exposing (Error(..), Response(..))
import Effect.Lamdera as Lamdera
import Effect.Subscription as Subscription exposing (Subscription)
import Effect.Task as Task exposing (Task)
import Effect.Time as Time
import EmailAddress exposing (EmailAddress)
import Env
import Helpers
import ICalendar exposing (IcsFile)
import Json.Decode as D
import Json.Encode as E
import Lamdera as LamderaCore
import Lamdera.Wire3 as Wire3
import Money
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated, SubmitStatus(..))
import Quantity exposing (Quantity, Rate)
import RichText exposing (Inline(..), RichText(..))
import Route exposing (Route(..))
import SeqDict
import Stripe exposing (ConversionRateStatus(..), CurrentCurrency, LocalCurrency, StripeCurrency)
import Theme
import Types exposing (FrontendModel(..), FrontendMsg(..), LoadedModel, LoadingModel, TicketsEnabled(..), ToBackend(..), ToFrontend(..))
import Ui
import Ui.Anim
import Ui.Font
import Ui.Prose
import Ui.Shadow
import UnconferenceFormat
import Untrusted
import Url
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query
import View.Logo
import View.Sales


app :
    { init : Url.Url -> Key -> ( FrontendModel, Cmd FrontendMsg )
    , view : FrontendModel -> Browser.Document FrontendMsg
    , update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
    , updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
    , subscriptions : FrontendModel -> Sub FrontendMsg
    , onUrlRequest : Browser.UrlRequest -> FrontendMsg
    , onUrlChange : Url.Url -> FrontendMsg
    }
app =
    Lamdera.frontend LamderaCore.sendToBackend app_


app_ :
    { init : Url.Url -> Navigation.Key -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
    , onUrlRequest : Effect.Browser.UrlRequest -> FrontendMsg
    , onUrlChange : Url.Url -> FrontendMsg
    , update : FrontendMsg -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
    , updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Command FrontendOnly toMsg FrontendMsg )
    , subscriptions : FrontendModel -> Subscription FrontendOnly FrontendMsg
    , view : FrontendModel -> Effect.Browser.Document FrontendMsg
    }
app_ =
    { init = init
    , onUrlRequest = UrlClicked
    , onUrlChange = UrlChanged
    , update = update
    , updateFromBackend = updateFromBackend
    , subscriptions = subscriptions
    , view = view
    }


subscriptions : FrontendModel -> Subscription FrontendOnly FrontendMsg
subscriptions model =
    let
        logoSubscription =
            case model of
                Types.Loaded loadedModel ->
                    if View.Logo.needsAnimationFrame loadedModel.logoModel then
                        Effect.Browser.Events.onAnimationFrame (\posix -> View.Logo.Tick posix |> Types.LogoMsg)

                    else
                        Subscription.none

                Types.Loading _ ->
                    Subscription.none
    in
    Subscription.batch
        [ Effect.Browser.Events.onResize GotWindowSize
        , Effect.Browser.Events.onMouseUp (D.succeed MouseDown)
        , Time.every (Duration.seconds 5) Tick
        , logoSubscription
        ]


queryBool : String -> Query.Parser (Maybe Bool)
queryBool name =
    Query.enum name (Dict.fromList [ ( "true", True ), ( "false", False ) ])


init : Url.Url -> Navigation.Key -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
init url key =
    let
        isOrganiser =
            case url |> Url.Parser.parse (Url.Parser.top <?> queryBool "organiser") of
                Just (Just isOrganiser_) ->
                    isOrganiser_

                _ ->
                    False
    in
    ( Loading
        { key = key
        , now = Nothing
        , timeZone = Nothing
        , window = Nothing
        , initData = Nothing
        , url = url
        , isOrganiser = isOrganiser
        , elmUiState = Ui.Anim.init
        }
    , Command.batch
        [ Dom.getViewport
            |> Task.perform (\{ viewport } -> GotWindowSize (round viewport.width) (round viewport.height))
        , Time.now |> Task.perform Tick
        , Time.here |> Task.perform GotZone
        , case Route.decode url of
            PaymentCancelRoute ->
                Lamdera.sendToBackend CancelPurchaseRequest

            AdminRoute passM ->
                case passM of
                    Just pass ->
                        Lamdera.sendToBackend (AdminInspect pass)

                    Nothing ->
                        Command.none

            _ ->
                Command.none
        ]
    )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
update msg model =
    case model of
        Loading loading ->
            case msg of
                GotWindowSize width height ->
                    tryLoading { loading | window = Just { width = width, height = height } }

                Tick now ->
                    tryLoading { loading | now = Just now }

                GotZone zone ->
                    tryLoading { loading | timeZone = Just zone }

                _ ->
                    ( model, Command.none )

        Loaded loaded ->
            updateLoaded msg loaded |> Tuple.mapFirst Loaded


tryLoading : LoadingModel -> ( FrontendModel, Command FrontendOnly toMsg FrontendMsg )
tryLoading loadingModel =
    Maybe.map4
        (\window initData now timeZone ->
            ( Loaded
                { key = loadingModel.key
                , now = now
                , timeZone = timeZone
                , window = window
                , showTooltip = False
                , initData = initData
                , form = PurchaseForm.init
                , route = Route.decode loadingModel.url
                , backendModel = Nothing
                , logoModel = View.Logo.init
                , elmUiState = loadingModel.elmUiState
                , conversionRate = LoadingConversionRate
                }
            , Command.batch
                [ case loadingModel.url.fragment of
                    Just fragment ->
                        scrollToFragment (Dom.id fragment)

                    Nothing ->
                        Command.none
                , case initData of
                    Ok initData2 ->
                        Http.get
                            { url = "https://open.er-api.com/v6/latest/" ++ Money.toString initData2.stripeCurrency
                            , expect =
                                Http.expectJson
                                    GotConversionRate
                                    (D.map
                                        (\dict ->
                                            List.filterMap
                                                (\( key, value ) ->
                                                    case Money.fromString key of
                                                        Just key2 ->
                                                            Just ( key2, Quantity.unsafe (1 / value) )

                                                        Nothing ->
                                                            Nothing
                                                )
                                                (Dict.toList dict)
                                                |> SeqDict.fromList
                                        )
                                        (D.field "rates" (D.dict D.float))
                                    )
                            }

                    Err () ->
                        Command.none
                ]
            )
        )
        loadingModel.window
        loadingModel.initData
        loadingModel.now
        loadingModel.timeZone
        |> Maybe.withDefault ( Loading loadingModel, Command.none )


updateLoaded : FrontendMsg -> LoadedModel -> ( LoadedModel, Command FrontendOnly ToBackend FrontendMsg )
updateLoaded msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Navigation.pushUrl model.key (Route.decode url |> Route.encode url.fragment)
                    )

                Browser.External url ->
                    ( model
                    , Navigation.load url
                    )

        UrlChanged url ->
            let
                route : Route
                route =
                    Route.decode url
            in
            ( { model | route = route }
            , case url.fragment of
                Just fragment ->
                    scrollToFragment (Dom.id fragment)

                Nothing ->
                    scrollToTop
            )

        Tick now ->
            ( { model | now = now }, Command.none )

        GotZone zone ->
            ( { model | timeZone = zone }, Command.none )

        GotWindowSize width height ->
            ( { model | window = { width = width, height = height } }, Command.none )

        PressedShowTooltip ->
            ( { model | showTooltip = True }, Command.none )

        MouseDown ->
            ( { model | showTooltip = False }, Command.none )

        DownloadTicketSalesReminder ->
            ( model, downloadTicketSalesReminder )

        FormChanged form ->
            case model.form.submitStatus of
                NotSubmitted _ ->
                    ( { model | form = form }, Command.none )

                Submitting ->
                    ( model, Command.none )

                SubmitBackendError _ ->
                    ( { model | form = form }, Command.none )

        PressedSubmitForm ->
            case model.initData of
                Ok initData ->
                    let
                        form =
                            model.form
                    in
                    case form.submitStatus of
                        Submitting ->
                            ( model, Command.none )

                        _ ->
                            case PurchaseForm.validateForm initData.currentCurrency.conversionRate form of
                                Ok purchaseFormValidated ->
                                    ( { model | form = { form | submitStatus = Submitting } }
                                    , Lamdera.sendToBackend (SubmitFormRequest (Untrusted.untrust purchaseFormValidated))
                                    )

                                Err _ ->
                                    ( { model | form = { form | submitStatus = NotSubmitted PressedSubmit } }
                                    , jumpToId View.Sales.errorHtmlId 110
                                    )

                Err () ->
                    ( model, Command.none )

        SetViewport ->
            ( model, Command.none )

        Types.LogoMsg logoMsg ->
            ( { model | logoModel = View.Logo.update logoMsg model.logoModel }, Command.none )

        Noop ->
            ( model, Command.none )

        ElmUiMsg elmUiMsg ->
            ( { model | elmUiState = Ui.Anim.update elmUiMsg model.elmUiState }, Command.none )

        ScrolledToFragment ->
            ( model, Command.none )

        GotConversionRate result ->
            ( case result of
                Ok ok ->
                    { model
                        | conversionRate = LoadedConversionRate ok
                        , initData =
                            case model.initData of
                                Ok initData ->
                                    if initData.stripeCurrency == initData.currentCurrency.currency then
                                        Ok
                                            { initData
                                                | currentCurrency =
                                                    case SeqDict.get Money.EUR ok of
                                                        Just euro ->
                                                            { currency = Money.EUR, conversionRate = euro }

                                                        Nothing ->
                                                            initData.currentCurrency
                                            }

                                    else
                                        model.initData

                                Err () ->
                                    model.initData
                    }

                Err error ->
                    { model | conversionRate = LoadingConversionRateFailed error }
            , Command.none
            )

        SelectedCurrency currency ->
            ( case ( model.initData, model.conversionRate ) of
                ( Ok initData, LoadedConversionRate dict ) ->
                    case SeqDict.get currency dict of
                        Just conversionRate ->
                            let
                                form =
                                    model.form
                            in
                            { model
                                | initData =
                                    Ok { initData | currentCurrency = { currency = currency, conversionRate = conversionRate } }
                                , form =
                                    case PurchaseForm.validateGrantContribution form.grantContribution of
                                        Ok value ->
                                            { form
                                                | grantContribution =
                                                    -- Convert contribution text to proportionally equal value in new currency
                                                    Quantity.at
                                                        initData.currentCurrency.conversionRate
                                                        (Quantity.toFloatQuantity value)
                                                        |> Quantity.at_ conversionRate
                                                        |> Quantity.round
                                                        |> PurchaseForm.unvalidateGrantContribution
                                            }

                                        Err _ ->
                                            form
                            }

                        Nothing ->
                            model

                _ ->
                    model
            , Command.none
            )

        FusionPatch patch ->
            Debug.todo ""

        FusionQuery ->
            Debug.todo ""


{-| Copied from LamderaRPC.elm and made program-test compatible
-}
postJsonBytes : Wire3.Decoder b -> D.Value -> String -> Task r Error b
postJsonBytes decoder requestValue endpoint =
    Http.task
        { method = "POST"
        , headers = []
        , url = endpoint
        , body = Http.jsonBody requestValue
        , resolver =
            Http.bytesResolver
                (customResolver
                    (\metadata bytes ->
                        Wire3.bytesDecode decoder bytes
                            |> Result.fromMaybe (BadBody ("Failed to decode response from " ++ endpoint))
                    )
                )
        , timeout = Just (Duration.seconds 15)
        }


customResolver : (Http.Metadata -> responseType -> Result Error b) -> Response responseType -> Result Error b
customResolver fn response =
    case response of
        BadUrl_ urlString ->
            Err (BadUrl urlString)

        Timeout_ ->
            Err Timeout

        NetworkError_ ->
            Err NetworkError

        BadStatus_ metadata _ ->
            -- @TODO use metadata better here
            Err (BadStatus metadata.statusCode)

        GoodStatus_ metadata text ->
            fn metadata text


scrollToTop : Command FrontendOnly ToBackend FrontendMsg
scrollToTop =
    Dom.setViewport 0 0 |> Task.perform (\() -> SetViewport)


scrollToFragment : HtmlId -> Command FrontendOnly toMsg FrontendMsg
scrollToFragment fragment =
    Dom.getElement fragment
        |> Task.andThen (\{ element } -> Dom.setViewport 0 element.y)
        |> Task.attempt (\_ -> ScrolledToFragment)


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Command FrontendOnly toMsg FrontendMsg )
updateFromBackend msg model =
    case model of
        Loading loading ->
            case msg of
                InitData initData ->
                    tryLoading { loading | initData = Just initData }

                _ ->
                    ( model, Command.none )

        Loaded loaded ->
            updateFromBackendLoaded msg loaded |> Tuple.mapFirst Loaded


updateFromBackendLoaded : ToFrontend -> LoadedModel -> ( LoadedModel, Command FrontendOnly toMsg msg )
updateFromBackendLoaded msg model =
    case msg of
        InitData _ ->
            ( model, Command.none )

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
                    ( { model | form = { form | submitStatus = SubmitBackendError str } }, Command.none )

        SlotRemainingChanged slotsRemaining ->
            case model.initData of
                Ok initData ->
                    ( { model | initData = Ok { initData | ticketsAlreadyPurchased = slotsRemaining } }, Command.none )

                Err () ->
                    ( model, Command.none )

        TicketsEnabledChanged ticketsEnabled ->
            case model.initData of
                Ok initData ->
                    ( { model | initData = Ok { initData | ticketsEnabled = ticketsEnabled } }, Command.none )

                Err () ->
                    ( model, Command.none )

        AdminInspectResponse backendModel value ->
            ( { model | backendModel = Just ( backendModel, value ) }, Command.none )


view : FrontendModel -> Effect.Browser.Document FrontendMsg
view model =
    { title = "Elm Camp"
    , body =
        [ Theme.css
        , Ui.layout
            (Ui.withAnimation
                { toMsg = ElmUiMsg
                , state =
                    case model of
                        Loading loading ->
                            loading.elmUiState

                        Loaded loaded ->
                            loaded.elmUiState
                }
                Ui.default
            )
            [ Ui.Font.color Theme.lightTheme.defaultText
            , Ui.Font.family [ Ui.Font.typeface "Open Sans", Ui.Font.sansSerif ]
            , Ui.Font.size 16
            , Ui.Font.weight 500
            , Ui.height Ui.fill
            , Ui.background Theme.lightTheme.background
            , (case model of
                Loading _ ->
                    Ui.none

                Loaded loaded ->
                    case loaded.initData of
                        Ok initData ->
                            case initData.ticketsEnabled of
                                TicketsEnabled ->
                                    Ui.none

                                TicketsDisabled { adminMessage } ->
                                    Ui.Prose.paragraph
                                        [ Ui.Font.color (Ui.rgb 255 255 255)
                                        , Ui.Font.weight 500
                                        , Ui.Font.size 20
                                        , Ui.background (Ui.rgb 128 0 0)
                                        , Ui.padding 8
                                        ]
                                        [ Ui.text adminMessage ]

                        Err () ->
                            Ui.Prose.paragraph
                                [ Ui.Font.color (Ui.rgb 255 255 255)
                                , Ui.Font.weight 500
                                , Ui.Font.size 20
                                , Ui.background (Ui.rgb 128 0 0)
                                , Ui.padding 8
                                ]
                                [ Ui.text "Something went wrong when loading prices. Sorry about the inconvenience!" ]
              )
                |> Ui.inFront
            ]
            (case model of
                Loading _ ->
                    Ui.column [ Ui.padding 20 ]
                        [ Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Ui.text "Loading...")
                        ]

                Loaded loaded ->
                    loadedView loaded
            )
        ]
    }


loadedView : LoadedModel -> Ui.Element FrontendMsg
loadedView model =
    case model.route of
        HomepageRoute ->
            Camp26Czech.view model

        UnconferenceFormatRoute ->
            Ui.column
                [ Ui.height Ui.fill ]
                [ Camp26Czech.header model
                , Ui.column
                    (Ui.padding 20 :: Theme.contentAttributes)
                    [ RichText.view model UnconferenceFormat.view
                    ]
                , Theme.footer
                ]

        CodeOfConductRoute ->
            Ui.column
                [ Ui.height Ui.fill ]
                [ Camp26Czech.header model
                , Ui.column
                    (Ui.padding 20 :: Theme.contentAttributes)
                    [ RichText.view model codeOfConductContent
                    ]
                , Theme.footer
                ]

        ElmCampArchiveRoute ->
            Ui.column
                [ Ui.height Ui.fill ]
                [ Camp26Czech.header model
                , Ui.column
                    (Ui.padding 20 :: Theme.contentAttributes)
                    [ RichText.view model Archive.content ]
                , Theme.footer
                ]

        AdminRoute _ ->
            Admin.view model

        PaymentSuccessRoute maybeEmailAddress ->
            Ui.column
                [ Ui.width Ui.shrink, Ui.centerX, Ui.centerY, Ui.padding 24, Ui.spacing 16 ]
                [ Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.Font.center ] [ Ui.text "Your ticket purchase was successful!" ]
                , Ui.Prose.paragraph
                    [ Ui.width (Ui.px 420) ]
                    [ Ui.text "An email has been sent to "
                    , case maybeEmailAddress of
                        Just emailAddress ->
                            EmailAddress.toString emailAddress
                                |> Ui.text
                                |> Ui.el [ Ui.width Ui.shrink, Ui.Font.weight 600 ]

                        Nothing ->
                            Ui.text "your email address"
                    , Ui.text " with additional information."
                    ]
                , returnToHomepageButton
                ]

        PaymentCancelRoute ->
            Ui.column
                [ Ui.width Ui.shrink, Ui.centerX, Ui.centerY, Ui.padding 24, Ui.spacing 16 ]
                [ Ui.el
                    [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.centerX ]
                    (Ui.text "You cancelled your ticket purchase")
                , returnToHomepageButton
                ]

        Camp23Denmark ->
            Camp23Denmark.view model

        Camp24Uk ->
            Camp24Uk.view model

        Camp25US ->
            Camp25US.view model

        TicketPurchaseRoute ->
            View.Sales.view Camp26Czech.ticketTypes model


returnToHomepageButton : Ui.Element msg
returnToHomepageButton =
    Ui.el
        [ Ui.background (Ui.rgb 255 255 255)
        , Ui.padding 16
        , Ui.rounded 8
        , Ui.alignBottom
        , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 2, color = Ui.rgba 0 0 0 0.1 } ]
        , Ui.Font.weight 600
        , Ui.width Ui.shrink
        , Ui.link (Route.encode Nothing HomepageRoute)
        , Ui.contentCenterX
        , Ui.centerX
        ]
        (Ui.text "Return to homepage")


downloadTicketSalesReminder : Command FrontendOnly toMsg msg
downloadTicketSalesReminder =
    ICalendar.download
        { name = "elm-camp-ticket-sale-starts"
        , prodid = { company = "elm-camp", product = "website" }
        , events =
            [ { uid = "elm-camp-26-ticket-sale-starts"
              , start = Camp26Czech.ticketSalesOpenAt
              , summary = "Elm Camp Ticket Sale Starts"
              , description = "Can't wait to see you there!"
              }
            ]
        }


jumpToId : HtmlId -> Float -> Command FrontendOnly toMsg FrontendMsg
jumpToId id offset =
    Dom.getElement id
        |> Task.andThen (\el -> Dom.setViewport 0 (el.element.y - offset))
        |> Task.attempt
            (\_ -> Noop)


codeOfConductContent : List RichText
codeOfConductContent =
    [ Section "Code of Conduct"
        [ Paragraph [ Text "Elm Camp welcomes people with a wide range of backgrounds, experiences and knowledge. We can learn a lot from each other. It's important for us to make sure the environment where these discussions happen is inclusive and supportive. Everyone should feel comfortable to participate! The following guidelines are meant to codify these intentions." ]
        , Section "Help everyone feel welcome at Elm Camp"
            [ Paragraph [ Text "Everyone at Elm Camp is part of Elm Camp. There are a few staff on call and caterers preparing food, but there are no other guests on the grounds." ]
            , Paragraph [ Text "We expect everyone here to ensure that our community is harrassment-free for everyone." ]
            , BulletList
                [ Bold "Examples of behaviours that help us to provide an an open, welcoming, diverse, inclusive, and healthy community:" ]
                [ Paragraph [ Text "Demonstrating empathy and kindness toward other people" ]
                , Paragraph [ Text "Being respectful of differing opinions, viewpoints, and experiences" ]
                , Paragraph [ Text "Giving and gracefully accepting constructive feedback" ]
                , Paragraph [ Text "Accepting responsibility and apologising to those affected by our mistakes" ]
                , Paragraph [ Text "Learning from our and others' mistakes and not repeating negative behaviour" ]
                , Paragraph [ Text "Focusing on what is best for the overall community, not just ourselves as individuals" ]
                , Paragraph [ Text "Consider sharing your pronouns when introducing yourself, even if you think they are obvious" ]
                , Paragraph [ Text "Respect the name and pronouns others introduce themselves with" ]
                , Paragraph [ Text "When discussing code, avoid criticising the person who wrote the code or referring to the quality of the code in a negative way" ]
                , Paragraph [ Text "Leave silences to allow everyone a chance to speak" ]
                , Paragraph [ Text "When standing around talking, leave space for new people to join your converation (sometimes referred to pacman shape)" ]
                , Paragraph [ Text "If you think something you are about to say might be offensive, consider not saying it. If you need to say it, please warn people beforehand." ]
                ]
            , BulletList
                [ Bold "Examples of unacceptable behavior include:" ]
                [ Paragraph [ Text "Public or private harassment of any kind including offensive comments related to gender, sexual orientation, disability, physical appearance, body size, race, politics, or religion" ]
                , Paragraph [ Text "The use of sexualised language or imagery, and sexual attention or advances of any kind" ]
                , Paragraph [ Text "Interrupting people when they are speaking" ]
                , Paragraph [ Text "Sharing others' private information, such as a physical or email address, without their explicit permission" ]
                , Paragraph [ Text "Other conduct which could reasonably be considered inappropriate in a professional setting" ]
                ]
            ]
        , Section "Guidelines for running a camp session"
            [ Paragraph [ Text "As a facilitator it's important that you not only follow our code of conduct, but also help to enforce it." ]
            , Paragraph [ Text "If you have any concerns when planning, during or after your session, please get in touch with one of the organisers so we can help you." ]
            ]
        , Section "Talk to us"
            [ BulletList
                [ Text "If you experience any behaviours or atmosphere at Elm Camp that feels contrary to these values, please let us know. We want everyone to feel safe, equal and welcome." ]
                [ Paragraph [ Text "Email the organiser team: ", ExternalLink "team@elm.camp" "mailto:team@elm.camp" ]
                , Paragraph
                    [ Text "Contact Katja on "
                    , ExternalLink "Elm Slack" "https://elm-lang.org/community/slack"
                    , Text ": @katjam or "
                    , ExternalLink "Elmcraft Discord" Helpers.discordInviteLink
                    , Text ": katjam_"
                    ]
                ]
            ]
        , Section "How we handle Code of Conduct issues"
            [ Paragraph [ Text "If someone makes you or anyone else feel unsafe or unwelcome, please report it as soon as possible. You can make a report personally, anonymously or ask someone to do it on your behalf." ]
            , Paragraph [ Text "The Code of Conduct is in place to protect everyone at Elm Camp. If any participant violates these rules the organisers will take action." ]
            , Paragraph [ Text "We prefer to resolve things collaboratively and listening to everyone involved. We can all learn things from each other if we discuss issues openly." ]
            , Paragraph [ Text "However, if you feel you want help resolving something more privately, please ask an organiser. We are here to support you. The organisers will never disclose who brought the matter to our attention, in the case that they prefer to remain anonymous." ]
            , Paragraph [ Text "Where appropriate, we aim to be forgiving: if it seems like someone has made a good-natured mistake, we want to give space to grow and learn and a chance to apologise." ]
            , Paragraph [ Text "Where deemed necessary, the organisers will ask participants who harm the Elm Camp community to leave. This Code of Conduct is a guide, and since we can't possibly write down all the ways you can hurt people, we may ask participants to leave for reasons that we didn't write down explicitly here." ]
            , Paragraph [ Text "If you have any questions, concerns or suggestions regarding this policy, please get in touch." ]
            , Paragraph
                [ Text "This code of conduct was inspired by the "
                , ExternalLink "!!Con code of conduct" "https://bangbangcon.com/conduct.html"
                , Text " and drafted with the guidance of the "
                , ExternalLink "Geek Feminism Wiki" "https://geekfeminism.fandom.com/wiki/Conference_anti-harassment/Policy_resources"
                ]
            ]
        ]
    ]



--    Ui.column [ Ui.width Ui.shrink ]
--        [ """
--# What happened at Elm Camp 2023
--
--Last year we ran a 3-day event in Odense, Denmark. Here are some of the memories folks have shared:
--
--"""
--            ++ Camp23Denmark.Artifacts.posts
--            ++ Camp23Denmark.Artifacts.media
--            ++ """
--Did you attend Elm Camp 2023? We're [open to contributions on Github](https://github.com/elm-camp/website/edit/main/src/Camp23Denmark/Artifacts.elm)!
--
--[Archive: Elm Camp 2023 - Denmark website](/23-denmark)
--
--[Archive: Elm Camp 2024 - UK website](/24-uk)
--
--[Archive: Elm Camp 2025 - US website](/25-us)
--        """
--            |> MarkdownThemed.renderFull
--        ]
