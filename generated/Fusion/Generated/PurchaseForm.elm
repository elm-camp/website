module Fusion.Generated.PurchaseForm exposing
    ( build_AttendeeFormValidated, build_PurchaseFormValidated, build_TicketTypes, patch_AttendeeFormValidated, patch_PurchaseFormValidated, patch_TicketTypes
    , patcher_AttendeeFormValidated, patcher_PurchaseFormValidated, patcher_TicketTypes, toValue_AttendeeFormValidated, toValue_PurchaseFormValidated, toValue_TicketTypes
    )

{-|
@docs build_AttendeeFormValidated, build_PurchaseFormValidated, build_TicketTypes, patch_AttendeeFormValidated, patch_PurchaseFormValidated, patch_TicketTypes
@docs patcher_AttendeeFormValidated, patcher_PurchaseFormValidated, patcher_TicketTypes, toValue_AttendeeFormValidated, toValue_PurchaseFormValidated, toValue_TicketTypes
-}


import Dict
import Fusion
import Fusion.EmailAddress
import Fusion.Generated.Name
import Fusion.Generated.Quantity
import Fusion.Generated.String.Nonempty
import Fusion.Generated.Stripe
import Fusion.NonNegative
import Fusion.Patch
import PurchaseForm


build_AttendeeFormValidated :
    Fusion.Value -> Result Fusion.Patch.Error PurchaseForm.AttendeeFormValidated
build_AttendeeFormValidated value =
    Fusion.Patch.build_Record
        (\build_RecordUnpack ->
             Result.map3
                 (\name country originCity ->
                      { name = name
                      , country = country
                      , originCity = originCity
                      }
                 )
                 (Result.andThen
                      Fusion.Generated.Name.build_Name
                      (build_RecordUnpack "name")
                 )
                 (Result.andThen
                      Fusion.Generated.String.Nonempty.build_NonemptyString
                      (build_RecordUnpack "country")
                 )
                 (Result.andThen
                      Fusion.Generated.String.Nonempty.build_NonemptyString
                      (build_RecordUnpack "originCity")
                 )
        )
        value


build_PurchaseFormValidated :
    Fusion.Value -> Result Fusion.Patch.Error PurchaseForm.PurchaseFormValidated
build_PurchaseFormValidated value =
    Fusion.Patch.build_Record
        (\build_RecordUnpack ->
             Result.map4
                 (\attendees count billingEmail grantContribution ->
                      { attendees = attendees
                      , count = count
                      , billingEmail = billingEmail
                      , grantContribution = grantContribution
                      }
                 )
                 (Result.andThen
                      (Fusion.Patch.build_List patcher_AttendeeFormValidated)
                      (build_RecordUnpack "attendees")
                 )
                 (Result.andThen
                      (build_TicketTypes Fusion.NonNegative.patcher_NonNegative)
                      (build_RecordUnpack "count")
                 )
                 (Result.andThen
                      Fusion.EmailAddress.build_EmailAddress
                      (build_RecordUnpack "billingEmail")
                 )
                 (Result.andThen
                      (Fusion.Generated.Quantity.build_Quantity
                           Fusion.Patch.patcher_Float
                           Fusion.Generated.Stripe.patcher_StripeCurrency
                      )
                      (build_RecordUnpack "grantContribution")
                 )
        )
        value


build_TicketTypes :
    Fusion.Patch.Patcher a
    -> Fusion.Value
    -> Result Fusion.Patch.Error (PurchaseForm.TicketTypes a)
build_TicketTypes aPatcher value =
    Fusion.Patch.build_Record
        (\build_RecordUnpack ->
             Result.map3
                 (\campfireTicket singleRoomTicket sharedRoomTicket ->
                      { campfireTicket = campfireTicket
                      , singleRoomTicket = singleRoomTicket
                      , sharedRoomTicket = sharedRoomTicket
                      }
                 )
                 (Result.andThen
                      aPatcher.build
                      (build_RecordUnpack "campfireTicket")
                 )
                 (Result.andThen
                      aPatcher.build
                      (build_RecordUnpack "singleRoomTicket")
                 )
                 (Result.andThen
                      aPatcher.build
                      (build_RecordUnpack "sharedRoomTicket")
                 )
        )
        value


patch_AttendeeFormValidated :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> PurchaseForm.AttendeeFormValidated
    -> Result Fusion.Patch.Error PurchaseForm.AttendeeFormValidated
patch_AttendeeFormValidated options patch value =
    Fusion.Patch.patch_Record
        (\fieldName fieldPatch acc ->
             case fieldName of
                 "name" ->
                     Result.map
                         (\name -> { acc | name = name })
                         (Fusion.Generated.Name.patch_Name
                              options
                              fieldPatch
                              acc.name
                         )

                 "country" ->
                     Result.map
                         (\country -> { acc | country = country })
                         (Fusion.Generated.String.Nonempty.patch_NonemptyString
                              options
                              fieldPatch
                              acc.country
                         )

                 "originCity" ->
                     Result.map
                         (\originCity -> { acc | originCity = originCity })
                         (Fusion.Generated.String.Nonempty.patch_NonemptyString
                              options
                              fieldPatch
                              acc.originCity
                         )

                 _ ->
                     Result.Err (Fusion.Patch.UnexpectedField fieldName)
        )
        patch
        value


patch_PurchaseFormValidated :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> PurchaseForm.PurchaseFormValidated
    -> Result Fusion.Patch.Error PurchaseForm.PurchaseFormValidated
