module RecordedTests exposing (main, setup, stripePurchaseWebhookResponse, tests)

import Backend
import Bytes exposing (Bytes)
import Camp26Czech
import Dict exposing (Dict)
import Duration
import Effect.Browser.Dom as Dom
import Effect.Lamdera as Lamdera
import Effect.Test as T exposing (FileUpload(..), HttpRequest, HttpResponse(..), MultipleFilesUpload(..), PointerOptions(..))
import EmailAddress exposing (EmailAddress)
import Expect
import Frontend
import Json.Decode as D
import List.Extra
import Name exposing (Name)
import NonNegative
import Quantity
import Route
import Sales
import SeqDict
import String.Nonempty exposing (NonemptyString(..))
import Test.Html.Query
import Test.Html.Selector
import Theme exposing (Size)
import Time
import Types exposing (BackendModel, BackendMsg(..), EmailResult(..), FrontendModel, FrontendMsg, ToBackend(..), ToFrontend)
import Unsafe
import Untrusted
import Url exposing (Url)


setup : T.ViewerWith (List (T.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel))
setup =
    T.viewerWith tests
        |> T.addBytesFiles (Dict.values fileRequests)


main : Program () (T.Model ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel) (T.Msg ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel)
main =
    T.startViewer setup


domain : Url
domain =
    Unsafe.url "http://localhost:8000"


{-| Please don't modify or rename this function
-}
fileRequests : Dict String String
fileRequests =
    Dict.empty


isPurchaseConfirmationEmail : EmailAddress -> HttpRequest -> Bool
isPurchaseConfirmationEmail emailAddress httpRequest =
    if httpRequest.url == "https://api.postmarkapp.com/email" then
        case httpRequest.body of
            T.JsonBody value ->
                case D.decodeValue decodePostmark value |> Debug.log "httpRequests" of
                    Ok ( subject, to, _ ) ->
                        (emailAddress == to)
                            && (subject == String.Nonempty.toString Backend.confirmationEmailSubject)

                    Err _ ->
                        False

            _ ->
                False

    else
        False


decodePostmark : D.Decoder ( String, EmailAddress, String )
decodePostmark =
    D.map3 (\subject to body -> ( subject, to, body ))
        (D.field "Subject" D.string)
        (D.field "To" D.string
            |> D.andThen
                (\to ->
                    case String.split "<" to of
                        [ _, email ] ->
                            case EmailAddress.fromString (String.dropRight 1 email) of
                                Just emailAddress ->
                                    D.succeed emailAddress

                                Nothing ->
                                    D.fail "Invalid email address"

                        [ email ] ->
                            case EmailAddress.fromString email of
                                Just emailAddress ->
                                    D.succeed emailAddress

                                Nothing ->
                                    D.fail "Invalid email address"

                        _ ->
                            D.fail "Invalid email address"
                )
        )
        (D.field "TextBody" D.string)


handleHttpRequests : Dict String String -> Dict String Bytes -> { currentRequest : HttpRequest, data : T.Data FrontendModel BackendModel } -> HttpResponse
handleHttpRequests overrides fileData { currentRequest } =
    let
        key : String
        key =
            currentRequest.method ++ "_" ++ currentRequest.url

        getData : String -> HttpResponse
        getData path =
            case Dict.get path fileData of
                Just data ->
                    BytesHttpResponse { url = currentRequest.url, statusCode = 200, statusText = "OK", headers = Dict.empty } data

                Nothing ->
                    UnhandledHttpRequest
    in
    case ( Dict.get key overrides, Dict.get key fileRequests ) of
        ( Just path, _ ) ->
            getData path

        ( Nothing, Just path ) ->
            getData path

        _ ->
            if currentRequest.url == "https://api.stripe.com/v1/prices" then
                StringHttpResponse
                    { url = currentRequest.url, statusCode = 200, statusText = "OK", headers = Dict.empty }
                    stripePricesResponse

            else if currentRequest.url == "https://api.stripe.com/v1/checkout/sessions" then
                StringHttpResponse
                    { url = currentRequest.url, statusCode = 200, statusText = "OK", headers = Dict.empty }
                    ("""{"id":\"""" ++ stripeSessionId ++ "\"}")

            else if currentRequest.url == "https://open.er-api.com/v6/latest/CZK" then
                StringHttpResponse
                    { url = currentRequest.url, statusCode = 200, statusText = "OK", headers = Dict.empty }
                    exchangeRateResponse

            else if currentRequest.url == "https://api.postmarkapp.com/email" then
                StringHttpResponse
                    { url = currentRequest.url, statusCode = 200, statusText = "OK", headers = Dict.empty }
                    """{"ErrorCode":0,"Message":""}"""

            else
                UnhandledHttpRequest


