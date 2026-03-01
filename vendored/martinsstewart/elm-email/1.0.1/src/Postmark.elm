module Postmark exposing
    ( apiKey, ApiKey, sendEmail, sendEmails, sendEmailTask, sendEmailsTask, Email, EmailBody(..), MessageStream(..), PostmarkError_, SendEmailError(..), SendEmailsError(..)
    , Attachments, noAttachments, attachments
    , UnknownErrorData
    )

{-|


# Sending emails

@docs apiKey, ApiKey, sendEmail, sendEmails, sendEmailTask, sendEmailsTask, Email, EmailBody, MessageStream, PostmarkError_, SendEmailError, SendEmailsError


# Email attachments

@docs Attachments, noAttachments, attachments

-}

import Base64
import Bytes exposing (Bytes)
import Dict exposing (Dict)
import Effect.Command exposing (BackendOnly, Command)
import Effect.Http as Http
import Effect.Task as Task exposing (Task)
import Email.Html
import EmailAddress exposing (EmailAddress)
import Internal
import Json.Decode as D
import Json.Encode as E
import List.Nonempty exposing (Nonempty(..))
import String.Nonempty exposing (NonemptyString)


endpoint : String
endpoint =
    "https://api.postmarkapp.com"


{-| A SendGrid API key. In order to send an email you must have one of these (see the readme for how to get one).
-}
type ApiKey
    = ApiKey String


{-| Create an API key from a raw string (see the readme for how to get one).
-}
apiKey : String -> ApiKey
apiKey apiKey_ =
    ApiKey apiKey_


{-|

    What kind of email content are you sending? Just plain text (TextBody), HTML (HtmlBody), or both (HtmlAndTextBody).
    If you do send HTML, it's recommended to also send a plain text version for accessibility and it might reduce the odds of the email getting blocked by a spam filter.

    Note that email clients are quite limited in what html features are supported!
    To avoid accidentally using html that's unsupported by some email clients, the `Email.Html` and `Email.Html.Attributes` modules only define tags and attributes with universal support.
    You can still use `Email.Html.node` and `Email.Html.Attributes.attribute` if you want something that might not be universally supported though.

-}
type EmailBody
    = HtmlBody Email.Html.Html
    | TextBody String
    | HtmlAndTextBody Email.Html.Html String


{-| Configuration for the email(s) you want to send.

    { from = { name = "ascii-collab", email = asciiCollabEmail }
    , to = List.Nonempty.fromElement { name = "", email = recipient }
    , subject = NonemptyString 'H' "ello!"
    , body = Postmark.TextBody "Hello! Here's your login code 123123"
    , messageStream = Postmark.TransactionalEmail
    , attachments = Postmark.noAttachments
    }

-}
type alias Email =
    { from : { name : String, email : EmailAddress }
    , to : Nonempty { name : String, email : EmailAddress }
    , subject : NonemptyString
    , body : EmailBody
    , messageStream : MessageStream
    , attachments : Attachments
    }


{-| A group of email attachments.

Note that the contents of each attachment has to be base64 encoded. This can be slow for large attachments so reuse the same `Attachment` for multiple emails if possible.

-}
type Attachments
    = Attachments (Dict String { content : String, mimeType : String })


{-| Don't include any attachments in the email.
-}
noAttachments : Attachments
noAttachments =
    Attachments Dict.empty


{-| Create attachments to be shown at the bottom of an email. If you want to have inline image attachments, use `Email.Html.inlineGifImg`, `Email.Html.inlineJpgImg`, or `Email.Html.inlinePngImg`

Note that the contents of each attachment has to be base64 encoded. This can be slow for large attachments so you might want to reuse the same `Attachment` for multiple emails if possible.

-}
attachments : Dict String { content : Bytes, mimeType : String } -> Attachments
attachments dict =
    Dict.map
        (\_ a ->
            { content = Base64.fromBytes a.content |> Maybe.withDefault ""
            , mimeType = a.mimeType
            }
        )
        dict
        |> Attachments


unwrapAttachments : Attachments -> Dict String { content : String, mimeType : String }
unwrapAttachments (Attachments a) =
    a


{-| What type of email are you sending? `TransactionalEmail` is for high priority email intended for a single recipient (a login link for example). `BroadcastEmail` is for emails to be sent to many recipients (a product announcement or a terms of service change). `OtherMessageStream` is in case you have created additional message streams.
-}
type MessageStream
    = TransactionalEmail
    | BroadcastEmail
    | OtherMessageStream String


{-| Possible errors we might get back when trying to send an email.
Some are just normal HTTP errors and others are specific to the Postmark API.
-}
type SendEmailError
    = UnknownError UnknownErrorData
    | PostmarkError PostmarkError_
    | NetworkError
    | Timeout
    | BadUrl String


type alias UnknownErrorData =
    { statusCode : Int, body : String }


{-| Possible errors we might get back when trying to send multiple emails.
Some are just normal HTTP errors and others are specific to the Postmark API.
-}
type SendEmailsError
    = UnknownError_ UnknownErrorData
    | PostmarkErrors (Nonempty PostmarkError_)
    | NetworkError_
    | Timeout_
    | BadUrl_ String


