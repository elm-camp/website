module View.Sales exposing
    ( errorHtmlId
    , view
    )

import Camp26Czech exposing (TicketType)
import Effect.Browser.Dom as Dom exposing (HtmlId)
import Effect.Time as Time
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Icons
import List.Extra
import Money
import NonNegative exposing (NonNegative)
import PurchaseForm exposing (PressedSubmit(..), PurchaseForm, PurchaseFormValidated, SubmitStatus(..), TicketTypes)
import Quantity exposing (Quantity)
import RichText exposing (Inline(..), RichText(..), Shared)
import Route exposing (Route(..))
import SeqDict
import String.Nonempty
import Stripe exposing (ConversionRateStatus(..), CurrentCurrency, LocalCurrency, Price, PriceId, ProductId(..), StripeCurrency)
import Theme
import Types exposing (FrontendMsg(..), InitData2, LoadedModel)
import Ui exposing (Element)
import Ui.Font
import Ui.Input
import Ui.Lazy
import Ui.Prose
import Ui.Shadow


view : TicketTypes TicketType -> LoadedModel -> Ui.Element FrontendMsg
view ticketTypes model =
    let
        form =
            model.form
    in
    Ui.column
        [ Ui.spacing 20 ]
        [ Camp26Czech.header model
        , Ui.column
            [ Ui.htmlAttribute (Dom.idToAttribute ticketsHtmlId) ]
            (case ( Camp26Czech.detailedCountdown model.now == Nothing, model.initData ) of
                ( True, Ok initData ) ->
                    [ Ui.el
                        Theme.contentAttributes
                        (RichText.h1 model.window "Attend Elm Camp" |> Ui.html)
                    , Ui.column
                        [ Ui.spacing 32 ]
                        [ accommodationView ticketTypes initData model
                        , attendeesView initData model
                        , opportunityGrant form initData model
                        , summary ticketTypes initData model
                        , purchaseView initData model
                        ]
                    ]

                _ ->
                    []
            )
        , Theme.footer
        ]


purchaseView : InitData2 -> LoadedModel -> Element FrontendMsg
purchaseView initData model =
    let
        form =
            model.form
    in
    Ui.column
        (Ui.spacing 24 :: Theme.contentAttributes)
        [ textInput
            (Dom.id "billingEmail")
            model.form
            (\a -> FormChanged { form | billingEmail = a })
            "Billing email address"
            PurchaseForm.validateEmailAddress
            form.billingEmail
        , case form.submitStatus of
            NotSubmitted _ ->
                Ui.none

            Submitting ->
                Ui.none

            SubmitBackendError err ->
                Ui.Prose.paragraph
                    [ Ui.border 1
                    , Ui.borderColor (Ui.rgb 200 0 0)
                    , Ui.background (Ui.rgb 255 240 240)
                    , Ui.width Ui.shrink
                    , Ui.paddingXY 16 16
                    , Ui.rounded 8
                    ]
                    [ Ui.text err ]
        , RichText.view
            model
            [ Paragraph [ Text "Your order will be processed by Elm Camp's fiscal host:" ]
            , Image { source = "/sponsors/cofoundry.png", maxWidth = Just 100, caption = [] }
            , Paragraph [ Text "By purchasing you agree to the event ", Link "Code of Conduct" CodeOfConductRoute ]
            ]
        , Theme.rowToColumnWhen
            model.window
            [ Ui.spacing 16 ]
            [ submitButton form
            , Ui.Lazy.lazy2 submitFormError initData.currentCurrency.conversionRate form
            ]
        , RichText.view
            model
            [ Paragraph
                [ Text "Problem with something above? Get in touch with the team at "
                , ExternalLink "team@elm.camp" "mailto:team@elm.camp"
                , Text "."
                ]
            ]
        ]


submitButton : PurchaseForm -> Element FrontendMsg
submitButton form =
    Ui.el
        (Theme.submitButtonAttributes (Dom.id "submitForm") PressedSubmitForm True)
        (Ui.row
            [ Ui.width Ui.shrink, Ui.Font.center, Ui.Font.exactWhitespace ]
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
                    Theme.spinnerWhite

                SubmitBackendError _ ->
                    Ui.none
            ]
        )


listMoveToStart : a -> List a -> List a
listMoveToStart item list =
    if List.member item list then
        item :: List.Extra.remove item list

    else
        list


