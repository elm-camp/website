module View.Sales exposing
    ( accommodationView
    , attendeeForm
    , carbonOffsetForm
    , errorHtmlId
    , errorText
    , formView
    , goToTicketSales
    , opportunityGrant
    , opportunityGrantInfo
    , radioButton
    , sponsorshipOption
    , sponsorships
    , summary
    , summaryAccommodation
    , textInput
    , ticketInfo
    , ticketSalesHtmlId
    , ticketSalesOpenCountdown
    , ticketsHtmlId
    , ticketsView
    , tooltip
    , view
    )

import Camp26Czech.Inventory as Inventory
import Camp26Czech.Product as Product
import Camp26Czech.Tickets as Tickets
import DateFormat
import Effect.Browser.Dom as Dom exposing (HtmlId)
import Effect.Time as Time
import Formatting exposing (Formatting(..), Inline(..), Shared)
import Html
import Html.Attributes
import Html.Events
import Id exposing (Id)
import List.Extra as List
import Money
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated, SubmitStatus(..))
import Route exposing (Route(..))
import SeqDict
import String.Nonempty
import Stripe exposing (PriceId, ProductId(..))
import Theme exposing (normalButtonAttributes, showyButtonAttributes)
import TimeFormat
import Types exposing (FrontendMsg(..), LoadedModel)
import Ui
import Ui.Anim
import Ui.Events
import Ui.Font
import Ui.Input
import Ui.Layout
import Ui.Prose
import Ui.Shadow
import View.Countdown


