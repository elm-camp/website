module Fusion.Generated.TypeDict exposing (typeDict)

{-|

@docs typeDict

-}

import Dict
import Fusion
import Fusion.Generated.TypeDict.Effect.Http
import Fusion.Generated.TypeDict.Effect.Time
import Fusion.Generated.TypeDict.Id
import Fusion.Generated.TypeDict.Money
import Fusion.Generated.TypeDict.Name
import Fusion.Generated.TypeDict.Postmark
import Fusion.Generated.TypeDict.PurchaseForm
import Fusion.Generated.TypeDict.Quantity
import Fusion.Generated.TypeDict.String.Nonempty
import Fusion.Generated.TypeDict.Stripe
import Fusion.Generated.TypeDict.Types


typeDict : Dict.Dict (List String) (Dict.Dict String ( Fusion.Type, List String ))
typeDict =
    Dict.fromList
        [ ( [ "TypeDict", "Effect", "Http" ]
          , Fusion.Generated.TypeDict.Effect.Http.typeDict
          )
        , ( [ "TypeDict", "Effect", "Time" ]
          , Fusion.Generated.TypeDict.Effect.Time.typeDict
          )
        , ( [ "TypeDict", "Id" ], Fusion.Generated.TypeDict.Id.typeDict )
        , ( [ "TypeDict", "Money" ], Fusion.Generated.TypeDict.Money.typeDict )
        , ( [ "TypeDict", "Name" ], Fusion.Generated.TypeDict.Name.typeDict )
        , ( [ "TypeDict", "Postmark" ]
          , Fusion.Generated.TypeDict.Postmark.typeDict
          )
        , ( [ "TypeDict", "PurchaseForm" ]
          , Fusion.Generated.TypeDict.PurchaseForm.typeDict
          )
        , ( [ "TypeDict", "Quantity" ]
          , Fusion.Generated.TypeDict.Quantity.typeDict
          )
        , ( [ "TypeDict", "String", "Nonempty" ]
          , Fusion.Generated.TypeDict.String.Nonempty.typeDict
          )
        , ( [ "TypeDict", "Stripe" ]
          , Fusion.Generated.TypeDict.Stripe.typeDict
          )
        , ( [ "TypeDict", "Types" ], Fusion.Generated.TypeDict.Types.typeDict )
        ]
