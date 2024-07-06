module View.Sales exposing (..)

import AssocList
import Camp24Devon.Inventory as Inventory
import Camp24Devon.Product as Product
import Camp24Devon.Tickets as Tickets
import DateFormat
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes
import Html.Events
import Id exposing (Id)
import List.Extra as List
import MarkdownThemed
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated, SubmitStatus(..))
import String.Nonempty
import Stripe exposing (PriceId, ProductId(..))
import Theme exposing (normalButtonAttributes, showyButtonAttributes)
import Time
import TimeFormat
import Types exposing (..)
import View.Countdown


year =
    "2024"


ticketSalesOpen =
    (TimeFormat.certain "2024-04-04T19:00" Time.utc).time


view model =
    let
        ticketsAreLive =
            View.Countdown.ticketSalesLive ticketSalesOpen model

        afterTicketsAreLive v =
            if ticketsAreLive then
                v

            else
                none

        beforeTicketsAreLive v =
            if ticketsAreLive then
                none

            else
                v
    in
    column []
        [ -- , text " ---------------------------------------------- START OF BEFORE TICKET SALES GO LIVE CONTENT ------------------"
          beforeTicketsAreLive <|
            column Theme.contentAttributes
                [ ticketInfo
                ]
        , column
            [ width fill
            , spacing 60
            , htmlAttribute (Html.Attributes.id ticketsHtmlId)
            ]
            [ el Theme.contentAttributes opportunityGrantInfo
            , grantApplicationCopy
                |> MarkdownThemed.renderFull
                |> el Theme.contentAttributes
            , el Theme.contentAttributes organisersInfo

            -- , text "-------------------------------------------- START OF TICKETS LIVE CONTENT ---------------"
            , afterTicketsAreLive <| el Theme.contentAttributes <| MarkdownThemed.renderFull "# Attend Elm Camp"
            , afterTicketsAreLive <| ticketsView model
            , afterTicketsAreLive <| accommodationView model
            , afterTicketsAreLive <|
                formView model
                    (Id.fromString Product.ticket.campingSpot)
                    (Id.fromString "testing")
                    Tickets.attendanceTicket

            -- , Element.el Theme.contentAttributes content3
            ]
        ]


ticketSalesOpenCountdown model =
    let
        ticketsAreLive =
            View.Countdown.ticketSalesLive ticketSalesOpen model
    in
    column (Theme.contentAttributes ++ [ spacing 20 ]) <|
        if ticketsAreLive then
            [ el [ Font.size 20, centerX ] goToTicketSales ]

        else
            [ View.Countdown.detailedCountdown ticketSalesOpen "until ticket sales open" model
            , case model.zone of
                Just zone ->
                    DateFormat.format
                        [ DateFormat.yearNumber
                        , DateFormat.text "-"
                        , DateFormat.monthFixed
                        , DateFormat.text "-"
                        , DateFormat.dayOfMonthFixed
                        , DateFormat.text " "
                        , DateFormat.hourMilitaryFixed
                        , DateFormat.text ":"
                        , DateFormat.minuteFixed
                        ]
                        zone
                        ticketSalesOpen
                        |> (\t ->
                                el
                                    [ centerX
                                    , paddingEach { bottom = 10, top = 10, left = 0, right = 0 }
                                    ]
                                <|
                                    text t
                           )

                _ ->
                    el [ centerX ] <| text "nozone"
            , Input.button
                (Theme.submitButtonAttributes True ++ [ width (px 200), centerX ])
                { onPress = Just DownloadTicketSalesReminder
                , label = el [ Font.center, centerX ] <| text "Add to calendar"
                }
            , text " "
            ]


goToTicketSales =
    Input.button showyButtonAttributes
        { onPress = Just (SetViewPortForElement "🎟️-attendance-ticket---£200")
        , label = text "Tickets on sale now! ⬇️"
        }


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


ticketsHtmlId =
    "tickets"


grantApplicationCopy =
    """

## 🤗 Opportunity grant applications

If you would like to attend but are unsure about how to cover the combination of ticket, accommodations and travel expenses, please get in touch with a brief paragraph about what motivates you to attend Elm Camp and how an opportunity grant could help.

Please apply by sending an email to [team@elm.camp](mailto:team@elm.camp). The final date for applications is the 1st of May. Decisions will be communicated directly to each applicant by 7th of May. Elm Camp grant decisions are made by the Elm Camp organizers using a blind selection process.

All applicants and grant recipients will remain confidential. In the unlikely case that there are unused funds, the amount will be publicly communicated and saved for future Elm Camp grants.
"""


opportunityGrantInfo =
    """
# 🫶 Opportunity grant

Last year, we were able to offer opportunity grants to cover both ticket and travel costs for a number of attendees who would otherwise not have been able to attend. This year we will be offering the same opportunity again.

"""
        |> MarkdownThemed.renderFull


