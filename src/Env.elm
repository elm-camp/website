module Env exposing (..)

import EmailAddress exposing (EmailAddress)
import Postmark


domain : String
domain =
    "http://localhost:8000"


stripePrivateApiKey : String
stripePrivateApiKey =
    -- Test environment, prod key set in prod
    "sk_test_BmyEiWFhwdb5PH3hGD5xZXft00r6mCGnKI"


stripePublicApiKey : String
stripePublicApiKey =
    "pk_test_S7leIg6SGfj2NMkUaP6ipIOv00gGgSlmgj"


isProduction_ : String
isProduction_ =
    "false"


isProduction : Bool
isProduction =
    String.toLower isProduction_ == "true"


postmarkApiKey_ : String
postmarkApiKey_ =
    ""


postmarkApiKey : Postmark.ApiKey
postmarkApiKey =
    Postmark.apiKey postmarkApiKey_


developerEmails_ : String
developerEmails_ =
    ""


developerEmails : List EmailAddress
developerEmails =
    List.filterMap (\email -> String.trim email |> EmailAddress.fromString) (String.split "," developerEmails_)


adminPassword : String
adminPassword =
    "123"
