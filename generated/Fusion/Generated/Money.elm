module Fusion.Generated.Money exposing ( build_Currency, patch_Currency, patcher_Currency, toValue_Currency )

{-|
@docs build_Currency, patch_Currency, patcher_Currency, toValue_Currency
-}


import Fusion
import Fusion.Patch
import Money


build_Currency : Fusion.Value -> Result Fusion.Patch.Error Money.Currency
build_Currency value =
    Fusion.Patch.build_Custom
        (\name params ->
             case ( name, params ) of
                 ( "USD", [] ) ->
                     Result.Ok Money.USD

                 ( "CAD", [] ) ->
                     Result.Ok Money.CAD

                 ( "EUR", [] ) ->
                     Result.Ok Money.EUR

                 ( "BTC", [] ) ->
                     Result.Ok Money.BTC

                 ( "AED", [] ) ->
                     Result.Ok Money.AED

                 ( "AFN", [] ) ->
                     Result.Ok Money.AFN

                 ( "ALL", [] ) ->
                     Result.Ok Money.ALL

                 ( "AMD", [] ) ->
                     Result.Ok Money.AMD

                 ( "ARS", [] ) ->
                     Result.Ok Money.ARS

                 ( "AUD", [] ) ->
                     Result.Ok Money.AUD

                 ( "AZN", [] ) ->
                     Result.Ok Money.AZN

                 ( "BAM", [] ) ->
                     Result.Ok Money.BAM

                 ( "BDT", [] ) ->
                     Result.Ok Money.BDT

                 ( "BGN", [] ) ->
                     Result.Ok Money.BGN

                 ( "BHD", [] ) ->
                     Result.Ok Money.BHD

                 ( "BIF", [] ) ->
                     Result.Ok Money.BIF

                 ( "BND", [] ) ->
                     Result.Ok Money.BND

                 ( "BOB", [] ) ->
                     Result.Ok Money.BOB

                 ( "BRL", [] ) ->
                     Result.Ok Money.BRL

                 ( "BWP", [] ) ->
                     Result.Ok Money.BWP

                 ( "BYN", [] ) ->
                     Result.Ok Money.BYN

                 ( "BZD", [] ) ->
                     Result.Ok Money.BZD

                 ( "CDF", [] ) ->
                     Result.Ok Money.CDF

                 ( "CHF", [] ) ->
                     Result.Ok Money.CHF

                 ( "CLP", [] ) ->
                     Result.Ok Money.CLP

                 ( "CNY", [] ) ->
                     Result.Ok Money.CNY

                 ( "COP", [] ) ->
                     Result.Ok Money.COP

                 ( "CRC", [] ) ->
                     Result.Ok Money.CRC

                 ( "CVE", [] ) ->
                     Result.Ok Money.CVE

                 ( "CZK", [] ) ->
                     Result.Ok Money.CZK

                 ( "DJF", [] ) ->
                     Result.Ok Money.DJF

                 ( "DKK", [] ) ->
                     Result.Ok Money.DKK

                 ( "DOP", [] ) ->
                     Result.Ok Money.DOP

                 ( "DZD", [] ) ->
                     Result.Ok Money.DZD

                 ( "EEK", [] ) ->
                     Result.Ok Money.EEK

                 ( "EGP", [] ) ->
                     Result.Ok Money.EGP

                 ( "ERN", [] ) ->
                     Result.Ok Money.ERN

                 ( "ETB", [] ) ->
                     Result.Ok Money.ETB

                 ( "GBP", [] ) ->
                     Result.Ok Money.GBP

                 ( "GEL", [] ) ->
                     Result.Ok Money.GEL

                 ( "GHS", [] ) ->
                     Result.Ok Money.GHS

                 ( "GNF", [] ) ->
                     Result.Ok Money.GNF

                 ( "GTQ", [] ) ->
                     Result.Ok Money.GTQ

                 ( "HKD", [] ) ->
                     Result.Ok Money.HKD

                 ( "HNL", [] ) ->
                     Result.Ok Money.HNL

                 ( "HRK", [] ) ->
                     Result.Ok Money.HRK

                 ( "HUF", [] ) ->
                     Result.Ok Money.HUF

                 ( "IDR", [] ) ->
                     Result.Ok Money.IDR

                 ( "ILS", [] ) ->
                     Result.Ok Money.ILS

                 ( "INR", [] ) ->
                     Result.Ok Money.INR

                 ( "IQD", [] ) ->
                     Result.Ok Money.IQD

                 ( "IRR", [] ) ->
                     Result.Ok Money.IRR

                 ( "ISK", [] ) ->
                     Result.Ok Money.ISK

                 ( "JMD", [] ) ->
                     Result.Ok Money.JMD

                 ( "JOD", [] ) ->
                     Result.Ok Money.JOD

                 ( "JPY", [] ) ->
                     Result.Ok Money.JPY

                 ( "KES", [] ) ->
                     Result.Ok Money.KES

                 ( "KHR", [] ) ->
                     Result.Ok Money.KHR

                 ( "KMF", [] ) ->
                     Result.Ok Money.KMF

                 ( "KRW", [] ) ->
                     Result.Ok Money.KRW

                 ( "KWD", [] ) ->
                     Result.Ok Money.KWD

                 ( "KZT", [] ) ->
                     Result.Ok Money.KZT

                 ( "LAK", [] ) ->
                     Result.Ok Money.LAK

                 ( "LBP", [] ) ->
                     Result.Ok Money.LBP

                 ( "LKR", [] ) ->
                     Result.Ok Money.LKR

                 ( "LTL", [] ) ->
                     Result.Ok Money.LTL

                 ( "LVL", [] ) ->
                     Result.Ok Money.LVL

                 ( "LYD", [] ) ->
                     Result.Ok Money.LYD

                 ( "MAD", [] ) ->
                     Result.Ok Money.MAD

                 ( "MDL", [] ) ->
                     Result.Ok Money.MDL

                 ( "MGA", [] ) ->
                     Result.Ok Money.MGA

                 ( "MKD", [] ) ->
                     Result.Ok Money.MKD

                 ( "MMK", [] ) ->
                     Result.Ok Money.MMK

                 ( "MOP", [] ) ->
                     Result.Ok Money.MOP

                 ( "MUR", [] ) ->
                     Result.Ok Money.MUR

                 ( "MXN", [] ) ->
                     Result.Ok Money.MXN

                 ( "MYR", [] ) ->
                     Result.Ok Money.MYR

                 ( "MZN", [] ) ->
                     Result.Ok Money.MZN

                 ( "NAD", [] ) ->
                     Result.Ok Money.NAD

                 ( "NGN", [] ) ->
                     Result.Ok Money.NGN

                 ( "NIO", [] ) ->
                     Result.Ok Money.NIO

                 ( "NOK", [] ) ->
                     Result.Ok Money.NOK

                 ( "NPR", [] ) ->
                     Result.Ok Money.NPR

                 ( "NZD", [] ) ->
                     Result.Ok Money.NZD

                 ( "OMR", [] ) ->
                     Result.Ok Money.OMR

                 ( "PAB", [] ) ->
                     Result.Ok Money.PAB

                 ( "PEN", [] ) ->
                     Result.Ok Money.PEN

                 ( "PHP", [] ) ->
                     Result.Ok Money.PHP

                 ( "PKR", [] ) ->
                     Result.Ok Money.PKR

                 ( "PLN", [] ) ->
                     Result.Ok Money.PLN

                 ( "PYG", [] ) ->
                     Result.Ok Money.PYG

                 ( "QAR", [] ) ->
                     Result.Ok Money.QAR

                 ( "RON", [] ) ->
                     Result.Ok Money.RON

                 ( "RSD", [] ) ->
                     Result.Ok Money.RSD

                 ( "RUB", [] ) ->
                     Result.Ok Money.RUB

                 ( "RWF", [] ) ->
                     Result.Ok Money.RWF

                 ( "SAR", [] ) ->
                     Result.Ok Money.SAR

                 ( "SDG", [] ) ->
                     Result.Ok Money.SDG

                 ( "SEK", [] ) ->
                     Result.Ok Money.SEK

                 ( "SGD", [] ) ->
                     Result.Ok Money.SGD

                 ( "SOS", [] ) ->
                     Result.Ok Money.SOS

                 ( "SYP", [] ) ->
                     Result.Ok Money.SYP

                 ( "THB", [] ) ->
                     Result.Ok Money.THB

                 ( "TND", [] ) ->
                     Result.Ok Money.TND

                 ( "TOP", [] ) ->
                     Result.Ok Money.TOP

                 ( "TRY", [] ) ->
                     Result.Ok Money.TRY

                 ( "TTD", [] ) ->
                     Result.Ok Money.TTD

                 ( "TWD", [] ) ->
                     Result.Ok Money.TWD

                 ( "TZS", [] ) ->
                     Result.Ok Money.TZS

                 ( "UAH", [] ) ->
                     Result.Ok Money.UAH

                 ( "UGX", [] ) ->
                     Result.Ok Money.UGX

                 ( "UYU", [] ) ->
                     Result.Ok Money.UYU

                 ( "UZS", [] ) ->
                     Result.Ok Money.UZS

                 ( "VED", [] ) ->
                     Result.Ok Money.VED

                 ( "VND", [] ) ->
                     Result.Ok Money.VND

                 ( "XAF", [] ) ->
                     Result.Ok Money.XAF

                 ( "XOF", [] ) ->
                     Result.Ok Money.XOF

                 ( "YER", [] ) ->
                     Result.Ok Money.YER

                 ( "ZAR", [] ) ->
                     Result.Ok Money.ZAR

                 ( "ZMK", [] ) ->
                     Result.Ok Money.ZMK

                 ( "AOA", [] ) ->
                     Result.Ok Money.AOA

                 ( "XCD", [] ) ->
                     Result.Ok Money.XCD

                 ( "AWG", [] ) ->
                     Result.Ok Money.AWG

                 ( "BSD", [] ) ->
                     Result.Ok Money.BSD

                 ( "BBD", [] ) ->
                     Result.Ok Money.BBD

                 ( "BMD", [] ) ->
                     Result.Ok Money.BMD

                 ( "BTN", [] ) ->
                     Result.Ok Money.BTN

                 ( "KYD", [] ) ->
                     Result.Ok Money.KYD

                 ( "CUP", [] ) ->
                     Result.Ok Money.CUP

                 ( "ANG", [] ) ->
                     Result.Ok Money.ANG

                 ( "SZL", [] ) ->
                     Result.Ok Money.SZL

                 ( "FKP", [] ) ->
                     Result.Ok Money.FKP

                 ( "FJD", [] ) ->
                     Result.Ok Money.FJD

                 ( "XPF", [] ) ->
                     Result.Ok Money.XPF

                 ( "GMD", [] ) ->
                     Result.Ok Money.GMD

                 ( "GIP", [] ) ->
                     Result.Ok Money.GIP

                 ( "GYD", [] ) ->
                     Result.Ok Money.GYD

                 ( "HTG", [] ) ->
                     Result.Ok Money.HTG

                 ( "KPW", [] ) ->
                     Result.Ok Money.KPW

                 ( "KGS", [] ) ->
                     Result.Ok Money.KGS

                 ( "LSL", [] ) ->
                     Result.Ok Money.LSL

                 ( "LRD", [] ) ->
                     Result.Ok Money.LRD

                 ( "MWK", [] ) ->
                     Result.Ok Money.MWK

                 ( "MVR", [] ) ->
                     Result.Ok Money.MVR

                 ( "MRU", [] ) ->
                     Result.Ok Money.MRU

                 ( "MNT", [] ) ->
                     Result.Ok Money.MNT

                 ( "PGK", [] ) ->
                     Result.Ok Money.PGK

                 ( "SHP", [] ) ->
                     Result.Ok Money.SHP

                 ( "WST", [] ) ->
                     Result.Ok Money.WST

                 ( "STN", [] ) ->
                     Result.Ok Money.STN

                 ( "SCR", [] ) ->
                     Result.Ok Money.SCR

                 ( "SLE", [] ) ->
                     Result.Ok Money.SLE

                 ( "SBD", [] ) ->
                     Result.Ok Money.SBD

                 ( "SSP", [] ) ->
                     Result.Ok Money.SSP

                 ( "SRD", [] ) ->
                     Result.Ok Money.SRD

                 ( "TJS", [] ) ->
                     Result.Ok Money.TJS

                 ( "TMT", [] ) ->
                     Result.Ok Money.TMT

                 ( "VUV", [] ) ->
                     Result.Ok Money.VUV

                 ( "VES", [] ) ->
                     Result.Ok Money.VES

                 ( "ZMW", [] ) ->
                     Result.Ok Money.ZMW

                 ( "ZWL", [] ) ->
                     Result.Ok Money.ZWL

                 _ ->
                     Result.Err
                         (Fusion.Patch.WrongType "buildCustom last branch")
        )
        value


