module Camp exposing (Meta)

{-| Shared definition for all camp years.
-}


type alias Meta =
    { logo : { src : String, description : String }
    , tag : String
    , location : String
    , dates : String
    , artifactPicture : { src : String, description : String }
    }
