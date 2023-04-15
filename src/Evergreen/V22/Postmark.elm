module Evergreen.V22.Postmark exposing (..)


type alias PostmarkSendResponse =
    { to : String
    , submittedAt : String
    , messageId : String
    , errorCode : Int
    , message : String
    }
