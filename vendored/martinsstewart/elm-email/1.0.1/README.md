# elm-email

This package lets you create and send emails using multiple different email services. Currently [SendGrid](https://sendgrid.com/) and [Postmark](https://account.postmarkapp.com) are supported.

*Note that you cannot use this package to send emails from a browser.
You'll be blocked by CORS.
You need to run this server-side or from a stand-alone application.*

## Examples

Sending a plain text email with SendGrid

```elm

-- Make sure to install `MartinSStewart/elm-nonempty-string` and `mgold/elm-nonempty-list`.

import EmailAddress exposing (EmailAddress)
import List.Nonempty
import SendGrid
import String.Nonempty exposing (NonemptyString(..))

simpleEmail : (Result SendGrid.Error () -> msg) -> EmailAddress -> SendGrid.ApiKey -> Cmd msg
simpleEmail msg recipient apiKey =
    SendGrid.textEmail
        { subject = NonemptyString 'H' "ello!" 
        , to = List.Nonempty.fromElement recipient
        , content = NonemptyString 'H' "i!"
        , nameOfSender = "Sender Name"
        , emailAddressOfSender = senderEmailAddress
        }
        |> SendGrid.sendEmail msg apiKey
```

Sending a html email with an attachment with Postmark

```elm

-- Make sure to install `MartinSStewart/elm-nonempty-string` and `mgold/elm-nonempty-list`.

import Email.Html
import EmailAddress exposing (EmailAddress)
import List.Nonempty exposing (Nonempty)
import Postmark
import SendGrid
import String.Nonempty exposing (NonemptyString(..))

emailsWithAttachments :
    (Result Postmark.SendEmailsError () -> msg)
    -> Nonempty { name : String, email : EmailAddress }
    -> Cmd msg
emailsWithAttachments msg recipients =
    let
        attachments : Postmark.Attachments
        attachments =
            Postmark.attachments myAttachments
    in
    Postmark.sendEmails
        msg
        apiKey
        (List.Nonempty.map
            (\recipient ->
                { from = { name = senderName, email = senderEmail }
                , to = recipient
                , subject = NonemptyString 'H' "ello world!"
                , body =
                    Postmark.HtmlAndTextBody
                        (Email.Html.b [] [ Email.Html.text "Hello world!" ])
                        "Hello world!"
                , messageStream = Postmark.BroadcastEmail
                , attachments = attachments
                }
            )
            recipients
        )


```

## Postmark tool

If you are using Postmark, you can use this tool I've made https://postmark-email-client.lamdera.app/ to test sending emails and seeing what they look like for the end user.
