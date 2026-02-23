module OpportunityGrant exposing (emailHtmlId, messageHtmlId, submitHtmlId, view)

import Camp26Czech
import Effect.Browser.Dom as Dom exposing (HtmlId)
import Html.Attributes
import PurchaseForm
import RichText
import Theme
import Types exposing (FrontendMsg(..), LoadedModel, OpportunityGrantForm, OpportunityGrantPressedSubmit(..), OpportunityGrantSubmitStatus(..))
import Ui exposing (Element)
import Ui.Font
import Ui.Input
import Ui.Prose


view : LoadedModel -> Element FrontendMsg
view model =
    Ui.column
        [ Ui.spacing 20, Ui.height Ui.fill ]
        [ Camp26Czech.header model
        , Ui.column
            (Theme.contentAttributes ++ [ Ui.spacing 32, Ui.paddingXY 16 24 ])
            [ RichText.h1 model.window "Opportunity grant application" |> Ui.html
            , intro
            , grantForm model.opportunityGrantForm
            ]
        , Theme.footer
        ]


intro : Element FrontendMsg
intro =
    Ui.column
        [ Ui.spacing 18 ]
        [ Ui.Prose.paragraph
            [ Ui.width Ui.fill ]
            [ Ui.text "Elm Camp is committed to making the event accessible to everyone. "
            , Ui.text "If the cost of attendance is a barrier for you or if you "
            , Ui.text "come from an under-represented group in tech, we invite you "
            , Ui.text "to apply for an opportunity grant. If you're not sure whether "
            , Ui.text "this applies to you, it probably does! "
            ]
        , Ui.Prose.paragraph
            [ Ui.width Ui.fill ]
            [ Ui.text "Opportunity grants cover the cost of a ticket to Elm Camp, but "
            , Ui.text "the exact ticket type depends on the number of applicants, "
            , Ui.text "the amount of funding we have available, and the specific "
            , Ui.text "needs of each applicant."
            ]
        , Ui.Prose.paragraph
            [ Ui.width Ui.fill ]
            [ Ui.text "To apply, just provide your email address. If there's anything "
            , Ui.text "else you'd like us to know, you can share that too, but it's "
            , Ui.text "not required."
            ]
        ]


grantForm : OpportunityGrantForm -> Element FrontendMsg
grantForm form =
    let
        isSubmitting =
            form.submitStatus == OpportunityGrantSubmitting

        pressedSubmit =
            form.submitStatus == OpportunityGrantNotSubmitted OpportunityGrantPressedSubmit
    in
    case form.submitStatus of
        OpportunityGrantSubmitBackendError err ->
            Ui.column
                [ Ui.spacing 24 ]
                [ formFields form pressedSubmit isSubmitting
                , Ui.Prose.paragraph
                    [ Ui.border 1
                    , Ui.borderColor (Ui.rgb 200 0 0)
                    , Ui.background (Ui.rgb 255 240 240)
                    , Ui.width Ui.fill
                    , Ui.paddingXY 16 16
                    , Ui.rounded 8
                    ]
                    [ Ui.text err ]
                , submitButton isSubmitting
                ]

        OpportunityGrantSubmittedSuccessfully ->
            Ui.column
                [ Ui.spacing 24 ]
                [ formFields form pressedSubmit isSubmitting
                , submitButton isSubmitting
                , Ui.Prose.paragraph
                    [ Ui.Font.size 14
                    , Ui.Font.color (Ui.rgb 0 128 0)
                    , Ui.paddingXY 4 0
                    ]
                    [ Ui.text "Thank you! We've received your application and will be in touch." ]
                ]

        _ ->
            Ui.column
                [ Ui.spacing 24 ]
                [ formFields form pressedSubmit isSubmitting
                , submitButton isSubmitting
                ]


formFields : OpportunityGrantForm -> Bool -> Bool -> Element FrontendMsg
formFields form pressedSubmit isSubmitting =
    Ui.column
        [ Ui.spacing 20, Ui.width Ui.fill ]
        [ emailField form pressedSubmit isSubmitting
        , messageField form isSubmitting
        ]