stripeSessionId : String
stripeSessionId =
    "cs_live_b11eNtNWg68DgbLFAUbiuhiUxjDXJqqOxXhFTqG0iaimcgQjayLSRJlK4Z"


svenMail : EmailAddress
svenMail =
    Unsafe.emailAddress "sven@svenmail.se"


sven : Name
sven =
    Unsafe.name "Sven"


aliceMail : EmailAddress
aliceMail =
    Unsafe.emailAddress "alice@alicemail.com"


sessionId0 : Lamdera.SessionId
sessionId0 =
    Lamdera.sessionIdFromString "sessionId0"


windowSize : Size
windowSize =
    { width = 800, height = 1200 }


{-| You can change parts of this function represented with `...`.
The rest needs to remain unchanged in order for the test generator to be able to add new tests.

    tests : ... -> List (T.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel)
    tests ... =
        let
            config = ...

            ...
        in
        [ ...
        ]

-}
tests : Dict String Bytes -> List (T.EndToEndTest ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel)
tests fileData =
    let
        config =
            T.Config
                Frontend.app_
                Backend.app_
                (handleHttpRequests Dict.empty fileData)
                (\_ -> Nothing)
                (\_ -> UnhandledFileUpload)
                (\_ -> UnhandledMultiFileUpload)
                domain
    in
    [ T.start
        "Links are reachable"
        (Time.millisToPosix 1757440953858)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ tab1.clickLink 100 "/code-of-conduct"
                , tab1.checkView 100
                    (Test.Html.Query.has [ Test.Html.Selector.exactText "Code of Conduct" ])
                , tab1.clickLink 100 "/unconference-format"
                , tab1.checkView 100
                    (Test.Html.Query.has [ Test.Html.Selector.exactText "Unconference Format" ])
                , tab1.clickLink 100 "/elm-camp-archive"
                , tab1.checkView 100
                    (Test.Html.Query.has [ Test.Html.Selector.text "Here we keep track of what has come out of past Elm Camp events." ])
                , tab1.clickLink 100 "/24-uk"
                , tab1.navigateBack 100
                , tab1.clickLink 100 "/23-denmark"
                , tab1.checkView 100
                    (Test.Html.Query.has [ Test.Html.Selector.exactText "Dallund Castle, Denmark" ])
                ]
            )
        ]
    , T.start
        "Show countdown"
        (Duration.subtractFrom Camp26Czech.ticketSalesOpenAt (Duration.hours 25))
        config
        [ T.connectFrontend
            0
            sessionId0
            "/"
            windowSize
            (\_ -> [])
        , T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ tab1.checkView 100 (Test.Html.Query.has [ Test.Html.Selector.text "1 day 59m" ])
                , tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                , tab1.checkView 100 (Test.Html.Query.has [ Test.Html.Selector.text "1 day 59m" ])
                ]
            )
        ]
    , T.start
        "Cant buy tickets before countdown is finished"
        (Duration.subtractFrom Camp26Czech.ticketSalesOpenAt (Duration.hours 25))
        config
        [ T.connectFrontend 0 sessionId0 "/" windowSize (\_ -> [])
        , T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ tab1.sendToBackend
                    100
                    ({ attendees =
                        [ { name = sven
                          , country = NonemptyString 'S' "weden"
                          , originCity = NonemptyString 'S' "tockholm"
                          }
                        , { name = sven
                          , country = NonemptyString 'S' "weden"
                          , originCity = NonemptyString 'S' "tockholm"
                          }
                        ]
                     , count =
                        { campfireTicket = NonNegative.zero
                        , singleRoomTicket = NonNegative.increment NonNegative.one
                        , sharedRoomTicket = NonNegative.zero
                        }
                     , billingEmail = aliceMail
                     , grantContribution = Quantity.zero
                     }
                        |> Untrusted.untrust
                        |> SubmitFormRequest
                    )
                , T.checkBackend
                    100
                    (\backend ->
                        if SeqDict.isEmpty backend.pendingOrders && SeqDict.isEmpty backend.orders then
                            Ok ()

                        else
                            Err "User was allowed to buy a ticket too early"
                    )
                ]
            )
        ]
    , T.start
        "Purchase ticket"
        (Duration.addTo Camp26Czech.ticketSalesOpenAt Duration.minute)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\_ -> [])
        , T.connectFrontend
            100
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                , tab1.click 100 (Sales.selectTicketId Camp26Czech.singleRoomTicket)
                , tab1.input 100 (Dom.id "attendeeName_0") "Sven"
                , tab1.input 100 (Dom.id "attendeeCountry_0") "Sweden"
                , tab1.input 100 (Dom.id "attendeeCity_0") "Malmö"
                , tab1.input 100 (Dom.id "billingEmail") (EmailAddress.toString svenMail)
                , tab1.click 100 (Dom.id "submitForm")
                , T.checkState 100
                    (\data ->
                        case data.portRequests of
                            head :: _ ->
                                if head.portName == "stripe_to_js" && head.clientId == tab1.clientId then
                                    Ok ()

                                else
                                    Err "Frontend doesn't trigger Stripe checkout"

                            [] ->
                                Err "Frontend doesn't trigger Stripe checkout"
                    )
                , T.checkState
                    100
                    (\data ->
                        let
                            purchaseConfirmations : Int
                            purchaseConfirmations =
                                List.Extra.count (isPurchaseConfirmationEmail svenMail) data.httpRequests
                        in
                        if purchaseConfirmations == 0 then
                            Ok ()

                        else
                            Err ("Expected 0 purchase confirmation but got " ++ String.fromInt purchaseConfirmations)
                    )
                , T.backendUpdate 100 (StripeWebhookResponse stripePurchaseWebhookResponse)
                , T.checkState
                    100
                    (\data ->
                        let
                            purchaseConfirmations : Int
                            purchaseConfirmations =
                                List.Extra.count (isPurchaseConfirmationEmail svenMail) data.httpRequests
                        in
                        if purchaseConfirmations == 1 then
                            if SeqDict.size data.backend.orders == 1 then
                                Ok ()

                            else
                                Err ("Expected 1 order on the backend but found " ++ String.fromInt (SeqDict.size data.backend.orders))

                        else
                            Err ("Expected 1 purchase confirmation but got " ++ String.fromInt purchaseConfirmations)
                    )
                ]
            )
        ]
    , T.start
        "All rooms sold out"
        (Duration.addTo Camp26Czech.ticketSalesOpenAt Duration.minute)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\_ -> [])
        , T.connectFrontend
            100
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                , purchaseSingleRoomTickets Camp26Czech.maxRooms tab1
                , tab1.input 100 (Dom.id "billingEmail") "sven@svenmail.se"
                , tab1.click 100 (Dom.id "submitForm")
                , T.connectFrontend
                    100
                    (Lamdera.sessionIdFromString "session ID 2")
                    (Route.encode Nothing Route.TicketPurchaseRoute)
                    windowSize
                    (\tab2 ->
                        [ tab2.checkView
                            100
                            (\html ->
                                Test.Html.Query.count
                                    (Expect.equal 2)
                                    (Test.Html.Query.findAll [ Test.Html.Selector.exactText "Sold out!" ] html)
                            )
                        ]
                    )
                ]
            )
        ]
    , T.start
        "All but one room sold out"
        (Duration.addTo Camp26Czech.ticketSalesOpenAt Duration.minute)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\_ -> [])
        , T.connectFrontend
            100
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                , purchaseSingleRoomTickets (Camp26Czech.maxRooms - 1) tab1
                , tab1.input 100 (Dom.id "billingEmail") "sven@svenmail.se"
                , tab1.click 100 (Dom.id "submitForm")
                , T.connectFrontend
                    100
                    (Lamdera.sessionIdFromString "session ID 2")
                    (Route.encode Nothing Route.TicketPurchaseRoute)
                    windowSize
                    (\tab2 ->
                        [ tab2.checkView 100 (Test.Html.Query.hasNot [ Test.Html.Selector.exactText "Sold out!" ])
                        , purchaseSingleRoomTickets 1 tab2
                        , tab2.checkView 100 (Test.Html.Query.has [ Test.Html.Selector.exactText "Sold out!" ])
                        ]
                    )
                ]
            )
        ]
    , T.start
        "Sold out in the middle of a session"
        (Duration.addTo Camp26Czech.ticketSalesOpenAt Duration.minute)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\_ -> [])
        , T.connectFrontend
            100
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ T.connectFrontend
                    100
                    (Lamdera.sessionIdFromString "session ID 2")
                    (Route.encode Nothing Route.TicketPurchaseRoute)
                    windowSize
                    (\tab2 ->
                        [ tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                        , purchaseSingleRoomTickets (Camp26Czech.maxRooms - 1) tab1
                        , tab1.input 100 (Dom.id "billingEmail") "sven@svenmail.se"
                        , tab1.click 100 (Dom.id "submitForm")
                        , tab2.checkView 100 (Test.Html.Query.hasNot [ Test.Html.Selector.exactText "Sold out!" ])
                        , purchaseSingleRoomTickets 1 tab2
                        , tab2.checkView 100 (Test.Html.Query.has [ Test.Html.Selector.exactText "Sold out!" ])
                        ]
                    )
                ]
            )
        ]
    , T.start
        "Backend verifies if tickets are available"
        (Duration.addTo Camp26Czech.ticketSalesOpenAt Duration.minute)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\_ -> [])
        , T.connectFrontend
            100
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ T.connectFrontend
                    100
                    (Lamdera.sessionIdFromString "session ID 2")
                    (Route.encode Nothing Route.TicketPurchaseRoute)
                    windowSize
                    (\tab2 ->
                        [ tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                        , purchaseSingleRoomTickets (Camp26Czech.maxRooms - 1) tab1
                        , tab1.input 100 (Dom.id "billingEmail") (EmailAddress.toString svenMail)
                        , tab1.click 100 (Dom.id "submitForm")
                        , tab2.sendToBackend
                            100
                            ({ attendees =
                                [ { name = sven
                                  , country = NonemptyString 'S' "weden"
                                  , originCity = NonemptyString 'S' "tockholm"
                                  }
                                , { name = sven
                                  , country = NonemptyString 'S' "weden"
                                  , originCity = NonemptyString 'S' "tockholm"
                                  }
                                ]
                             , count =
                                { campfireTicket = NonNegative.zero
                                , singleRoomTicket = NonNegative.increment NonNegative.one
                                , sharedRoomTicket = NonNegative.zero
                                }
                             , billingEmail = aliceMail
                             , grantContribution = Quantity.zero
                             }
                                |> Untrusted.untrust
                                |> SubmitFormRequest
                            )
                        , tab2.checkView
                            100
                            (Test.Html.Query.has [ Test.Html.Selector.exactText "Sorry, tickets are sold out." ])
                        ]
                    )
                ]
            )
        ]
    , T.start
        "All tickets sold out"
        (Duration.addTo Camp26Czech.ticketSalesOpenAt Duration.minute)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\_ -> [])
        , T.connectFrontend
            100
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                , purchasecampfireTickets 0 Camp26Czech.maxAttendees tab1
                , tab1.input 100 (Dom.id "billingEmail") "sven@svenmail.se"
                , tab1.click 100 (Dom.id "submitForm")
                , T.connectFrontend
                    100
                    (Lamdera.sessionIdFromString "session ID 2")
                    (Route.encode Nothing Route.TicketPurchaseRoute)
                    windowSize
                    (\tab2 ->
                        [ tab2.checkView
                            100
                            (\html ->
                                Test.Html.Query.count
                                    (Expect.equal 3)
                                    (Test.Html.Query.findAll [ Test.Html.Selector.exactText "Sold out!" ] html)
                            )
                        ]
                    )
                ]
            )
        ]
    , T.start
        "All tickets and rooms sold out"
        (Duration.addTo Camp26Czech.ticketSalesOpenAt Duration.minute)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\_ -> [])
        , T.connectFrontend
            100
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                , purchaseSingleRoomTickets Camp26Czech.maxRooms tab1
                , purchasecampfireTickets Camp26Czech.maxRooms (Camp26Czech.maxAttendees - Camp26Czech.maxRooms) tab1
                , tab1.input 100 (Dom.id "billingEmail") "sven@svenmail.se"
                , tab1.click 100 (Dom.id "submitForm")
                , T.connectFrontend
                    100
                    (Lamdera.sessionIdFromString "session ID 2")
                    (Route.encode Nothing Route.TicketPurchaseRoute)
                    windowSize
                    (\tab2 ->
                        [ tab2.checkView
                            100
                            (\html ->
                                Test.Html.Query.count
                                    (Expect.equal 3)
                                    (Test.Html.Query.findAll [ Test.Html.Selector.exactText "Sold out!" ] html)
                            )
                        ]
                    )
                ]
            )
        ]
    , T.start
        "All but one room sold out (which is then sold out via shared room tickets)"
        (Duration.addTo Camp26Czech.ticketSalesOpenAt Duration.minute)
        config
        [ T.connectFrontend
            0
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\_ -> [])
        , T.connectFrontend
            100
            (Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "/"
            windowSize
            (\tab1 ->
                [ tab1.clickLink 100 (Route.encode Nothing Route.TicketPurchaseRoute)
                , purchaseSingleRoomTickets (Camp26Czech.maxRooms - 1) tab1
                , purchaseSharedRoomTickets (Camp26Czech.maxRooms - 1) 2 tab1
                , tab1.input 100 (Dom.id "billingEmail") "sven@svenmail.se"
                , tab1.click 100 (Dom.id "submitForm")
                , T.connectFrontend
                    100
                    (Lamdera.sessionIdFromString "session ID 2")
                    (Route.encode Nothing Route.TicketPurchaseRoute)
                    windowSize
                    (\tab2 ->
                        [ tab2.checkView
                            100
                            (\html ->
                                Test.Html.Query.count
                                    (Expect.equal 2)
                                    (Test.Html.Query.findAll [ Test.Html.Selector.exactText "Sold out!" ] html)
                            )
                        ]
                    )
                ]
            )
        ]
    ]


