module View.Sales exposing
    ( accommodationView
    , attendeeForm
    , backgroundColor
    , carbonOffsetForm
    , errorHtmlId
    , errorText
    , formView
    , goToTicketSales
    , grantApplicationCopy
    , htmlId
    , opportunityGrant
    , opportunityGrantInfo
    , organisersInfo
    , radioButton
    , sponsorshipOption
    , sponsorships
    , summary
    , summaryAccommodation
    , textInput
    , ticketInfo
    , ticketSalesHtmlId
    , ticketSalesOpen
    , ticketSalesOpenCountdown
    , ticketsHtmlId
    , ticketsView
    , tooltip
    , view
    , year
    )

import Camp25US.Inventory as Inventory
import Camp25US.Product as Product
import Camp25US.Tickets as Tickets
import DateFormat
import Element exposing (Color, Element)
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
import Money
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated, SubmitStatus(..))
import SeqDict
import String.Nonempty
import Stripe exposing (PriceId, ProductId(..))
import Theme exposing (normalButtonAttributes, showyButtonAttributes)
import Time
import TimeFormat
import Types exposing (FrontendMsg(..), LoadedModel)
import View.Countdown


year : String
year =
    "2025"


ticketSalesOpen : Time.Posix
ticketSalesOpen =
    (TimeFormat.certain "2025-04-04T19:00" Time.utc).time


view : LoadedModel -> Element FrontendMsg
view model =
    let
        ticketsAreLive =
            View.Countdown.ticketSalesLive ticketSalesOpen model

        afterTicketsAreLive v =
            if ticketsAreLive then
                v

            else
                Element.none

        beforeTicketsAreLive v =
            if ticketsAreLive then
                Element.none

            else
                v
    in
    Element.column Theme.contentAttributes
        [ -- , text " ---------------------------------------------- START OF BEFORE TICKET SALES GO LIVE CONTENT ------------------"
          beforeTicketsAreLive
            (Element.column Theme.contentAttributes
                [ ticketInfo model
                ]
            )
        , Element.column
            [ Element.width Element.fill
            , Element.spacing 60
            , Element.htmlAttribute (Html.Attributes.id ticketsHtmlId)
            ]
            [ Element.el Theme.contentAttributes opportunityGrantInfo
            , grantApplicationCopy
                |> MarkdownThemed.renderFull
                |> Element.el Theme.contentAttributes
            , Element.el Theme.contentAttributes organisersInfo

            -- , text "-------------------------------------------- START OF TICKETS LIVE CONTENT ---------------"
            , afterTicketsAreLive (Element.el Theme.contentAttributes (MarkdownThemed.renderFull "# Attend Elm Camp"))
            , afterTicketsAreLive (ticketsView model)
            , afterTicketsAreLive (accommodationView model)
            , afterTicketsAreLive
                (formView model
                    (Id.fromString Product.ticket.campingSpot)
                    (Id.fromString "testing")
                    Tickets.attendanceTicket
                )

            -- , Element.el Theme.contentAttributes content3
            ]
        ]


ticketSalesOpenCountdown : LoadedModel -> Element FrontendMsg
ticketSalesOpenCountdown model =
    let
        ticketsAreLive =
            View.Countdown.ticketSalesLive ticketSalesOpen model
    in
    Element.column (Theme.contentAttributes ++ [ Element.spacing 20 ])
        (if ticketsAreLive then
            [ Element.el [ Font.size 20, Element.centerX ] goToTicketSales ]

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
                                Element.el
                                    [ Element.centerX
                                    , Element.paddingEach { bottom = 10, top = 10, left = 0, right = 0 }
                                    ]
                                    (Element.text t)
                           )

                _ ->
                    Element.el [ Element.centerX ] (Element.text "nozone")
            , Input.button
                (Theme.submitButtonAttributes True ++ [ Element.width (Element.px 200), Element.centerX ])
                { onPress = Just DownloadTicketSalesReminder
                , label = Element.el [ Font.center, Element.centerX ] (Element.text "Add to calendar")
                }
            , Element.text " "
            ]
        )


ticketSalesHtmlId : String
ticketSalesHtmlId =
    "ticket-sales"


goToTicketSales : Element FrontendMsg
goToTicketSales =
    Input.button showyButtonAttributes
        { onPress = Just (SetViewPortForElement ticketSalesHtmlId)
        , label = Element.text "Tickets on sale now! ⬇️"
        }