{-| Send an email (but as a `Task` instead of a `Cmd`)

    import EmailAddress exposing (EmailAddress)
    import List.Nonempty exposing (Nonempty)
    import Postmark
    import Task exposing (Task)

    {-| An email to be sent to a recipient's email address.
    -}
    email : EmailAddress -> Task Postmark.SendEmailError ()
    email recipient =
        Postmark.sendEmailTask
            postmarkApiKey
            { from = { name = "ascii-collab", email = asciiCollabEmail }
            , to = List.Nonempty.fromElement { name = "", email = recipient }
            , subject = subject
            , body = Postmark.TextBody "Hello! Here's your login code: 123123"
            , messageStream = Postmark.TransactionalEmail
            , attachments = Postmark.noAttachments
            }

-}
sendEmailTask : ApiKey -> Email -> Task BackendOnly SendEmailError ()
sendEmailTask (ApiKey token) d =
    Http.task
        { method = "POST"
        , headers = [ Http.header "X-Postmark-Server-Token" token ]
        , url = endpoint ++ "/email"
        , body = Http.jsonBody (encodeEmail d)
        , resolver = jsonResolver
        , timeout = Nothing
        }


encodeEmail : Email -> E.Value
encodeEmail d =
    let
        ( htmlContent, inlineImages ) =
            case d.body of
                HtmlBody html ->
                    Internal.toString html

                HtmlAndTextBody html _ ->
                    Internal.toString html

                TextBody _ ->
                    ( "", [] )

        inlineAttachments : Dict String { content : String, mimeType : String }
        inlineAttachments =
            inlineImages
                |> List.map
                    (\( filename, { content, imageType } ) ->
                        ( filename
                        , { content = Base64.fromBytes content |> Maybe.withDefault ""
                          , mimeType = Internal.mimeType imageType
                          }
                        )
                    )
                |> Dict.fromList

        allAttachments : Dict String { content : String, mimeType : String }
        allAttachments =
            Dict.union inlineAttachments (unwrapAttachments d.attachments)

        attachmentsList : List ( String, { content : String, mimeType : String } )
        attachmentsList =
            Dict.toList allAttachments
    in
    E.object
        ([ ( "From", E.string <| emailToString d.from )
         , ( "To", E.string <| emailsToString d.to )
         , ( "Subject", E.string <| String.Nonempty.toString d.subject )
         , ( "MessageStream"
           , E.string
                (case d.messageStream of
                    TransactionalEmail ->
                        "outbound"

                    BroadcastEmail ->
                        "broadcast"

                    OtherMessageStream stream ->
                        stream
                )
           )
         ]
            ++ (case d.body of
                    HtmlBody _ ->
                        [ ( "HtmlBody", E.string htmlContent ) ]

                    TextBody text ->
                        [ ( "TextBody", E.string text ) ]

                    HtmlAndTextBody _ text ->
                        [ ( "HtmlBody", E.string htmlContent )
                        , ( "TextBody", E.string text )
                        ]
               )
            ++ (case attachmentsList of
                    [] ->
                        []

                    _ ->
                        [ ( "Attachments", E.list encodeAttachment attachmentsList ) ]
               )
        )


{-| Task version of `sendEmails`
-}
sendEmailsTask : ApiKey -> Nonempty Email -> Task BackendOnly SendEmailsError ()
sendEmailsTask (ApiKey token) d =
    Http.task
        { method = "POST"
        , headers = [ Http.header "X-Postmark-Server-Token" token ]
        , url = endpoint ++ "/email/batch"
        , body = List.Nonempty.toList d |> E.list encodeEmail |> Http.jsonBody
        , resolver = jsonResolver2
        , timeout = Nothing
        }


{-| Send an email

    import EmailAddress exposing (EmailAddress)
    import List.Nonempty
    import Postmark

    {-| An email to be sent to a recipient's email address.
    -}
    email : EmailAddress -> Command BackendOnly toMsg Msg
    email recipient =
        Postmark.sendEmail
            SentEmail
            postmarkApiKey
            { from = { name = "ascii-collab", email = asciiCollabEmail }
            , to = List.Nonempty.fromElement { name = "", email = recipient }
            , subject = subject
            , body = Postmark.TextBody "Hello! Here's your login code 123123"
            , messageStream = Postmark.TransactionalEmail
            , attachments = Postmark.noAttachments
            }

-}
sendEmail : (Result SendEmailError () -> msg) -> ApiKey -> Email -> Command BackendOnly toMsg msg
sendEmail msg token d =
    sendEmailTask token d |> Task.attempt msg


{-| Send multiple emails in a single API request. See more here <https://postmarkapp.com/developer/user-guide/send-email-with-api/batch-emails>
-}
sendEmails : (Result SendEmailsError () -> msg) -> ApiKey -> Nonempty Email -> Command BackendOnly toMsg msg
sendEmails msg token d =
    sendEmailsTask token d |> Task.attempt msg


