module MyTests exposing (main, setup, tests)

import Backend
import Bytes exposing (Bytes)
import Dict exposing (Dict)
import Effect.Browser.Dom as Dom
import Effect.Lamdera
import Effect.Test as T exposing (FileUpload(..), HttpRequest, HttpResponse(..), MultipleFilesUpload(..), PointerOptions(..))
import Frontend
import Json.Decode
import Json.Encode
import Time
import Types exposing (BackendModel, BackendMsg, FrontendModel, FrontendMsg, ToBackend, ToFrontend)
import Unsafe
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
    []
        |> Dict.fromList


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
                BadUrlResponse ""

            else
                UnhandledHttpRequest


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
        "new test"
        (Time.millisToPosix 1757440953858)
        config
        [ T.connectFrontend
            0
            (Effect.Lamdera.sessionIdFromString "113298c04b8f7b594cdeedebc2a8029b82943b0a")
            "https://abc.com/"
            { width = 881, height = 1312 }
            (\tab1 ->
                [ tab1.clickLink 100 "/code-of-conduct"
                , tab1.clickLink 100 "/unconference-format"
                , tab1.clickLink 100 "/venue-and-access"
                , tab1.clickLink 100 "/organisers"
                , tab1.clickLink 100 "/elm-camp-archive"
                , tab1.clickLink 100 "/24-uk"
                ]
            )
        ]
    ]
