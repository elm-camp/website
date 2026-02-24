module Fusion.Generated.TypeDict.Postmark exposing (typeDict, type_PostmarkError_, type_SendEmailError, type_UnknownErrorData)

{-|

@docs typeDict, type_PostmarkError_, type_SendEmailError, type_UnknownErrorData

-}

import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List a )
typeDict =
    Dict.fromList
        [ ( "PostmarkError_", ( type_PostmarkError_, [] ) )
        , ( "UnknownErrorData", ( type_UnknownErrorData, [] ) )
        , ( "SendEmailError", ( type_SendEmailError, [] ) )
        ]


type_PostmarkError_ : Fusion.Type
type_PostmarkError_ =
    Fusion.TRecord
        [ ( "errorCode"
          , Fusion.TNamed [ "Basics" ] "Int" [] (Just Fusion.TInt)
          )
        , ( "message"
          , Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString)
          )
        , ( "to"
          , Fusion.TNamed
                [ "List" ]
                "List"
                [ Fusion.TNamed [ "EmailAddress" ] "EmailAddress" [] Nothing ]
                (Just
                    (Fusion.TList
                        (Fusion.TNamed
                            [ "EmailAddress" ]
                            "EmailAddress"
                            []
                            Nothing
                        )
                    )
                )
          )
        ]


type_SendEmailError : Fusion.Type
type_SendEmailError =
    Fusion.TCustom
        "SendEmailError"
        []
        [ ( "UnknownError"
          , [ Fusion.TNamed [ "Postmark" ] "UnknownErrorData" [] Nothing ]
          )
        , ( "PostmarkError"
          , [ Fusion.TNamed [ "Postmark" ] "PostmarkError_" [] Nothing ]
          )
        , ( "NetworkError", [] )
        , ( "Timeout", [] )
        , ( "BadUrl"
          , [ Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString) ]
          )
        ]


type_UnknownErrorData : Fusion.Type
type_UnknownErrorData =
    Fusion.TRecord
        [ ( "statusCode"
          , Fusion.TNamed [ "Basics" ] "Int" [] (Just Fusion.TInt)
          )
        , ( "body"
          , Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString)
          )
        ]
