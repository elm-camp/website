module View.Sales exposing
    ( TicketType
    , accommodationView
    , attendeeForm
    , carbonOffsetForm
    , errorHtmlId
    , errorText
    , formView
    , goToTicketSales
    , opportunityGrant
    , opportunityGrantInfo
    , radioButton
    , summary
    , summaryAccommodation
    , textInput
    , ticketSalesOpenCountdown
    , ticketsHtmlId
    , ticketsView
    , tooltip
    , view
    )

import Effect.Browser.Dom as Dom exposing (HtmlId)
import Effect.Time as Time
import Html
import Html.Attributes
import Html.Events
import Id exposing (Id)
import List.Extra as List
import List.Nonempty exposing (Nonempty(..))
import Money
import NonNegative exposing (NonNegative)
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated, SubmitStatus(..), TicketCount)
import RichText exposing (Inline(..), RichText(..), Shared)
import Route exposing (Route(..))
import SeqDict
import String.Nonempty
import Stripe exposing (Price, PriceId, ProductId(..))
import Theme
import Types exposing (FrontendMsg(..), LoadedModel)
import Ui
import Ui.Events
import Ui.Font
import Ui.Input
import Ui.Prose
import Ui.Shadow


view : Nonempty TicketType -> Time.Posix -> LoadedModel -> Ui.Element FrontendMsg
view allTicketTypes ticketSalesOpenAt model =
    let
        ticketsAreLive =
            detailedCountdown ticketSalesOpenAt model.now == Nothing
    in
    Ui.column
        Theme.contentAttributes
        [ --if ticketsAreLive then
          --    Ui.none
          --
          --  else
          --    Ui.column Theme.contentAttributes [ ticketInfo model ]
          Ui.column
            [ Ui.spacing 60
            , Ui.htmlAttribute (Dom.idToAttribute ticketsHtmlId)
            ]
            (Ui.el
                Theme.contentAttributes
                (RichText.view model opportunityGrantInfo)
                :: (if ticketsAreLive then
                        [ Ui.el
                            Theme.contentAttributes
                            (RichText.h1 attendSectionId model.window "Attend Elm Camp" |> Ui.html)
                        , ticketsView model
                        , accommodationView allTicketTypes model
                        , formView allTicketTypes model
                        ]

                    else
                        []
                   )
            )
        ]


attendSectionId =
    "attend-elm-camp"


detailedCountdown : Time.Posix -> Time.Posix -> Maybe (Ui.Element msg)
detailedCountdown target now =
    Nothing