view : Time.Posix -> LoadedModel -> Ui.Element FrontendMsg
view ticketSalesOpenAt model =
    let
        ticketsAreLive =
            case View.Countdown.detailedCountdown ticketSalesOpenAt model.now of
                Just _ ->
                    False

                Nothing ->
                    True

        afterTicketsAreLive v =
            if ticketsAreLive then
                v

            else
                Ui.none

        beforeTicketsAreLive v =
            if ticketsAreLive then
                Ui.none

            else
                v
    in
    Ui.column
        Theme.contentAttributes
        [ -- , text " ---------------------------------------------- START OF BEFORE TICKET SALES GO LIVE CONTENT ------------------"
          beforeTicketsAreLive
            (Ui.column
                Theme.contentAttributes
                [ ticketInfo model
                ]
            )
        , Ui.column
            [ Ui.spacing 60
            , Ui.htmlAttribute (Dom.idToAttribute ticketsHtmlId)
            ]
            [ Ui.el
                Theme.contentAttributes
                (Formatting.view model opportunityGrantInfo)

            -- , text "-------------------------------------------- START OF TICKETS LIVE CONTENT ---------------"
            --, afterTicketsAreLive
            --    (Ui.el
            --        Theme.contentAttributes
            --        (MarkdownThemed.renderFull "# Attend Elm Camp")
            --    )
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


ticketSalesOpenCountdown : Time.Posix -> Time.Zone -> Time.Posix -> Ui.Element FrontendMsg
ticketSalesOpenCountdown ticketSalesOpenAt timeZone now =
    Ui.column
        (Theme.contentAttributes ++ [ Ui.spacing 20 ])
        (case View.Countdown.detailedCountdown ticketSalesOpenAt now of
            Nothing ->
                [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.centerX ] goToTicketSales ]

            Just countdownElement ->
                [ countdownElement
                , DateFormat.format
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
                    timeZone
                    ticketSalesOpenAt
                    |> (\t ->
                            Ui.el
                                [ Ui.width Ui.shrink
                                , Ui.centerX
                                , Ui.paddingWith { bottom = 10, top = 10, left = 0, right = 0 }
                                ]
                                (Ui.text t)
                       )
                , Ui.el
                    (Theme.submitButtonAttributes DownloadTicketSalesReminder True ++ [ Ui.width (Ui.px 200), Ui.centerX ])
                    (Ui.el [ Ui.width Ui.shrink, Ui.Font.center, Ui.centerX ] (Ui.text "Add to calendar"))
                , Ui.text " "
                ]
        )


ticketSalesHtmlId : HtmlId
ticketSalesHtmlId =
    Dom.id "ticket-sales"


goToTicketSales : Ui.Element FrontendMsg
goToTicketSales =
    Ui.el
        (showyButtonAttributes (SetViewPortForElement ticketSalesHtmlId))
        (Ui.text "Tickets on sale now! ⬇️")



{--| Note that ticketInfo is shown before tickets are live.
    It is replaced by accommodationView after tickets are live.
--}


ticketInfo : LoadedModel -> Ui.Element msg
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
    [ Section "Tickets"
        [ Paragraph [ Text "There is a mix of room types — singles, doubles, dorm style rooms suitable for up to four people. Attendees will self-organize to distribute among the rooms and share bathrooms. The facilities for those who wish to bring a tent or campervan and camp are excellent. The surrounding grounds are beautiful and include woodland, a swimming lake and a firepit." ]
        , Paragraph [ Text "Each attendee will need to purchase ticket. If you purchase a shared room ticket, please let up know who you are sharing with. If possisble, purchase shared room tickets for everyone in your room in one transaction." ]
        , Section "All tickets include full access to the event 18th - 21st June 2024 and all meals."
            [ BulletList
                [ Text ("Staying offsite – " ++ offsitePrice) ]
                [ Paragraph [ Text "You will organise your own accommodation elsewhere." ] ]
            , BulletList
                [ if campingPrice == "£0" || campingPrice == "$0" then
                    Text "Camping space – Free"

                  else
                    Text ("Camping space – " ++ campingPrice)
                ]
                [ Paragraph [ Text "Bring your own tent or campervan and stay on site" ]
                , Paragraph [ Text "Showers & toilets provided" ]
                ]
            , BulletList
                [ Text ("Shared room – " ++ dormPrice) ]
                [ Paragraph [ Text "Suitable for a couple or up to 4 people in twin beds" ]
                ]
            , BulletList
                [ Text ("Single room – " ++ singlePrice) ]
                [ Paragraph [ Text "Limited availability" ]
                ]
            ]
        , Paragraph [ Text "This year's venue has capacity for 75 attendees. Our plan is to maximise opportunity to attend by encouraging folks to share rooms." ]
        ]
    ]
        |> Formatting.view model


ticketsHtmlId : HtmlId
ticketsHtmlId =
    Dom.id "tickets"


opportunityGrantInfo : List Formatting
opportunityGrantInfo =
    [ Section "🫶 Opportunity grant"
        [ Paragraph [ Text "Last year, we were able to offer opportunity grants to cover both ticket and travel costs for a number of attendees who would otherwise not have been able to attend. This year we will be offering the same opportunity again." ]
        , Section "🤗 Opportunity grant applications"
            [ Paragraph [ Text "If you would like to attend but are unsure about how to cover the combination of ticket, accommodations and travel expenses, please get in touch with a brief paragraph about what motivates you to attend Elm Camp and how an opportunity grant could help." ]
            , Paragraph
                [ Text "Please apply by sending an email to "
                , ExternalLink "team@elm.camp" "mailto:team@elm.camp"
                , Text ". The final date for applications is the 8th of May. Decisions will be communicated directly to each applicant by 14th of May. Elm Camp grant decisions are made by the Elm Camp organizers using a blind selection process."
                ]
            , Paragraph [ Text "All applicants and grant recipients will remain confidential. In the unlikely case that there are unused funds, the amount will be publicly communicated and saved for future Elm Camp grants." ]
            ]
        ]
    ]


ticketsView : LoadedModel -> Ui.Element FrontendMsg
ticketsView model =
    Ui.column
        -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
        Theme.contentAttributes
        [ Ui.row
            [ Ui.htmlAttribute (Dom.idToAttribute ticketSalesHtmlId)
            ]
            [ Ui.column
                []
                [ Formatting.h2 "attendee-details" "🎟️ Attendee Details" |> Ui.html
                , Ui.text "Please enter details for each person attending Elm camp, then select your accommodation below."
                ]
            , Ui.column [ Ui.width Ui.shrink ]
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
                Ui.none

            _ ->
                Ui.column [ Ui.spacing 20 ]
                    [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20 ] (Ui.text "Attendees")
                    , Ui.column
                        [ Ui.spacing 16 ]
                        (List.indexedMap (\i attendee -> attendeeForm model i attendee) model.form.attendees)
                    , Ui.Prose.paragraph [ Ui.width Ui.shrink ] [ Ui.text "We collect this info so we can estimate the carbon footprint of your trip. We pay Ecologi to offset some of the environmental impact (this is already priced in and doesn't change the shown ticket price)" ]

                    -- , carbonOffsetForm model.showCarbonOffsetTooltip model.form
                    ]
        ]



{--| Note that accommodationView is shown after tickets are live
    It is replaced by ticketInfo before tickets are live.
--}


accommodationView : LoadedModel -> Ui.Element FrontendMsg
accommodationView model =
    Ui.column [ Ui.spacing 20 ]
        [ Ui.column
            -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
            Theme.contentAttributes
            [ Theme.h2 "🏕️ Ticket type"
            , Formatting.view
                model
                [ Paragraph [ Text "Please select one accommodation option per attendee." ]
                , Paragraph [ Text "There is a mix of room types — singles, doubles and dorm style rooms suitable for up to four people. Attendees will be distributed among the rooms according to the type of ticket purchased. Bathroom facilities are shared." ]
                , Paragraph [ Text "The facilities for those who wish to bring a tent or campervan and camp are excellent. The surrounding grounds and countryside are beautiful and include woodland, a swimming lake and a firepit." ]
                ]
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
                            Ui.text "No ticket prices found"
                )
            |> Theme.rowToColumnWhen 1200 model.window [ Ui.spacing 16 ]
        ]


formView : LoadedModel -> Id ProductId -> Id PriceId -> Tickets.Ticket -> Ui.Element FrontendMsg
formView model productId priceId ticket =
    let
        form =
            model.form

        submitButton hasAttendeesAndAccommodation =
            Ui.el
                (Theme.submitButtonAttributes
                    PressedSubmitForm
                    (hasAttendeesAndAccommodation && Inventory.purchaseable ticket.productId model.slotsRemaining)
                )
                (Ui.Prose.paragraph
                    [ Ui.width Ui.shrink, Ui.Font.center ]
                    [ Ui.text
                        (if Inventory.purchaseable ticket.productId model.slotsRemaining then
                            "Purchase "

                         else
                            "Waitlist"
                        )
                    , case form.submitStatus of
                        NotSubmitted _ ->
                            Ui.none

                        Submitting ->
                            Ui.el [ Ui.width Ui.shrink, Ui.move { x = 0, y = 5, z = 0 } ] Theme.spinnerWhite

                        SubmitBackendError _ ->
                            Ui.none
                    ]
                )

        cancelButton =
            Ui.el
                (normalButtonAttributes PressedCancelForm)
                (Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Ui.text "Cancel"))

        includesAccom =
            Tickets.formIncludesAccom form

        hasAttendees =
            List.length form.attendees > 0

        includesRoom =
            Tickets.formIncludesRoom form

        --orderNotes =
        --    if includesAccom && not hasAttendees then
        --        "<red>Warning: you have chosen accommodation but no attendees, please add details for each attendee.</red>"
        --
        --    else if not includesAccom && hasAttendees then
        --        "<red>Warning: you have added attendees but no sleeping arrangement. Please select one Accommodation type per attendee.</red>"
        --
        --    else if not includesRoom then
        --        "**Please note:** You have selected a Camping ticket which means you need to make your own sleeping arrangements. You can stay offsite or bring a tent/ campervan and stay onsite."
        --
        --    else
        --        ""
    in
    Ui.column
        [ Ui.spacing 60 ]
        [ Ui.none

        -- , carbonOffsetForm model.showCarbonOffsetTooltip form
        , opportunityGrant form

        --, sponsorships model form
        , summary model
        , Ui.column
            -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
            (Theme.contentAttributes
                ++ [ Ui.spacing 24

                   --    , padding 16
                   ]
            )
            [ Ui.none

            --, MarkdownThemed.renderFull orderNotes
            , textInput
                model.form
                (\a -> FormChanged { form | billingEmail = a })
                "Billing email address"
                PurchaseForm.validateEmailAddress
                form.billingEmail
            , case form.submitStatus of
                NotSubmitted _ ->
                    Ui.none

                Submitting ->
                    -- @TODO spinner
                    Ui.none

                SubmitBackendError err ->
                    Ui.Prose.paragraph [ Ui.width Ui.shrink ] [ Ui.text err ]
            , Formatting.view
                model
                [ Paragraph [ Text "Your order will be processed by Elm Camp's fiscal host:" ]
                , Image { source = "/sponsors/cofoundry.png", maxWidth = Just 100, caption = [] }
                , Paragraph [ Text "By purchasing you agree to the event ", Link "Code of Conduct" CodeOfConductRoute ]
                ]
            , if model.window.width > 600 then
                Ui.row [ Ui.spacing 16 ] [ cancelButton, submitButton (includesAccom && hasAttendees) ]

              else
                Ui.column [ Ui.spacing 16 ] [ submitButton (includesAccom && hasAttendees), cancelButton ]
            , Formatting.view
                model
                [ Paragraph
                    [ Text "Problem with something above? Get in touch with the team at "
                    , ExternalLink "team@elm.camp" "mailto:team@elm.camp"
                    , Text "."
                    ]
                ]
            ]
        ]