purchaseSingleRoomTickets :
    Int
    -> T.FrontendActions toBackend frontendMsg frontendModel toFrontend backendMsg backendModel
    -> T.Action toBackend frontendMsg frontendModel toFrontend backendMsg backendModel
purchaseSingleRoomTickets count tab1 =
    List.concatMap
        (\index ->
            [ if index == 0 then
                tab1.click 100 (Sales.selectTicketId Camp26Czech.singleRoomTicket)

              else
                tab1.click 100 (Sales.numericFieldPlusId (Sales.selectTicketId Camp26Czech.singleRoomTicket))
            , tab1.input 100 (Dom.id ("attendeeName_" ++ String.fromInt index)) "Sven"
            , tab1.input 100 (Dom.id ("attendeeCountry_" ++ String.fromInt index)) "Sweden"
            , tab1.input 100 (Dom.id ("attendeeCity_" ++ String.fromInt index)) "Malmö"
            ]
        )
        (List.range 0 (count - 1))
        |> T.collapsableGroup ("Purchase " ++ String.fromInt count ++ " single room tickets")


purchaseSharedRoomTickets :
    Int
    -> Int
    -> T.FrontendActions toBackend frontendMsg frontendModel toFrontend backendMsg backendModel
    -> T.Action toBackend frontendMsg frontendModel toFrontend backendMsg backendModel