currencyDropdown : Money.Currency -> Money.Currency -> ConversionRateStatus -> Element Money.Currency
currencyDropdown stripeCurrency selected currencies =
    let
        currencies2 : List Money.Currency
        currencies2 =
            case currencies of
                LoadingConversionRate ->
                    []

                LoadedConversionRate dict ->
                    SeqDict.keys dict
                        |> List.sortBy (Money.toName { plural = False })
                        |> listMoveToStart Money.USD
                        |> listMoveToStart Money.EUR

                LoadingConversionRateFailed _ ->
                    []
    in
    Ui.column
        [ Ui.spacing 8 ]
        [ Html.select
            [ Html.Attributes.value (Money.toString selected)
            , Html.Events.onInput (\text -> Money.fromString text |> Maybe.withDefault selected)
            , Html.Attributes.style "width" "300px"
            , Html.Attributes.style "padding" "7px 8px"
            , Html.Attributes.style "font-size" "16px"
            , Html.Attributes.style "cursor" "pointer"
            ]
            (List.map
                (\currency ->
                    Html.option
                        [ Html.Attributes.value (Money.toString currency)
                        , Html.Attributes.selected (currency == selected)
                        ]
                        [ Html.text (Money.toName { plural = False } currency ++ " (" ++ Money.toString currency ++ ")") ]
                )
                currencies2
            )
            |> Ui.html
        , Ui.Prose.paragraph
            [ Ui.Font.size 14, Ui.Font.color Theme.lightTheme.mutedText ]
            [ Ui.text "Exchange rates provided by "
            , Ui.el
                [ Ui.link "https://www.exchangerate-api.com"
                , Ui.Font.underline
                , Ui.Font.color Theme.lightTheme.link
                ]
                (Ui.text "Exchange Rate API")
            , Ui.text
                (". The selected currency is for viewing purposes. "
                    ++ Money.toName { plural = False } stripeCurrency
                    ++ " ("
                    ++ Money.toString stripeCurrency
                    ++ ") will be used during the Stripe checkout step."
                )
            ]
        ]


ticketsHtmlId : HtmlId
ticketsHtmlId =
    Dom.id "tickets"


attendeesView : InitData2 -> LoadedModel -> Ui.Element FrontendMsg
attendeesView initData model =
    let
        form : PurchaseForm
        form =
            model.form

        attendeeCount : Int
        attendeeCount =
            List.length form.attendees
    in
    Ui.column
        (Ui.spacing 16 :: Theme.contentAttributes)
        [ Ui.column
            []
            [ RichText.h2 "🎟️ Attendee Details" |> Ui.html
            , Ui.text "Please enter details for each person attending Elm camp, then select your accommodation below."
            ]
        , Ui.column
            [ Ui.spacing 20 ]
            [ Ui.column [ Ui.spacing 16 ] (List.indexedMap (attendeeForm model) form.attendees)
            , if attendeeCount < 10 then
                Theme.rowToColumnWhen
                    model.window
                    [ Ui.spacing 16 ]
                    [ Ui.el
                        (Theme.normalButtonAttributes
                            (FormChanged { form | attendees = form.attendees ++ [ PurchaseForm.defaultAttendee ] })
                        )
                        (Ui.text "Add attendee")
                    , case ( form.submitStatus, PurchaseForm.validateAttendees form.count form.attendees ) of
                        ( NotSubmitted PressedSubmit, Err (Just error) ) ->
                            errorText error

                        _ ->
                            Ui.none
                    ]

              else
                Ui.none
            , Ui.Prose.paragraph
                [ Ui.width Ui.shrink, Ui.paddingXY 0 4 ]
                [ Ui.text "We collect this info so we can estimate the carbon footprint of your trip. We pay Ecologi to offset some of the environmental impact (this is already priced in and doesn't change the shown ticket price)" ]
            ]
        ]



{--| Note that accommodationView is shown after tickets are live
    It is replaced by ticketInfo before tickets are live.
--}