emailsToString : List.Nonempty.Nonempty { name : String, email : EmailAddress } -> String
emailsToString nonEmptyEmails =
    nonEmptyEmails
        |> List.Nonempty.toList
        |> List.map emailToString
        |> String.join ", "


emailToString : { name : String, email : EmailAddress } -> String
emailToString address =
    if address.name == "" then
        EmailAddress.toString address.email

    else
        String.filter (\char -> char /= '<' && char /= '>' && char /= ',') address.name
            ++ " <"
            ++ EmailAddress.toString address.email
            ++ ">"


{-| Error message you can potentially get from Postmark
-}
type alias PostmarkError_ =
    { errorCode : Int
    , message : String
    , to : List EmailAddress
    }


decodePostmarkSendResponse : D.Decoder PostmarkError_
decodePostmarkSendResponse =
    D.map3 PostmarkError_
        (D.field "ErrorCode" D.int)
        (D.field "Message" D.string)
        (optionalField "To" Internal.decodeEmails
            |> D.map
                (\a ->
                    case a of
                        Just nonempty ->
                            List.Nonempty.toList nonempty

                        Nothing ->
                            []
                )
        )


{-| Copied from <https://package.elm-lang.org/packages/elm-community/json-extra/latest/Json-Decode-Extra>
-}
optionalField : String -> D.Decoder a -> D.Decoder (Maybe a)
optionalField fieldName decoder =
    let
        finishDecoding json =
            case D.decodeValue (D.field fieldName D.value) json of
                Ok val ->
                    -- The field is present, so run the decoder on it.
                    D.map Just (D.field fieldName decoder)

                Err _ ->
                    -- The field was missing, which is fine!
                    D.succeed Nothing
    in
    D.value
        |> D.andThen finishDecoding



-- Helpers


jsonResolver : Http.Resolver BackendOnly SendEmailError ()
jsonResolver =
    let
        decodeBody : Http.Metadata -> String -> Result SendEmailError ()
        decodeBody metadata body =
            case D.decodeString decodePostmarkSendResponse body of
                Ok json ->
                    if json.errorCode == 0 then
                        Ok ()

                    else
                        PostmarkError json |> Err

                Err _ ->
                    UnknownError { statusCode = metadata.statusCode, body = body } |> Err
    in
    Http.stringResolver
        (\response ->
            case response of
                Http.GoodStatus_ metadata body ->
                    decodeBody metadata body

                Http.BadUrl_ message ->
                    Err (BadUrl message)

                Http.Timeout_ ->
                    Err Timeout

                Http.NetworkError_ ->
                    Err NetworkError

                Http.BadStatus_ metadata body ->
                    decodeBody metadata body
        )


decodeNonempty : D.Decoder a -> D.Decoder (Nonempty a)
decodeNonempty decoder =
    D.list decoder
        |> D.andThen
            (\list ->
                case List.Nonempty.fromList list of
                    Just nonempty ->
                        D.succeed nonempty

                    Nothing ->
                        D.fail "Didn't get back any results"
            )


jsonResolver2 : Http.Resolver BackendOnly SendEmailsError ()
jsonResolver2 =
    let
        decoder : D.Decoder (Nonempty PostmarkError_)
        decoder =
            D.oneOf
                [ decodeNonempty decodePostmarkSendResponse
                , decodePostmarkSendResponse |> D.map (\a -> Nonempty a [])
                ]

        decodeBody metadata body =
            case D.decodeString decoder body of
                Ok list ->
                    let
                        results : Nonempty (Result PostmarkError_ ())
                        results =
                            List.Nonempty.map
                                (\json ->
                                    if json.errorCode == 0 then
                                        Ok ()

                                    else
                                        Err json
                                )
                                list

                        badResults : List PostmarkError_
                        badResults =
                            List.Nonempty.toList results
                                |> List.filterMap
                                    (\a ->
                                        case a of
                                            Ok _ ->
                                                Nothing

                                            Err error ->
                                                Just error
                                    )
                    in
                    case List.Nonempty.fromList badResults of
                        Just nonempty ->
                            PostmarkErrors nonempty |> Err

                        Nothing ->
                            Ok ()

                Err _ ->
                    UnknownError_ { statusCode = metadata.statusCode, body = body } |> Err
    in
    Http.stringResolver
        (\response ->
            case response of
                Http.GoodStatus_ metadata body ->
                    decodeBody metadata body

                Http.BadUrl_ message ->
                    Err (BadUrl_ message)

                Http.Timeout_ ->
                    Err Timeout_

                Http.NetworkError_ ->
                    Err NetworkError_

                Http.BadStatus_ metadata body ->
                    decodeBody metadata body
        )


encodeAttachment : ( String, { content : String, mimeType : String } ) -> E.Value
encodeAttachment ( filename, attachment ) =
    E.object
        [ ( "Name", E.string filename )
        , ( "Content", E.string attachment.content )
        , ( "ContentType", E.string attachment.mimeType )
        , ( "ContentID", E.string ("cid:" ++ filename) )
        ]
