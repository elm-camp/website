module Camp25US.Product exposing (Sponsorship, sponsorship, sponsorshipItems, ticket, year)

import Env


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
    case Env.mode of
        Env.Production ->
            { attendanceTicket = "prod_S57SF0eTq5vOvx"
            , offsite = "prod_RzWC4KcrRdLzBH"
            , campingSpot = "prod_RzWC4KcrRdLzBH"
            , singleRoom = "prod_RzWGafvirlc2HL"
            , doubleRoom = ""
            , groupRoom = "prod_RzWIY7BfNEYSqF"
            }

        Env.Development ->
            { attendanceTicket = "prod_S57SF0eTq5vOvx"
            , offsite = "prod_RzWC4KcrRdLzBH"
            , campingSpot = "prod_RzWC4KcrRdLzBH"
            , singleRoom = "prod_RzWGafvirlc2HL"
            , doubleRoom = ""
            , groupRoom = "prod_RzWIY7BfNEYSqF"
            }


sponsorship : { silver : String, gold : String, platinum : String }
sponsorship =
    case Env.mode of
        Env.Production ->
            { silver = "prod_RzWTill7eglkFc"
            , gold = "prod_RzWVRbQ0spItOf"
            , platinum = "prod_RzWWOS4E6aID6y"
            }

        Env.Development ->
            { silver = "prod_RzWTill7eglkFc"
            , gold = "prod_RzWVRbQ0spItOf"
            , platinum = "prod_RzWWOS4E6aID6y"
            }


type alias Sponsorship =
    { name : String, price : Int, productId : String, description : String, features : List String }


sponsorshipItems =
    [ { name = "Silver"
      , price = 100000
      , productId = sponsorship.silver
      , description = "You will be a major supporter of Elm Camp " ++ year ++ "."
      , features =
            [ "Thank you tweet"
            , "Logo on webpage"
            , "Small logo on shared slide, displayed during breaks"
            ]
      }
    , { name = "Gold"
      , price = 250000
      , productId = sponsorship.gold
      , description = "You will be a pivotal supporter of Elm Camp " ++ year ++ "."
      , features =
            [ "Thank you tweet"
            , "Rollup or poster inside the venue (provided by you)"
            , "Logo on webpage"
            , "Medium logo on shared slide, displayed during breaks"
            , "1 free campfire ticket"
            ]
      }
    , { name = "Platinum"
      , price = 500000
      , productId = sponsorship.platinum
      , description = "You will be principal sponsor and guarantee that Elm Camp " ++ year ++ " is a success."
      , features =
            [ "Thank you tweet"
            , "Rollup or poster inside the venue (provided by you)"
            , "Self-written snippet on shared web page about use of Elm at your company"
            , "Logo on webpage"
            , "2 free campfire tickets or 1 free ticket with accommodation"
            , "Big logo on shared slide, displayed during breaks"
            , "Honorary mention in opening and closing talks"
            ]
      }
    ]