--let
--    target2 =
--        Time.posixToMillis target
--
--    now2 =
--        Time.posixToMillis now
--
--    secondsRemaining =
--        (target2 - now2) // 1000
--
--    days =
--        secondsRemaining // (60 * 60 * 24)
--
--    hours =
--        modBy 24 (secondsRemaining // (60 * 60))
--
--    minutes =
--        modBy 60 (secondsRemaining // 60)
--
--    formatDays =
--        if days > 1 then
--            Just (String.fromInt days ++ " days")
--
--        else if days == 1 then
--            Just "1 day"
--
--        else
--            Nothing
--
--    formatHours =
--        if hours > 0 then
--            Just (String.fromInt hours ++ "h")
--
--        else
--            Nothing
--
--    formatMinutes =
--        if minutes > 0 then
--            Just (String.fromInt minutes ++ "m")
--
--        else
--            Nothing
--
--    output =
--        String.join " "
--            (List.filterMap identity [ formatDays, formatHours, formatMinutes ])
--in
--if secondsRemaining < 0 then
--    Nothing
--
--else
--    Ui.Prose.paragraph
--        (Theme.contentAttributes ++ [ Ui.Font.center ])
--        [ Theme.h2 (output ++ " until\u{00A0}ticket\u{00A0}sales\u{00A0}open") ]
--        |> Just


ticketSalesOpenCountdown : Time.Posix -> Time.Posix -> Ui.Element FrontendMsg
ticketSalesOpenCountdown ticketSalesOpenAt now =
    Ui.column
        (Theme.contentAttributes ++ [ Ui.spacing 20 ])
        (case detailedCountdown ticketSalesOpenAt now of
            Nothing ->
                [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.centerX ] goToTicketSales ]

            Just countdownElement ->
                [ countdownElement

                --, DateFormat.format
                --    [ DateFormat.yearNumber
                --    , DateFormat.text "-"
                --    , DateFormat.monthFixed
                --    , DateFormat.text "-"
                --    , DateFormat.dayOfMonthFixed
                --    , DateFormat.text " "
                --    , DateFormat.hourMilitaryFixed
                --    , DateFormat.text ":"
                --    , DateFormat.minuteFixed
                --    ]
                --    timeZone
                --    ticketSalesOpenAt
                --    |> (\t ->
                --            Ui.el
                --                [ Ui.width Ui.shrink
                --                , Ui.centerX
                --                , Ui.paddingWith { bottom = 10, top = 10, left = 0, right = 0 }
                --                ]
                --                (Ui.text t)
                --       )
                , Ui.el
                    (Theme.submitButtonAttributes DownloadTicketSalesReminder True
                        ++ [ Ui.width (Ui.px 200)
                           , Ui.centerX
                           , Ui.Font.size 20
                           ]
                    )
                    (Ui.el [ Ui.width Ui.shrink, Ui.Font.center, Ui.centerX ] (Ui.text "Add to calendar"))
                , Ui.text " "
                ]
        )


goToTicketSales : Ui.Element FrontendMsg
goToTicketSales =
    Ui.el
        [ Ui.width Ui.fill
        , Ui.background (Ui.rgb 255 172 98)
        , Ui.padding 16
        , Ui.rounded 8
        , Ui.Font.color (Ui.rgb 0 0 0)
        , Ui.alignBottom
        , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 2, color = Ui.rgba 0 0 0 0.1 } ]
        , Ui.Font.weight 600
        , Ui.link (Route.encode (Just attendSectionId) Route.HomepageRoute)
        ]
        (Ui.text "Tickets on sale now! ⬇️")



--ticketInfo : LoadedModel -> Ui.Element msg
--ticketInfo model =
--    let
--        -- Get prices for each ticket type
--        formatTicketPrice productId =
--            model.prices
--                |> SeqDict.get (Id.fromString productId)
--                |> Maybe.map (\price -> Theme.priceText price.price)
--                |> Maybe.withDefault "Price not available"
--
--        offsitePrice =
--            formatTicketPrice Product.ticket.offsite
--
--        campingPrice =
--            formatTicketPrice Product.ticket.campingSpot
--
--        singlePrice =
--            formatTicketPrice Product.ticket.singleRoom
--
--        doublePrice =
--            formatTicketPrice Product.ticket.doubleRoom
--
--        dormPrice =
--            formatTicketPrice Product.ticket.groupRoom
--
--        -- Calculate example prices
--        exampleTickets3 =
--            model.prices
--                |> SeqDict.get (Id.fromString Product.ticket.attendanceTicket)
--                |> Maybe.map (\price -> Theme.priceAmount price.price * 3)
--                |> Maybe.withDefault 0
--
--        exampleDorm =
--            model.prices
--                |> SeqDict.get (Id.fromString Product.ticket.groupRoom)
--                |> Maybe.map (\price -> Theme.priceAmount price.price)
--                |> Maybe.withDefault 0
--
--        exampleTotal1 =
--            exampleTickets3 + exampleDorm
--
--        examplePerson1 =
--            exampleTotal1 / 3
--
--        exampleTicket1 =
--            model.prices
--                |> SeqDict.get (Id.fromString Product.ticket.attendanceTicket)
--                |> Maybe.map (\price -> Theme.priceAmount price.price)
--                |> Maybe.withDefault 0
--
--        exampleSingle =
--            model.prices
--                |> SeqDict.get (Id.fromString Product.ticket.singleRoom)
--                |> Maybe.map (\price -> Theme.priceAmount price.price)
--                |> Maybe.withDefault 0
--
--        exampleTotal2 =
--            exampleTicket1 + exampleSingle
--
--        -- Get a reference price for formatting
--        refPrice =
--            model.prices
--                |> SeqDict.get (Id.fromString Product.ticket.attendanceTicket)
--                |> Maybe.map .price
--
--        formatPrice amount =
--            case refPrice of
--                Just price ->
--                    Theme.priceText { price | amount = round (amount * 100) }
--
--                Nothing ->
--                    "Price not available"
--    in
--    [ Section "Tickets"
--        [ Paragraph [ Text "There is a mix of room types — singles, doubles, dorm style rooms suitable for up to four people. Attendees will self-organize to distribute among the rooms and share bathrooms. The facilities for those who wish to bring a tent or campervan and camp are excellent. The surrounding grounds are beautiful and include woodland, a swimming lake and a firepit." ]
--        , Paragraph [ Text "Each attendee will need to purchase ticket. If you purchase a shared room ticket, please let up know who you are sharing with. If possisble, purchase shared room tickets for everyone in your room in one transaction." ]
--        , Section "All tickets include full access to the event 18th - 21st June 2024 and all meals."
--            [ BulletList
--                [ Text ("Staying offsite – " ++ offsitePrice) ]
--                [ Paragraph [ Text "You will organise your own accommodation elsewhere." ] ]
--            , BulletList
--                [ if campingPrice == "£0" || campingPrice == "$0" then
--                    Text "Camping space – Free"
--
--                  else
--                    Text ("Camping space – " ++ campingPrice)
--                ]
--                [ Paragraph [ Text "Bring your own tent or campervan and stay on site" ]
--                , Paragraph [ Text "Showers & toilets provided" ]
--                ]
--            , BulletList
--                [ Text ("Shared room – " ++ dormPrice) ]
--                [ Paragraph [ Text "Suitable for a couple or up to 4 people in twin beds" ]
--                ]
--            , BulletList
--                [ Text ("Single room – " ++ singlePrice) ]
--                [ Paragraph [ Text "Limited availability" ]
--                ]
--            ]
--        , Paragraph [ Text "This year's venue has capacity for 75 attendees. Our plan is to maximise opportunity to attend by encouraging folks to share rooms." ]
--        ]
--    ]
--        |> RichText.view model