accommodationView : TicketTypes TicketType -> InitData2 -> LoadedModel -> Ui.Element FrontendMsg
accommodationView ticketTypes initData model =
    let
        form =
            model.form
    in
    Ui.column
        [ Ui.spacing 20 ]
        [ Ui.column
            Theme.contentAttributes
            [ RichText.h2 "🏕️ Ticket type" |> Ui.html
            , RichText.view
                model
                [ Paragraph [ Text "Please select one accommodation option per attendee." ]
                , Paragraph [ Text "There is a mix of room types — singles, doubles and dorm style rooms suitable for up to four people. Attendees will be distributed among the rooms according to the type of ticket purchased. Bathroom facilities are shared." ]
                , Paragraph [ Text "The facilities for those who wish to bring a tent or campervan and camp are excellent. The surrounding grounds and countryside are beautiful and include woodland, a swimming lake and a firepit." ]
                ]
            ]
        , List.map4
            (\ticket price count setter ->
                viewAccom count True price ticket initData
                    |> Ui.map
                        (\count2 ->
                            let
                                formCount2 : TicketTypes NonNegative
                                formCount2 =
                                    setter count2 model.form.count

                                totalTicketsPrevious : Int
                                totalTicketsPrevious =
                                    List.foldl NonNegative.add NonNegative.zero (PurchaseForm.allTicketTypes model.form.count)
                                        |> NonNegative.toInt

                                totalTickets : Int
                                totalTickets =
                                    List.foldl NonNegative.add NonNegative.zero (PurchaseForm.allTicketTypes formCount2)
                                        |> NonNegative.toInt
                            in
                            FormChanged
                                { form
                                    | count = formCount2
                                    , attendees =
                                        if totalTicketsPrevious < totalTickets then
                                            if List.length form.attendees < totalTickets then
                                                form.attendees ++ [ PurchaseForm.defaultAttendee ]

                                            else
                                                form.attendees

                                        else
                                            List.Extra.remove PurchaseForm.defaultAttendee form.attendees
                                }
                        )
            )
            (PurchaseForm.allTicketTypes ticketTypes)
            (PurchaseForm.allTicketTypes initData.prices)
            (PurchaseForm.allTicketTypes model.form.count)
            PurchaseForm.ticketTypesSetters
            |> Theme.rowToColumnWhen model.window [ Ui.spacing 16 ]
            |> Ui.el [ Ui.widthMax 1000, Ui.centerX, Ui.paddingXY 16 0 ]
        , Ui.Lazy.lazy3
            currencyDropdown
            initData.stripeCurrency
            initData.currentCurrency.currency
            model.conversionRate
            |> Ui.map SelectedCurrency
            |> Ui.el Theme.contentAttributes
        ]


viewAccom : NonNegative -> Bool -> Price -> TicketType -> InitData2 -> Ui.Element NonNegative
viewAccom count ticketAvailable price ticket2 initData =
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
        [ Ui.Prose.paragraph [ Ui.width Ui.shrink, Ui.Font.weight 600, Ui.Font.size 20 ] [ Ui.text ticket2.name ]
        , Ui.text ticket2.description
        , Ui.column
            [ Ui.alignBottom, Ui.spacing 8 ]
            [ Ui.el
                [ Ui.width Ui.shrink, Ui.Font.bold, Ui.Font.size 36 ]
                (Ui.text (localPriceTextFromStripe (Quantity.toFloatQuantity price.amount) initData.currentCurrency))
            , if ticketAvailable then
                if NonNegative.toInt count > 0 then
                    Theme.numericField
                        "Tickets"
                        (NonNegative.toInt count)
                        (\value -> Result.withDefault count (NonNegative.fromInt value))

                else
                    Ui.el
                        [ Ui.background
                            (if True then
                                Ui.rgb 92 176 126

                             else
                                Ui.rgb 137 141 137
                            )
                        , Ui.height (Ui.px 56)
                        , Ui.Font.center
                        , Ui.contentCenterY
                        , Ui.rounded 8
                        , Ui.alignBottom
                        , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 2, color = Ui.rgba 0 0 0 0.1 } ]
                        , Ui.Font.weight 600
                        , Ui.Font.color (Ui.rgb 255 255 255)
                        , Ui.Input.button NonNegative.one
                        , Ui.id ("selectTicket_" ++ ticket2.name)
                        ]
                        (Ui.text "Select")

              else if ticket2.name == "Campfire Ticket" then
                Ui.text "Waitlist"

              else
                Ui.text "Sold out!"
            ]
        ]


purchaseable ticket model =
    True


