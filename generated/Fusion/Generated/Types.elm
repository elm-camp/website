module Fusion.Generated.Types exposing
    ( build_BackendModel, build_CompletedOrder, build_EmailResult, build_PendingOrder, build_TicketPriceStatus, build_TicketsEnabled
    , build_adminMessage, patch_BackendModel, patch_CompletedOrder, patch_EmailResult, patch_PendingOrder, patch_TicketPriceStatus, patch_TicketsEnabled
    , patch_adminMessage, patcher_BackendModel, patcher_CompletedOrder, patcher_EmailResult, patcher_PendingOrder, patcher_TicketPriceStatus, patcher_TicketsEnabled
    , patcher_adminMessage, query_BackendModel, query_CompletedOrder, query_EmailResult, query_PendingOrder, query_TicketPriceStatus, query_TicketsEnabled
    , query_adminMessage, toValue_BackendModel, toValue_CompletedOrder, toValue_EmailResult, toValue_PendingOrder, toValue_TicketPriceStatus, toValue_TicketsEnabled
    , toValue_adminMessage
    )

{-|
@docs build_BackendModel, build_CompletedOrder, build_EmailResult, build_PendingOrder, build_TicketPriceStatus, build_TicketsEnabled
@docs build_adminMessage, patch_BackendModel, patch_CompletedOrder, patch_EmailResult, patch_PendingOrder, patch_TicketPriceStatus
@docs patch_TicketsEnabled, patch_adminMessage, patcher_BackendModel, patcher_CompletedOrder, patcher_EmailResult, patcher_PendingOrder
@docs patcher_TicketPriceStatus, patcher_TicketsEnabled, patcher_adminMessage, query_BackendModel, query_CompletedOrder, query_EmailResult
@docs query_PendingOrder, query_TicketPriceStatus, query_TicketsEnabled, query_adminMessage, toValue_BackendModel, toValue_CompletedOrder
@docs toValue_EmailResult, toValue_PendingOrder, toValue_TicketPriceStatus, toValue_TicketsEnabled, toValue_adminMessage
-}


import Dict
import Fusion
import Fusion.Effect.Lamdera
import Fusion.Generated.Effect.Http
import Fusion.Generated.Effect.Time
import Fusion.Generated.Id
import Fusion.Generated.Money
import Fusion.Generated.Postmark
import Fusion.Generated.PurchaseForm
import Fusion.Generated.Stripe
import Fusion.Patch
import Fusion.SeqDict
import Result.Extra
import Types


build_BackendModel :
    Fusion.Value -> Result Fusion.Patch.Error Types.BackendModel
build_BackendModel value =
    Fusion.Patch.build_Record
        (\build_RecordUnpack ->
             Result.Ok
                 (\orders pendingOrder expiredOrders prices time ticketsEnabled ->
                      { orders = orders
                      , pendingOrder = pendingOrder
                      , expiredOrders = expiredOrders
                      , prices = prices
                      , time = time
                      , ticketsEnabled = ticketsEnabled
                      }
                 ) |> Result.Extra.andMap
                              (Result.andThen
                                       (Fusion.SeqDict.build_SeqDict
                                                (Fusion.Generated.Id.patcher_Id
                                                         Fusion.Generated.Stripe.patcher_StripeSessionId
                                                )
                                                patcher_CompletedOrder
                                       )
                                       (build_RecordUnpack "orders")
                              ) |> Result.Extra.andMap
                                           (Result.andThen
                                                    (Fusion.SeqDict.build_SeqDict
                                                             (Fusion.Generated.Id.patcher_Id
                                                                      Fusion.Generated.Stripe.patcher_StripeSessionId
                                                             )
                                                             patcher_PendingOrder
                                                    )
                                                    (build_RecordUnpack
                                                             "pendingOrder"
                                                    )
                                           ) |> Result.Extra.andMap
                                                        (Result.andThen
                                                                 (Fusion.SeqDict.build_SeqDict
                                                                          (Fusion.Generated.Id.patcher_Id
                                                                                   Fusion.Generated.Stripe.patcher_StripeSessionId
                                                                          )
                                                                          patcher_PendingOrder
                                                                 )
                                                                 (build_RecordUnpack
                                                                          "expiredOrders"
                                                                 )
                                                        ) |> Result.Extra.andMap
                                                                     (Result.andThen
                                                                              build_TicketPriceStatus
                                                                              (build_RecordUnpack
                                                                                       "prices"
                                                                              )
                                                                     ) |> Result.Extra.andMap
                                                                                  (Result.andThen
                                                                                           Fusion.Generated.Effect.Time.build_Posix
                                                                                           (build_RecordUnpack
                                                                                                    "time"
                                                                                           )
                                                                                  ) |> Result.Extra.andMap
                                                                                               (Result.andThen
                                                                                                        build_TicketsEnabled
                                                                                                        (build_RecordUnpack
                                                                                                                 "ticketsEnabled"
                                                                                                        )
                                                                                               )
        )
        value


