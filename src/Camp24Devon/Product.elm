module Camp24Devon.Product exposing (..)

import Env


year =
    "2024"


includesAccom productId =
    if productId == ticket.attendanceTicket then
        False

    else if productId == ticket.campingSpot then
        False

    else
        True


ticket :
    { attendanceTicket : String
    , campingSpot : String
    , singleRoom : String
    , doubleRoom : String
    , groupRoom : String
    }
ticket =
    case Env.mode of
        Env.Production ->
            { attendanceTicket = "prod_PhhIapmx1JVmy9"
            , campingSpot = "prod_PhhJG27yB8GmzH"
            , singleRoom = "prod_PhhLtqV8I5Spjo"
            , doubleRoom = "prod_PhhLZ9pJjyEDfF"
            , groupRoom = "prod_PhhLsuxKXAfjse"
            }

        Env.Development ->
            { attendanceTicket = ""
            , campingSpot = ""
            , singleRoom = ""
            , doubleRoom = ""
            , groupRoom = ""
            }


sponsorship : { silver : String, gold : String, platinum : String }
sponsorship =
    case Env.mode of
        Env.Production ->
            { silver = ""
            , gold = ""
            , platinum = ""
            }

        Env.Development ->
            { silver = ""
            , gold = ""
            , platinum = ""
            }


type alias Sponsorship =
    { name : String, price : Int, productId : String, description : String, features : List String }


sponsorshipItems =
    [ { name = "Silver"
      , price = 1000
      , productId = sponsorship.silver
      , description = "You will be a major supporter of Elm Camp Europe " ++ year ++ "."
      , features =
            [ "Thank you tweet"
            , "Logo on webpage"
            , "Small logo on shared slide, displayed during breaks"
            ]
      }
    , { name = "Gold"
      , price = 2500
      , productId = sponsorship.gold
      , description = "You will be a pivotal supporter of Elm Camp Europe " ++ year ++ "."
      , features =
            [ "Thank you tweet"
            , "Rollup or poster inside the venue (provided by you)"
            , "Logo on webpage"
            , "Medium logo on shared slide, displayed during breaks"
            , "1 free campfire ticket"
            ]
      }
    , { name = "Platinum"
      , price = 5000
      , productId = sponsorship.platinum
      , description = "You will be principal sponsor and guarantee that Elm Camp Europe " ++ year ++ " is a success."
      , features =
            [ "Thank you tweet"
            , "Rollup or poster inside the venue (provided by you)"
            , "Self-written snippet on shared web page about use of Elm at your company"
            , "Logo on webpage"
            , "2 free campfire tickets or 1 free camp ticket"
            , "Big logo on shared slide, displayed during breaks"
            , "Honorary mention in opening and closing talks"
            ]
      }
    ]