submitFormError : Quantity Float (Quantity.Rate StripeCurrency LocalCurrency) -> PurchaseForm -> Element msg
submitFormError conversionRate form =
    case ( form.submitStatus, PurchaseForm.validateForm conversionRate form ) of
        ( NotSubmitted PressedSubmit, Err error ) ->
            Ui.el [ errorFontColor ] (Ui.text error)

        _ ->
            Ui.none


attendeeForm : LoadedModel -> Int -> PurchaseForm.AttendeeForm -> Ui.Element FrontendMsg
attendeeForm model i attendee =
    let
        form =
            model.form
    in
    Theme.rowToColumnWhen
        model.window
        [ Ui.width Ui.fill, Ui.spacing 8 ]
        [ textInput
            (Dom.id ("attendeeName_" ++ String.fromInt i))
            model.form
            (\a -> FormChanged { form | attendees = List.Extra.setAt i { attendee | name = a } model.form.attendees })
            "Name"
            PurchaseForm.validateName
            attendee.name
        , textInput
            (Dom.id ("attendeeCountry_" ++ String.fromInt i))
            model.form
            (\a -> FormChanged { form | attendees = List.Extra.setAt i { attendee | country = a } model.form.attendees })
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
            (Dom.id ("attendeeCity_" ++ String.fromInt i))
            model.form
            (\a -> FormChanged { form | attendees = List.Extra.setAt i { attendee | originCity = a } model.form.attendees })
            "City/town"
            (\text ->
                case String.Nonempty.fromString text of
                    Just nonempty ->
                        Ok nonempty

                    Nothing ->
                        Err "Please type in the name of city nearest to you"
            )
            attendee.originCity
        , Ui.el
            [ Ui.background (Ui.rgb 230 40 30)
            , Ui.rounded 8
            , Ui.width (Ui.px 50)
            , Ui.height (Ui.px textInputHeight)
            , Html.Attributes.title "Remove attendee" |> Ui.htmlAttribute
            , Ui.Shadow.shadows [ { x = 0, y = 1, size = 0, blur = 2, color = Ui.rgba 0 0 0 0.1 } ]
            , Ui.alignTop
            , if Theme.isMobile model.window then
                Ui.noAttr

              else
                Ui.move { x = 0, y = 27, z = 0 }
            , Ui.Input.button
                (FormChanged { form | attendees = List.Extra.removeIfIndex (\j -> i == j) model.form.attendees })
            , Ui.Font.color (Ui.rgb 255 255 255)
            , Ui.contentCenterX
            , Ui.contentCenterY
            ]
            (Ui.html Icons.trash)
        ]


noShrink : Ui.Attribute msg
noShrink =
    Html.Attributes.style "flex-shrink" "0" |> Ui.htmlAttribute