purchaseSharedRoomTickets offset count tab1 =
    List.concatMap
        (\index ->
            let
                attendanceIndex : Int
                attendanceIndex =
                    offset + index
            in
            [ if index == 0 then
                tab1.click 100 (Sales.selectTicketId Camp26Czech.sharedRoomTicket)

              else
                tab1.click 100 (Sales.numericFieldPlusId (Sales.selectTicketId Camp26Czech.sharedRoomTicket))
            , tab1.input 100 (Dom.id ("attendeeName_" ++ String.fromInt attendanceIndex)) "Sven"
            , tab1.input 100 (Dom.id ("attendeeCountry_" ++ String.fromInt attendanceIndex)) "Sweden"
            , tab1.input 100 (Dom.id ("attendeeCity_" ++ String.fromInt attendanceIndex)) "Malmö"
            ]
        )
        (List.range 0 (count - 1))
        |> T.collapsableGroup ("Purchase " ++ String.fromInt count ++ " shared room tickets")


purchasecampfireTickets :
    Int
    -> Int
    -> T.FrontendActions toBackend frontendMsg frontendModel toFrontend backendMsg backendModel
    -> T.Action toBackend frontendMsg frontendModel toFrontend backendMsg backendModel
purchasecampfireTickets offset count tab1 =
    List.concatMap
        (\index ->
            let
                attendanceIndex : Int
                attendanceIndex =
                    offset + index
            in
            [ if index == 0 then
                tab1.click 100 (Sales.selectTicketId Camp26Czech.campfireTicket)

              else
                tab1.click 100 (Sales.numericFieldPlusId (Sales.selectTicketId Camp26Czech.campfireTicket))
            , tab1.input 100 (Dom.id ("attendeeName_" ++ String.fromInt attendanceIndex)) "Sven"
            , tab1.input 100 (Dom.id ("attendeeCountry_" ++ String.fromInt attendanceIndex)) "Sweden"
            , tab1.input 100 (Dom.id ("attendeeCity_" ++ String.fromInt attendanceIndex)) "Malmö"
            ]
        )
        (List.range 0 (count - 1))
        |> T.collapsableGroup ("Purchase " ++ String.fromInt count ++ " campfire tickets")