ticketsHtmlId : HtmlId
ticketsHtmlId =
    Dom.id "tickets"


opportunityGrantInfo : List RichText
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
    let
        form =
            model.form

        attendeeCount =
            List.Nonempty.length form.attendees
    in
    Ui.column
        Theme.contentAttributes
        [ Ui.column
            []
            [ RichText.h2 "attendee-details" "🎟️ Attendee Details" |> Ui.html
            , Ui.text "Please enter details for each person attending Elm camp, then select your accommodation below."
            ]
        , Ui.column
            [ Ui.spacing 20 ]
            [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20 ] (Ui.text "Attendees")
            , Ui.column
                [ Ui.spacing 16 ]
                (List.indexedMap (attendeeForm (attendeeCount > 1) model) (List.Nonempty.toList form.attendees))
            , if attendeeCount < 10 then
                Ui.el
                    (Theme.normalButtonAttributes
                        (FormChanged
                            { form
                                | attendees =
                                    List.Nonempty.append form.attendees (Nonempty PurchaseForm.defaultAttendee [])
                            }
                        )
                    )
                    (Ui.text "Add another attendee")

              else
                Ui.none
            , Ui.Prose.paragraph [ Ui.width Ui.shrink ] [ Ui.text "We collect this info so we can estimate the carbon footprint of your trip. We pay Ecologi to offset some of the environmental impact (this is already priced in and doesn't change the shown ticket price)" ]

            -- , carbonOffsetForm model.showCarbonOffsetTooltip model.form
            ]
        ]



{--| Note that accommodationView is shown after tickets are live
    It is replaced by ticketInfo before tickets are live.
--}


