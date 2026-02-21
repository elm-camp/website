module Fusion.Generated.TypeDict.Postmark exposing ( typeDict, type_PostmarkError_, type_SendEmailError, type_statusCode__body )

{-|
@docs typeDict, type_PostmarkError_, type_SendEmailError, type_statusCode__body
-}


import Dict
import Fusion


typeDict : Dict.Dict String ( Fusion.Type, List a )
typeDict =
    Dict.fromList
        [ ( "PostmarkError_", ( type_PostmarkError_, [] ) )
        , ( "statusCode__body", ( type_statusCode__body, [] ) )
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
          , [ Fusion.TRecord
                [ ( "statusCode"
                  , Fusion.TNamed [ "Basics" ] "Int" [] (Just Fusion.TInt)
                  )
                , ( "body"
                  , Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString)
                  )
                ]
            ]
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


type_statusCode__body : Fusion.Type
type_statusCode__body =
    Fusion.TRecord
        [ ( "statusCode"
          , Fusion.TNamed [ "Basics" ] "Int" [] (Just Fusion.TInt)
          )
        , ( "body"
          , Fusion.TNamed [ "String" ] "String" [] (Just Fusion.TString)
          )
        ]