build_CompletedOrder :
    Fusion.Value -> Result Fusion.Patch.Error Types.CompletedOrder
build_CompletedOrder value =
    Fusion.Patch.build_Record
        (\build_RecordUnpack ->
             Result.map3
                 (\submitTime form emailResult ->
                      { submitTime = submitTime
                      , form = form
                      , emailResult = emailResult
                      }
                 )
                 (Result.andThen
                      Fusion.Generated.Effect.Time.build_Posix
                      (build_RecordUnpack "submitTime")
                 )
                 (Result.andThen
                      Fusion.Generated.PurchaseForm.build_PurchaseFormValidated
                      (build_RecordUnpack "form")
                 )
                 (Result.andThen
                      build_EmailResult
                      (build_RecordUnpack "emailResult")
                 )
        )
        value


build_EmailResult : Fusion.Value -> Result Fusion.Patch.Error Types.EmailResult
build_EmailResult value =
    Fusion.Patch.build_Custom
        (\name params ->
             case ( name, params ) of
                 ( "SendingEmail", [] ) ->
                     Result.Ok Types.SendingEmail

                 ( "EmailSuccess", [] ) ->
                     Result.Ok Types.EmailSuccess

                 ( "EmailFailed", [ patch0 ] ) ->
                     Result.map
                         Types.EmailFailed
                         (Fusion.Generated.Postmark.build_SendEmailError patch0)

                 _ ->
                     Result.Err
                         (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


build_PendingOrder :
    Fusion.Value -> Result Fusion.Patch.Error Types.PendingOrder
build_PendingOrder value =
    Fusion.Patch.build_Record
        (\build_RecordUnpack ->
             Result.map3
                 (\submitTime form sessionId ->
                      { submitTime = submitTime
                      , form = form
                      , sessionId = sessionId
                      }
                 )
                 (Result.andThen
                      Fusion.Generated.Effect.Time.build_Posix
                      (build_RecordUnpack "submitTime")
                 )
                 (Result.andThen
                      Fusion.Generated.PurchaseForm.build_PurchaseFormValidated
                      (build_RecordUnpack "form")
                 )
                 (Result.andThen
                      Fusion.Effect.Lamdera.build_SessionId
                      (build_RecordUnpack "sessionId")
                 )
        )
        value


build_TicketPriceStatus :
    Fusion.Value -> Result Fusion.Patch.Error Types.TicketPriceStatus
build_TicketPriceStatus value =
    Fusion.Patch.build_Custom
        (\name params ->
             case ( name, params ) of
                 ( "NotLoadingTicketPrices", [] ) ->
                     Result.Ok Types.NotLoadingTicketPrices

                 ( "LoadingTicketPrices", [] ) ->
                     Result.Ok Types.LoadingTicketPrices

                 ( "LoadedTicketPrices", [ patch0, patch1 ] ) ->
                     Result.map2
                         Types.LoadedTicketPrices
                         (Fusion.Generated.Money.build_Currency patch0)
                         ((Fusion.Generated.PurchaseForm.build_TicketTypes
                               Fusion.Generated.Stripe.patcher_Price
                          )
                              patch1
                         )

                 ( "FailedToLoadTicketPrices", [ patch0 ] ) ->
                     Result.map
                         Types.FailedToLoadTicketPrices
                         (Fusion.Generated.Effect.Http.build_Error patch0)

                 ( "TicketCurrenciesDoNotMatch", [] ) ->
                     Result.Ok Types.TicketCurrenciesDoNotMatch

                 _ ->
                     Result.Err
                         (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


build_TicketsEnabled :
    Fusion.Value -> Result Fusion.Patch.Error Types.TicketsEnabled
build_TicketsEnabled value =
    Fusion.Patch.build_Custom
        (\name params ->
             case ( name, params ) of
                 ( "TicketsEnabled", [] ) ->
                     Result.Ok Types.TicketsEnabled

                 ( "TicketsDisabled", [ patch0 ] ) ->
                     Result.map
                         Types.TicketsDisabled
                         (Fusion.Patch.build_Record
                              (\build_RecordUnpack ->
                                   Result.map
                                       (\adminMessage ->
                                            { adminMessage = adminMessage }
                                       )
                                       (Result.andThen
                                            Fusion.Patch.build_String
                                            (build_RecordUnpack "adminMessage")
                                       )
                              )
                              patch0
                         )

                 _ ->
                     Result.Err
                         (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


build_adminMessage :
    Fusion.Value -> Result Fusion.Patch.Error { adminMessage : String }
build_adminMessage value =
    Fusion.Patch.build_Record
        (\build_RecordUnpack ->
             Result.map
                 (\adminMessage -> { adminMessage = adminMessage })
                 (Result.andThen
                      Fusion.Patch.build_String
                      (build_RecordUnpack "adminMessage")
                 )
        )
        value


patch_BackendModel :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Types.BackendModel
    -> Result Fusion.Patch.Error Types.BackendModel
patch_BackendModel options patch value =
    Fusion.Patch.patch_Record
        (\fieldName fieldPatch acc ->
             case fieldName of
                 "orders" ->
                     Result.map
                         (\orders -> { acc | orders = orders })
                         ((Fusion.SeqDict.patch_SeqDict
                               (Fusion.Generated.Id.patcher_Id
                                    Fusion.Generated.Stripe.patcher_StripeSessionId
                               )
                               patcher_CompletedOrder
                          )
                              options
                              fieldPatch
                              acc.orders
                         )

                 "pendingOrder" ->
                     Result.map
                         (\pendingOrder -> { acc | pendingOrder = pendingOrder }
                         )
                         ((Fusion.SeqDict.patch_SeqDict
                               (Fusion.Generated.Id.patcher_Id
                                    Fusion.Generated.Stripe.patcher_StripeSessionId
                               )
                               patcher_PendingOrder
                          )
                              options
                              fieldPatch
                              acc.pendingOrder
                         )

                 "expiredOrders" ->
                     Result.map
                         (\expiredOrders ->
                              { acc | expiredOrders = expiredOrders }
                         )
                         ((Fusion.SeqDict.patch_SeqDict
                               (Fusion.Generated.Id.patcher_Id
                                    Fusion.Generated.Stripe.patcher_StripeSessionId
                               )
                               patcher_PendingOrder
                          )
                              options
                              fieldPatch
                              acc.expiredOrders
                         )

                 "prices" ->
                     Result.map
                         (\prices -> { acc | prices = prices })
                         (patch_TicketPriceStatus options fieldPatch acc.prices)

                 "time" ->
                     Result.map
                         (\time -> { acc | time = time })
                         (Fusion.Generated.Effect.Time.patch_Posix
                              options
                              fieldPatch
                              acc.time
                         )

                 "ticketsEnabled" ->
                     Result.map
                         (\ticketsEnabled ->
                              { acc | ticketsEnabled = ticketsEnabled }
                         )
                         (patch_TicketsEnabled
                              options
                              fieldPatch
                              acc.ticketsEnabled
                         )

                 _ ->
                     Result.Err (Fusion.Patch.UnexpectedField fieldName)
        )
        patch
        value


patch_CompletedOrder :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Types.CompletedOrder
    -> Result Fusion.Patch.Error Types.CompletedOrder
patch_CompletedOrder options patch value =
    Fusion.Patch.patch_Record
        (\fieldName fieldPatch acc ->
             case fieldName of
                 "submitTime" ->
                     Result.map
                         (\submitTime -> { acc | submitTime = submitTime })
                         (Fusion.Generated.Effect.Time.patch_Posix
                              options
                              fieldPatch
                              acc.submitTime
                         )

                 "form" ->
                     Result.map
                         (\form -> { acc | form = form })
                         (Fusion.Generated.PurchaseForm.patch_PurchaseFormValidated
                              options
                              fieldPatch
                              acc.form
                         )

                 "emailResult" ->
                     Result.map
                         (\emailResult -> { acc | emailResult = emailResult })
                         (patch_EmailResult options fieldPatch acc.emailResult)

                 _ ->
                     Result.Err (Fusion.Patch.UnexpectedField fieldName)
        )
        patch
        value


patch_EmailResult :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Types.EmailResult
    -> Result Fusion.Patch.Error Types.EmailResult
patch_EmailResult options patch value =
    let
        isCorrectVariant expected =
            case ( value, expected ) of
                ( Types.SendingEmail, "SendingEmail" ) ->
                    True

                ( Types.EmailSuccess, "EmailSuccess" ) ->
                    True

                ( Types.EmailFailed _, "EmailFailed" ) ->
                    True

                _ ->
                    False
    in
    case ( value, patch, options.force ) of
        ( Types.SendingEmail, Fusion.Patch.PCustomSame "SendingEmail" [], _ ) ->
            Result.Ok Types.SendingEmail

        ( _, Fusion.Patch.PCustomSame "SendingEmail" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SendingEmail" [], _ ) ->
            Result.Ok Types.SendingEmail

        ( Types.EmailSuccess, Fusion.Patch.PCustomSame "EmailSuccess" [], _ ) ->
            Result.Ok Types.EmailSuccess

        ( _, Fusion.Patch.PCustomSame "EmailSuccess" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "EmailSuccess" [], _ ) ->
            Result.Ok Types.EmailSuccess

        ( Types.EmailFailed arg0, Fusion.Patch.PCustomSame "EmailFailed" [ patch0 ], _ ) ->
            Result.map
                Types.EmailFailed
                (Fusion.Patch.maybeApply
                     Fusion.Generated.Postmark.patcher_SendEmailError
                     options
                     patch0
                     arg0
                )

        ( _, Fusion.Patch.PCustomSame "EmailFailed" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "EmailFailed" [ (Just patch0) ], _ ) ->
            Result.map
                Types.EmailFailed
                (Fusion.Patch.buildFromPatch
                     Fusion.Generated.Postmark.build_SendEmailError
                     patch0
                )

        ( _, Fusion.Patch.PCustomSame "EmailFailed" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        ( _, Fusion.Patch.PCustomChange expectedVariant "SendingEmail" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Types.SendingEmail

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "EmailSuccess" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Types.EmailSuccess

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "EmailFailed" [ arg0 ], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.map
                    Types.EmailFailed
                    (Fusion.Generated.Postmark.build_SendEmailError arg0)

            else
                Result.Err Fusion.Patch.Conflict

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patch_PendingOrder :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Types.PendingOrder
    -> Result Fusion.Patch.Error Types.PendingOrder
patch_PendingOrder options patch value =
    Fusion.Patch.patch_Record
        (\fieldName fieldPatch acc ->
             case fieldName of
                 "submitTime" ->
                     Result.map
                         (\submitTime -> { acc | submitTime = submitTime })
                         (Fusion.Generated.Effect.Time.patch_Posix
                              options
                              fieldPatch
                              acc.submitTime
                         )

                 "form" ->
                     Result.map
                         (\form -> { acc | form = form })
                         (Fusion.Generated.PurchaseForm.patch_PurchaseFormValidated
                              options
                              fieldPatch
                              acc.form
                         )

                 "sessionId" ->
                     Result.map
                         (\sessionId -> { acc | sessionId = sessionId })
                         (Fusion.Effect.Lamdera.patch_SessionId
                              options
                              fieldPatch
                              acc.sessionId
                         )

                 _ ->
                     Result.Err (Fusion.Patch.UnexpectedField fieldName)
        )
        patch
        value


patch_TicketPriceStatus :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Types.TicketPriceStatus
    -> Result Fusion.Patch.Error Types.TicketPriceStatus
patch_TicketPriceStatus options patch value =
    let
        isCorrectVariant expected =
            case ( value, expected ) of
                ( Types.NotLoadingTicketPrices, "NotLoadingTicketPrices" ) ->
                    True

                ( Types.LoadingTicketPrices, "LoadingTicketPrices" ) ->
                    True

                ( Types.LoadedTicketPrices _ _, "LoadedTicketPrices" ) ->
                    True

                ( Types.FailedToLoadTicketPrices _, "FailedToLoadTicketPrices" ) ->
                    True

                ( Types.TicketCurrenciesDoNotMatch, "TicketCurrenciesDoNotMatch" ) ->
                    True

                _ ->
                    False
    in
    case ( value, patch, options.force ) of
        ( Types.NotLoadingTicketPrices, Fusion.Patch.PCustomSame "NotLoadingTicketPrices" [], _ ) ->
            Result.Ok Types.NotLoadingTicketPrices

        ( _, Fusion.Patch.PCustomSame "NotLoadingTicketPrices" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "NotLoadingTicketPrices" [], _ ) ->
            Result.Ok Types.NotLoadingTicketPrices

        ( Types.LoadingTicketPrices, Fusion.Patch.PCustomSame "LoadingTicketPrices" [], _ ) ->
            Result.Ok Types.LoadingTicketPrices

        ( _, Fusion.Patch.PCustomSame "LoadingTicketPrices" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "LoadingTicketPrices" [], _ ) ->
            Result.Ok Types.LoadingTicketPrices

        ( Types.LoadedTicketPrices arg0 arg1, Fusion.Patch.PCustomSame "LoadedTicketPrices" [ patch0, patch1 ], _ ) ->
            Result.map2
                Types.LoadedTicketPrices
                (Fusion.Patch.maybeApply
                     Fusion.Generated.Money.patcher_Currency
                     options
                     patch0
                     arg0
                )
                (Fusion.Patch.maybeApply
                     (Fusion.Generated.PurchaseForm.patcher_TicketTypes
                          Fusion.Generated.Stripe.patcher_Price
                     )
                     options
                     patch1
                     arg1
                )

        ( _, Fusion.Patch.PCustomSame "LoadedTicketPrices" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "LoadedTicketPrices" [ (Just patch0), (Just patch1) ], _ ) ->
            Result.map2
                Types.LoadedTicketPrices
                (Fusion.Patch.buildFromPatch
                     Fusion.Generated.Money.build_Currency
                     patch0
                )
                (Fusion.Patch.buildFromPatch
                     (Fusion.Generated.PurchaseForm.build_TicketTypes
                          Fusion.Generated.Stripe.patcher_Price
                     )
                     patch1
                )

        ( _, Fusion.Patch.PCustomSame "LoadedTicketPrices" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( Types.FailedToLoadTicketPrices arg0, Fusion.Patch.PCustomSame "FailedToLoadTicketPrices" [ patch0 ], _ ) ->
            Result.map
                Types.FailedToLoadTicketPrices
                (Fusion.Patch.maybeApply
                     Fusion.Generated.Effect.Http.patcher_Error
                     options
                     patch0
                     arg0
                )

        ( _, Fusion.Patch.PCustomSame "FailedToLoadTicketPrices" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "FailedToLoadTicketPrices" [ (Just patch0) ], _ ) ->
            Result.map
                Types.FailedToLoadTicketPrices
                (Fusion.Patch.buildFromPatch
                     Fusion.Generated.Effect.Http.build_Error
                     patch0
                )

        ( _, Fusion.Patch.PCustomSame "FailedToLoadTicketPrices" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( Types.TicketCurrenciesDoNotMatch, Fusion.Patch.PCustomSame "TicketCurrenciesDoNotMatch" [], _ ) ->
            Result.Ok Types.TicketCurrenciesDoNotMatch

        ( _, Fusion.Patch.PCustomSame "TicketCurrenciesDoNotMatch" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TicketCurrenciesDoNotMatch" [], _ ) ->
            Result.Ok Types.TicketCurrenciesDoNotMatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        ( _, Fusion.Patch.PCustomChange expectedVariant "NotLoadingTicketPrices" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Types.NotLoadingTicketPrices

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "LoadingTicketPrices" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Types.LoadingTicketPrices

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "LoadedTicketPrices" [ arg0, arg1 ], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.map2
                    Types.LoadedTicketPrices
                    (Fusion.Generated.Money.build_Currency arg0)
                    ((Fusion.Generated.PurchaseForm.build_TicketTypes
                          Fusion.Generated.Stripe.patcher_Price
                     )
                         arg1
                    )

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "FailedToLoadTicketPrices" [ arg0 ], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.map
                    Types.FailedToLoadTicketPrices
                    (Fusion.Generated.Effect.Http.build_Error arg0)

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "TicketCurrenciesDoNotMatch" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Types.TicketCurrenciesDoNotMatch

            else
                Result.Err Fusion.Patch.Conflict

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patch_TicketsEnabled :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Types.TicketsEnabled
    -> Result Fusion.Patch.Error Types.TicketsEnabled
patch_TicketsEnabled options patch value =
    let
        isCorrectVariant expected =
            case ( value, expected ) of
                ( Types.TicketsEnabled, "TicketsEnabled" ) ->
                    True

                ( Types.TicketsDisabled _, "TicketsDisabled" ) ->
                    True

                _ ->
                    False
    in
    case ( value, patch, options.force ) of
        ( Types.TicketsEnabled, Fusion.Patch.PCustomSame "TicketsEnabled" [], _ ) ->
            Result.Ok Types.TicketsEnabled

        ( _, Fusion.Patch.PCustomSame "TicketsEnabled" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TicketsEnabled" [], _ ) ->
            Result.Ok Types.TicketsEnabled

        ( Types.TicketsDisabled arg0, Fusion.Patch.PCustomSame "TicketsDisabled" [ patch0 ], _ ) ->
            Result.map
                Types.TicketsDisabled
                (Fusion.Patch.maybeApply
                     { patch = patch_adminMessage Fusion.Patch.patcher_String
                     , build = build_adminMessage Fusion.Patch.patcher_String
                     , toValue =
                         toValue_adminMessage Fusion.Patch.patcher_String
                     }
                     options
                     patch0
                     arg0
                )

        ( _, Fusion.Patch.PCustomSame "TicketsDisabled" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TicketsDisabled" [ (Just patch0) ], _ ) ->
            Result.map
                Types.TicketsDisabled
                (Fusion.Patch.buildFromPatch
                     (Fusion.Patch.build_Record
                          (\build_RecordUnpack ->
                               Result.map
                                   (\adminMessage ->
                                        { adminMessage = adminMessage }
                                   )
                                   (Result.andThen
                                        Fusion.Patch.build_String
                                        (build_RecordUnpack "adminMessage")
                                   )
                          )
                     )
                     patch0
                )

        ( _, Fusion.Patch.PCustomSame "TicketsDisabled" _, _ ) ->
            Result.Err Fusion.Patch.CouldNotBuildValueFromPatch

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        ( _, Fusion.Patch.PCustomChange expectedVariant "TicketsEnabled" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Types.TicketsEnabled

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "TicketsDisabled" [ arg0 ], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.map
                    Types.TicketsDisabled
                    (Fusion.Patch.build_Record
                         (\build_RecordUnpack ->
                              Result.map
                                  (\adminMessage ->
                                       { adminMessage = adminMessage }
                                  )
                                  (Result.andThen
                                       Fusion.Patch.build_String
                                       (build_RecordUnpack "adminMessage")
                                  )
                         )
                         arg0
                    )

            else
                Result.Err Fusion.Patch.Conflict

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patch_adminMessage :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> { adminMessage : String }
    -> Result Fusion.Patch.Error { adminMessage : String }
patch_adminMessage options patch value =
    Fusion.Patch.patch_Record
        (\fieldName fieldPatch acc ->
             case fieldName of
                 "adminMessage" ->
                     Result.map
                         (\adminMessage -> { acc | adminMessage = adminMessage }
                         )
                         (Fusion.Patch.patch_String
                              options
                              fieldPatch
                              acc.adminMessage
                         )

                 _ ->
                     Result.Err (Fusion.Patch.UnexpectedField fieldName)
        )
        patch
        value


patcher_BackendModel : Fusion.Patch.Patcher Types.BackendModel
patcher_BackendModel =
    { patch = patch_BackendModel
    , build = build_BackendModel
    , toValue = toValue_BackendModel
    }


patcher_CompletedOrder : Fusion.Patch.Patcher Types.CompletedOrder
patcher_CompletedOrder =
    { patch = patch_CompletedOrder
    , build = build_CompletedOrder
    , toValue = toValue_CompletedOrder
    }


patcher_EmailResult : Fusion.Patch.Patcher Types.EmailResult
patcher_EmailResult =
    { patch = patch_EmailResult
    , build = build_EmailResult
    , toValue = toValue_EmailResult
    }


patcher_PendingOrder : Fusion.Patch.Patcher Types.PendingOrder
patcher_PendingOrder =
    { patch = patch_PendingOrder
    , build = build_PendingOrder
    , toValue = toValue_PendingOrder
    }


patcher_TicketPriceStatus : Fusion.Patch.Patcher Types.TicketPriceStatus
patcher_TicketPriceStatus =
    { patch = patch_TicketPriceStatus
    , build = build_TicketPriceStatus
    , toValue = toValue_TicketPriceStatus
    }


patcher_TicketsEnabled : Fusion.Patch.Patcher Types.TicketsEnabled
patcher_TicketsEnabled =
    { patch = patch_TicketsEnabled
    , build = build_TicketsEnabled
    , toValue = toValue_TicketsEnabled
    }


patcher_adminMessage : Fusion.Patch.Patcher { adminMessage : String }
patcher_adminMessage =
    { patch = patch_adminMessage
    , build = build_adminMessage
    , toValue = toValue_adminMessage
    }


query_BackendModel : Fusion.Query -> Types.BackendModel -> Fusion.Value
query_BackendModel query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (Fusion.VRecord
                     (Dict.fromList
                          [ ( "orders"
                            , (Fusion.SeqDict.query_SeqDict
                                   (Fusion.Generated.Id.patcher_Id
                                        Fusion.Generated.Stripe.patcher_StripeSessionId
                                   )
                                   patcher_CompletedOrder
                              )
                                  query
                                  value.orders
                            )
                          , ( "pendingOrder"
                            , (Fusion.SeqDict.query_SeqDict
                                   (Fusion.Generated.Id.patcher_Id
                                        Fusion.Generated.Stripe.patcher_StripeSessionId
                                   )
                                   patcher_PendingOrder
                              )
                                  query
                                  value.pendingOrder
                            )
                          , ( "expiredOrders"
                            , (Fusion.SeqDict.query_SeqDict
                                   (Fusion.Generated.Id.patcher_Id
                                        Fusion.Generated.Stripe.patcher_StripeSessionId
                                   )
                                   patcher_PendingOrder
                              )
                                  query
                                  value.expiredOrders
                            )
                          , ( "prices"
                            , query_TicketPriceStatus query value.prices
                            )
                          , ( "time"
                            , Fusion.Generated.Effect.Time.query_Posix
                                  query
                                  value.time
                            )
                          , ( "ticketsEnabled"
                            , query_TicketsEnabled query value.ticketsEnabled
                            )
                          ]
                     )
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Debug.todo "record - qRecord"

        Fusion.QIndexed fusionValue fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery


query_CompletedOrder : Fusion.Query -> Types.CompletedOrder -> Fusion.Value
query_CompletedOrder query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (Fusion.VRecord
                     (Dict.fromList
                          [ ( "submitTime"
                            , Fusion.Generated.Effect.Time.query_Posix
                                  query
                                  value.submitTime
                            )
                          , ( "form"
                            , Fusion.Generated.PurchaseForm.query_PurchaseFormValidated
                                  query
                                  value.form
                            )
                          , ( "emailResult"
                            , query_EmailResult query value.emailResult
                            )
                          ]
                     )
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Debug.todo "record - qRecord"

        Fusion.QIndexed fusionValue fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery


query_EmailResult : Fusion.Query -> Types.EmailResult -> Fusion.Value
query_EmailResult query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (case value of
                     Types.SendingEmail ->
                         Fusion.VCustom "SendingEmail" []

                     Types.EmailSuccess ->
                         Fusion.VCustom "EmailSuccess" []

                     Types.EmailFailed arg0 ->
                         Fusion.VCustom
                             "EmailFailed"
                             [ Fusion.Generated.Postmark.query_SendEmailError
                                 query
                                 arg0
                             ]
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery

        Fusion.QIndexed fusionValue fusionQuery ->
            Debug.todo "custom - qIndexed"


query_PendingOrder : Fusion.Query -> Types.PendingOrder -> Fusion.Value
query_PendingOrder query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (Fusion.VRecord
                     (Dict.fromList
                          [ ( "submitTime"
                            , Fusion.Generated.Effect.Time.query_Posix
                                  query
                                  value.submitTime
                            )
                          , ( "form"
                            , Fusion.Generated.PurchaseForm.query_PurchaseFormValidated
                                  query
                                  value.form
                            )
                          , ( "sessionId"
                            , Fusion.Effect.Lamdera.query_SessionId
                                  query
                                  value.sessionId
                            )
                          ]
                     )
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Debug.todo "record - qRecord"

        Fusion.QIndexed fusionValue fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery


query_TicketPriceStatus :
    Fusion.Query -> Types.TicketPriceStatus -> Fusion.Value
query_TicketPriceStatus query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (case value of
                     Types.NotLoadingTicketPrices ->
                         Fusion.VCustom "NotLoadingTicketPrices" []

                     Types.LoadingTicketPrices ->
                         Fusion.VCustom "LoadingTicketPrices" []

                     Types.LoadedTicketPrices arg0 arg1 ->
                         Fusion.VCustom
                             "LoadedTicketPrices"
                             [ Fusion.Generated.Money.query_Currency query arg0
                             , (Fusion.Generated.PurchaseForm.query_TicketTypes
                                  Fusion.Generated.Stripe.patcher_Price
                               )
                                 query
                                 arg1
                             ]

                     Types.FailedToLoadTicketPrices arg0 ->
                         Fusion.VCustom
                             "FailedToLoadTicketPrices"
                             [ Fusion.Generated.Effect.Http.query_Error
                                 query
                                 arg0
                             ]

                     Types.TicketCurrenciesDoNotMatch ->
                         Fusion.VCustom "TicketCurrenciesDoNotMatch" []
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery

        Fusion.QIndexed fusionValue fusionQuery ->
            Debug.todo "custom - qIndexed"


query_TicketsEnabled : Fusion.Query -> Types.TicketsEnabled -> Fusion.Value
query_TicketsEnabled query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (case value of
                     Types.TicketsEnabled ->
                         Fusion.VCustom "TicketsEnabled" []

                     Types.TicketsDisabled arg0 ->
                         Fusion.VCustom
                             "TicketsDisabled"
                             [ case query of
                                 Fusion.QLoad ->
                                     Result.Ok
                                         (Fusion.VRecord
                                              (Dict.fromList
                                                   [ ( "adminMessage"
                                                     , Fusion.Patch.query_String
                                                           query
                                                           arg0.adminMessage
                                                     )
                                                   ]
                                              )
                                         )

                                 Fusion.QRecord arg_0 fusionQuery ->
                                     Debug.todo "record - qRecord"

                                 Fusion.QIndexed fusionValue fusionQuery ->
                                     Result.Err Fusion.Patch.WrongQuery
                             ]
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery

        Fusion.QIndexed fusionValue fusionQuery ->
            Debug.todo "custom - qIndexed"


query_adminMessage : Fusion.Query -> { adminMessage : String } -> Fusion.Value
query_adminMessage query value =
    case query of
        Fusion.QLoad ->
            Result.Ok
                (Fusion.VRecord
                     (Dict.fromList
                          [ ( "adminMessage"
                            , Fusion.Patch.query_String query value.adminMessage
                            )
                          ]
                     )
                )

        Fusion.QRecord arg_0 fusionQuery ->
            Debug.todo "record - qRecord"

        Fusion.QIndexed fusionValue fusionQuery ->
            Result.Err Fusion.Patch.WrongQuery


toValue_BackendModel : Types.BackendModel -> Fusion.Value
toValue_BackendModel value =
    Fusion.VRecord
        (Dict.fromList
             [ ( "orders"
               , (Fusion.SeqDict.toValue_SeqDict
                      (Fusion.Generated.Id.patcher_Id
                           Fusion.Generated.Stripe.patcher_StripeSessionId
                      )
                      patcher_CompletedOrder
                 )
                     value.orders
               )
             , ( "pendingOrder"
               , (Fusion.SeqDict.toValue_SeqDict
                      (Fusion.Generated.Id.patcher_Id
                           Fusion.Generated.Stripe.patcher_StripeSessionId
                      )
                      patcher_PendingOrder
                 )
                     value.pendingOrder
               )
             , ( "expiredOrders"
               , (Fusion.SeqDict.toValue_SeqDict
                      (Fusion.Generated.Id.patcher_Id
                           Fusion.Generated.Stripe.patcher_StripeSessionId
                      )
                      patcher_PendingOrder
                 )
                     value.expiredOrders
               )
             , ( "prices", toValue_TicketPriceStatus value.prices )
             , ( "time", Fusion.Generated.Effect.Time.toValue_Posix value.time )
             , ( "ticketsEnabled", toValue_TicketsEnabled value.ticketsEnabled )
             ]
        )


toValue_CompletedOrder : Types.CompletedOrder -> Fusion.Value
toValue_CompletedOrder value =
    Fusion.VRecord
        (Dict.fromList
             [ ( "submitTime"
               , Fusion.Generated.Effect.Time.toValue_Posix value.submitTime
               )
             , ( "form"
               , Fusion.Generated.PurchaseForm.toValue_PurchaseFormValidated
                     value.form
               )
             , ( "emailResult", toValue_EmailResult value.emailResult )
             ]
        )


toValue_EmailResult : Types.EmailResult -> Fusion.Value
toValue_EmailResult value =
    case value of
        Types.SendingEmail ->
            Fusion.VCustom "SendingEmail" []

        Types.EmailSuccess ->
            Fusion.VCustom "EmailSuccess" []

        Types.EmailFailed arg0 ->
            Fusion.VCustom
                "EmailFailed"
                [ Fusion.Generated.Postmark.toValue_SendEmailError arg0 ]


toValue_PendingOrder : Types.PendingOrder -> Fusion.Value
toValue_PendingOrder value =
    Fusion.VRecord
        (Dict.fromList
             [ ( "submitTime"
               , Fusion.Generated.Effect.Time.toValue_Posix value.submitTime
               )
             , ( "form"
               , Fusion.Generated.PurchaseForm.toValue_PurchaseFormValidated
                     value.form
               )
             , ( "sessionId"
               , Fusion.Effect.Lamdera.toValue_SessionId value.sessionId
               )
             ]
        )


toValue_TicketPriceStatus : Types.TicketPriceStatus -> Fusion.Value
toValue_TicketPriceStatus value =
    case value of
        Types.NotLoadingTicketPrices ->
            Fusion.VCustom "NotLoadingTicketPrices" []

        Types.LoadingTicketPrices ->
            Fusion.VCustom "LoadingTicketPrices" []

        Types.LoadedTicketPrices arg0 arg1 ->
            Fusion.VCustom
                "LoadedTicketPrices"
                [ Fusion.Generated.Money.toValue_Currency arg0
                , (Fusion.Generated.PurchaseForm.toValue_TicketTypes
                     Fusion.Generated.Stripe.patcher_Price
                  )
                    arg1
                ]

        Types.FailedToLoadTicketPrices arg0 ->
            Fusion.VCustom
                "FailedToLoadTicketPrices"
                [ Fusion.Generated.Effect.Http.toValue_Error arg0 ]

        Types.TicketCurrenciesDoNotMatch ->
            Fusion.VCustom "TicketCurrenciesDoNotMatch" []


toValue_TicketsEnabled : Types.TicketsEnabled -> Fusion.Value
toValue_TicketsEnabled value =
    case value of
        Types.TicketsEnabled ->
            Fusion.VCustom "TicketsEnabled" []

        Types.TicketsDisabled arg0 ->
            Fusion.VCustom
                "TicketsDisabled"
                [ Fusion.VRecord
                    (Dict.fromList
                       [ ( "adminMessage", Fusion.VString arg0.adminMessage ) ]
                    )
                ]


toValue_adminMessage : { adminMessage : String } -> Fusion.Value
toValue_adminMessage value =
    Fusion.VRecord
        (Dict.fromList [ ( "adminMessage", Fusion.VString value.adminMessage ) ]
        )