attendeeForm : LoadedModel -> Int -> PurchaseForm.AttendeeForm -> Ui.Element FrontendMsg
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
            Ui.el
                (normalButtonAttributes (FormChanged { form | attendees = List.removeIfIndex (\j -> i == j) model.form.attendees })
                    ++ [ Ui.width (Ui.px 100), Ui.alignTop, Ui.move { x = 0, y = removeButtonAlignment, z = 0 } ]
                )
                (Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Ui.text "Remove"))
    in
    Theme.rowToColumnWhen columnWhen
        model.window
        [ Ui.width Ui.fill, Ui.spacing 16 ]
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


opportunityGrant : PurchaseForm -> Ui.Element FrontendMsg
opportunityGrant form =
    Ui.column
        -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
        (Theme.contentAttributes ++ [ Ui.spacing 20 ])
        [ Theme.h2 "🫶 Opportunity grants"
        , Ui.Prose.paragraph [ Ui.width Ui.shrink ] [ Ui.text "We want Elm Camp to reflect the diverse community of Elm users and benefit from the contribution of anyone, irrespective of financial background. We therefore rely on the support of sponsors and individual participants to lessen the financial impact on those who may otherwise have to abstain from attending." ]
        , Theme.panel []
            [ Ui.column [ Ui.width Ui.shrink ]
                [ Ui.Prose.paragraph [ Ui.width Ui.shrink ] [ Ui.text "All amounts are helpful and 100% of the donation (less payment processing fees) will be put to good use supporting expenses for our grantees!" ]
                , Ui.row [ Ui.spacing 30 ]
                    [ Ui.column [ Ui.width (Ui.portion 1) ]
                        [ Ui.row [ Ui.width Ui.shrink ]
                            [ Ui.text "$ "
                            , textInput form (\a -> FormChanged { form | grantContribution = a }) "" PurchaseForm.validateInt form.grantContribution
                            ]
                        ]
                    , Ui.column [ Ui.width (Ui.portion 3) ]
                        [ Ui.row [ Ui.width (Ui.portion 3) ]
                            [ Ui.el [ Ui.width Ui.shrink, Ui.paddingXY 0 10 ] (Ui.text "0")
                            , Ui.el [ Ui.width Ui.shrink, Ui.paddingXY 0 10, Ui.alignRight ] (Ui.text (Theme.priceText { currency = Money.USD, amount = 75000 }))
                            ]
                        , Ui.Input.sliderHorizontal
                            [ Ui.width Ui.shrink
                            , Ui.behindContent
                                (Ui.el
                                    [ Ui.height (Ui.px 5)
                                    , Ui.centerY
                                    , Ui.background (Ui.rgb 94 176 125)
                                    , Ui.rounded 2
                                    ]
                                    Ui.none
                                )
                            ]
                            { onChange = \a -> FormChanged { form | grantContribution = String.fromFloat (a / 100) }
                            , label = Ui.Input.labelHidden "Opportunity grant contribution value selection slider"
                            , min = 0
                            , max = 75000
                            , value = (String.toFloat form.grantContribution |> Maybe.withDefault 0) * 100
                            , thumb = Nothing
                            , step = Just 1000
                            }
                        , Ui.row [ Ui.width (Ui.portion 3) ]
                            [ Ui.el [ Ui.width Ui.shrink, Ui.paddingXY 0 10 ] (Ui.text "No contribution")
                            , Ui.el [ Ui.width Ui.shrink, Ui.paddingXY 0 10, Ui.alignRight ] (Ui.text "Donate full attendance")
                            ]
                        ]
                    ]
                ]
            ]
        ]


