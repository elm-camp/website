module Evergreen.V94.EmailAddress exposing (..)


type EmailAddress
    = EmailAddress
        { localPart : String
        , tags : List String
        , domain : String
        , tld : List String
        }
