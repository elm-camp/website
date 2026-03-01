module Evergreen.V117.Postmark exposing (..)

import Evergreen.V117.EmailAddress


type alias UnknownErrorData =
    { statusCode : Int
    , body : String
    }


type alias PostmarkError_ =
    { errorCode : Int
    , message : String
    , to : List Evergreen.V117.EmailAddress.EmailAddress
    }


type SendEmailError
    = UnknownError UnknownErrorData
    | PostmarkError PostmarkError_
    | NetworkError
    | Timeout
    | BadUrl String