stripePurchaseWebhookResponse : { json : String, endpoint : String }
stripePurchaseWebhookResponse =
    { json =
        """{
  "id": "evt_1T28zeHHD80VvsjK4Juvu6pm",
  "object": "event",
  "api_version": "2020-03-02",
  "created": 1771414354,
  "data": {
    "object": {
      "id": \""""
            ++ stripeSessionId
            ++ """",
      "object": "checkout.session",
      "adaptive_pricing": {
        "enabled": true
      },
      "after_expiration": null,
      "allow_promotion_codes": true,
      "amount_subtotal": 2427,
      "amount_total": 2427,
      "automatic_tax": {
        "enabled": false,
        "liability": null,
        "provider": null,
        "status": null
      },
      "billing_address_collection": null,
      "branding_settings": {
        "background_color": "#ffffff",
        "border_style": "rounded",
        "button_color": "#62b6ce",
        "display_name": "Cofoundry Ltd",
        "font_family": "default",
        "icon": {
          "file": "file_1MjQFxHHD80VvsjK6qqVMCl0",
          "type": "file"
        },
        "logo": {
          "file": "file_1MjQFkHHD80VvsjKFF7tUO9t",
          "type": "file"
        }
      },
      "cancel_url": "http://localhost:8000/stripeCancel",
      "client_reference_id": null,
      "client_secret": null,
      "collected_information": {
        "business_name": null,
        "individual_name": null,
        "shipping_details": null
      },
      "consent": null,
      "consent_collection": null,
      "created": 1771414277,
      "currency": "czk",
      "currency_conversion": null,
      "custom_fields": [],
      "custom_text": {
        "after_submit": null,
        "shipping_address": null,
        "submit": null,
        "terms_of_service_acceptance": null
      },
      "customer": "cus_U09IBJBVAmennB",
      "customer_account": null,
      "customer_creation": "always",
      "customer_details": {
        "address": {
          "city": null,
          "country": "SE",
          "line1": null,
          "line2": null,
          "postal_code": null,
          "state": null
        },
        "business_name": null,
        "email": "martinsstewart@gmail.com",
        "individual_name": null,
        "name": "Martin Stewart",
        "phone": null,
        "tax_exempt": "none",
        "tax_ids": []
      },
      "customer_email": "martinsstewart@gmail.com",
      "discounts": [],
      "expires_at": 1771416076,
      "invoice": null,
      "invoice_creation": {
        "enabled": false,
        "invoice_data": {
          "account_tax_ids": null,
          "custom_fields": null,
          "description": null,
          "footer": null,
          "issuer": null,
          "metadata": {},
          "rendering_options": null
        }
      },
      "livemode": true,
      "locale": null,
      "metadata": {},
      "mode": "payment",
      "origin_context": null,
      "payment_intent": "pi_3T28yPHHD80VvsjK12neihui",
      "payment_link": null,
      "payment_method_collection": "always",
      "payment_method_configuration_details": {
        "id": "pmc_1MjOXdHHD80VvsjKu0s7ebsQ",
        "parent": null
      },
      "payment_method_options": {
        "card": {
          "request_three_d_secure": "automatic"
        }
      },
      "payment_method_types": [
        "card",
        "link"
      ],
      "payment_status": "paid",
      "permissions": null,
      "phone_number_collection": {
        "enabled": false
      },
      "recovered_from": null,
      "saved_payment_method_options": {
        "allow_redisplay_filters": [
          "always"
        ],
        "payment_method_remove": "disabled",
        "payment_method_save": null
      },
      "setup_intent": null,
      "shipping": null,
      "shipping_address_collection": null,
      "shipping_options": [],
      "shipping_rate": null,
      "status": "complete",
      "submit_type": null,
      "subscription": null,
      "success_url": "http://localhost:8000/stripeSuccess?email-address=martinsstewart%40gmail.com",
      "total_details": {
        "amount_discount": 0,
        "amount_shipping": 0,
        "amount_tax": 0
      },
      "ui_mode": "hosted",
      "url": null,
      "wallet_options": null
    }
  },
  "livemode": true,
  "pending_webhooks": 1,
  "request": {
    "id": null,
    "idempotency_key": null
  },
  "type": "checkout.session.completed"
}"""
    , endpoint = "stripe"
    }