emailField : OpportunityGrantForm -> Bool -> Bool -> Element FrontendMsg
emailField form pressedSubmit isSubmitting =
    let
        labelEl =
            Ui.Input.label
                (Dom.idToString emailHtmlId)
                [ Ui.width Ui.shrink, Ui.Font.weight 600, Ui.paddingXY 4 0 ]
                (Ui.text "Email address")

        validationError =
            if pressedSubmit then
                case PurchaseForm.validateEmailAddress form.email of
                    Err err ->
                        Ui.el
                            [ Ui.paddingXY 4 0 ]
                            (Ui.Prose.paragraph
                                [ Ui.width Ui.shrink
                                , Ui.Font.color (Ui.rgb 172 0 0)
                                ]
                                [ Ui.text err ]
                            )

                    Ok _ ->
                        Ui.none

            else
                Ui.none
    in
    Ui.column
        [ Ui.spacing 4, Ui.width Ui.fill ]
        [ labelEl.element
        , Ui.Input.text
            [ Ui.id (Dom.idToString emailHtmlId)
            , Ui.width Ui.fill
            , Ui.rounded 8
            , Ui.paddingXY 12 0
            , Ui.height (Ui.px 38)
            , Ui.border 1
            , if isSubmitting then
                Ui.htmlAttribute (Html.Attributes.disabled True)

              else
                Theme.attr "opacity" "1"
            ]
            { text = form.email
            , onChange =
                \val ->
                    OpportunityGrantFormChanged { form | email = val }
            , placeholder = Just "you@example.com"
            , label = labelEl.id
            }
        , validationError
        ]


messageField : OpportunityGrantForm -> Bool -> Element FrontendMsg
messageField form isSubmitting =
    let
        labelEl =
            Ui.Input.label
                (Dom.idToString messageHtmlId)
                [ Ui.width Ui.shrink, Ui.Font.weight 600, Ui.paddingXY 4 0 ]
                (Ui.text "Anything we need to know? (optional)")
    in
    Ui.column
        [ Ui.spacing 8, Ui.width Ui.fill ]
        [ labelEl.element
        , Ui.Prose.paragraph
            [ Ui.Font.size 14
            , Ui.Font.color Theme.lightTheme.mutedText
            , Ui.paddingXY 4 0
            ]
            [ Ui.text "You can use this section to let us know anything you think "
            , Ui.text "might be important. For example, you might let us know if "
            , Ui.text "you are happy to camp or if you would only feel comfortable "
            , Ui.text "sharing a room with someone of a particular gender."
            ]
        , Ui.Input.multiline
            [ Ui.id (Dom.idToString messageHtmlId)
            , Ui.width Ui.fill
            , Ui.rounded 8
            , Ui.paddingXY 12 10
            , Ui.height (Ui.px 160)
            , Ui.border 1
            , if isSubmitting then
                Ui.htmlAttribute (Html.Attributes.disabled True)

              else
                Theme.attr "opacity" "1"
            ]
            { text = form.message
            , onChange =
                \val ->
                    OpportunityGrantFormChanged { form | message = val }
            , placeholder = Nothing
            , label = labelEl.id
            , spellcheck = True
            }
        , Ui.Prose.paragraph
            [ Ui.Font.size 14
            , Ui.Font.color Theme.lightTheme.mutedText
            , Ui.paddingXY 4 0
            ]
            [ Ui.el [ Ui.Font.underline ] (Ui.text "You do not need to fill this in.")
            , Ui.text " An email address alone is enough to apply and we will never"
            , Ui.text " turn someone away for not providing more information."
            ]
        ]


emailHtmlId : HtmlId
emailHtmlId =
    Dom.id "opportunityGrantEmail"


messageHtmlId : HtmlId
messageHtmlId =
    Dom.id "opportunityGrantMessage"


submitHtmlId : HtmlId
submitHtmlId =
    Dom.id "submitOpportunityGrant"


submitButton : Bool -> Element FrontendMsg
submitButton isSubmitting =
    Ui.el
        (Theme.submitButtonAttributes submitHtmlId PressedSubmitOpportunityGrant (not isSubmitting))
        (Ui.row
            [ Ui.width Ui.shrink, Ui.Font.center, Ui.Font.exactWhitespace ]
            [ Ui.text "Submit application "
            , if isSubmitting then
                Theme.spinnerWhite

              else
                Ui.none
            ]
        )