patch_PurchaseFormValidated options patch value =
    Fusion.Patch.patch_Record
        (\fieldName fieldPatch acc ->
             case fieldName of
                 "attendees" ->
                     Result.map
                         (\attendees -> { acc | attendees = attendees })
                         (Fusion.Patch.patch_List
                              patcher_AttendeeFormValidated
                              options
                              fieldPatch
                              acc.attendees
                         )

                 "count" ->
                     Result.map
                         (\count -> { acc | count = count })
                         ((patch_TicketTypes
                               Fusion.NonNegative.patcher_NonNegative
                          )
                              options
                              fieldPatch
                              acc.count
                         )

                 "billingEmail" ->
                     Result.map
                         (\billingEmail -> { acc | billingEmail = billingEmail }
                         )
                         (Fusion.EmailAddress.patch_EmailAddress
                              options
                              fieldPatch
                              acc.billingEmail
                         )

                 "grantContribution" ->
                     Result.map
                         (\grantContribution ->
                              { acc | grantContribution = grantContribution }
                         )
                         ((Fusion.Generated.Quantity.patch_Quantity
                               Fusion.Patch.patcher_Float
                               Fusion.Generated.Stripe.patcher_StripeCurrency
                          )
                              options
                              fieldPatch
                              acc.grantContribution
                         )

                 _ ->
                     Result.Err (Fusion.Patch.UnexpectedField fieldName)
        )
        patch
        value


patch_TicketTypes :
    Fusion.Patch.Patcher a
    -> { force : Bool }
    -> Fusion.Patch.Patch
    -> PurchaseForm.TicketTypes a
    -> Result Fusion.Patch.Error (PurchaseForm.TicketTypes a)
patch_TicketTypes aPatcher options patch value =
    Fusion.Patch.patch_Record
        (\fieldName fieldPatch acc ->
             case fieldName of
                 "campfireTicket" ->
                     Result.map
                         (\campfireTicket ->
                              { acc | campfireTicket = campfireTicket }
                         )
                         (aPatcher.patch options fieldPatch acc.campfireTicket)

                 "singleRoomTicket" ->
                     Result.map
                         (\singleRoomTicket ->
                              { acc | singleRoomTicket = singleRoomTicket }
                         )
                         (aPatcher.patch options fieldPatch acc.singleRoomTicket
                         )

                 "sharedRoomTicket" ->
                     Result.map
                         (\sharedRoomTicket ->
                              { acc | sharedRoomTicket = sharedRoomTicket }
                         )
                         (aPatcher.patch options fieldPatch acc.sharedRoomTicket
                         )

                 _ ->
                     Result.Err (Fusion.Patch.UnexpectedField fieldName)
        )
        patch
        value


patcher_AttendeeFormValidated :
    Fusion.Patch.Patcher PurchaseForm.AttendeeFormValidated
patcher_AttendeeFormValidated =
    { patch = patch_AttendeeFormValidated
    , build = build_AttendeeFormValidated
    , toValue = toValue_AttendeeFormValidated
    }


patcher_PurchaseFormValidated :
    Fusion.Patch.Patcher PurchaseForm.PurchaseFormValidated
patcher_PurchaseFormValidated =
    { patch = patch_PurchaseFormValidated
    , build = build_PurchaseFormValidated
    , toValue = toValue_PurchaseFormValidated
    }


patcher_TicketTypes :
    Fusion.Patch.Patcher a -> Fusion.Patch.Patcher (PurchaseForm.TicketTypes a)
patcher_TicketTypes aPatcher =
    { patch = patch_TicketTypes aPatcher
    , build = build_TicketTypes aPatcher
    , toValue = toValue_TicketTypes aPatcher
    }


toValue_AttendeeFormValidated :
    PurchaseForm.AttendeeFormValidated -> Fusion.Value
toValue_AttendeeFormValidated value =
    Fusion.VRecord
        (Dict.fromList
             [ ( "name", Fusion.Generated.Name.toValue_Name value.name )
             , ( "country"
               , Fusion.Generated.String.Nonempty.toValue_NonemptyString
                     value.country
               )
             , ( "originCity"
               , Fusion.Generated.String.Nonempty.toValue_NonemptyString
                     value.originCity
               )
             ]
        )


toValue_PurchaseFormValidated :
    PurchaseForm.PurchaseFormValidated -> Fusion.Value
toValue_PurchaseFormValidated value =
    Fusion.VRecord
        (Dict.fromList
             [ ( "attendees"
               , Fusion.Patch.toValue_List
                     patcher_AttendeeFormValidated
                     value.attendees
               )
             , ( "count"
               , (toValue_TicketTypes Fusion.NonNegative.patcher_NonNegative)
                     value.count
               )
             , ( "billingEmail"
               , Fusion.EmailAddress.toValue_EmailAddress value.billingEmail
               )
             , ( "grantContribution"
               , (Fusion.Generated.Quantity.toValue_Quantity
                      Fusion.Patch.patcher_Float
                      Fusion.Generated.Stripe.patcher_StripeCurrency
                 )
                     value.grantContribution
               )
             ]
        )


toValue_TicketTypes :
    Fusion.Patch.Patcher a -> PurchaseForm.TicketTypes a -> Fusion.Value
toValue_TicketTypes aPatcher value =
    Fusion.VRecord
        (Dict.fromList
             [ ( "campfireTicket", aPatcher.toValue value.campfireTicket )
             , ( "singleRoomTicket", aPatcher.toValue value.singleRoomTicket )
             , ( "sharedRoomTicket", aPatcher.toValue value.sharedRoomTicket )
             ]
        )