{--| Note that ticketInfo is shown before tickets are live.
    It is replaced by accommodationView after tickets are live.
--}


ticketInfo : LoadedModel -> Element msg
ticketInfo model =
    let
        -- Get prices for each ticket type
        formatTicketPrice productId =
            model.prices
                |> SeqDict.get (Id.fromString productId)
                |> Maybe.map (\price -> Theme.priceText price.price)
                |> Maybe.withDefault "Price not available"

        offsitePrice =
            formatTicketPrice Product.ticket.offsite

        campingPrice =
            formatTicketPrice Product.ticket.campingSpot

        singlePrice =
            formatTicketPrice Product.ticket.singleRoom

        doublePrice =
            formatTicketPrice Product.ticket.doubleRoom

        dormPrice =
            formatTicketPrice Product.ticket.groupRoom

        -- Calculate example prices
        exampleTickets3 =
            model.prices
                |> SeqDict.get (Id.fromString Product.ticket.attendanceTicket)
                |> Maybe.map (\price -> Theme.priceAmount price.price * 3)
                |> Maybe.withDefault 0

        exampleDorm =
            model.prices
                |> SeqDict.get (Id.fromString Product.ticket.groupRoom)
                |> Maybe.map (\price -> Theme.priceAmount price.price)
                |> Maybe.withDefault 0

        exampleTotal1 =
            exampleTickets3 + exampleDorm

        examplePerson1 =
            exampleTotal1 / 3

        exampleTicket1 =
            model.prices
                |> SeqDict.get (Id.fromString Product.ticket.attendanceTicket)
                |> Maybe.map (\price -> Theme.priceAmount price.price)
                |> Maybe.withDefault 0

        exampleSingle =
            model.prices
                |> SeqDict.get (Id.fromString Product.ticket.singleRoom)
                |> Maybe.map (\price -> Theme.priceAmount price.price)
                |> Maybe.withDefault 0

        exampleTotal2 =
            exampleTicket1 + exampleSingle

        -- Get a reference price for formatting
        refPrice =
            model.prices
                |> SeqDict.get (Id.fromString Product.ticket.attendanceTicket)
                |> Maybe.map .price

        formatPrice amount =
            case refPrice of
                Just price ->
                    Theme.priceText { price | amount = round (amount * 100) }

                Nothing ->
                    "Price not available"
    in
    """
# Tickets

There is a mix of room types — singles, doubles, dorm style rooms
suitable for up to four people. Attendees will self-organize
to distribute among the rooms and share bathrooms.
The facilities for those who wish to bring a tent or campervan and camp
are excellent. The surrounding grounds are
beautiful and include woodland, a swimming lake and a firepit.

Each attendee will need to purchase ticket. If you purchase a shared room ticket, please let up know who you are sharing with. If possisble, purchase shared room tickets for everyone in your room in one transaction.

## All tickets include full access to the event 18th - 21st June 2024 and all meals.

### Staying offsite - """
        ++ offsitePrice
        ++ """
You will organise your own accommodation elsewhere.

### Camping space – """
        ++ (if campingPrice == "£0" || campingPrice == "$0" then
                "Free"

            else
                campingPrice
           )
        ++ """
- Bring your own tent or campervan and stay on site
- Showers & toilets provided

### Shared room - """
        ++ dormPrice
        ++ """
- Suitable for a couple or up to 4 people in twin beds

### Single room – """
        ++ singlePrice
        ++ """
- Limited availability


This year's venue has capacity for 75 attendees. Our plan is to maximise opportunity to attend by encouraging folks to share rooms.
"""
        |> MarkdownThemed.renderFull


ticketsHtmlId : String
ticketsHtmlId =
    "tickets"


grantApplicationCopy : String
grantApplicationCopy =
    """

## 🤗 Opportunity grant applications

If you would like to attend but are unsure about how to cover the combination of ticket, accommodations and travel expenses, please get in touch with a brief paragraph about what motivates you to attend Elm Camp and how an opportunity grant could help.

Please apply by sending an email to [team@elm.camp](mailto:team@elm.camp). The final date for applications is the 8th of May. Decisions will be communicated directly to each applicant by 14th of May. Elm Camp grant decisions are made by the Elm Camp organizers using a blind selection process.

All applicants and grant recipients will remain confidential. In the unlikely case that there are unused funds, the amount will be publicly communicated and saved for future Elm Camp grants.
"""