stripePricesResponse : String
stripePricesResponse =
    """{
  "object": "list",
  "data": [
    {
      "id": "price_1SokONHHD80VvsjKI7Fcrgpv",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1768221523,
      "currency": "czk",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_TmJ0n8liux9A3d",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 1500000,
      "unit_amount_decimal": "1500000"
    },
    {
      "id": "price_1SokNtHHD80VvsjKBvsbpibp",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1768221493,
      "currency": "czk",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_TmIzrbSouU0bYE",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 1000000,
      "unit_amount_decimal": "1000000"
    },
    {
      "id": "price_1SokMMHHD80VvsjKBDguCA1L",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1768221398,
      "currency": "czk",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_TmIy0Mltqmgzg5",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 500000,
      "unit_amount_decimal": "500000"
    },
    {
      "id": "price_1RAxDAHHD80VvsjKwpYM6dm9",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1743961344,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_S57SF0eTq5vOvx",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 0,
      "unit_amount_decimal": "0"
    },
    {
      "id": "price_1R5XTOHHD80VvsjKhUJRznqW",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742670766,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWWOS4E6aID6y",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 500000,
      "unit_amount_decimal": "500000"
    },
    {
      "id": "price_1R5XSrHHD80VvsjKzqKGqCKV",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742670733,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWVRbQ0spItOf",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 250000,
      "unit_amount_decimal": "250000"
    },
    {
      "id": "price_1R5XR0HHD80VvsjKLs71zqeA",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742670618,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWTill7eglkFc",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 100000,
      "unit_amount_decimal": "100000"
    },
    {
      "id": "price_1R5XFkHHD80VvsjKj9YCTgLP",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742669920,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWIY7BfNEYSqF",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 50000,
      "unit_amount_decimal": "50000"
    },
    {
      "id": "price_1R5XE4HHD80VvsjKuFX5ZA2M",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742669816,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWGafvirlc2HL",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 75000,
      "unit_amount_decimal": "75000"
    },
    {
      "id": "price_1R5XAHHHD80VvsjK1TuNuqSL",
      "object": "price",
      "active": true,
      "billing_scheme": "per_unit",
      "created": 1742669581,
      "currency": "usd",
      "custom_unit_amount": null,
      "livemode": true,
      "lookup_key": null,
      "metadata": {},
      "nickname": null,
      "product": "prod_RzWC4KcrRdLzBH",
      "recurring": null,
      "tax_behavior": "unspecified",
      "tiers_mode": null,
      "transform_quantity": null,
      "type": "one_time",
      "unit_amount": 30000,
      "unit_amount_decimal": "30000"
    }
  ],
  "has_more": true,
  "url": "/v1/prices"
}"""