accommodationView : Nonempty TicketType -> LoadedModel -> Ui.Element FrontendMsg
accommodationView allTicketTypes model =
    let
        form =
            model.form
    in
    Ui.column [ Ui.spacing 20 ]
        [ Ui.column
            Theme.contentAttributes
            [ Theme.h2 "🏕️ Ticket type"
            , RichText.view
                model
                [ Paragraph [ Text "Please select one accommodation option per attendee." ]
                , Paragraph [ Text "There is a mix of room types — singles, doubles and dorm style rooms suitable for up to four people. Attendees will be distributed among the rooms according to the type of ticket purchased. Bathroom facilities are shared." ]
                , Paragraph [ Text "The facilities for those who wish to bring a tent or campervan and camp are excellent. The surrounding grounds and countryside are beautiful and include woodland, a swimming lake and a firepit." ]
                ]
            ]
        , List.map
            (\ticket ->
                case SeqDict.get ticket.productId model.prices of
                    Just price ->
                        viewAccom model.form.count True price.price ticket

                    Nothing ->
                        Ui.text "No ticket prices found"
            )
            (List.Nonempty.toList allTicketTypes)
            |> Theme.rowToColumnWhen 700 model.window [ Ui.spacing 16 ]
            |> Ui.map (\formCount -> FormChanged { form | count = formCount })
        ]


viewAccom : TicketCount -> Bool -> Price -> TicketType -> Ui.Element TicketCount
viewAccom formCount ticketAvailable price ticket2 =
    let
        count =
            ticket2.getter formCount
    in
    Ui.column
        [ Ui.width Ui.fill
        , Ui.height Ui.fill
        , Ui.spacing 16
        , Ui.background (Ui.rgb 255 255 255)
        , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 4, color = Ui.rgba 0 0 0 0.25 } ]
        , Ui.height Ui.fill
        , Ui.rounded 16
        , Ui.padding 16
        ]
        [ Ui.none
        , Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.weight 600, Ui.Font.size 20 ] [ Ui.text ticket2.name ]
        , Ui.text ticket2.description
        , Ui.el
            [ Ui.width Ui.shrink, Ui.Font.bold, Ui.Font.size 36, Ui.alignBottom ]
            (Ui.text (Theme.priceText price))
        , if ticketAvailable then
            if NonNegative.toInt count > 0 then
                Theme.numericField
                    "Tickets"
                    (NonNegative.toInt count)
                    (\value -> ticket2.setter (Result.withDefault count (NonNegative.fromInt value)) formCount)

            else
                Ui.el
                    (Theme.submitButtonAttributes (ticket2.setter NonNegative.one formCount) ticketAvailable)
                    (Ui.el
                        [ Ui.width Ui.shrink, Ui.centerX, Ui.Font.weight 600, Ui.Font.color (Ui.rgb 255 255 255) ]
                        (Ui.text "Select")
                    )

          else if ticket2.name == "Campfire Ticket" then
            Ui.text "Waitlist"

          else
            Ui.text "Sold out!"
        ]


type alias TicketType =
    { name : String
    , description : String
    , image : String
    , productId : Id ProductId
    , getter : TicketCount -> NonNegative
    , setter : NonNegative -> TicketCount -> TicketCount
    }


purchaseable ticket model =
    True