opportunityGrantInfo : Element msg
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


ticketsView : LoadedModel -> Element FrontendMsg
ticketsView model =
    let
        attendanceTicketPriceText =
            -- Look up the attendance ticket price from model.prices
            case SeqDict.get (Id.fromString Product.ticket.attendanceTicket) model.prices of
                Just priceInfo ->
                    " - " ++ Theme.priceText priceInfo.price

                Nothing ->
                    " - Price not available"
    in
    Element.column Theme.contentAttributes
        [ Element.row [ Element.width Element.fill, htmlId ticketSalesHtmlId ]
            [ Element.column [ Element.width Element.fill ]
                [ """## 🎟️ Attendee Details
Please enter details for each person attending Elm camp, then select your accommodation below.
                """
                    |> MarkdownThemed.renderFull
                ]
            , Element.column []
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
                Element.none

            _ ->
                Element.column [ Element.width Element.fill, Element.spacing 20 ]
                    [ Element.el [ Font.size 20 ] (Element.text "Attendees")
                    , Element.column
                        [ Element.spacing 16, Element.width Element.fill ]
                        (List.indexedMap (\i attendee -> attendeeForm model i attendee) model.form.attendees)
                    , Element.paragraph [] [ Element.text "We collect this info so we can estimate the carbon footprint of your trip. We pay Ecologi to offset some of the environmental impact (this is already priced in and doesn't change the shown ticket price)" ]

                    -- , carbonOffsetForm model.showCarbonOffsetTooltip model.form
                    ]
        ]



{--| Note that accommodationView is shown after tickets are live
    It is replaced by ticketInfo before tickets are live.
--}


accommodationView : LoadedModel -> Element FrontendMsg
accommodationView model =
    Element.column [ Element.width Element.fill, Element.spacing 20 ]
        [ Element.column Theme.contentAttributes
            [ Theme.h2 "🏕️ Ticket type"
            , """
Please select one accommodation option per attendee.

There is a mix of room types — singles, doubles and dorm style rooms suitable for up to four people. Attendees will be distributed among the rooms according to the type of ticket purchased. Bathroom facilities are shared.

The facilities for those who wish to bring a tent or campervan and camp are excellent. The surrounding grounds and countryside are beautiful and include woodland, a swimming lake and a firepit.
"""
                |> MarkdownThemed.renderFull
            ]
        , SeqDict.toList Tickets.accommodationOptions
            |> List.reverse
            |> List.map
                (\( productId, ( accom, ticket ) ) ->
                    case SeqDict.get productId model.prices of
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
                            Element.text "No ticket prices found"
                )
            |> Theme.rowToColumnWhen 1200 model.window [ Element.spacing 16 ]
        ]


formView : LoadedModel -> Id ProductId -> Id PriceId -> Tickets.Ticket -> Element FrontendMsg
formView model productId priceId ticket =
    let
        form =
            model.form

        submitButton hasAttendeesAndAccommodation =
            Input.button
                (Theme.submitButtonAttributes (hasAttendeesAndAccommodation && Inventory.purchaseable ticket.productId model.slotsRemaining))
                { onPress = Just PressedSubmitForm
                , label =
                    Element.paragraph
                        [ Font.center ]
                        [ Element.text
                            (if Inventory.purchaseable ticket.productId model.slotsRemaining then
                                "Purchase "

                             else
                                "Waitlist"
                            )
                        , case form.submitStatus of
                            NotSubmitted _ ->
                                Element.none

                            Submitting ->
                                Element.el [ Element.moveDown 5 ] Theme.spinnerWhite

                            SubmitBackendError _ ->
                                Element.none
                        ]
                }

        cancelButton =
            Input.button
                normalButtonAttributes
                { onPress = Just PressedCancelForm
                , label = Element.el [ Element.centerX ] (Element.text "Cancel")
                }

        includesAccom =
            Tickets.formIncludesAccom form

        hasAttendees =
            List.length form.attendees > 0

        includesRoom =
            Tickets.formIncludesRoom form

        orderNotes =
            if includesAccom && not hasAttendees then
                "<red>Warning: you have chosen accommodation but no attendees, please add details for each attendee.</red>"

            else if not includesAccom && hasAttendees then
                "<red>Warning: you have added attendees but no sleeping arrangement. Please select one Accommodation type per attendee.</red>"

            else if not includesRoom then
                "**Please note:** You have selected a Camping ticket which means you need to make your own sleeping arrangements. You can stay offsite or bring a tent/ campervan and stay onsite."

            else
                ""
    in
    Element.column
        [ Element.width Element.fill, Element.spacing 60 ]
        [ Element.none

        -- , carbonOffsetForm model.showCarbonOffsetTooltip form
        , opportunityGrant form

        --, sponsorships model form
        , summary model
        , Element.column
            (Theme.contentAttributes
                ++ [ Element.spacing 24

                   --    , padding 16
                   ]
            )
            [ Element.none
            , MarkdownThemed.renderFull orderNotes
            , textInput
                model.form
                (\a -> FormChanged { form | billingEmail = a })
                "Billing email address"
                PurchaseForm.validateEmailAddress
                form.billingEmail
            , case form.submitStatus of
                NotSubmitted _ ->
                    Element.none

                Submitting ->
                    -- @TODO spinner
                    Element.none

                SubmitBackendError err ->
                    Element.paragraph [] [ Element.text err ]
            , """
Your order will be processed by Elm Camp's fiscal host: <img src="/sponsors/cofoundry.png" width="100" />.

By purchasing you agree to the event [Code of Conduct](/code-of-conduct).
""" |> MarkdownThemed.renderFull
            , if model.window.width > 600 then
                Element.row [ Element.width Element.fill, Element.spacing 16 ] [ cancelButton, submitButton (includesAccom && hasAttendees) ]

              else
                Element.column [ Element.width Element.fill, Element.spacing 16 ] [ submitButton (includesAccom && hasAttendees), cancelButton ]
            , """Problem with something above? Get in touch with the team at [team@elm.camp](mailto:team@elm.camp)."""
                |> MarkdownThemed.renderFull
            ]
        ]


htmlId : String -> Element.Attribute msg
htmlId str =
    Element.htmlAttribute (Html.Attributes.id str)


attendeeForm : LoadedModel -> Int -> PurchaseForm.AttendeeForm -> Element FrontendMsg
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
                (normalButtonAttributes ++ [ Element.width (Element.px 100), Element.alignTop, Element.moveDown removeButtonAlignment ])
                { onPress =
                    Just
                        (FormChanged { form | attendees = List.removeIfIndex (\j -> i == j) model.form.attendees })
                , label = Element.el [ Element.centerX ] (Element.text "Remove")
                }
    in
    Theme.rowToColumnWhen columnWhen
        model.window
        [ Element.width Element.fill, Element.spacing 16 ]
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


opportunityGrant : PurchaseForm -> Element FrontendMsg
opportunityGrant form =
    Element.column (Theme.contentAttributes ++ [ Element.spacing 20 ])
        [ Theme.h2 "🫶 Opportunity grants"
        , Element.paragraph [] [ Element.text "We want Elm Camp to reflect the diverse community of Elm users and benefit from the contribution of anyone, irrespective of financial background. We therefore rely on the support of sponsors and individual participants to lessen the financial impact on those who may otherwise have to abstain from attending." ]
        , Theme.panel []
            [ Element.column []
                [ Element.paragraph [] [ Element.text "All amounts are helpful and 100% of the donation (less payment processing fees) will be put to good use supporting expenses for our grantees!" ]
                , Element.row [ Element.width Element.fill, Element.spacing 30 ]
                    [ Element.column [ Element.width (Element.fillPortion 1) ]
                        [ Element.row []
                            [ Element.text "$ "
                            , textInput form (\a -> FormChanged { form | grantContribution = a }) "" PurchaseForm.validateInt form.grantContribution
                            ]
                        ]
                    , Element.column [ Element.width (Element.fillPortion 3) ]
                        [ Element.row [ Element.width (Element.fillPortion 3) ]
                            [ Element.el [ Element.paddingXY 0 10 ] (Element.text "0")
                            , Element.el [ Element.paddingXY 0 10, Element.alignRight ] (Element.text (Theme.priceText { currency = Money.USD, amount = 75000 }))
                            ]
                        , Input.slider
                            [ Element.behindContent
                                (Element.el
                                    [ Element.width Element.fill
                                    , Element.height (Element.px 5)
                                    , Element.centerY
                                    , Background.color (Element.rgb255 94 176 125)
                                    , Border.rounded 2
                                    ]
                                    Element.none
                                )
                            ]
                            { onChange = \a -> FormChanged { form | grantContribution = String.fromFloat (a / 100) }
                            , label = Input.labelHidden "Opportunity grant contribution value selection slider"
                            , min = 0
                            , max = 75000
                            , value = (String.toFloat form.grantContribution |> Maybe.withDefault 0) * 100
                            , thumb = Input.defaultThumb
                            , step = Just 1000
                            }
                        , Element.row [ Element.width (Element.fillPortion 3) ]
                            [ Element.el [ Element.paddingXY 0 10 ] (Element.text "No contribution")
                            , Element.el [ Element.paddingXY 0 10, Element.alignRight ] (Element.text "Donate full attendance")
                            ]
                        ]
                    ]
                ]
            ]
        ]


sponsorships : LoadedModel -> PurchaseForm -> Element FrontendMsg
sponsorships model form =
    Element.column (Theme.contentAttributes ++ [ Element.spacing 20 ])
        [ Theme.h2 "🤝 Sponsor Elm Camp"
        , Element.paragraph [] [ Element.text ("Position your company as a leading supporter of the Elm community and help Elm Camp " ++ year ++ " achieve a reasonable ticket offering.") ]
        , Product.sponsorshipItems
            |> List.map (sponsorshipOption model form)
            |> Theme.rowToColumnWhen 700 model.window [ Element.spacing 20, Element.width Element.fill ]
        ]


sponsorshipOption : LoadedModel -> PurchaseForm -> Product.Sponsorship -> Element FrontendMsg
sponsorshipOption model form s =
    let
        displayCurrency =
            model.prices
                |> SeqDict.get (Id.fromString s.productId)
                |> Maybe.map .price
                |> Maybe.map .currency
                |> Maybe.withDefault Money.USD

        selected =
            form.sponsorship == Just s.productId

        attrs =
            if selected then
                [ Border.color (Element.rgb255 94 176 125), Border.width 3 ]

            else
                [ Border.color (Element.rgba255 0 0 0 0), Border.width 3 ]

        priceDisplay =
            Theme.priceText { currency = displayCurrency, amount = s.price }

        -- Fallback to hardcoded price if not in model.prices
    in
    Theme.panel attrs
        [ Element.el [ Font.size 20, Font.bold ] (Element.text s.name)
        , Element.el [ Font.size 30, Font.bold ] (Element.text priceDisplay)
        , Element.paragraph [] [ Element.text s.description ]
        , s.features
            |> List.map (\point -> Element.paragraph [ Font.size 12 ] [ Element.text ("• " ++ point) ])
            |> Element.column [ Element.spacing 5 ]
        , Input.button
            (Theme.submitButtonAttributes True)
            { onPress =
                Just
                    (FormChanged
                        { form
                            | sponsorship =
                                if selected then
                                    Nothing

                                else
                                    Just s.productId
                        }
                    )
            , label =
                Element.el
                    [ Element.centerX, Font.semiBold, Font.color (Element.rgb 1 1 1) ]
                    (Element.text
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
            (model.form.grantContribution |> String.toFloat |> Maybe.withDefault 0) * 100

        ticketsTotal =
            model.form.attendees
                |> List.length
                |> (\num ->
                        model.prices
                            |> SeqDict.get (Id.fromString Tickets.attendanceTicket.productId)
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
                            |> SeqDict.get (Id.fromString t.productId)
                            |> Maybe.map (\price -> Theme.priceAmount price.price)
                            |> Maybe.withDefault 0
                    )
                |> List.sum

        sponsorshipTotal =
            model.form.sponsorship
                |> Maybe.andThen
                    (\productId ->
                        model.prices
                            |> SeqDict.get (Id.fromString productId)
                            |> Maybe.map (\price -> Theme.priceAmount price.price)
                    )
                |> Maybe.withDefault 0

        total =
            ticketsTotal + accomTotal + grantTotal + sponsorshipTotal

        displayCurrency : Money.Currency
        displayCurrency =
            model.prices
                |> SeqDict.get (Id.fromString Tickets.attendanceTicket.productId)
                |> Maybe.map .price
                |> Maybe.map .currency
                |> Maybe.withDefault Money.USD
    in
    Element.column (Theme.contentAttributes ++ [ Element.spacing 10 ])
        [ Theme.h2 "Summary"
        , model.form.attendees |> List.length |> (\num -> Element.text ("Attendees x " ++ String.fromInt num))
        , if List.isEmpty model.form.accommodationBookings then
            Element.text "No accommodation bookings"

          else
            model.form.accommodationBookings
                |> List.group
                |> List.map
                    (\group -> summaryAccommodation model group displayCurrency)
                |> Element.column []
        , Theme.viewIf (model.form.grantContribution /= "0")
            (Element.text
                ("Opportunity grant: "
                    ++ Theme.priceText { currency = displayCurrency, amount = floor grantTotal }
                )
            )
        , Theme.viewIf (sponsorshipTotal > 0)
            (Element.text
                ("Sponsorship: "
                    ++ Theme.priceText { currency = displayCurrency, amount = floor sponsorshipTotal }
                )
            )
        , Theme.h3 ("Total: " ++ Theme.priceText { currency = displayCurrency, amount = floor total })
        ]


summaryAccommodation : LoadedModel -> ( PurchaseForm.Accommodation, List PurchaseForm.Accommodation ) -> Money.Currency -> Element msg
summaryAccommodation model ( accom, items ) displayCurrency =
    model.form.accommodationBookings
        |> List.filter ((==) accom)
        |> List.length
        |> (\num ->
                let
                    total =
                        model.prices
                            |> SeqDict.get (Id.fromString (Tickets.accomToTicket accom).productId)
                            |> Maybe.map (\price -> Theme.priceAmount price.price)
                            |> Maybe.withDefault 0
                            |> (\price -> price * toFloat num)
                in
                Tickets.accomToString accom ++ " x " ++ String.fromInt num ++ " – " ++ Theme.priceText { currency = displayCurrency, amount = floor total }
           )
        |> Element.text


backgroundColor : Color
backgroundColor =
    Element.rgb255 255 244 225


carbonOffsetForm : Bool -> PurchaseForm -> Element FrontendMsg
carbonOffsetForm showCarbonOffsetTooltip form =
    Element.column
        [ Element.width Element.fill
        , Element.spacing 24
        , Element.paddingEach { left = 16, right = 16, top = 32, bottom = 16 }
        , Border.width 2
        , Border.color (Element.rgb255 94 176 125)
        , Border.rounded 12
        , Element.el
            [ (if showCarbonOffsetTooltip then
                tooltip "We collect this info so we can estimate the carbon footprint of your trip. We pay Ecologi to offset some of the environmental impact (this is already priced in and doesn't change the shown ticket price)"

               else
                Element.none
              )
                |> Element.below
            , Element.moveUp 20
            , Element.moveRight 8
            , Background.color backgroundColor
            ]
            (Input.button
                [ Element.padding 8 ]
                { onPress = Just PressedShowCarbonOffsetTooltip
                , label =
                    Element.row
                        []
                        [ Element.el [ Font.size 20 ] (Element.text "🌲 Carbon offsetting ")
                        , Element.el [ Font.size 12 ] (Element.text "ℹ️")
                        ]
                }
            )
            |> Element.inFront
        ]
        [ Element.none
        , Element.column
            [ Element.spacing 8 ]
            [ Element.paragraph
                [ Font.semiBold ]
                [ Element.text "What will be your primary method of travelling to the event?" ]

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
        |> Element.html
        |> Element.el []


textInput : PurchaseForm -> (String -> msg) -> String -> (String -> Result String value) -> String -> Element msg
textInput form onChange title validator text =
    Element.column
        [ Element.spacing 4, Element.width Element.fill, Element.alignTop ]
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
                Element.none
        ]


{-| Used to scroll to errors.

It's technically invalid to use the same ID multiple times, but in practice
getting an element by ID means getting the _first_ element with that ID, which
is exactly what we want here.

-}
errorHtmlId : String
errorHtmlId =
    "error"


errorText : String -> Element msg
errorText error =
    Element.paragraph
        [ Font.color (Element.rgb255 172 0 0)
        , Element.htmlAttribute (Html.Attributes.id errorHtmlId)
        ]
        [ Element.text ("🚨 " ++ error) ]


tooltip : String -> Element msg
tooltip text =
    Element.paragraph
        [ Element.paddingXY 12 8
        , Background.color (Element.rgb 1 1 1)
        , Element.width (Element.px 300)
        , Border.shadow { offset = ( 0, 1 ), size = 0, blur = 4, color = Element.rgba 0 0 0 0.25 }
        ]
        [ Element.text text ]
