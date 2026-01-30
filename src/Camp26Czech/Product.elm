module Camp26Czech.Product exposing (Sponsorship, sponsorship, sponsorshipItems, ticket, year)


year : String
year =
    "2025"


ticket :
    { attendanceTicket : String
    , offsite : String
    , campingSpot : String
    , singleRoom : String
    , doubleRoom : String
    , groupRoom : String
    }
ticket =
    { attendanceTicket = ""
    , offsite = ""
    , campingSpot = "prod_TmIy0Mltqmgzg5"
    , singleRoom = "prod_TmJ0n8liux9A3d"
    , doubleRoom = "prod_TmIzrbSouU0bYE"
    , groupRoom = ""
    }


sponsorship : { bronze : String, silver : String, gold : String }
sponsorship =
    { bronze = ""
    , silver = "prod_RzWTill7eglkFc"
    , gold = "prod_RzWVRbQ0spItOf"
    }


type alias Sponsorship =
    { name : String, price : Int, productId : String, description : String, features : List String }


sponsorshipItems : List Sponsorship
sponsorshipItems =
    [ { name = "Bronze"
      , price = 50000
      , productId = sponsorship.bronze
      , description = "You will be a minor supporter of Elm Camp " ++ year ++ "."
      , features =
            [ "Thank you tweet"
            , "Logo on website"
            , "Small logo on shared slide during the opening and closing sessions"
            ]
      }
    , { name = "Silver"
      , price = 100000
      , productId = sponsorship.silver
      , description = "You will be a major supporter of Elm Camp " ++ year ++ "."
      , features =
            [ "Thank you tweet"
            , "Logo on website"
            , "Small logo on shared slide during the opening and closing sessions"
            , "Small logo on a slide displayed between sessions throughout the event"
            , "One campfire ticket"
            ]
      }
    , { name = "Gold"
      , price = 250000
      , productId = sponsorship.gold
      , description = "You will be a pivotal supporter of Elm Camp " ++ year ++ "."
      , features =
            [ "Thank you tweet"
            , "Dedicated \"thank you\" slide during the opening and closing sessions"
            , "Large logo on a slide displayed between sessions throughout the event"
            , "Two campfire tickets or one single room ticket"
            , "A self-written snippet on the website about your use of Elm and an optional CTA if you are hiring"
            , "A rollup or poster (provided by you) visible inside the venue during the event"
            ]
      }
    ]