opportunityGrant : PurchaseForm -> InitData2 -> LoadedModel -> Ui.Element FrontendMsg
opportunityGrant form initData model =
    let
        ticketPrice : Quantity Int StripeCurrency
        ticketPrice =
            initData.prices.singleRoomTicket.amount

        valueInput =
            Ui.row
                [ Ui.width (Ui.px 130), noShrink, Ui.spacing 2 ]
                [ Ui.el
                    [ noShrink, Ui.alignTop, Ui.move { x = 0, y = 7, z = 0 } ]
                    (Ui.text (Money.toNativeSymbol initData.currentCurrency.currency))
                , textInput
                    (Dom.id "opportunityGrant_textInput")
                    form
                    (\a -> FormChanged { form | grantContribution = a })
                    ""
                    PurchaseForm.validateGrantContribution
                    form.grantContribution
                ]

        slider =
            Ui.column [ Ui.width (Ui.portion 3) ]
                [ Ui.row [ Ui.width (Ui.portion 3) ]
                    [ Ui.el
                        [ Ui.width Ui.shrink, Ui.paddingXY 0 10 ]
                        (Ui.text (localPriceText Quantity.zero initData.currentCurrency))
                    , Ui.el
                        [ Ui.width Ui.shrink, Ui.paddingXY 0 10, Ui.alignRight ]
                        (Ui.text
                            (localPriceTextFromStripe
                                (Quantity.toFloatQuantity ticketPrice)
                                initData.currentCurrency
                            )
                        )
                    ]
                , sliderHorizontal
                    []
                    { onChange = \a -> FormChanged { form | grantContribution = PurchaseForm.unvalidateGrantContribution (Quantity.round a) }
                    , label = Ui.Input.labelHidden "Opportunity grant contribution value selection slider"
                    , min = Quantity.zero
                    , max = Quantity.at_ initData.currentCurrency.conversionRate (Quantity.toFloatQuantity ticketPrice)
                    , value =
                        PurchaseForm.validateGrantContribution form.grantContribution
                            |> Result.withDefault Quantity.zero
                            |> Quantity.toFloatQuantity
                    , thumb = Nothing
                    , step = Just (Quantity.unsafe 100)
                    }
                , Ui.row
                    [ Ui.width (Ui.portion 3), Ui.paddingXY 0 10 ]
                    [ Ui.el [ Ui.width Ui.shrink ] (Ui.text "No contribution")
                    , Ui.el [ Ui.width Ui.shrink, Ui.alignRight ] (Ui.text "Donate full attendance")
                    ]
                ]
    in
    Ui.column
        (Ui.spacing 20 :: Theme.contentAttributes)
        [ Ui.column
            []
            [ RichText.h2 "🫶 Opportunity grants" |> Ui.html
            , RichText.view
                model
                [ Paragraph [ Text "We want Elm Camp to reflect the diverse community of Elm users and benefit from the contribution of anyone, irrespective of financial background. We therefore rely on the support of sponsors and individual participants to lessen the financial impact on those who may otherwise have to abstain from attending." ]
                , Paragraph
                    [ Text "If you are looking to apply for an opportunity grant "
                    , LinkWithFragment "click here" Route.HomepageRoute Camp26Czech.opportunityGrant
                    , Text "."
                    ]
                ]
            ]
        , Theme.panel
            []
            [ Ui.column
                [ Ui.width Ui.shrink, Ui.spacing 16 ]
                [ Ui.Prose.paragraph
                    [ Ui.width Ui.shrink, Ui.paddingXY 0 4 ]
                    [ Ui.text "All amounts are helpful and 100% of the donation (less payment processing fees) will be put to good use supporting expenses for our grantees!" ]
                , if Theme.isMobile model.window then
                    Ui.column [ Ui.spacing 8 ] [ valueInput, slider ]

                  else
                    Ui.row [ Ui.spacing 32 ] [ valueInput, slider ]
                ]
            ]
        ]


sliderHorizontal :
    List (Ui.Attribute msg)
    ->
        { label : Ui.Input.Label
        , onChange : Quantity Float unit -> msg
        , min : Quantity Float unit
        , max : Quantity Float unit
        , value : Quantity Float unit
        , thumb : Maybe (Ui.Input.Thumb msg)
        , step : Maybe (Quantity Float unit)
        }
    -> Element msg
sliderHorizontal attributes input =
    Ui.Input.sliderHorizontal
        attributes
        { label = input.label
        , onChange = \value -> Quantity.unsafe value |> input.onChange
        , min = Quantity.unwrap input.min
        , max = Quantity.unwrap input.max
        , value = Quantity.unwrap input.value
        , thumb = input.thumb
        , step = Maybe.map Quantity.unwrap input.step
        }


summary : TicketTypes TicketType -> InitData2 -> LoadedModel -> Ui.Element msg
summary ticketTypes initData model =
    let
        grant : Result String (Quantity Int LocalCurrency)
        grant =
            PurchaseForm.validateGrantContribution model.form.grantContribution

        accomTotal : Quantity Int StripeCurrency
        accomTotal =
            List.map2
                (\price count -> Quantity.multiplyBy (NonNegative.toInt count) price.amount)
                (PurchaseForm.allTicketTypes initData.prices)
                (PurchaseForm.allTicketTypes model.form.count)
                |> Quantity.sum

        total : Quantity Float LocalCurrency
        total =
            Quantity.plus
                (Quantity.toFloatQuantity accomTotal |> Quantity.at_ initData.currentCurrency.conversionRate)
                (Result.withDefault Quantity.zero grant |> Quantity.toFloatQuantity)
    in
    Ui.column
        Theme.contentAttributes
        [ RichText.h2 "Summary" |> Ui.html
        , Ui.column
            [ Ui.spacing 8 ]
            [ Ui.text ("Attendees x " ++ String.fromInt (List.length model.form.attendees))
            , if model.form.count == PurchaseForm.initTicketCount then
                Ui.text "No accommodation bookings"

              else
                summaryAccommodation ticketTypes initData model.form.count
            , case grant of
                Err _ ->
                    Ui.none

                Ok (Quantity.Quantity 0) ->
                    Ui.none

                Ok grant2 ->
                    Ui.text ("Opportunity grant: " ++ localPriceText grant2 initData.currentCurrency)
            , "Total: "
                ++ localPriceText (Quantity.round total) initData.currentCurrency
                ++ (if initData.currentCurrency.currency == initData.stripeCurrency then
                        ""

                    else
                        " ("
                            ++ stripePriceText
                                (Quantity.at initData.currentCurrency.conversionRate total |> Quantity.round)
                                initData
                            ++ ")"
                   )
                |> Theme.h3
            ]
        ]


