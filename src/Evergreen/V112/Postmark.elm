module Evergreen.V112.Postmark exposing (..)

import Evergreen.V112.EmailAddress


type alias UnknownErrorData =
    { statusCode : Int
    , body : String
    }


type alias PostmarkError_ =
    { errorCode : Int
    , message : String
    , to : List Evergreen.V112.EmailAddress.EmailAddress
    }


type SendEmailError
    = UnknownError UnknownErrorData
    | PostmarkError PostmarkError_
    | NetworkError
    | Timeout
    | BadUrl String