formView : Nonempty TicketType -> LoadedModel -> Ui.Element FrontendMsg
formView allTicketTypes model =
    let
        form =
            model.form

        submitButton =
            Ui.el
                (Theme.submitButtonAttributes PressedSubmitForm True)
                (Ui.row
                    [ Ui.width Ui.shrink, Ui.Font.center ]
                    [ Ui.text
                        (--if purchaseable ticket.productId model.slotsRemaining then
                         "Purchase "
                         --else
                         --   "Waitlist"
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
                (Theme.normalButtonAttributes PressedCancelForm)
                (Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Ui.text "Cancel"))
    in
    Ui.column
        [ Ui.spacing 60 ]
        [ Ui.none

        -- , carbonOffsetForm model.showCarbonOffsetTooltip form
        , opportunityGrant form

        --, sponsorships model form
        , summary allTicketTypes model
        , Ui.column
            (Ui.spacing 24 :: Theme.contentAttributes)
            [ textInput
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
            , RichText.view
                model
                [ Paragraph [ Text "Your order will be processed by Elm Camp's fiscal host:" ]
                , Image { source = "/sponsors/cofoundry.png", maxWidth = Just 100, caption = [] }
                , Paragraph [ Text "By purchasing you agree to the event ", Link "Code of Conduct" CodeOfConductRoute ]
                ]
            , if model.window.width > 600 then
                Ui.row [ Ui.spacing 16 ] [ cancelButton, submitButton ]

              else
                Ui.column [ Ui.spacing 16 ] [ submitButton, cancelButton ]
            , RichText.view
                model
                [ Paragraph
                    [ Text "Problem with something above? Get in touch with the team at "
                    , ExternalLink "team@elm.camp" "mailto:team@elm.camp"
                    , Text "."
                    ]
                ]
            ]
        ]


attendeeForm : Bool -> LoadedModel -> Int -> PurchaseForm.AttendeeForm -> Ui.Element FrontendMsg
attendeeForm showRemove model i attendee =
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
    in
    Theme.rowToColumnWhen columnWhen
        model.window
        [ Ui.width Ui.fill, Ui.spacing 16 ]
        [ textInput
            model.form
            (\a -> FormChanged { form | attendees = nonemptySetAt i { attendee | name = a } model.form.attendees })
            "Name"
            PurchaseForm.validateName
            attendee.name
        , textInput
            model.form
            (\a -> FormChanged { form | attendees = nonemptySetAt i { attendee | email = a } model.form.attendees })
            "Email"
            PurchaseForm.validateEmailAddress
            attendee.email
        , textInput
            model.form
            (\a -> FormChanged { form | attendees = nonemptySetAt i { attendee | country = a } model.form.attendees })
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
            (\a -> FormChanged { form | attendees = nonemptySetAt i { attendee | originCity = a } model.form.attendees })
            "City/town"
            (\text ->
                case String.Nonempty.fromString text of
                    Just nonempty ->
                        Ok nonempty

                    Nothing ->
                        Err "Please type in the name of city nearest to you"
            )
            attendee.originCity
        , if showRemove then
            Ui.el
                (Theme.normalButtonAttributes
                    (FormChanged
                        { form
                            | attendees =
                                List.removeIfIndex (\j -> i == j) (List.Nonempty.toList model.form.attendees)
                                    |> List.Nonempty.fromList
                                    |> Maybe.withDefault model.form.attendees
                        }
                    )
                    ++ [ Ui.width (Ui.px 100)
                       , Ui.alignTop
                       , Ui.move { x = 0, y = removeButtonAlignment, z = 0 }
                       ]
                )
                (Ui.el [ Ui.width Ui.shrink, Ui.centerX ] (Ui.text "Remove"))

          else
            Ui.none
        ]


nonemptySetAt : Int -> a -> Nonempty a -> Nonempty a
nonemptySetAt index a nonempty =
    List.Nonempty.indexedMap
        (\i item ->
            if i == index then
                a

            else
                item
        )
        nonempty


noShrink : Ui.Attribute msg
noShrink =
    Html.Attributes.style "flex-shrink" "0" |> Ui.htmlAttribute


opportunityGrant : PurchaseForm -> Ui.Element FrontendMsg
opportunityGrant form =
    Ui.column
        (Ui.spacing 20 :: Theme.contentAttributes)
        [ Theme.h2 "🫶 Opportunity grants"
        , Ui.Prose.paragraph
            [ Ui.width Ui.shrink ]
            [ Ui.text "We want Elm Camp to reflect the diverse community of Elm users and benefit from the contribution of anyone, irrespective of financial background. We therefore rely on the support of sponsors and individual participants to lessen the financial impact on those who may otherwise have to abstain from attending." ]
        , Theme.panel []
            [ Ui.column [ Ui.width Ui.shrink ]
                [ Ui.Prose.paragraph
                    [ Ui.width Ui.shrink ]
                    [ Ui.text "All amounts are helpful and 100% of the donation (less payment processing fees) will be put to good use supporting expenses for our grantees!" ]
                , Ui.row [ Ui.spacing 30 ]
                    [ Ui.row
                        [ Ui.width (Ui.px 100), noShrink ]
                        [ Ui.el [ noShrink, Ui.alignTop, Ui.paddingXY 0 3 ] (Ui.text "$")
                        , textInput
                            form
                            (\a -> FormChanged { form | grantContribution = a })
                            ""
                            PurchaseForm.validateGrantContribution
                            form.grantContribution
                        ]
                    , Ui.column [ Ui.width (Ui.portion 3) ]
                        [ Ui.row [ Ui.width (Ui.portion 3) ]
                            [ Ui.el [ Ui.width Ui.shrink, Ui.paddingXY 0 10 ] (Ui.text "0")
                            , Ui.el
                                [ Ui.width Ui.shrink, Ui.paddingXY 0 10, Ui.alignRight ]
                                (Ui.text (Theme.priceText { currency = Money.USD, amount = 75000 }))
                            ]
                        , Ui.Input.sliderHorizontal
                            []
                            { onChange = \a -> FormChanged { form | grantContribution = String.fromFloat (a / 100) }
                            , label = Ui.Input.labelHidden "Opportunity grant contribution value selection slider"
                            , min = 0
                            , max = 75000
                            , value = (String.toFloat form.grantContribution |> Maybe.withDefault 0) * 100
                            , thumb = Nothing
                            , step = Just 1000
                            }
                        , Ui.row
                            [ Ui.width (Ui.portion 3), Ui.paddingXY 0 10 ]
                            [ Ui.el [ Ui.width Ui.shrink ] (Ui.text "No contribution")
                            , Ui.el [ Ui.width Ui.shrink, Ui.alignRight ] (Ui.text "Donate full attendance")
                            ]
                        ]
                    ]
                ]
            ]
        ]



--
--sponsorships : Time.Posix -> LoadedModel -> PurchaseForm -> Ui.Element FrontendMsg
--sponsorships ticketSalesOpenAt model form =
--    let
--        year : String
--        year =
--            Time.toYear Time.utc ticketSalesOpenAt |> String.fromInt
--    in
--    Ui.column
--        (Ui.spacing 20 :: Theme.contentAttributes)
--        [ Theme.h2 "🤝 Sponsor Elm Camp"
--        , "Position your company as a leading supporter of the Elm community and help Elm Camp "
--            ++ year
--            ++ " achieve a reasonable ticket offering."
--            |> Ui.text
--        , Product.sponsorshipItems
--            |> List.map (sponsorshipOption model form)
--            |> Theme.rowToColumnWhen 700 model.window [ Ui.spacing 20, Ui.width Ui.fill ]
--        ]
--
--
--sponsorshipOption : LoadedModel -> PurchaseForm -> Product.Sponsorship -> Ui.Element FrontendMsg
--sponsorshipOption model form s =
--    let
--        displayCurrency =
--            model.prices
--                |> SeqDict.get (Id.fromString s.productId)
--                |> Maybe.map .price
--                |> Maybe.map .currency
--                |> Maybe.withDefault Money.USD
--
--        selected =
--            form.sponsorship == Just s.productId
--
--        attrs =
--            if selected then
--                [ Ui.borderColor (Ui.rgb 94 176 125), Ui.border 3 ]
--
--            else
--                [ Ui.borderColor (Ui.rgba 0 0 0 0), Ui.border 3 ]
--
--        priceDisplay =
--            Theme.priceText { currency = displayCurrency, amount = s.price }
--
--        -- Fallback to hardcoded price if not in model.prices
--    in
--    Theme.panel attrs
--        [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 20, Ui.Font.bold ] (Ui.text s.name)
--        , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 30, Ui.Font.bold ] (Ui.text priceDisplay)
--        , Ui.Prose.paragraph [ Ui.width Ui.shrink ] [ Ui.text s.description ]
--        , s.features
--            |> List.map (\point -> Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.size 12 ] [ Ui.text ("• " ++ point) ])
--            |> Ui.column [ Ui.width Ui.shrink, Ui.spacing 5 ]
--        , Ui.el
--            (Theme.submitButtonAttributes
--                (FormChanged
--                    { form
--                        | sponsorship =
--                            if selected then
--                                Nothing
--
--                            else
--                                Just s.productId
--                    }
--                )
--                True
--            )
--            (Ui.el
--                [ Ui.width Ui.shrink, Ui.centerX, Ui.Font.weight 600, Ui.Font.color (Ui.rgb 255 255 255) ]
--                (Ui.text
--                    (if selected then
--                        "Un-select"
--
--                     else
--                        "Select"
--                    )
--                )
--            )
--        ]