sponsorships : Time.Posix -> LoadedModel -> PurchaseForm -> Ui.Element FrontendMsg
sponsorships ticketSalesOpenAt model form =
    let
        year : String
        year =
            Time.toYear Time.utc ticketSalesOpenAt |> String.fromInt
    in
    Ui.column
        -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
        (Theme.contentAttributes ++ [ Ui.spacing 20 ])
        [ Theme.h2 "🤝 Sponsor Elm Camp"
        , "Position your company as a leading supporter of the Elm community and help Elm Camp "
            ++ year
            ++ " achieve a reasonable ticket offering."
            |> Ui.text
        , Product.sponsorshipItems
            |> List.map (sponsorshipOption model form)
            |> Theme.rowToColumnWhen 700 model.window [ Ui.spacing 20, Ui.width Ui.fill ]
        ]


sponsorshipOption : LoadedModel -> PurchaseForm -> Product.Sponsorship -> Ui.Element FrontendMsg
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
                [ Ui.borderColor (Ui.rgb 94 176 125), Ui.border 3 ]

            else
                [ Ui.borderColor (Ui.rgba 0 0 0 0), Ui.border 3 ]

        priceDisplay =
            Theme.priceText { currency = displayCurrency, amount = s.price }

        -- Fallback to hardcoded price if not in model.prices
    in
    Theme.panel attrs
        [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.Font.bold ] (Ui.text s.name)
        , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 30, Ui.Font.bold ] (Ui.text priceDisplay)
        , Ui.Prose.paragraph [ Ui.width Ui.shrink ] [ Ui.text s.description ]
        , s.features
            |> List.map (\point -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.size 12 ] [ Ui.text ("• " ++ point) ])
            |> Ui.column [ Ui.width Ui.shrink, Ui.spacing 5 ]
        , Ui.el
            (Theme.submitButtonAttributes
                (FormChanged
                    { form
                        | sponsorship =
                            if selected then
                                Nothing

                            else
                                Just s.productId
                    }
                )
                True
            )
            (Ui.el
                [ Ui.width Ui.shrink, Ui.centerX, Ui.Font.weight 600, Ui.Font.color (Ui.rgb 255 255 255) ]
                (Ui.text
                    (if selected then
                        "Un-select"

                     else
                        "Select"
                    )
                )
            )
        ]