localPriceTextFromStripe : Quantity Float StripeCurrency -> CurrentCurrency -> String
localPriceTextFromStripe amount currentCurrency =
    let
        amount2 : Int
        amount2 =
            Quantity.at_ currentCurrency.conversionRate amount |> Quantity.unwrap |> round
    in
    Money.toNativeSymbol currentCurrency.currency ++ " " ++ formatNumber (amount2 // 100)


localPriceText : Quantity Int LocalCurrency -> CurrentCurrency -> String
localPriceText amount currentCurrency =
    Money.toNativeSymbol currentCurrency.currency ++ " " ++ formatNumber (Quantity.unwrap amount // 100)


stripePriceText : Quantity Int StripeCurrency -> InitData2 -> String
stripePriceText amount initData =
    Money.toNativeSymbol initData.stripeCurrency ++ " " ++ formatNumber (Quantity.unwrap amount // 100)


formatNumber : Int -> String
formatNumber value =
    String.fromInt value
        |> String.toList
        |> List.reverse
        |> List.Extra.greedyGroupsOf 3
        |> List.reverse
        |> List.map (\a -> List.reverse a |> String.fromList)
        |> String.join ","


summaryAccommodation : TicketTypes TicketType -> InitData2 -> TicketTypes NonNegative -> Ui.Element msg
summaryAccommodation ticketTypes initData ticketCount =
    List.map3
        (\ticket price count ->
            let
                total : Quantity Int StripeCurrency
                total =
                    Quantity.multiplyBy (NonNegative.toInt count) price.amount
            in
            if Quantity.greaterThanZero total then
                ticket.name
                    ++ " x "
                    ++ NonNegative.toString count
                    ++ " – "
                    ++ localPriceTextFromStripe (Quantity.toFloatQuantity total) initData.currentCurrency
                    |> Ui.text
                    |> Just

            else
                Nothing
        )
        (PurchaseForm.allTicketTypes ticketTypes)
        (PurchaseForm.allTicketTypes initData.prices)
        (PurchaseForm.allTicketTypes ticketCount)
        |> List.filterMap identity
        |> Ui.column [ Ui.width Ui.shrink ]


textInputHeight : number
textInputHeight =
    38


textInput : HtmlId -> PurchaseForm -> (String -> msg) -> String -> (String -> Result String value) -> String -> Ui.Element msg
textInput id form onChange title validator text =
    let
        label =
            Ui.Input.label
                (Dom.idToString id)
                [ Ui.width Ui.shrink, Ui.Font.weight 600, Ui.paddingXY 4 0 ]
                (Ui.text title)
    in
    Ui.column
        [ Ui.spacing 4, Ui.alignTop ]
        [ if title == "" then
            Ui.none

          else
            label.element
        , Ui.Input.text
            [ Ui.width Ui.shrink
            , Ui.rounded 8
            , Ui.paddingXY 12 0
            , Ui.height (Ui.px textInputHeight)
            , Ui.width Ui.fill
            , Ui.border 1
            ]
            { text = text
            , onChange = onChange
            , placeholder = Nothing
            , label = label.id
            }
        , case ( form.submitStatus, validator text ) of
            ( NotSubmitted PressedSubmit, Err error ) ->
                Ui.el [ Ui.paddingXY 4 0 ] (errorText error)

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
        , errorFontColor
        , Ui.htmlAttribute (Dom.idToAttribute errorHtmlId)
        ]
        [ Ui.text error ]


errorFontColor : Ui.Attribute msg
errorFontColor =
    Ui.Font.color (Ui.rgb 172 0 0)