summary : Nonempty TicketType -> LoadedModel -> Ui.Element msg
summary allTicketTypes model =
    let
        grant : Result String Int
        grant =
            PurchaseForm.validateGrantContribution model.form.grantContribution

        grantTotal : Float
        grantTotal =
            case grant of
                Ok value ->
                    toFloat value * 100

                Err _ ->
                    0

        accomTotal : Float
        accomTotal =
            List.map
                (\ticket ->
                    case SeqDict.get ticket.productId model.prices of
                        Just price ->
                            Theme.priceAmount price.price * toFloat (NonNegative.toInt (ticket.getter model.form.count))

                        Nothing ->
                            0
                )
                (List.Nonempty.toList allTicketTypes)
                |> List.sum

        --sponsorshipTotal : Float
        --sponsorshipTotal =
        --    model.form.sponsorship
        --        |> Maybe.andThen
        --            (\productId ->
        --                model.prices
        --                    |> SeqDict.get (Id.fromString productId)
        --                    |> Maybe.map (\price -> Theme.priceAmount price.price)
        --            )
        --        |> Maybe.withDefault 0
        displayCurrency : Money.Currency
        displayCurrency =
            model.prices
                |> SeqDict.get (List.Nonempty.head allTicketTypes).productId
                |> Maybe.map .price
                |> Maybe.map .currency
                |> Maybe.withDefault Money.USD
    in
    Ui.column
        (Ui.spacing 10 :: Theme.contentAttributes)
        [ Theme.h2 "Summary"
        , Ui.text ("Attendees x " ++ String.fromInt (List.Nonempty.length model.form.attendees))
        , if model.form.count == PurchaseForm.initTicketCount then
            Ui.text "No accommodation bookings"

          else
            summaryAccommodation allTicketTypes model model.form.count displayCurrency
        , case grant of
            Err _ ->
                Ui.none

            Ok 0 ->
                Ui.none

            Ok _ ->
                Ui.text
                    ("Opportunity grant: "
                        ++ Theme.priceText { currency = displayCurrency, amount = floor grantTotal }
                    )

        --, if sponsorshipTotal > 0 then
        --    Ui.text
        --        ("Sponsorship: "
        --            ++ Theme.priceText { currency = displayCurrency, amount = floor sponsorshipTotal }
        --        )
        --
        --  else
        --    Ui.none
        , "Total: "
            ++ Theme.priceText
                { currency = displayCurrency
                , amount = accomTotal + grantTotal |> floor -- + sponsorshipTotal |> floor
                }
            |> Theme.h3
        ]