summary : LoadedModel -> Ui.Element msg
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
    Ui.column
        -- Containers now width fill by default (instead of width shrink). I couldn't update that here so I recommend you review these attributes
        (Theme.contentAttributes ++ [ Ui.spacing 10 ])
        [ Theme.h2 "Summary"
        , model.form.attendees |> List.length |> (\num -> Ui.text ("Attendees x " ++ String.fromInt num))
        , if List.isEmpty model.form.accommodationBookings then
            Ui.text "No accommodation bookings"

          else
            model.form.accommodationBookings
                |> List.group
                |> List.map
                    (\group -> summaryAccommodation model group displayCurrency)
                |> Ui.column [ Ui.width Ui.shrink ]
        , if model.form.grantContribution == "0" then
            Ui.none

          else
            Ui.text
                ("Opportunity grant: "
                    ++ Theme.priceText { currency = displayCurrency, amount = floor grantTotal }
                )
        , if sponsorshipTotal > 0 then
            Ui.text
                ("Sponsorship: "
                    ++ Theme.priceText { currency = displayCurrency, amount = floor sponsorshipTotal }
                )

          else
            Ui.none
        , Theme.h3 ("Total: " ++ Theme.priceText { currency = displayCurrency, amount = floor total })
        ]


summaryAccommodation : LoadedModel -> ( PurchaseForm.Accommodation, List PurchaseForm.Accommodation ) -> Money.Currency -> Ui.Element msg
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
        |> Ui.text