exchangeRateResponse : String
exchangeRateResponse =
    """{"result":"success","provider":"https://www.exchangerate-api.com","documentation":"https://www.exchangerate-api.com/docs/free","terms_of_use":"https://www.exchangerate-api.com/terms","time_last_update_unix":1771372952,"time_last_update_utc":"Wed, 18 Feb 2026 00:02:32 +0000","time_next_update_unix":1771461262,"time_next_update_utc":"Thu, 19 Feb 2026 00:34:22 +0000","time_eol_unix":0,"base_code":"CZK","rates":{"CZK":1,"AED":0.17914,"AFN":3.099372,"ALL":3.973075,"AMD":18.418392,"ANG":0.087314,"AOA":45.708659,"ARS":70.838759,"AUD":0.069102,"AWG":0.087314,"AZN":0.082964,"BAM":0.080573,"BBD":0.097557,"BDT":5.975498,"BGN":2.711751,"BHD":0.018341,"BIF":144.61165,"BMD":0.048779,"BND":0.061624,"BOB":0.338482,"BRL":0.254623,"BSD":0.048779,"BTN":4.420903,"BWP":0.657228,"BYN":0.138802,"BZD":0.097557,"CAD":0.066567,"CDF":111.992481,"CHF":0.037579,"CLF":0.001066,"CLP":42.115397,"CNH":0.336572,"CNY":0.3408,"COP":179.002488,"CRC":23.512248,"CUP":1.170687,"CVE":4.542538,"DJF":8.668986,"DKK":0.307342,"DOP":3.03193,"DZD":6.332679,"EGP":2.292068,"ERN":0.731679,"ETB":7.591743,"EUR":0.041197,"FJD":0.106122,"FKP":0.035962,"FOK":0.307342,"GBP":0.035991,"GEL":0.130731,"GGP":0.035962,"GHS":0.537601,"GIP":0.035962,"GMD":3.614406,"GNF":426.774642,"GTQ":0.374398,"GYD":10.216049,"HKD":0.381113,"HNL":1.291611,"HRK":0.310395,"HTG":6.389961,"HUF":15.580769,"IDR":821.875524,"ILS":0.15115,"IMP":0.035962,"INR":4.42477,"IQD":63.927039,"IRR":62555.023923,"ISK":5.973146,"JEP":0.035962,"JMD":7.633807,"JOD":0.034584,"JPY":7.475499,"KES":6.292519,"KGS":4.268347,"KHR":195.986842,"KID":0.069102,"KMF":20.267376,"KRW":70.402584,"KWD":0.014932,"KYD":0.040649,"KZT":23.929516,"LAK":1054.070902,"LBP":4365.686985,"LKR":14.960643,"LRD":9.082726,"LSL":0.782336,"LYD":0.307697,"MAD":0.445302,"MDL":0.827836,"MGA":212.785714,"MKD":2.538274,"MMK":102.540461,"MNT":172.799837,"MOP":0.392546,"MRU":1.944771,"MUR":2.241378,"MVR":0.754392,"MWK":85.013701,"MXN":0.837244,"MYR":0.190209,"MZN":3.110562,"NAD":0.782336,"NGN":66.035991,"NIO":1.796596,"NOK":0.465188,"NPR":7.073445,"NZD":0.080855,"OMR":0.018755,"PAB":0.048779,"PEN":0.163506,"PGK":0.209586,"PHP":2.821394,"PKR":13.678831,"PLN":0.173725,"PYG":318.255094,"QAR":0.177554,"RON":0.209975,"RSD":4.83123,"RUB":3.746487,"RWF":71.335275,"SAR":0.18292,"SBD":0.382822,"SCR":0.705823,"SDG":21.808199,"SEK":0.437933,"SGD":0.061624,"SHP":0.035962,"SLE":1.200888,"SLL":1200.894902,"SOS":27.841121,"SRD":1.840025,"SSP":223.672714,"STN":1.009316,"SYP":5.480602,"SZL":0.782336,"THB":1.524727,"TJS":0.45803,"TMT":0.170813,"TND":0.139306,"TOP":0.113761,"TRY":2.132472,"TTD":0.331135,"TVD":0.069102,"TWD":1.531448,"TZS":127.566021,"UAH":2.11254,"UGX":172.684781,"USD":0.048779,"UYU":1.894314,"UZS":593.855413,"VES":19.334279,"VND":1265.671705,"VUV":5.690396,"WST":0.129086,"XAF":27.023168,"XCD":0.131702,"XCG":0.087314,"XDR":0.03548,"XOF":27.023168,"XPF":4.916067,"YER":11.634724,"ZAR":0.782337,"ZMW":0.901461,"ZWG":1.248254,"ZWL":1.248246}}"""
