module Camp26Czech.Product exposing (Sponsorship, sponsorship, sponsorshipItems, ticket, year)

import Env


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
    case Env.mode of
        Env.Production ->
            { attendanceTicket = "prod_S57SF0eTq5vOvx"
            , offsite = "prod_RzWC4KcrRdLzBH"
            , campingSpot = "prod_TmIy0Mltqmgzg5"
            , singleRoom = "prod_TmJ0n8liux9A3d"
            , doubleRoom = ""
            , groupRoom = "prod_TmIzrbSouU0bYE"
            }

        Env.Development ->
            { attendanceTicket = "prod_S57SF0eTq5vOvx"
            , offsite = "prod_RzWC4KcrRdLzBH"
            , campingSpot = "prod_TmIy0Mltqmgzg5"
            , singleRoom = "prod_TmJ0n8liux9A3d"
            , doubleRoom = ""
            , groupRoom = "prod_TmIzrbSouU0bYE"
            }



{- (Ok [{ createdAt = Posix 1686420847, isActive = True,
   --price = { amount = 0, currency = EUR }, priceId = Id "price_1NHWIdHHD80VvsjKg03QUzMB", productId = Id "prod_O3dZfPAP3QH9M3" },
   { createdAt = Posix 1686420847
   , isActive = True
   , price = { amount = 80000, currency = EUR }, priceId = Id "price_1NHWIdHHD80VvsjKu8q5wLhS", productId = Id "prod_O3dZfPAP3QH9M3" }
   ,{ createdAt = Posix 1686420847, isActive = True, price = { amount = 40000, currency = EUR }, priceId = Id "price_1NHWIdHHD80VvsjKFqJMVRRo", productId = Id "prod_O3dZfPAP3QH9M3" }
   ,{ createdAt = Posix 1686420847, isActive = True, price = { amount = 20000, currency = EUR }, priceId = Id "price_1NHWIdHHD80VvsjKVe0Lp4Xd", productId = Id "prod_O3dZfPAP3QH9M3" }
   ,{ createdAt = Posix 1686420847, isActive = True, price = { amount = 10000, currency = EUR }, priceId = Id "price_1NHWIdHHD80VvsjKCAzCWqTM", productId = Id "prod_O3dZfPAP3QH9M3" }
   ,{ createdAt = Posix 1686420847, isActive = True, price = { amount = 5000, currency = EUR }, priceId = Id "price_1NHWIdHHD80VvsjKWywndZ9t", productId = Id "prod_O3dZfPAP3QH9M3" }
   ,{ createdAt = Posix 1680896704, isActive = True, price = { amount = 500000, currency = EUR }, priceId = Id "price_1MuLDYHHD80VvsjKjviFf0NB", productId = Id "prod_NfgasPyftxzylU" }
   ,{ createdAt = Posix 1680896663, isActive = True, price = { amount = 250000, currency = EUR }, priceId = Id "price_1MuLCtHHD80VvsjKiyYjf4ym", productId = Id "prod_NfgaDIHFcTZaXO" }
   ,{ createdAt = Posix 1680896620, isActive = True, price = { amount = 100000, currency = EUR }, priceId = Id "price_1MuLCCHHD80VvsjK53YFQ9wT", productId = Id "prod_NfgZ9Lztw4rqY1" }
   ,{ createdAt = Posix 1679653321, isActive = False, price = { amount = 100, currency = EUR }, priceId = Id "price_1Mp7kzHHD80VvsjKi2F2nsp0", productId = Id "prod_NZEShNjlWMPhTA" }])

-}


sponsorship : { bronze : String, silver : String, gold : String }
sponsorship =
    case Env.mode of
        Env.Production ->
            { bronze = ""
            , silver = "prod_RzWTill7eglkFc"
            , gold = "prod_RzWVRbQ0spItOf"
            }

        Env.Development ->
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