carbonOffsetForm : Bool -> PurchaseForm -> Ui.Element FrontendMsg
carbonOffsetForm showCarbonOffsetTooltip form =
    Ui.column
        [ Ui.spacing 24
        , Ui.paddingWith { left = 16, right = 16, top = 32, bottom = 16 }
        , Ui.border 2
        , Ui.borderColor (Ui.rgb 94 176 125)
        , Ui.rounded 12
        , Ui.el
            [ Ui.width Ui.shrink
            , (if showCarbonOffsetTooltip then
                tooltip "We collect this info so we can estimate the carbon footprint of your trip. We pay Ecologi to offset some of the environmental impact (this is already priced in and doesn't change the shown ticket price)"

               else
                Ui.none
              )
                |> Ui.below
            , Ui.move { x = 8, y = -20, z = 0 }
            , Ui.background Theme.lightTheme.background
            ]
            (Ui.el
                [ Ui.Events.onClick Types.PressedShowCarbonOffsetTooltip, Ui.padding 8 ]
                (Ui.row [ Ui.width Ui.shrink ]
                    [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20 ] (Ui.text "🌲 Carbon offsetting ")
                    , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 12 ] (Ui.text "ℹ️")
                    ]
                )
            )
            |> Ui.inFront
        ]
        [ Ui.none
        , Ui.column
            [ Ui.width Ui.shrink, Ui.spacing 8 ]
            [ Ui.Prose.paragraph
                [ Ui.width Ui.shrink, Ui.Font.weight 600 ]
                [ Ui.text "What will be your primary method of travelling to the event?" ]

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


radioButton : String -> String -> Bool -> Ui.Element ()
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
        |> Ui.html
        |> Ui.el [ Ui.width Ui.shrink ]


textInput : PurchaseForm -> (String -> msg) -> String -> (String -> Result String value) -> String -> Ui.Element msg
textInput form onChange title validator text =
    let
        label =
            Ui.Input.label ("textInput_" ++ title) [ Ui.width Ui.shrink, Ui.Font.weight 600 ] (Ui.text title)
    in
    Ui.column
        [ Ui.spacing 4, Ui.alignTop ]
        [ label.element
        , Ui.Input.text
            [ Ui.width Ui.shrink, Ui.rounded 8 ]
            { text = text
            , onChange = onChange
            , placeholder = Nothing
            , label = label.id
            }
        , case ( form.submitStatus, validator text ) of
            ( NotSubmitted PressedSubmit, Err error ) ->
                errorText error

            _ ->
                Ui.none
        ]


{-| Used to scroll to errors.

It's technically invalid to use the same ID multiple times, but in practice
getting an element by ID means getting the _first_ element with that ID, which
is exactly what we want here.

-}
errorHtmlId : HtmlId
errorHtmlId =
    Dom.id "error"


errorText : String -> Ui.Element msg
errorText error =
    Ui.Prose.paragraph
        [ Ui.width Ui.shrink
        , Ui.Font.color (Ui.rgb 172 0 0)
        , Ui.htmlAttribute (Dom.idToAttribute errorHtmlId)
        ]
        [ Ui.text ("🚨 " ++ error) ]


tooltip : String -> Ui.Element msg
tooltip text =
    Ui.Prose.paragraph
        [ Ui.paddingXY 12 8
        , Ui.background (Ui.rgb 255 255 255)
        , Ui.width (Ui.px 300)
        , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 4, color = Ui.rgba 0 0 0 0.25 } ]
        ]
        [ Ui.text text ]