organisersInfo : Element msg
organisersInfo =
    """

# Organisers

Elm Camp is a community-driven non-profit initiative, organised by [enthusiastic members of the Elm community](/organisers).

"""
        -- ++ organisers2024
        |> MarkdownThemed.renderFull


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
                [ if List.length model.form.attendees == 0 then
                    let
                        form =
                            model.form
                    in
                    Input.button
                        (Theme.submitButtonAttributes True)
                        { onPress = Just <| FormChanged { form | attendees = model.form.attendees ++ [ PurchaseForm.defaultAttendee ] }
                        , label =
                            el
                                [ centerX, Font.semiBold, Font.color (rgb 1 1 1) ]
                                (text "Select")
                        }

                  else
                    Theme.numericField
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
                    , paragraph [] [ text "We collect this info so we can estimate the carbon footprint of your trip. We pay Ecologi to offset some of the environmental impact (this is already priced in and doesn't change the shown ticket price)" ]

                    -- , carbonOffsetForm model.showCarbonOffsetTooltip model.form
                    ]
        ]


accommodationView : LoadedModel -> Element FrontendMsg_
accommodationView model =
    column [ width fill, spacing 20 ]
        [ column Theme.contentAttributes
            [ Theme.h2 "🏕️ Accommodation"
            , """
You can upgrade a camp ticket with any of the below on-site accommodation options, or organise your own off-site accommodation.

There is a mix of room types — singles, doubles, dorm style rooms suitable for up to four people. Attendees will self-organize to distribute among the rooms and share bathrooms.

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

        includesAccom =
            Tickets.formIncludesAccom form

        hasAttendees =
            List.length form.attendees > 0

        orderNotes =
            if includesAccom && not hasAttendees then
                "<red>Warning: you have chosen accommodation but no attendees, please make sure each attendee has a ticket selection (unless they've purchased them separately).</red>"

            else if not includesAccom && hasAttendees then
                "Please note: your selected options ***do not include accommodation***."

            else
                ""
    in
    column
        [ width fill, spacing 60 ]
        [ none

        -- , carbonOffsetForm model.showCarbonOffsetTooltip form
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
            , MarkdownThemed.renderFull orderNotes
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


htmlId : String -> Element.Attribute msg
htmlId str =
    Element.htmlAttribute (Html.Attributes.id str)


attendeeForm model i attendee =
    let
        form =
            model.form

        columnWhen =
            700

        removeButtonAlignment =
            if model.window.width > columnWhen then
                -- This depends on the size of the text input labels.
                15

            else
                0

        removeButton =
            Input.button
                (normalButtonAttributes ++ [ width (px 100), alignTop, moveDown removeButtonAlignment ])
                { onPress =
                    Just
                        (FormChanged { form | attendees = List.removeIfIndex (\j -> i == j) model.form.attendees })
                , label = el [ centerX ] (text "Remove")
                }
    in
    Theme.rowToColumnWhen columnWhen
        model
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
            "City/town"
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


opportunityGrant form =
    column (Theme.contentAttributes ++ [ spacing 20 ])
        [ Theme.h2 "🫶 Opportunity grants"
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

        ticketsTotal =
            model.form.attendees
                |> List.length
                |> (\num ->
                        model.prices
                            |> AssocList.get (Id.fromString Tickets.attendanceTicket.productId)
                            |> Maybe.map (\price -> Theme.priceAmount price.price)
                            |> Maybe.withDefault 0
                            |> (\price -> price * toFloat num)
                   )

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
            ticketsTotal + accomTotal + grantTotal + sponsorshipTotal
    in
    column (Theme.contentAttributes ++ [ spacing 10 ])
        [ Theme.h2 "Summary"
        , model.form.attendees |> List.length |> (\num -> text <| "Attendance tickets x " ++ String.fromInt num ++ " – £" ++ String.fromFloat ticketsTotal)
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


carbonOffsetForm : Bool -> PurchaseForm -> Element FrontendMsg_
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
            -- , case ( form.submitStatus, form.primaryModeOfTravel ) of
            --     ( NotSubmitted PressedSubmit, Nothing ) ->
            --         errorText "Please select one of the above"
            --     _ ->
            --         none
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


textInput : PurchaseForm -> (String -> msg) -> String -> (String -> Result String value) -> String -> Element msg
textInput form onChange title validator text =
    column
        [ spacing 4, width fill, alignTop ]
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


{-| Used to scroll to errors.

It’s technically invalid to use the same ID multiple times, but in practice
getting an element by ID means getting the _first_ element with that ID, which
is exactly what we want here.

-}
errorHtmlId : String
errorHtmlId =
    "error"


errorText : String -> Element msg
errorText error =
    paragraph
        [ Font.color (rgb255 172 0 0)
        , htmlAttribute (Html.Attributes.id errorHtmlId)
        ]
        [ text ("🚨 " ++ error) ]


tooltip : String -> Element msg
tooltip text =
    paragraph
        [ paddingXY 12 8
        , Background.color (rgb 1 1 1)
        , width (px 300)
        , Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = rgba 0 0 0 0.25 }
        ]
        [ Element.text text ]
