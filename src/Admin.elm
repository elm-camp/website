module Admin exposing
    ( attendees
    , quickTable
    , view
    , viewAdmin
    , viewExpiredOrders
    , viewOrder
    , viewOrders
    )

import Env
import Fusion
import Fusion.Editor
import Fusion.Generated.TypeDict
import Fusion.Generated.TypeDict.Types
import Html
import Id exposing (Id)
import Name
import SeqDict exposing (SeqDict)
import String.Nonempty
import Stripe exposing (Price, PriceData, PriceId, ProductId, StripeSessionId)
import Theme
import Types exposing (BackendModel, FrontendMsg(..), LoadedModel, ReplaceBackendModelStatus(..), TicketsEnabled(..))
import Ui
import Ui.Font
import Ui.Input


view : LoadedModel -> Ui.Element FrontendMsg
view model =
    case model.backendModel of
        Just ( backendModel, value ) ->
            viewAdmin backendModel value model

        Nothing ->
            Ui.text "loading"


viewAdmin : BackendModel -> Fusion.Value -> LoadedModel -> Ui.Element FrontendMsg
viewAdmin backendModel value model =
    let
        numberOfOrders =
            List.length (SeqDict.toList backendModel.orders)

        numberOfPendingOrders =
            List.length (SeqDict.toList backendModel.pendingOrders)

        numberOfExpiredOrders =
            List.length (SeqDict.toList backendModel.expiredOrders)

        info : String
        info =
            "Orders (completed, pending, expired): "
                ++ (List.map String.fromInt [ numberOfOrders, numberOfPendingOrders, numberOfExpiredOrders ] |> String.join ", ")

        backendModelJsonLabel : { element : Ui.Element msg, id : Ui.Input.Label }
        backendModelJsonLabel =
            Ui.Input.label "backendModelJsonInput" [] (Ui.text "Backend model json")
    in
    Ui.column
        [ Ui.padding 24
        , Ui.spacing 40
        , Ui.background (Ui.rgb 200 200 200)
        ]
        [ Ui.el [ Ui.width Ui.shrink, Ui.Font.size 18 ] (Ui.text "Admin")
        , Ui.column
            [ Ui.contentBottom, Ui.spacing 8 ]
            [ Ui.column
                []
                [ backendModelJsonLabel.element
                , Ui.Input.text
                    [ Ui.height (Ui.px 40) ]
                    { onChange = TypedBackendModelJson
                    , text = Result.withDefault "" model.backendModelJson
                    , placeholder = Nothing
                    , label = backendModelJsonLabel.id
                    }
                ]
            , Ui.row
                [ Ui.spacing 8 ]
                [ button PressedDownloadBackendModelJson "Load backend model json"
                , case model.backendModelJson of
                    Ok "" ->
                        Ui.none

                    Ok _ ->
                        button PressedUploadBackendModelJson "Upload backend model"

                    Err () ->
                        Ui.none
                , case model.replaceBackendModelStatus of
                    NotReplacingBackendModel ->
                        Ui.none

                    ReplacingBackendModel ->
                        Ui.text "Uploading..."

                    ReplacedBackendModel ->
                        Ui.text "Uploaded!"

                    FailedToReplaceBackendModel string ->
                        Ui.el [ Ui.Font.color Theme.colors.red ] (Ui.text string)
                ]
            ]
        , Ui.el [ Ui.width Ui.shrink, Ui.Font.size 18 ] (Ui.text info)
        , viewOrders backendModel.orders
        , viewExpiredOrders backendModel.expiredOrders
        , Fusion.Editor.value
            { typeDict = Fusion.Generated.TypeDict.typeDict
            , type_ = Just Fusion.Generated.TypeDict.Types.type_BackendModel
            , editMsg = FusionPatch
            , queryMsg = \_ -> FusionQuery
            }
            value
            |> Ui.html
        ]


button onPress text =
    Ui.el
        [ Ui.Input.button onPress
        , Ui.background (Ui.rgb 190 255 200)
        , Ui.contentCenterY
        , Ui.width Ui.shrink
        , Ui.height (Ui.px 40)
        , Ui.paddingXY 8 0
        ]
        (Ui.text text)


viewOrders : SeqDict (Id StripeSessionId) Types.CompletedOrder -> Ui.Element msg
viewOrders orders =
    Ui.column
        [ Ui.spacing 12
        ]
        (orders |> SeqDict.toList |> List.indexedMap viewOrder)


viewExpiredOrders : SeqDict (Id StripeSessionId) Types.PendingOrder -> Ui.Element msg
viewExpiredOrders orders =
    let
        n =
            orders |> SeqDict.toList |> List.length
    in
    Ui.column
        [ Ui.spacing 12
        ]
        ([ Ui.el [ Ui.width Ui.shrink ] (Ui.text ("Expired orders (incorrectly marked expired due to postback issues): " ++ String.fromInt n))
         , quickTable (orders |> SeqDict.values)
            [ \order -> List.map (\a -> Name.toString a.name) order.form.attendees |> String.join ", "

            --, \order -> toString order.form.accommodationBookings
            -- , .form >> .grantApply >> Debug.toString
            -- , .form >> .grantContribution >> Debug.toString
            , \order -> List.map (\a -> String.Nonempty.toString a.country) order.form.attendees |> String.join ", "
            ]
         ]
         -- ++ (orders |> SeqDict.toList |> List.indexedMap viewPendingOrder)
        )


quickTable : List a -> List (a -> String) -> Ui.Element msg
quickTable collection fns =
    -- Because Element.table copy/paste doesn't do table formatting in GDocs
    collection
        |> List.map
            (\item ->
                fns
                    |> List.map
                        (\fn ->
                            Html.td [] [ Html.text (fn item) ]
                        )
                    |> Html.tr []
            )
        |> Html.table []
        |> Ui.html


viewOrder : Int -> ( Id StripeSessionId, Types.CompletedOrder ) -> Ui.Element msg
viewOrder idx ( id, order ) =
    Ui.row
        [ Ui.Font.size 14, Ui.spacing 12 ]
        [ Ui.el [ Ui.width Ui.shrink ] (Ui.text (String.fromInt idx))
        , Ui.el [ Ui.width Ui.shrink ] (Ui.text (String.join ", " (attendees order)))
        ]


attendees : Types.CompletedOrder -> List String
attendees order =
    List.map (\a -> Name.toString a.name) order.form.attendees