summaryAccommodation : Nonempty TicketType -> LoadedModel -> TicketCount -> Money.Currency -> Ui.Element msg
summaryAccommodation ticketTypes model ticketCount displayCurrency =
    List.filterMap
        (\ticket ->
            case SeqDict.get ticket.productId model.prices of
                Just price ->
                    let
                        total : Float
                        total =
                            Theme.priceAmount price.price * toFloat (NonNegative.toInt (ticket.getter ticketCount))
                    in
                    if total > 0 then
                        ticket.name
                            ++ " x "
                            ++ NonNegative.toString (ticket.getter ticketCount)
                            ++ " – "
                            ++ Theme.priceText { currency = displayCurrency, amount = floor total }
                            |> Ui.text
                            |> Just

                    else
                        Nothing

                Nothing ->
                    Nothing
        )
        (List.Nonempty.toList ticketTypes)
        |> Ui.column [ Ui.width Ui.shrink ]


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
        [ if title == "" then
            Ui.none

          else
            label.element
        , Ui.Input.text
            [ Ui.width Ui.shrink, Ui.rounded 8, Ui.paddingXY 8 4, Ui.width Ui.fill ]
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
        [ Ui.text error ]


tooltip : String -> Ui.Element msg
tooltip text =
    Ui.Prose.paragraph
        [ Ui.paddingXY 12 8
        , Ui.background (Ui.rgb 255 255 255)
        , Ui.width (Ui.px 300)
        , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 4, color = Ui.rgba 0 0 0 0.25 } ]
        ]
        [ Ui.text text ]