patch_Currency :
    { force : Bool }
    -> Fusion.Patch.Patch
    -> Money.Currency
    -> Result Fusion.Patch.Error Money.Currency
patch_Currency options patch value =
    let
        isCorrectVariant expected =
            case ( value, expected ) of
                ( Money.USD, "USD" ) ->
                    True

                ( Money.CAD, "CAD" ) ->
                    True

                ( Money.EUR, "EUR" ) ->
                    True

                ( Money.BTC, "BTC" ) ->
                    True

                ( Money.AED, "AED" ) ->
                    True

                ( Money.AFN, "AFN" ) ->
                    True

                ( Money.ALL, "ALL" ) ->
                    True

                ( Money.AMD, "AMD" ) ->
                    True

                ( Money.ARS, "ARS" ) ->
                    True

                ( Money.AUD, "AUD" ) ->
                    True

                ( Money.AZN, "AZN" ) ->
                    True

                ( Money.BAM, "BAM" ) ->
                    True

                ( Money.BDT, "BDT" ) ->
                    True

                ( Money.BGN, "BGN" ) ->
                    True

                ( Money.BHD, "BHD" ) ->
                    True

                ( Money.BIF, "BIF" ) ->
                    True

                ( Money.BND, "BND" ) ->
                    True

                ( Money.BOB, "BOB" ) ->
                    True

                ( Money.BRL, "BRL" ) ->
                    True

                ( Money.BWP, "BWP" ) ->
                    True

                ( Money.BYN, "BYN" ) ->
                    True

                ( Money.BZD, "BZD" ) ->
                    True

                ( Money.CDF, "CDF" ) ->
                    True

                ( Money.CHF, "CHF" ) ->
                    True

                ( Money.CLP, "CLP" ) ->
                    True

                ( Money.CNY, "CNY" ) ->
                    True

                ( Money.COP, "COP" ) ->
                    True

                ( Money.CRC, "CRC" ) ->
                    True

                ( Money.CVE, "CVE" ) ->
                    True

                ( Money.CZK, "CZK" ) ->
                    True

                ( Money.DJF, "DJF" ) ->
                    True

                ( Money.DKK, "DKK" ) ->
                    True

                ( Money.DOP, "DOP" ) ->
                    True

                ( Money.DZD, "DZD" ) ->
                    True

                ( Money.EEK, "EEK" ) ->
                    True

                ( Money.EGP, "EGP" ) ->
                    True

                ( Money.ERN, "ERN" ) ->
                    True

                ( Money.ETB, "ETB" ) ->
                    True

                ( Money.GBP, "GBP" ) ->
                    True

                ( Money.GEL, "GEL" ) ->
                    True

                ( Money.GHS, "GHS" ) ->
                    True

                ( Money.GNF, "GNF" ) ->
                    True

                ( Money.GTQ, "GTQ" ) ->
                    True

                ( Money.HKD, "HKD" ) ->
                    True

                ( Money.HNL, "HNL" ) ->
                    True

                ( Money.HRK, "HRK" ) ->
                    True

                ( Money.HUF, "HUF" ) ->
                    True

                ( Money.IDR, "IDR" ) ->
                    True

                ( Money.ILS, "ILS" ) ->
                    True

                ( Money.INR, "INR" ) ->
                    True

                ( Money.IQD, "IQD" ) ->
                    True

                ( Money.IRR, "IRR" ) ->
                    True

                ( Money.ISK, "ISK" ) ->
                    True

                ( Money.JMD, "JMD" ) ->
                    True

                ( Money.JOD, "JOD" ) ->
                    True

                ( Money.JPY, "JPY" ) ->
                    True

                ( Money.KES, "KES" ) ->
                    True

                ( Money.KHR, "KHR" ) ->
                    True

                ( Money.KMF, "KMF" ) ->
                    True

                ( Money.KRW, "KRW" ) ->
                    True

                ( Money.KWD, "KWD" ) ->
                    True

                ( Money.KZT, "KZT" ) ->
                    True

                ( Money.LAK, "LAK" ) ->
                    True

                ( Money.LBP, "LBP" ) ->
                    True

                ( Money.LKR, "LKR" ) ->
                    True

                ( Money.LTL, "LTL" ) ->
                    True

                ( Money.LVL, "LVL" ) ->
                    True

                ( Money.LYD, "LYD" ) ->
                    True

                ( Money.MAD, "MAD" ) ->
                    True

                ( Money.MDL, "MDL" ) ->
                    True

                ( Money.MGA, "MGA" ) ->
                    True

                ( Money.MKD, "MKD" ) ->
                    True

                ( Money.MMK, "MMK" ) ->
                    True

                ( Money.MOP, "MOP" ) ->
                    True

                ( Money.MUR, "MUR" ) ->
                    True

                ( Money.MXN, "MXN" ) ->
                    True

                ( Money.MYR, "MYR" ) ->
                    True

                ( Money.MZN, "MZN" ) ->
                    True

                ( Money.NAD, "NAD" ) ->
                    True

                ( Money.NGN, "NGN" ) ->
                    True

                ( Money.NIO, "NIO" ) ->
                    True

                ( Money.NOK, "NOK" ) ->
                    True

                ( Money.NPR, "NPR" ) ->
                    True

                ( Money.NZD, "NZD" ) ->
                    True

                ( Money.OMR, "OMR" ) ->
                    True

                ( Money.PAB, "PAB" ) ->
                    True

                ( Money.PEN, "PEN" ) ->
                    True

                ( Money.PHP, "PHP" ) ->
                    True

                ( Money.PKR, "PKR" ) ->
                    True

                ( Money.PLN, "PLN" ) ->
                    True

                ( Money.PYG, "PYG" ) ->
                    True

                ( Money.QAR, "QAR" ) ->
                    True

                ( Money.RON, "RON" ) ->
                    True

                ( Money.RSD, "RSD" ) ->
                    True

                ( Money.RUB, "RUB" ) ->
                    True

                ( Money.RWF, "RWF" ) ->
                    True

                ( Money.SAR, "SAR" ) ->
                    True

                ( Money.SDG, "SDG" ) ->
                    True

                ( Money.SEK, "SEK" ) ->
                    True

                ( Money.SGD, "SGD" ) ->
                    True

                ( Money.SOS, "SOS" ) ->
                    True

                ( Money.SYP, "SYP" ) ->
                    True

                ( Money.THB, "THB" ) ->
                    True

                ( Money.TND, "TND" ) ->
                    True

                ( Money.TOP, "TOP" ) ->
                    True

                ( Money.TRY, "TRY" ) ->
                    True

                ( Money.TTD, "TTD" ) ->
                    True

                ( Money.TWD, "TWD" ) ->
                    True

                ( Money.TZS, "TZS" ) ->
                    True

                ( Money.UAH, "UAH" ) ->
                    True

                ( Money.UGX, "UGX" ) ->
                    True

                ( Money.UYU, "UYU" ) ->
                    True

                ( Money.UZS, "UZS" ) ->
                    True

                ( Money.VED, "VED" ) ->
                    True

                ( Money.VND, "VND" ) ->
                    True

                ( Money.XAF, "XAF" ) ->
                    True

                ( Money.XOF, "XOF" ) ->
                    True

                ( Money.YER, "YER" ) ->
                    True

                ( Money.ZAR, "ZAR" ) ->
                    True

                ( Money.ZMK, "ZMK" ) ->
                    True

                ( Money.AOA, "AOA" ) ->
                    True

                ( Money.XCD, "XCD" ) ->
                    True

                ( Money.AWG, "AWG" ) ->
                    True

                ( Money.BSD, "BSD" ) ->
                    True

                ( Money.BBD, "BBD" ) ->
                    True

                ( Money.BMD, "BMD" ) ->
                    True

                ( Money.BTN, "BTN" ) ->
                    True

                ( Money.KYD, "KYD" ) ->
                    True

                ( Money.CUP, "CUP" ) ->
                    True

                ( Money.ANG, "ANG" ) ->
                    True

                ( Money.SZL, "SZL" ) ->
                    True

                ( Money.FKP, "FKP" ) ->
                    True

                ( Money.FJD, "FJD" ) ->
                    True

                ( Money.XPF, "XPF" ) ->
                    True

                ( Money.GMD, "GMD" ) ->
                    True

                ( Money.GIP, "GIP" ) ->
                    True

                ( Money.GYD, "GYD" ) ->
                    True

                ( Money.HTG, "HTG" ) ->
                    True

                ( Money.KPW, "KPW" ) ->
                    True

                ( Money.KGS, "KGS" ) ->
                    True

                ( Money.LSL, "LSL" ) ->
                    True

                ( Money.LRD, "LRD" ) ->
                    True

                ( Money.MWK, "MWK" ) ->
                    True

                ( Money.MVR, "MVR" ) ->
                    True

                ( Money.MRU, "MRU" ) ->
                    True

                ( Money.MNT, "MNT" ) ->
                    True

                ( Money.PGK, "PGK" ) ->
                    True

                ( Money.SHP, "SHP" ) ->
                    True

                ( Money.WST, "WST" ) ->
                    True

                ( Money.STN, "STN" ) ->
                    True

                ( Money.SCR, "SCR" ) ->
                    True

                ( Money.SLE, "SLE" ) ->
                    True

                ( Money.SBD, "SBD" ) ->
                    True

                ( Money.SSP, "SSP" ) ->
                    True

                ( Money.SRD, "SRD" ) ->
                    True

                ( Money.TJS, "TJS" ) ->
                    True

                ( Money.TMT, "TMT" ) ->
                    True

                ( Money.VUV, "VUV" ) ->
                    True

                ( Money.VES, "VES" ) ->
                    True

                ( Money.ZMW, "ZMW" ) ->
                    True

                ( Money.ZWL, "ZWL" ) ->
                    True

                _ ->
                    False
    in
    case ( value, patch, options.force ) of
        ( Money.USD, Fusion.Patch.PCustomSame "USD" [], _ ) ->
            Result.Ok Money.USD

        ( _, Fusion.Patch.PCustomSame "USD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "USD" [], _ ) ->
            Result.Ok Money.USD

        ( Money.CAD, Fusion.Patch.PCustomSame "CAD" [], _ ) ->
            Result.Ok Money.CAD

        ( _, Fusion.Patch.PCustomSame "CAD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "CAD" [], _ ) ->
            Result.Ok Money.CAD

        ( Money.EUR, Fusion.Patch.PCustomSame "EUR" [], _ ) ->
            Result.Ok Money.EUR

        ( _, Fusion.Patch.PCustomSame "EUR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "EUR" [], _ ) ->
            Result.Ok Money.EUR

        ( Money.BTC, Fusion.Patch.PCustomSame "BTC" [], _ ) ->
            Result.Ok Money.BTC

        ( _, Fusion.Patch.PCustomSame "BTC" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BTC" [], _ ) ->
            Result.Ok Money.BTC

        ( Money.AED, Fusion.Patch.PCustomSame "AED" [], _ ) ->
            Result.Ok Money.AED

        ( _, Fusion.Patch.PCustomSame "AED" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "AED" [], _ ) ->
            Result.Ok Money.AED

        ( Money.AFN, Fusion.Patch.PCustomSame "AFN" [], _ ) ->
            Result.Ok Money.AFN

        ( _, Fusion.Patch.PCustomSame "AFN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "AFN" [], _ ) ->
            Result.Ok Money.AFN

        ( Money.ALL, Fusion.Patch.PCustomSame "ALL" [], _ ) ->
            Result.Ok Money.ALL

        ( _, Fusion.Patch.PCustomSame "ALL" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ALL" [], _ ) ->
            Result.Ok Money.ALL

        ( Money.AMD, Fusion.Patch.PCustomSame "AMD" [], _ ) ->
            Result.Ok Money.AMD

        ( _, Fusion.Patch.PCustomSame "AMD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "AMD" [], _ ) ->
            Result.Ok Money.AMD

        ( Money.ARS, Fusion.Patch.PCustomSame "ARS" [], _ ) ->
            Result.Ok Money.ARS

        ( _, Fusion.Patch.PCustomSame "ARS" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ARS" [], _ ) ->
            Result.Ok Money.ARS

        ( Money.AUD, Fusion.Patch.PCustomSame "AUD" [], _ ) ->
            Result.Ok Money.AUD

        ( _, Fusion.Patch.PCustomSame "AUD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "AUD" [], _ ) ->
            Result.Ok Money.AUD

        ( Money.AZN, Fusion.Patch.PCustomSame "AZN" [], _ ) ->
            Result.Ok Money.AZN

        ( _, Fusion.Patch.PCustomSame "AZN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "AZN" [], _ ) ->
            Result.Ok Money.AZN

        ( Money.BAM, Fusion.Patch.PCustomSame "BAM" [], _ ) ->
            Result.Ok Money.BAM

        ( _, Fusion.Patch.PCustomSame "BAM" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BAM" [], _ ) ->
            Result.Ok Money.BAM

        ( Money.BDT, Fusion.Patch.PCustomSame "BDT" [], _ ) ->
            Result.Ok Money.BDT

        ( _, Fusion.Patch.PCustomSame "BDT" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BDT" [], _ ) ->
            Result.Ok Money.BDT

        ( Money.BGN, Fusion.Patch.PCustomSame "BGN" [], _ ) ->
            Result.Ok Money.BGN

        ( _, Fusion.Patch.PCustomSame "BGN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BGN" [], _ ) ->
            Result.Ok Money.BGN

        ( Money.BHD, Fusion.Patch.PCustomSame "BHD" [], _ ) ->
            Result.Ok Money.BHD

        ( _, Fusion.Patch.PCustomSame "BHD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BHD" [], _ ) ->
            Result.Ok Money.BHD

        ( Money.BIF, Fusion.Patch.PCustomSame "BIF" [], _ ) ->
            Result.Ok Money.BIF

        ( _, Fusion.Patch.PCustomSame "BIF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BIF" [], _ ) ->
            Result.Ok Money.BIF

        ( Money.BND, Fusion.Patch.PCustomSame "BND" [], _ ) ->
            Result.Ok Money.BND

        ( _, Fusion.Patch.PCustomSame "BND" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BND" [], _ ) ->
            Result.Ok Money.BND

        ( Money.BOB, Fusion.Patch.PCustomSame "BOB" [], _ ) ->
            Result.Ok Money.BOB

        ( _, Fusion.Patch.PCustomSame "BOB" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BOB" [], _ ) ->
            Result.Ok Money.BOB

        ( Money.BRL, Fusion.Patch.PCustomSame "BRL" [], _ ) ->
            Result.Ok Money.BRL

        ( _, Fusion.Patch.PCustomSame "BRL" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BRL" [], _ ) ->
            Result.Ok Money.BRL

        ( Money.BWP, Fusion.Patch.PCustomSame "BWP" [], _ ) ->
            Result.Ok Money.BWP

        ( _, Fusion.Patch.PCustomSame "BWP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BWP" [], _ ) ->
            Result.Ok Money.BWP

        ( Money.BYN, Fusion.Patch.PCustomSame "BYN" [], _ ) ->
            Result.Ok Money.BYN

        ( _, Fusion.Patch.PCustomSame "BYN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BYN" [], _ ) ->
            Result.Ok Money.BYN

        ( Money.BZD, Fusion.Patch.PCustomSame "BZD" [], _ ) ->
            Result.Ok Money.BZD

        ( _, Fusion.Patch.PCustomSame "BZD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BZD" [], _ ) ->
            Result.Ok Money.BZD

        ( Money.CDF, Fusion.Patch.PCustomSame "CDF" [], _ ) ->
            Result.Ok Money.CDF

        ( _, Fusion.Patch.PCustomSame "CDF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "CDF" [], _ ) ->
            Result.Ok Money.CDF

        ( Money.CHF, Fusion.Patch.PCustomSame "CHF" [], _ ) ->
            Result.Ok Money.CHF

        ( _, Fusion.Patch.PCustomSame "CHF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "CHF" [], _ ) ->
            Result.Ok Money.CHF

        ( Money.CLP, Fusion.Patch.PCustomSame "CLP" [], _ ) ->
            Result.Ok Money.CLP

        ( _, Fusion.Patch.PCustomSame "CLP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "CLP" [], _ ) ->
            Result.Ok Money.CLP

        ( Money.CNY, Fusion.Patch.PCustomSame "CNY" [], _ ) ->
            Result.Ok Money.CNY

        ( _, Fusion.Patch.PCustomSame "CNY" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "CNY" [], _ ) ->
            Result.Ok Money.CNY

        ( Money.COP, Fusion.Patch.PCustomSame "COP" [], _ ) ->
            Result.Ok Money.COP

        ( _, Fusion.Patch.PCustomSame "COP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "COP" [], _ ) ->
            Result.Ok Money.COP

        ( Money.CRC, Fusion.Patch.PCustomSame "CRC" [], _ ) ->
            Result.Ok Money.CRC

        ( _, Fusion.Patch.PCustomSame "CRC" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "CRC" [], _ ) ->
            Result.Ok Money.CRC

        ( Money.CVE, Fusion.Patch.PCustomSame "CVE" [], _ ) ->
            Result.Ok Money.CVE

        ( _, Fusion.Patch.PCustomSame "CVE" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "CVE" [], _ ) ->
            Result.Ok Money.CVE

        ( Money.CZK, Fusion.Patch.PCustomSame "CZK" [], _ ) ->
            Result.Ok Money.CZK

        ( _, Fusion.Patch.PCustomSame "CZK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "CZK" [], _ ) ->
            Result.Ok Money.CZK

        ( Money.DJF, Fusion.Patch.PCustomSame "DJF" [], _ ) ->
            Result.Ok Money.DJF

        ( _, Fusion.Patch.PCustomSame "DJF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "DJF" [], _ ) ->
            Result.Ok Money.DJF

        ( Money.DKK, Fusion.Patch.PCustomSame "DKK" [], _ ) ->
            Result.Ok Money.DKK

        ( _, Fusion.Patch.PCustomSame "DKK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "DKK" [], _ ) ->
            Result.Ok Money.DKK

        ( Money.DOP, Fusion.Patch.PCustomSame "DOP" [], _ ) ->
            Result.Ok Money.DOP

        ( _, Fusion.Patch.PCustomSame "DOP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "DOP" [], _ ) ->
            Result.Ok Money.DOP

        ( Money.DZD, Fusion.Patch.PCustomSame "DZD" [], _ ) ->
            Result.Ok Money.DZD

        ( _, Fusion.Patch.PCustomSame "DZD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "DZD" [], _ ) ->
            Result.Ok Money.DZD

        ( Money.EEK, Fusion.Patch.PCustomSame "EEK" [], _ ) ->
            Result.Ok Money.EEK

        ( _, Fusion.Patch.PCustomSame "EEK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "EEK" [], _ ) ->
            Result.Ok Money.EEK

        ( Money.EGP, Fusion.Patch.PCustomSame "EGP" [], _ ) ->
            Result.Ok Money.EGP

        ( _, Fusion.Patch.PCustomSame "EGP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "EGP" [], _ ) ->
            Result.Ok Money.EGP

        ( Money.ERN, Fusion.Patch.PCustomSame "ERN" [], _ ) ->
            Result.Ok Money.ERN

        ( _, Fusion.Patch.PCustomSame "ERN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ERN" [], _ ) ->
            Result.Ok Money.ERN

        ( Money.ETB, Fusion.Patch.PCustomSame "ETB" [], _ ) ->
            Result.Ok Money.ETB

        ( _, Fusion.Patch.PCustomSame "ETB" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ETB" [], _ ) ->
            Result.Ok Money.ETB

        ( Money.GBP, Fusion.Patch.PCustomSame "GBP" [], _ ) ->
            Result.Ok Money.GBP

        ( _, Fusion.Patch.PCustomSame "GBP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "GBP" [], _ ) ->
            Result.Ok Money.GBP

        ( Money.GEL, Fusion.Patch.PCustomSame "GEL" [], _ ) ->
            Result.Ok Money.GEL

        ( _, Fusion.Patch.PCustomSame "GEL" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "GEL" [], _ ) ->
            Result.Ok Money.GEL

        ( Money.GHS, Fusion.Patch.PCustomSame "GHS" [], _ ) ->
            Result.Ok Money.GHS

        ( _, Fusion.Patch.PCustomSame "GHS" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "GHS" [], _ ) ->
            Result.Ok Money.GHS

        ( Money.GNF, Fusion.Patch.PCustomSame "GNF" [], _ ) ->
            Result.Ok Money.GNF

        ( _, Fusion.Patch.PCustomSame "GNF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "GNF" [], _ ) ->
            Result.Ok Money.GNF

        ( Money.GTQ, Fusion.Patch.PCustomSame "GTQ" [], _ ) ->
            Result.Ok Money.GTQ

        ( _, Fusion.Patch.PCustomSame "GTQ" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "GTQ" [], _ ) ->
            Result.Ok Money.GTQ

        ( Money.HKD, Fusion.Patch.PCustomSame "HKD" [], _ ) ->
            Result.Ok Money.HKD

        ( _, Fusion.Patch.PCustomSame "HKD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "HKD" [], _ ) ->
            Result.Ok Money.HKD

        ( Money.HNL, Fusion.Patch.PCustomSame "HNL" [], _ ) ->
            Result.Ok Money.HNL

        ( _, Fusion.Patch.PCustomSame "HNL" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "HNL" [], _ ) ->
            Result.Ok Money.HNL

        ( Money.HRK, Fusion.Patch.PCustomSame "HRK" [], _ ) ->
            Result.Ok Money.HRK

        ( _, Fusion.Patch.PCustomSame "HRK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "HRK" [], _ ) ->
            Result.Ok Money.HRK

        ( Money.HUF, Fusion.Patch.PCustomSame "HUF" [], _ ) ->
            Result.Ok Money.HUF

        ( _, Fusion.Patch.PCustomSame "HUF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "HUF" [], _ ) ->
            Result.Ok Money.HUF

        ( Money.IDR, Fusion.Patch.PCustomSame "IDR" [], _ ) ->
            Result.Ok Money.IDR

        ( _, Fusion.Patch.PCustomSame "IDR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "IDR" [], _ ) ->
            Result.Ok Money.IDR

        ( Money.ILS, Fusion.Patch.PCustomSame "ILS" [], _ ) ->
            Result.Ok Money.ILS

        ( _, Fusion.Patch.PCustomSame "ILS" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ILS" [], _ ) ->
            Result.Ok Money.ILS

        ( Money.INR, Fusion.Patch.PCustomSame "INR" [], _ ) ->
            Result.Ok Money.INR

        ( _, Fusion.Patch.PCustomSame "INR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "INR" [], _ ) ->
            Result.Ok Money.INR

        ( Money.IQD, Fusion.Patch.PCustomSame "IQD" [], _ ) ->
            Result.Ok Money.IQD

        ( _, Fusion.Patch.PCustomSame "IQD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "IQD" [], _ ) ->
            Result.Ok Money.IQD

        ( Money.IRR, Fusion.Patch.PCustomSame "IRR" [], _ ) ->
            Result.Ok Money.IRR

        ( _, Fusion.Patch.PCustomSame "IRR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "IRR" [], _ ) ->
            Result.Ok Money.IRR

        ( Money.ISK, Fusion.Patch.PCustomSame "ISK" [], _ ) ->
            Result.Ok Money.ISK

        ( _, Fusion.Patch.PCustomSame "ISK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ISK" [], _ ) ->
            Result.Ok Money.ISK

        ( Money.JMD, Fusion.Patch.PCustomSame "JMD" [], _ ) ->
            Result.Ok Money.JMD

        ( _, Fusion.Patch.PCustomSame "JMD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "JMD" [], _ ) ->
            Result.Ok Money.JMD

        ( Money.JOD, Fusion.Patch.PCustomSame "JOD" [], _ ) ->
            Result.Ok Money.JOD

        ( _, Fusion.Patch.PCustomSame "JOD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "JOD" [], _ ) ->
            Result.Ok Money.JOD

        ( Money.JPY, Fusion.Patch.PCustomSame "JPY" [], _ ) ->
            Result.Ok Money.JPY

        ( _, Fusion.Patch.PCustomSame "JPY" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "JPY" [], _ ) ->
            Result.Ok Money.JPY

        ( Money.KES, Fusion.Patch.PCustomSame "KES" [], _ ) ->
            Result.Ok Money.KES

        ( _, Fusion.Patch.PCustomSame "KES" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "KES" [], _ ) ->
            Result.Ok Money.KES

        ( Money.KHR, Fusion.Patch.PCustomSame "KHR" [], _ ) ->
            Result.Ok Money.KHR

        ( _, Fusion.Patch.PCustomSame "KHR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "KHR" [], _ ) ->
            Result.Ok Money.KHR

        ( Money.KMF, Fusion.Patch.PCustomSame "KMF" [], _ ) ->
            Result.Ok Money.KMF

        ( _, Fusion.Patch.PCustomSame "KMF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "KMF" [], _ ) ->
            Result.Ok Money.KMF

        ( Money.KRW, Fusion.Patch.PCustomSame "KRW" [], _ ) ->
            Result.Ok Money.KRW

        ( _, Fusion.Patch.PCustomSame "KRW" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "KRW" [], _ ) ->
            Result.Ok Money.KRW

        ( Money.KWD, Fusion.Patch.PCustomSame "KWD" [], _ ) ->
            Result.Ok Money.KWD

        ( _, Fusion.Patch.PCustomSame "KWD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "KWD" [], _ ) ->
            Result.Ok Money.KWD

        ( Money.KZT, Fusion.Patch.PCustomSame "KZT" [], _ ) ->
            Result.Ok Money.KZT

        ( _, Fusion.Patch.PCustomSame "KZT" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "KZT" [], _ ) ->
            Result.Ok Money.KZT

        ( Money.LAK, Fusion.Patch.PCustomSame "LAK" [], _ ) ->
            Result.Ok Money.LAK

        ( _, Fusion.Patch.PCustomSame "LAK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "LAK" [], _ ) ->
            Result.Ok Money.LAK

        ( Money.LBP, Fusion.Patch.PCustomSame "LBP" [], _ ) ->
            Result.Ok Money.LBP

        ( _, Fusion.Patch.PCustomSame "LBP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "LBP" [], _ ) ->
            Result.Ok Money.LBP

        ( Money.LKR, Fusion.Patch.PCustomSame "LKR" [], _ ) ->
            Result.Ok Money.LKR

        ( _, Fusion.Patch.PCustomSame "LKR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "LKR" [], _ ) ->
            Result.Ok Money.LKR

        ( Money.LTL, Fusion.Patch.PCustomSame "LTL" [], _ ) ->
            Result.Ok Money.LTL

        ( _, Fusion.Patch.PCustomSame "LTL" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "LTL" [], _ ) ->
            Result.Ok Money.LTL

        ( Money.LVL, Fusion.Patch.PCustomSame "LVL" [], _ ) ->
            Result.Ok Money.LVL

        ( _, Fusion.Patch.PCustomSame "LVL" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "LVL" [], _ ) ->
            Result.Ok Money.LVL

        ( Money.LYD, Fusion.Patch.PCustomSame "LYD" [], _ ) ->
            Result.Ok Money.LYD

        ( _, Fusion.Patch.PCustomSame "LYD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "LYD" [], _ ) ->
            Result.Ok Money.LYD

        ( Money.MAD, Fusion.Patch.PCustomSame "MAD" [], _ ) ->
            Result.Ok Money.MAD

        ( _, Fusion.Patch.PCustomSame "MAD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MAD" [], _ ) ->
            Result.Ok Money.MAD

        ( Money.MDL, Fusion.Patch.PCustomSame "MDL" [], _ ) ->
            Result.Ok Money.MDL

        ( _, Fusion.Patch.PCustomSame "MDL" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MDL" [], _ ) ->
            Result.Ok Money.MDL

        ( Money.MGA, Fusion.Patch.PCustomSame "MGA" [], _ ) ->
            Result.Ok Money.MGA

        ( _, Fusion.Patch.PCustomSame "MGA" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MGA" [], _ ) ->
            Result.Ok Money.MGA

        ( Money.MKD, Fusion.Patch.PCustomSame "MKD" [], _ ) ->
            Result.Ok Money.MKD

        ( _, Fusion.Patch.PCustomSame "MKD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MKD" [], _ ) ->
            Result.Ok Money.MKD

        ( Money.MMK, Fusion.Patch.PCustomSame "MMK" [], _ ) ->
            Result.Ok Money.MMK

        ( _, Fusion.Patch.PCustomSame "MMK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MMK" [], _ ) ->
            Result.Ok Money.MMK

        ( Money.MOP, Fusion.Patch.PCustomSame "MOP" [], _ ) ->
            Result.Ok Money.MOP

        ( _, Fusion.Patch.PCustomSame "MOP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MOP" [], _ ) ->
            Result.Ok Money.MOP

        ( Money.MUR, Fusion.Patch.PCustomSame "MUR" [], _ ) ->
            Result.Ok Money.MUR

        ( _, Fusion.Patch.PCustomSame "MUR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MUR" [], _ ) ->
            Result.Ok Money.MUR

        ( Money.MXN, Fusion.Patch.PCustomSame "MXN" [], _ ) ->
            Result.Ok Money.MXN

        ( _, Fusion.Patch.PCustomSame "MXN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MXN" [], _ ) ->
            Result.Ok Money.MXN

        ( Money.MYR, Fusion.Patch.PCustomSame "MYR" [], _ ) ->
            Result.Ok Money.MYR

        ( _, Fusion.Patch.PCustomSame "MYR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MYR" [], _ ) ->
            Result.Ok Money.MYR

        ( Money.MZN, Fusion.Patch.PCustomSame "MZN" [], _ ) ->
            Result.Ok Money.MZN

        ( _, Fusion.Patch.PCustomSame "MZN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MZN" [], _ ) ->
            Result.Ok Money.MZN

        ( Money.NAD, Fusion.Patch.PCustomSame "NAD" [], _ ) ->
            Result.Ok Money.NAD

        ( _, Fusion.Patch.PCustomSame "NAD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "NAD" [], _ ) ->
            Result.Ok Money.NAD

        ( Money.NGN, Fusion.Patch.PCustomSame "NGN" [], _ ) ->
            Result.Ok Money.NGN

        ( _, Fusion.Patch.PCustomSame "NGN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "NGN" [], _ ) ->
            Result.Ok Money.NGN

        ( Money.NIO, Fusion.Patch.PCustomSame "NIO" [], _ ) ->
            Result.Ok Money.NIO

        ( _, Fusion.Patch.PCustomSame "NIO" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "NIO" [], _ ) ->
            Result.Ok Money.NIO

        ( Money.NOK, Fusion.Patch.PCustomSame "NOK" [], _ ) ->
            Result.Ok Money.NOK

        ( _, Fusion.Patch.PCustomSame "NOK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "NOK" [], _ ) ->
            Result.Ok Money.NOK

        ( Money.NPR, Fusion.Patch.PCustomSame "NPR" [], _ ) ->
            Result.Ok Money.NPR

        ( _, Fusion.Patch.PCustomSame "NPR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "NPR" [], _ ) ->
            Result.Ok Money.NPR

        ( Money.NZD, Fusion.Patch.PCustomSame "NZD" [], _ ) ->
            Result.Ok Money.NZD

        ( _, Fusion.Patch.PCustomSame "NZD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "NZD" [], _ ) ->
            Result.Ok Money.NZD

        ( Money.OMR, Fusion.Patch.PCustomSame "OMR" [], _ ) ->
            Result.Ok Money.OMR

        ( _, Fusion.Patch.PCustomSame "OMR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "OMR" [], _ ) ->
            Result.Ok Money.OMR

        ( Money.PAB, Fusion.Patch.PCustomSame "PAB" [], _ ) ->
            Result.Ok Money.PAB

        ( _, Fusion.Patch.PCustomSame "PAB" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "PAB" [], _ ) ->
            Result.Ok Money.PAB

        ( Money.PEN, Fusion.Patch.PCustomSame "PEN" [], _ ) ->
            Result.Ok Money.PEN

        ( _, Fusion.Patch.PCustomSame "PEN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "PEN" [], _ ) ->
            Result.Ok Money.PEN

        ( Money.PHP, Fusion.Patch.PCustomSame "PHP" [], _ ) ->
            Result.Ok Money.PHP

        ( _, Fusion.Patch.PCustomSame "PHP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "PHP" [], _ ) ->
            Result.Ok Money.PHP

        ( Money.PKR, Fusion.Patch.PCustomSame "PKR" [], _ ) ->
            Result.Ok Money.PKR

        ( _, Fusion.Patch.PCustomSame "PKR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "PKR" [], _ ) ->
            Result.Ok Money.PKR

        ( Money.PLN, Fusion.Patch.PCustomSame "PLN" [], _ ) ->
            Result.Ok Money.PLN

        ( _, Fusion.Patch.PCustomSame "PLN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "PLN" [], _ ) ->
            Result.Ok Money.PLN

        ( Money.PYG, Fusion.Patch.PCustomSame "PYG" [], _ ) ->
            Result.Ok Money.PYG

        ( _, Fusion.Patch.PCustomSame "PYG" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "PYG" [], _ ) ->
            Result.Ok Money.PYG

        ( Money.QAR, Fusion.Patch.PCustomSame "QAR" [], _ ) ->
            Result.Ok Money.QAR

        ( _, Fusion.Patch.PCustomSame "QAR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "QAR" [], _ ) ->
            Result.Ok Money.QAR

        ( Money.RON, Fusion.Patch.PCustomSame "RON" [], _ ) ->
            Result.Ok Money.RON

        ( _, Fusion.Patch.PCustomSame "RON" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "RON" [], _ ) ->
            Result.Ok Money.RON

        ( Money.RSD, Fusion.Patch.PCustomSame "RSD" [], _ ) ->
            Result.Ok Money.RSD

        ( _, Fusion.Patch.PCustomSame "RSD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "RSD" [], _ ) ->
            Result.Ok Money.RSD

        ( Money.RUB, Fusion.Patch.PCustomSame "RUB" [], _ ) ->
            Result.Ok Money.RUB

        ( _, Fusion.Patch.PCustomSame "RUB" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "RUB" [], _ ) ->
            Result.Ok Money.RUB

        ( Money.RWF, Fusion.Patch.PCustomSame "RWF" [], _ ) ->
            Result.Ok Money.RWF

        ( _, Fusion.Patch.PCustomSame "RWF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "RWF" [], _ ) ->
            Result.Ok Money.RWF

        ( Money.SAR, Fusion.Patch.PCustomSame "SAR" [], _ ) ->
            Result.Ok Money.SAR

        ( _, Fusion.Patch.PCustomSame "SAR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SAR" [], _ ) ->
            Result.Ok Money.SAR

        ( Money.SDG, Fusion.Patch.PCustomSame "SDG" [], _ ) ->
            Result.Ok Money.SDG

        ( _, Fusion.Patch.PCustomSame "SDG" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SDG" [], _ ) ->
            Result.Ok Money.SDG

        ( Money.SEK, Fusion.Patch.PCustomSame "SEK" [], _ ) ->
            Result.Ok Money.SEK

        ( _, Fusion.Patch.PCustomSame "SEK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SEK" [], _ ) ->
            Result.Ok Money.SEK

        ( Money.SGD, Fusion.Patch.PCustomSame "SGD" [], _ ) ->
            Result.Ok Money.SGD

        ( _, Fusion.Patch.PCustomSame "SGD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SGD" [], _ ) ->
            Result.Ok Money.SGD

        ( Money.SOS, Fusion.Patch.PCustomSame "SOS" [], _ ) ->
            Result.Ok Money.SOS

        ( _, Fusion.Patch.PCustomSame "SOS" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SOS" [], _ ) ->
            Result.Ok Money.SOS

        ( Money.SYP, Fusion.Patch.PCustomSame "SYP" [], _ ) ->
            Result.Ok Money.SYP

        ( _, Fusion.Patch.PCustomSame "SYP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SYP" [], _ ) ->
            Result.Ok Money.SYP

        ( Money.THB, Fusion.Patch.PCustomSame "THB" [], _ ) ->
            Result.Ok Money.THB

        ( _, Fusion.Patch.PCustomSame "THB" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "THB" [], _ ) ->
            Result.Ok Money.THB

        ( Money.TND, Fusion.Patch.PCustomSame "TND" [], _ ) ->
            Result.Ok Money.TND

        ( _, Fusion.Patch.PCustomSame "TND" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TND" [], _ ) ->
            Result.Ok Money.TND

        ( Money.TOP, Fusion.Patch.PCustomSame "TOP" [], _ ) ->
            Result.Ok Money.TOP

        ( _, Fusion.Patch.PCustomSame "TOP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TOP" [], _ ) ->
            Result.Ok Money.TOP

        ( Money.TRY, Fusion.Patch.PCustomSame "TRY" [], _ ) ->
            Result.Ok Money.TRY

        ( _, Fusion.Patch.PCustomSame "TRY" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TRY" [], _ ) ->
            Result.Ok Money.TRY

        ( Money.TTD, Fusion.Patch.PCustomSame "TTD" [], _ ) ->
            Result.Ok Money.TTD

        ( _, Fusion.Patch.PCustomSame "TTD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TTD" [], _ ) ->
            Result.Ok Money.TTD

        ( Money.TWD, Fusion.Patch.PCustomSame "TWD" [], _ ) ->
            Result.Ok Money.TWD

        ( _, Fusion.Patch.PCustomSame "TWD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TWD" [], _ ) ->
            Result.Ok Money.TWD

        ( Money.TZS, Fusion.Patch.PCustomSame "TZS" [], _ ) ->
            Result.Ok Money.TZS

        ( _, Fusion.Patch.PCustomSame "TZS" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TZS" [], _ ) ->
            Result.Ok Money.TZS

        ( Money.UAH, Fusion.Patch.PCustomSame "UAH" [], _ ) ->
            Result.Ok Money.UAH

        ( _, Fusion.Patch.PCustomSame "UAH" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "UAH" [], _ ) ->
            Result.Ok Money.UAH

        ( Money.UGX, Fusion.Patch.PCustomSame "UGX" [], _ ) ->
            Result.Ok Money.UGX

        ( _, Fusion.Patch.PCustomSame "UGX" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "UGX" [], _ ) ->
            Result.Ok Money.UGX

        ( Money.UYU, Fusion.Patch.PCustomSame "UYU" [], _ ) ->
            Result.Ok Money.UYU

        ( _, Fusion.Patch.PCustomSame "UYU" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "UYU" [], _ ) ->
            Result.Ok Money.UYU

        ( Money.UZS, Fusion.Patch.PCustomSame "UZS" [], _ ) ->
            Result.Ok Money.UZS

        ( _, Fusion.Patch.PCustomSame "UZS" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "UZS" [], _ ) ->
            Result.Ok Money.UZS

        ( Money.VED, Fusion.Patch.PCustomSame "VED" [], _ ) ->
            Result.Ok Money.VED

        ( _, Fusion.Patch.PCustomSame "VED" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "VED" [], _ ) ->
            Result.Ok Money.VED

        ( Money.VND, Fusion.Patch.PCustomSame "VND" [], _ ) ->
            Result.Ok Money.VND

        ( _, Fusion.Patch.PCustomSame "VND" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "VND" [], _ ) ->
            Result.Ok Money.VND

        ( Money.XAF, Fusion.Patch.PCustomSame "XAF" [], _ ) ->
            Result.Ok Money.XAF

        ( _, Fusion.Patch.PCustomSame "XAF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "XAF" [], _ ) ->
            Result.Ok Money.XAF

        ( Money.XOF, Fusion.Patch.PCustomSame "XOF" [], _ ) ->
            Result.Ok Money.XOF

        ( _, Fusion.Patch.PCustomSame "XOF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "XOF" [], _ ) ->
            Result.Ok Money.XOF

        ( Money.YER, Fusion.Patch.PCustomSame "YER" [], _ ) ->
            Result.Ok Money.YER

        ( _, Fusion.Patch.PCustomSame "YER" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "YER" [], _ ) ->
            Result.Ok Money.YER

        ( Money.ZAR, Fusion.Patch.PCustomSame "ZAR" [], _ ) ->
            Result.Ok Money.ZAR

        ( _, Fusion.Patch.PCustomSame "ZAR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ZAR" [], _ ) ->
            Result.Ok Money.ZAR

        ( Money.ZMK, Fusion.Patch.PCustomSame "ZMK" [], _ ) ->
            Result.Ok Money.ZMK

        ( _, Fusion.Patch.PCustomSame "ZMK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ZMK" [], _ ) ->
            Result.Ok Money.ZMK

        ( Money.AOA, Fusion.Patch.PCustomSame "AOA" [], _ ) ->
            Result.Ok Money.AOA

        ( _, Fusion.Patch.PCustomSame "AOA" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "AOA" [], _ ) ->
            Result.Ok Money.AOA

        ( Money.XCD, Fusion.Patch.PCustomSame "XCD" [], _ ) ->
            Result.Ok Money.XCD

        ( _, Fusion.Patch.PCustomSame "XCD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "XCD" [], _ ) ->
            Result.Ok Money.XCD

        ( Money.AWG, Fusion.Patch.PCustomSame "AWG" [], _ ) ->
            Result.Ok Money.AWG

        ( _, Fusion.Patch.PCustomSame "AWG" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "AWG" [], _ ) ->
            Result.Ok Money.AWG

        ( Money.BSD, Fusion.Patch.PCustomSame "BSD" [], _ ) ->
            Result.Ok Money.BSD

        ( _, Fusion.Patch.PCustomSame "BSD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BSD" [], _ ) ->
            Result.Ok Money.BSD

        ( Money.BBD, Fusion.Patch.PCustomSame "BBD" [], _ ) ->
            Result.Ok Money.BBD

        ( _, Fusion.Patch.PCustomSame "BBD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BBD" [], _ ) ->
            Result.Ok Money.BBD

        ( Money.BMD, Fusion.Patch.PCustomSame "BMD" [], _ ) ->
            Result.Ok Money.BMD

        ( _, Fusion.Patch.PCustomSame "BMD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BMD" [], _ ) ->
            Result.Ok Money.BMD

        ( Money.BTN, Fusion.Patch.PCustomSame "BTN" [], _ ) ->
            Result.Ok Money.BTN

        ( _, Fusion.Patch.PCustomSame "BTN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "BTN" [], _ ) ->
            Result.Ok Money.BTN

        ( Money.KYD, Fusion.Patch.PCustomSame "KYD" [], _ ) ->
            Result.Ok Money.KYD

        ( _, Fusion.Patch.PCustomSame "KYD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "KYD" [], _ ) ->
            Result.Ok Money.KYD

        ( Money.CUP, Fusion.Patch.PCustomSame "CUP" [], _ ) ->
            Result.Ok Money.CUP

        ( _, Fusion.Patch.PCustomSame "CUP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "CUP" [], _ ) ->
            Result.Ok Money.CUP

        ( Money.ANG, Fusion.Patch.PCustomSame "ANG" [], _ ) ->
            Result.Ok Money.ANG

        ( _, Fusion.Patch.PCustomSame "ANG" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ANG" [], _ ) ->
            Result.Ok Money.ANG

        ( Money.SZL, Fusion.Patch.PCustomSame "SZL" [], _ ) ->
            Result.Ok Money.SZL

        ( _, Fusion.Patch.PCustomSame "SZL" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SZL" [], _ ) ->
            Result.Ok Money.SZL

        ( Money.FKP, Fusion.Patch.PCustomSame "FKP" [], _ ) ->
            Result.Ok Money.FKP

        ( _, Fusion.Patch.PCustomSame "FKP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "FKP" [], _ ) ->
            Result.Ok Money.FKP

        ( Money.FJD, Fusion.Patch.PCustomSame "FJD" [], _ ) ->
            Result.Ok Money.FJD

        ( _, Fusion.Patch.PCustomSame "FJD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "FJD" [], _ ) ->
            Result.Ok Money.FJD

        ( Money.XPF, Fusion.Patch.PCustomSame "XPF" [], _ ) ->
            Result.Ok Money.XPF

        ( _, Fusion.Patch.PCustomSame "XPF" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "XPF" [], _ ) ->
            Result.Ok Money.XPF

        ( Money.GMD, Fusion.Patch.PCustomSame "GMD" [], _ ) ->
            Result.Ok Money.GMD

        ( _, Fusion.Patch.PCustomSame "GMD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "GMD" [], _ ) ->
            Result.Ok Money.GMD

        ( Money.GIP, Fusion.Patch.PCustomSame "GIP" [], _ ) ->
            Result.Ok Money.GIP

        ( _, Fusion.Patch.PCustomSame "GIP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "GIP" [], _ ) ->
            Result.Ok Money.GIP

        ( Money.GYD, Fusion.Patch.PCustomSame "GYD" [], _ ) ->
            Result.Ok Money.GYD

        ( _, Fusion.Patch.PCustomSame "GYD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "GYD" [], _ ) ->
            Result.Ok Money.GYD

        ( Money.HTG, Fusion.Patch.PCustomSame "HTG" [], _ ) ->
            Result.Ok Money.HTG

        ( _, Fusion.Patch.PCustomSame "HTG" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "HTG" [], _ ) ->
            Result.Ok Money.HTG

        ( Money.KPW, Fusion.Patch.PCustomSame "KPW" [], _ ) ->
            Result.Ok Money.KPW

        ( _, Fusion.Patch.PCustomSame "KPW" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "KPW" [], _ ) ->
            Result.Ok Money.KPW

        ( Money.KGS, Fusion.Patch.PCustomSame "KGS" [], _ ) ->
            Result.Ok Money.KGS

        ( _, Fusion.Patch.PCustomSame "KGS" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "KGS" [], _ ) ->
            Result.Ok Money.KGS

        ( Money.LSL, Fusion.Patch.PCustomSame "LSL" [], _ ) ->
            Result.Ok Money.LSL

        ( _, Fusion.Patch.PCustomSame "LSL" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "LSL" [], _ ) ->
            Result.Ok Money.LSL

        ( Money.LRD, Fusion.Patch.PCustomSame "LRD" [], _ ) ->
            Result.Ok Money.LRD

        ( _, Fusion.Patch.PCustomSame "LRD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "LRD" [], _ ) ->
            Result.Ok Money.LRD

        ( Money.MWK, Fusion.Patch.PCustomSame "MWK" [], _ ) ->
            Result.Ok Money.MWK

        ( _, Fusion.Patch.PCustomSame "MWK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MWK" [], _ ) ->
            Result.Ok Money.MWK

        ( Money.MVR, Fusion.Patch.PCustomSame "MVR" [], _ ) ->
            Result.Ok Money.MVR

        ( _, Fusion.Patch.PCustomSame "MVR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MVR" [], _ ) ->
            Result.Ok Money.MVR

        ( Money.MRU, Fusion.Patch.PCustomSame "MRU" [], _ ) ->
            Result.Ok Money.MRU

        ( _, Fusion.Patch.PCustomSame "MRU" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MRU" [], _ ) ->
            Result.Ok Money.MRU

        ( Money.MNT, Fusion.Patch.PCustomSame "MNT" [], _ ) ->
            Result.Ok Money.MNT

        ( _, Fusion.Patch.PCustomSame "MNT" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "MNT" [], _ ) ->
            Result.Ok Money.MNT

        ( Money.PGK, Fusion.Patch.PCustomSame "PGK" [], _ ) ->
            Result.Ok Money.PGK

        ( _, Fusion.Patch.PCustomSame "PGK" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "PGK" [], _ ) ->
            Result.Ok Money.PGK

        ( Money.SHP, Fusion.Patch.PCustomSame "SHP" [], _ ) ->
            Result.Ok Money.SHP

        ( _, Fusion.Patch.PCustomSame "SHP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SHP" [], _ ) ->
            Result.Ok Money.SHP

        ( Money.WST, Fusion.Patch.PCustomSame "WST" [], _ ) ->
            Result.Ok Money.WST

        ( _, Fusion.Patch.PCustomSame "WST" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "WST" [], _ ) ->
            Result.Ok Money.WST

        ( Money.STN, Fusion.Patch.PCustomSame "STN" [], _ ) ->
            Result.Ok Money.STN

        ( _, Fusion.Patch.PCustomSame "STN" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "STN" [], _ ) ->
            Result.Ok Money.STN

        ( Money.SCR, Fusion.Patch.PCustomSame "SCR" [], _ ) ->
            Result.Ok Money.SCR

        ( _, Fusion.Patch.PCustomSame "SCR" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SCR" [], _ ) ->
            Result.Ok Money.SCR

        ( Money.SLE, Fusion.Patch.PCustomSame "SLE" [], _ ) ->
            Result.Ok Money.SLE

        ( _, Fusion.Patch.PCustomSame "SLE" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SLE" [], _ ) ->
            Result.Ok Money.SLE

        ( Money.SBD, Fusion.Patch.PCustomSame "SBD" [], _ ) ->
            Result.Ok Money.SBD

        ( _, Fusion.Patch.PCustomSame "SBD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SBD" [], _ ) ->
            Result.Ok Money.SBD

        ( Money.SSP, Fusion.Patch.PCustomSame "SSP" [], _ ) ->
            Result.Ok Money.SSP

        ( _, Fusion.Patch.PCustomSame "SSP" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SSP" [], _ ) ->
            Result.Ok Money.SSP

        ( Money.SRD, Fusion.Patch.PCustomSame "SRD" [], _ ) ->
            Result.Ok Money.SRD

        ( _, Fusion.Patch.PCustomSame "SRD" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "SRD" [], _ ) ->
            Result.Ok Money.SRD

        ( Money.TJS, Fusion.Patch.PCustomSame "TJS" [], _ ) ->
            Result.Ok Money.TJS

        ( _, Fusion.Patch.PCustomSame "TJS" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TJS" [], _ ) ->
            Result.Ok Money.TJS

        ( Money.TMT, Fusion.Patch.PCustomSame "TMT" [], _ ) ->
            Result.Ok Money.TMT

        ( _, Fusion.Patch.PCustomSame "TMT" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "TMT" [], _ ) ->
            Result.Ok Money.TMT

        ( Money.VUV, Fusion.Patch.PCustomSame "VUV" [], _ ) ->
            Result.Ok Money.VUV

        ( _, Fusion.Patch.PCustomSame "VUV" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "VUV" [], _ ) ->
            Result.Ok Money.VUV

        ( Money.VES, Fusion.Patch.PCustomSame "VES" [], _ ) ->
            Result.Ok Money.VES

        ( _, Fusion.Patch.PCustomSame "VES" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "VES" [], _ ) ->
            Result.Ok Money.VES

        ( Money.ZMW, Fusion.Patch.PCustomSame "ZMW" [], _ ) ->
            Result.Ok Money.ZMW

        ( _, Fusion.Patch.PCustomSame "ZMW" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ZMW" [], _ ) ->
            Result.Ok Money.ZMW

        ( Money.ZWL, Fusion.Patch.PCustomSame "ZWL" [], _ ) ->
            Result.Ok Money.ZWL

        ( _, Fusion.Patch.PCustomSame "ZWL" _, False ) ->
            Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomSame "ZWL" [], _ ) ->
            Result.Ok Money.ZWL

        ( _, Fusion.Patch.PCustomSame _ _, _ ) ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.wrongSame")

        ( _, Fusion.Patch.PCustomChange expectedVariant "USD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.USD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "CAD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.CAD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "EUR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.EUR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BTC" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BTC

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "AED" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.AED

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "AFN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.AFN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ALL" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ALL

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "AMD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.AMD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ARS" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ARS

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "AUD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.AUD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "AZN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.AZN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BAM" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BAM

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BDT" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BDT

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BGN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BGN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BHD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BHD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BIF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BIF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BND" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BND

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BOB" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BOB

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BRL" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BRL

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BWP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BWP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BYN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BYN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BZD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BZD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "CDF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.CDF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "CHF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.CHF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "CLP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.CLP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "CNY" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.CNY

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "COP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.COP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "CRC" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.CRC

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "CVE" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.CVE

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "CZK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.CZK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "DJF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.DJF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "DKK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.DKK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "DOP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.DOP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "DZD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.DZD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "EEK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.EEK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "EGP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.EGP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ERN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ERN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ETB" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ETB

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "GBP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.GBP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "GEL" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.GEL

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "GHS" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.GHS

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "GNF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.GNF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "GTQ" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.GTQ

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "HKD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.HKD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "HNL" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.HNL

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "HRK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.HRK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "HUF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.HUF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "IDR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.IDR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ILS" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ILS

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "INR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.INR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "IQD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.IQD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "IRR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.IRR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ISK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ISK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "JMD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.JMD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "JOD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.JOD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "JPY" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.JPY

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "KES" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.KES

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "KHR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.KHR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "KMF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.KMF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "KRW" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.KRW

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "KWD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.KWD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "KZT" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.KZT

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "LAK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.LAK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "LBP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.LBP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "LKR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.LKR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "LTL" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.LTL

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "LVL" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.LVL

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "LYD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.LYD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MAD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MAD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MDL" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MDL

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MGA" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MGA

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MKD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MKD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MMK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MMK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MOP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MOP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MUR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MUR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MXN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MXN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MYR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MYR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MZN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MZN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "NAD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.NAD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "NGN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.NGN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "NIO" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.NIO

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "NOK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.NOK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "NPR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.NPR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "NZD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.NZD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "OMR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.OMR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "PAB" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.PAB

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "PEN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.PEN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "PHP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.PHP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "PKR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.PKR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "PLN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.PLN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "PYG" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.PYG

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "QAR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.QAR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "RON" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.RON

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "RSD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.RSD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "RUB" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.RUB

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "RWF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.RWF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SAR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SAR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SDG" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SDG

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SEK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SEK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SGD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SGD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SOS" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SOS

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SYP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SYP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "THB" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.THB

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "TND" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.TND

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "TOP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.TOP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "TRY" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.TRY

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "TTD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.TTD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "TWD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.TWD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "TZS" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.TZS

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "UAH" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.UAH

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "UGX" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.UGX

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "UYU" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.UYU

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "UZS" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.UZS

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "VED" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.VED

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "VND" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.VND

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "XAF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.XAF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "XOF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.XOF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "YER" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.YER

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ZAR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ZAR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ZMK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ZMK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "AOA" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.AOA

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "XCD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.XCD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "AWG" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.AWG

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BSD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BSD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BBD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BBD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BMD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BMD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "BTN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.BTN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "KYD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.KYD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "CUP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.CUP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ANG" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ANG

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SZL" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SZL

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "FKP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.FKP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "FJD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.FJD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "XPF" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.XPF

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "GMD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.GMD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "GIP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.GIP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "GYD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.GYD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "HTG" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.HTG

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "KPW" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.KPW

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "KGS" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.KGS

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "LSL" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.LSL

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "LRD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.LRD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MWK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MWK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MVR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MVR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MRU" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MRU

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "MNT" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.MNT

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "PGK" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.PGK

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SHP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SHP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "WST" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.WST

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "STN" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.STN

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SCR" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SCR

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SLE" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SLE

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SBD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SBD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SSP" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SSP

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "SRD" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.SRD

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "TJS" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.TJS

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "TMT" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.TMT

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "VUV" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.VUV

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "VES" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.VES

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ZMW" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ZMW

            else
                Result.Err Fusion.Patch.Conflict

        ( _, Fusion.Patch.PCustomChange expectedVariant "ZWL" [], _ ) ->
            if options.force || isCorrectVariant expectedVariant then
                Result.Ok Money.ZWL

            else
                Result.Err Fusion.Patch.Conflict

        _ ->
            Result.Err (Fusion.Patch.WrongType "patchCustom.lastBranch")


patcher_Currency : Fusion.Patch.Patcher Money.Currency
patcher_Currency =
    { patch = patch_Currency
    , build = build_Currency
    , toValue = toValue_Currency
    }


toValue_Currency : Money.Currency -> Fusion.Value
toValue_Currency value =
    case value of
        Money.USD ->
            Fusion.VCustom "USD" []

        Money.CAD ->
            Fusion.VCustom "CAD" []

        Money.EUR ->
            Fusion.VCustom "EUR" []

        Money.BTC ->
            Fusion.VCustom "BTC" []

        Money.AED ->
            Fusion.VCustom "AED" []

        Money.AFN ->
            Fusion.VCustom "AFN" []

        Money.ALL ->
            Fusion.VCustom "ALL" []

        Money.AMD ->
            Fusion.VCustom "AMD" []

        Money.ARS ->
            Fusion.VCustom "ARS" []

        Money.AUD ->
            Fusion.VCustom "AUD" []

        Money.AZN ->
            Fusion.VCustom "AZN" []

        Money.BAM ->
            Fusion.VCustom "BAM" []

        Money.BDT ->
            Fusion.VCustom "BDT" []

        Money.BGN ->
            Fusion.VCustom "BGN" []

        Money.BHD ->
            Fusion.VCustom "BHD" []

        Money.BIF ->
            Fusion.VCustom "BIF" []

        Money.BND ->
            Fusion.VCustom "BND" []

        Money.BOB ->
            Fusion.VCustom "BOB" []

        Money.BRL ->
            Fusion.VCustom "BRL" []

        Money.BWP ->
            Fusion.VCustom "BWP" []

        Money.BYN ->
            Fusion.VCustom "BYN" []

        Money.BZD ->
            Fusion.VCustom "BZD" []

        Money.CDF ->
            Fusion.VCustom "CDF" []

        Money.CHF ->
            Fusion.VCustom "CHF" []

        Money.CLP ->
            Fusion.VCustom "CLP" []

        Money.CNY ->
            Fusion.VCustom "CNY" []

        Money.COP ->
            Fusion.VCustom "COP" []

        Money.CRC ->
            Fusion.VCustom "CRC" []

        Money.CVE ->
            Fusion.VCustom "CVE" []

        Money.CZK ->
            Fusion.VCustom "CZK" []

        Money.DJF ->
            Fusion.VCustom "DJF" []

        Money.DKK ->
            Fusion.VCustom "DKK" []

        Money.DOP ->
            Fusion.VCustom "DOP" []

        Money.DZD ->
            Fusion.VCustom "DZD" []

        Money.EEK ->
            Fusion.VCustom "EEK" []

        Money.EGP ->
            Fusion.VCustom "EGP" []

        Money.ERN ->
            Fusion.VCustom "ERN" []

        Money.ETB ->
            Fusion.VCustom "ETB" []

        Money.GBP ->
            Fusion.VCustom "GBP" []

        Money.GEL ->
            Fusion.VCustom "GEL" []

        Money.GHS ->
            Fusion.VCustom "GHS" []

        Money.GNF ->
            Fusion.VCustom "GNF" []

        Money.GTQ ->
            Fusion.VCustom "GTQ" []

        Money.HKD ->
            Fusion.VCustom "HKD" []

        Money.HNL ->
            Fusion.VCustom "HNL" []

        Money.HRK ->
            Fusion.VCustom "HRK" []

        Money.HUF ->
            Fusion.VCustom "HUF" []

        Money.IDR ->
            Fusion.VCustom "IDR" []

        Money.ILS ->
            Fusion.VCustom "ILS" []

        Money.INR ->
            Fusion.VCustom "INR" []

        Money.IQD ->
            Fusion.VCustom "IQD" []

        Money.IRR ->
            Fusion.VCustom "IRR" []

        Money.ISK ->
            Fusion.VCustom "ISK" []

        Money.JMD ->
            Fusion.VCustom "JMD" []

        Money.JOD ->
            Fusion.VCustom "JOD" []

        Money.JPY ->
            Fusion.VCustom "JPY" []

        Money.KES ->
            Fusion.VCustom "KES" []

        Money.KHR ->
            Fusion.VCustom "KHR" []

        Money.KMF ->
            Fusion.VCustom "KMF" []

        Money.KRW ->
            Fusion.VCustom "KRW" []

        Money.KWD ->
            Fusion.VCustom "KWD" []

        Money.KZT ->
            Fusion.VCustom "KZT" []

        Money.LAK ->
            Fusion.VCustom "LAK" []

        Money.LBP ->
            Fusion.VCustom "LBP" []

        Money.LKR ->
            Fusion.VCustom "LKR" []

        Money.LTL ->
            Fusion.VCustom "LTL" []

        Money.LVL ->
            Fusion.VCustom "LVL" []

        Money.LYD ->
            Fusion.VCustom "LYD" []

        Money.MAD ->
            Fusion.VCustom "MAD" []

        Money.MDL ->
            Fusion.VCustom "MDL" []

        Money.MGA ->
            Fusion.VCustom "MGA" []

        Money.MKD ->
            Fusion.VCustom "MKD" []

        Money.MMK ->
            Fusion.VCustom "MMK" []

        Money.MOP ->
            Fusion.VCustom "MOP" []

        Money.MUR ->
            Fusion.VCustom "MUR" []

        Money.MXN ->
            Fusion.VCustom "MXN" []

        Money.MYR ->
            Fusion.VCustom "MYR" []

        Money.MZN ->
            Fusion.VCustom "MZN" []

        Money.NAD ->
            Fusion.VCustom "NAD" []

        Money.NGN ->
            Fusion.VCustom "NGN" []

        Money.NIO ->
            Fusion.VCustom "NIO" []

        Money.NOK ->
            Fusion.VCustom "NOK" []

        Money.NPR ->
            Fusion.VCustom "NPR" []

        Money.NZD ->
            Fusion.VCustom "NZD" []

        Money.OMR ->
            Fusion.VCustom "OMR" []

        Money.PAB ->
            Fusion.VCustom "PAB" []

        Money.PEN ->
            Fusion.VCustom "PEN" []

        Money.PHP ->
            Fusion.VCustom "PHP" []

        Money.PKR ->
            Fusion.VCustom "PKR" []

        Money.PLN ->
            Fusion.VCustom "PLN" []

        Money.PYG ->
            Fusion.VCustom "PYG" []

        Money.QAR ->
            Fusion.VCustom "QAR" []

        Money.RON ->
            Fusion.VCustom "RON" []

        Money.RSD ->
            Fusion.VCustom "RSD" []

        Money.RUB ->
            Fusion.VCustom "RUB" []

        Money.RWF ->
            Fusion.VCustom "RWF" []

        Money.SAR ->
            Fusion.VCustom "SAR" []

        Money.SDG ->
            Fusion.VCustom "SDG" []

        Money.SEK ->
            Fusion.VCustom "SEK" []

        Money.SGD ->
            Fusion.VCustom "SGD" []

        Money.SOS ->
            Fusion.VCustom "SOS" []

        Money.SYP ->
            Fusion.VCustom "SYP" []

        Money.THB ->
            Fusion.VCustom "THB" []

        Money.TND ->
            Fusion.VCustom "TND" []

        Money.TOP ->
            Fusion.VCustom "TOP" []

        Money.TRY ->
            Fusion.VCustom "TRY" []

        Money.TTD ->
            Fusion.VCustom "TTD" []

        Money.TWD ->
            Fusion.VCustom "TWD" []

        Money.TZS ->
            Fusion.VCustom "TZS" []

        Money.UAH ->
            Fusion.VCustom "UAH" []

        Money.UGX ->
            Fusion.VCustom "UGX" []

        Money.UYU ->
            Fusion.VCustom "UYU" []

        Money.UZS ->
            Fusion.VCustom "UZS" []

        Money.VED ->
            Fusion.VCustom "VED" []

        Money.VND ->
            Fusion.VCustom "VND" []

        Money.XAF ->
            Fusion.VCustom "XAF" []

        Money.XOF ->
            Fusion.VCustom "XOF" []

        Money.YER ->
            Fusion.VCustom "YER" []

        Money.ZAR ->
            Fusion.VCustom "ZAR" []

        Money.ZMK ->
            Fusion.VCustom "ZMK" []

        Money.AOA ->
            Fusion.VCustom "AOA" []

        Money.XCD ->
            Fusion.VCustom "XCD" []

        Money.AWG ->
            Fusion.VCustom "AWG" []

        Money.BSD ->
            Fusion.VCustom "BSD" []

        Money.BBD ->
            Fusion.VCustom "BBD" []

        Money.BMD ->
            Fusion.VCustom "BMD" []

        Money.BTN ->
            Fusion.VCustom "BTN" []

        Money.KYD ->
            Fusion.VCustom "KYD" []

        Money.CUP ->
            Fusion.VCustom "CUP" []

        Money.ANG ->
            Fusion.VCustom "ANG" []

        Money.SZL ->
            Fusion.VCustom "SZL" []

        Money.FKP ->
            Fusion.VCustom "FKP" []

        Money.FJD ->
            Fusion.VCustom "FJD" []

        Money.XPF ->
            Fusion.VCustom "XPF" []

        Money.GMD ->
            Fusion.VCustom "GMD" []

        Money.GIP ->
            Fusion.VCustom "GIP" []

        Money.GYD ->
            Fusion.VCustom "GYD" []

        Money.HTG ->
            Fusion.VCustom "HTG" []

        Money.KPW ->
            Fusion.VCustom "KPW" []

        Money.KGS ->
            Fusion.VCustom "KGS" []

        Money.LSL ->
            Fusion.VCustom "LSL" []

        Money.LRD ->
            Fusion.VCustom "LRD" []

        Money.MWK ->
            Fusion.VCustom "MWK" []

        Money.MVR ->
            Fusion.VCustom "MVR" []

        Money.MRU ->
            Fusion.VCustom "MRU" []

        Money.MNT ->
            Fusion.VCustom "MNT" []

        Money.PGK ->
            Fusion.VCustom "PGK" []

        Money.SHP ->
            Fusion.VCustom "SHP" []

        Money.WST ->
            Fusion.VCustom "WST" []

        Money.STN ->
            Fusion.VCustom "STN" []

        Money.SCR ->
            Fusion.VCustom "SCR" []

        Money.SLE ->
            Fusion.VCustom "SLE" []

        Money.SBD ->
            Fusion.VCustom "SBD" []

        Money.SSP ->
            Fusion.VCustom "SSP" []

        Money.SRD ->
            Fusion.VCustom "SRD" []

        Money.TJS ->
            Fusion.VCustom "TJS" []

        Money.TMT ->
            Fusion.VCustom "TMT" []

        Money.VUV ->
            Fusion.VCustom "VUV" []

        Money.VES ->
            Fusion.VCustom "VES" []

        Money.ZMW ->
            Fusion.VCustom "ZMW" []

        Money.ZWL ->
            Fusion.VCustom "ZWL" []