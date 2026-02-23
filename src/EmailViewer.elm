module EmailViewer exposing (main)

{-| This module is for letting you view parts of the app UI that would be difficult to reach under normal usage.
Start `lamdera live` and go to localhost:8000/src/UiViewer.elm to use it.
-}

import Backend
import Email.Html
import EmailAddress exposing (EmailAddress)
import Html exposing (Html)
import Html.Attributes
import Money
import NonNegative
import Quantity
import RPC
import String.Nonempty exposing (NonemptyString)
import Ui
import Ui.Font
import Unsafe


main : Html ()
main =
    Ui.layout
        Ui.default
        [ Ui.Font.family [ Ui.Font.sansSerif ] ]
        (Ui.column
            [ Ui.spacing 16, Ui.padding 16 ]
            [ Ui.html campfireTicket
            , Ui.html campfireAndSingleRoomTicket
            , Ui.html allTickets
            , Ui.html allTicketsAndGrant
            , Ui.html onlyGrant
            ]
        )


campfireTicket : Html msg
campfireTicket =
    let
        email =
            Backend.confirmationEmail
                { attendees = []
                , count =
                    { campfireTicket = NonNegative.one
                    , singleRoomTicket = NonNegative.zero
                    , sharedRoomTicket = NonNegative.zero
                    }
                , billingEmail = exampleEmail
                , grantContribution = Quantity.zero
                }
                Money.CZK
    in
    emailView email.subject email.htmlBody email.textBody


campfireAndSingleRoomTicket : Html msg
campfireAndSingleRoomTicket =
    let
        email =
            Backend.confirmationEmail
                { attendees = []
                , count =
                    { campfireTicket = NonNegative.one
                    , singleRoomTicket = NonNegative.one
                    , sharedRoomTicket = NonNegative.zero
                    }
                , billingEmail = exampleEmail
                , grantContribution = Quantity.zero
                }
                Money.CZK
    in
    emailView email.subject email.htmlBody email.textBody


allTickets : Html msg
allTickets =
    let
        email =
            Backend.confirmationEmail
                { attendees = []
                , count =
                    { campfireTicket = NonNegative.one
                    , singleRoomTicket = NonNegative.one
                    , sharedRoomTicket = NonNegative.one
                    }
                , billingEmail = exampleEmail
                , grantContribution = Quantity.zero
                }
                Money.CZK
    in
    emailView email.subject email.htmlBody email.textBody


allTicketsAndGrant : Html msg
allTicketsAndGrant =
    let
        email =
            Backend.confirmationEmail
                { attendees = []
                , count =
                    { campfireTicket = NonNegative.one
                    , singleRoomTicket = NonNegative.one
                    , sharedRoomTicket = NonNegative.one
                    }
                , billingEmail = exampleEmail
                , grantContribution = Quantity.unsafe 100000
                }
                Money.CZK
    in
    emailView email.subject email.htmlBody email.textBody


onlyGrant : Html msg
onlyGrant =
    let
        email =
            Backend.confirmationEmail
                { attendees = []
                , count =
                    { campfireTicket = NonNegative.zero
                    , singleRoomTicket = NonNegative.zero
                    , sharedRoomTicket = NonNegative.zero
                    }
                , billingEmail = exampleEmail
                , grantContribution = Quantity.unsafe 100000
                }
                Money.CZK
    in
    emailView email.subject email.htmlBody email.textBody


emailView : NonemptyString -> Email.Html.Html -> String -> Html msg
emailView subject content textContent =
    Html.div
        [ Html.Attributes.style "background-color" "white" ]
        [ Html.span []
            [ Html.b [] [ Html.text "Subject: " ]
            , String.Nonempty.toString subject ++ " " |> Html.text
            , Html.input
                [ Html.Attributes.readonly True
                , Html.Attributes.type_ "text"
                , Html.Attributes.value (Email.Html.toString content)
                ]
                []
            ]
        , Html.hr [] []
        , Email.Html.toHtml content
        , Html.hr [] []
        , Html.div [ Html.Attributes.style "white-space" "pre-wrap" ] [ Html.text textContent ]
        ]


exampleEmail : EmailAddress
exampleEmail =
    Unsafe.emailAddress "user@example.com"
