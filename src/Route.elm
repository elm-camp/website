module Route exposing (Route(..), decode, encode)

import EmailAddress exposing (EmailAddress)
import Id exposing (Id)
import Stripe exposing (StripeSessionId(..))
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query


type Route
    = HomepageRoute
    | UnconferenceFormatRoute
    | VenueAndAccessRoute
    | CodeOfConductRoute
    | ElmCampArchiveRoute
    | AdminRoute (Maybe String)
    | PaymentSuccessRoute (Maybe EmailAddress)
    | PaymentCancelRoute
    | Camp23Denmark
    | Camp24Uk
    | Camp25US
    | Camp26Czech


decode : Url -> Route
decode url =
    Url.Parser.oneOf
        [ Url.Parser.top |> Url.Parser.map HomepageRoute
        , Url.Parser.s "unconference-format" |> Url.Parser.map UnconferenceFormatRoute
        , Url.Parser.s "venue-and-access" |> Url.Parser.map VenueAndAccessRoute
        , Url.Parser.s "code-of-conduct" |> Url.Parser.map CodeOfConductRoute
        , Url.Parser.s "elm-camp-archive" |> Url.Parser.map ElmCampArchiveRoute
        , Url.Parser.s "admin" <?> parseAdminPass |> Url.Parser.map AdminRoute
        , Url.Parser.s Stripe.successPath <?> parseEmail |> Url.Parser.map PaymentSuccessRoute
        , Url.Parser.s Stripe.cancelPath |> Url.Parser.map PaymentCancelRoute

        -- Previous events
        , Url.Parser.s "23-denmark" |> Url.Parser.map Camp23Denmark
        , Url.Parser.s "24-uk" |> Url.Parser.map Camp24Uk

        -- Current event
        , Url.Parser.s "25-us" |> Url.Parser.map Camp25US
        ]
        |> (\a -> Url.Parser.parse a url |> Maybe.withDefault HomepageRoute)


parseEmail : Url.Parser.Query.Parser (Maybe EmailAddress)
parseEmail =
    Url.Parser.Query.map
        (Maybe.andThen EmailAddress.fromString)
        (Url.Parser.Query.string Stripe.emailAddressParameter)


parseAdminPass : Url.Parser.Query.Parser (Maybe String)
parseAdminPass =
    Url.Parser.Query.string "pass"


parseStripeSessionId : Url.Parser.Query.Parser (Maybe (Id StripeSessionId))
parseStripeSessionId =
    Url.Parser.Query.map (Maybe.map Id.fromString) (Url.Parser.Query.string Stripe.stripeSessionIdParameter)


encode : Maybe String -> Route -> String
encode fragment route =
    Url.Builder.absolute
        (case route of
            HomepageRoute ->
                []

            UnconferenceFormatRoute ->
                [ "unconference-format" ]

            VenueAndAccessRoute ->
                [ "venue-and-access" ]

            CodeOfConductRoute ->
                [ "code-of-conduct" ]

            ElmCampArchiveRoute ->
                [ "elm-camp-archive" ]

            AdminRoute _ ->
                [ "admin" ]

            PaymentSuccessRoute _ ->
                [ Stripe.successPath ]

            PaymentCancelRoute ->
                [ Stripe.cancelPath ]

            Camp23Denmark ->
                [ "23-denmark" ]

            Camp24Uk ->
                [ "24-uk" ]

            Camp25US ->
                [ "25-us" ]

            Camp26Czech ->
                [ "26-czech" ]
        )
        (case route of
            HomepageRoute ->
                []

            UnconferenceFormatRoute ->
                []

            VenueAndAccessRoute ->
                []

            CodeOfConductRoute ->
                []

            ElmCampArchiveRoute ->
                []

            AdminRoute _ ->
                []

            PaymentSuccessRoute maybeEmailAddress ->
                case maybeEmailAddress of
                    Just emailAddress ->
                        [ Url.Builder.string Stripe.emailAddressParameter (EmailAddress.toString emailAddress) ]

                    Nothing ->
                        []

            PaymentCancelRoute ->
                []

            Camp23Denmark ->
                []

            Camp24Uk ->
                []

            Camp25US ->
                []

            Camp26Czech ->
                []
        )
        ++ (case fragment of
                Just fragment2 ->
                    "#" ++ fragment2

                Nothing ->
                    ""
           )
