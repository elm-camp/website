module Email.Html.Attributes exposing (alt, attribute, backgroundColor, border, borderBottom, borderBottomColor, borderBottomStyle, borderBottomWidth, borderColor, borderLeft, borderLeftColor, borderLeftStyle, borderLeftWidth, borderRadius, borderRight, borderRightColor, borderRightStyle, borderRightWidth, borderStyle, borderTop, borderTopColor, borderWidth, color, fontFamily, fontSize, fontStyle, fontVariant, height, href, letterSpacing, lineHeight, padding, paddingBottom, paddingLeft, paddingRight, paddingTop, src, style, textAlign, verticalAlign, width)

{-| Only html attributes that are supported by all major email clients are listed here.
If you need something not that's included (and potentially not universally supported) use [`attribute`](#attribute) or [`style`](#style).

These sources were used to determine what should be included:
<https://www.campaignmonitor.com/css/color-background/background/>
<https://www.pinpointe.com/blog/email-campaign-html-and-css-support>
<https://www.caniemail.com/>

Open an issue on github if something is missing or incorrectly included.


# Attributes and styles

@docs alt, attribute, backgroundColor, border, borderBottom, borderBottomColor, borderBottomStyle, borderBottomWidth, borderColor, borderLeft, borderLeftColor, borderLeftStyle, borderLeftWidth, borderRadius, borderRight, borderRightColor, borderRightStyle, borderRightWidth, borderStyle, borderTop, borderTopColor, borderWidth, color, fontFamily, fontSize, fontStyle, fontVariant, height, href, letterSpacing, lineHeight, padding, paddingBottom, paddingLeft, paddingRight, paddingTop, src, style, textAlign, verticalAlign, width

-}

import Email.Html exposing (Attribute)
import Internal


{-| Use this if there's a style you want to add that isn't present in this module.
Note that there's a risk that it isn't supported by some email clients.
-}
style : String -> String -> Attribute
style =
    Internal.StyleAttribute


{-| Use this if there's a attribute you want to add that isn't present in this module.
Note that there's a risk that it isn't supported by some email clients.
-}
attribute : String -> String -> Attribute
attribute =
    Internal.Attribute


{-| -}
backgroundColor : String -> Attribute
backgroundColor =
    Internal.StyleAttribute "background-color"


{-| -}
border : String -> Attribute
border =
    Internal.StyleAttribute "border"


{-| -}
borderRadius : String -> Attribute
borderRadius =
    Internal.StyleAttribute "border-radius"


{-| -}
borderBottom : String -> Attribute
borderBottom =
    Internal.StyleAttribute "border-bottom"


{-| -}
borderBottomColor : String -> Attribute
borderBottomColor =
    Internal.StyleAttribute "border-bottom-color"


{-| -}
borderBottomStyle : String -> Attribute
borderBottomStyle =
    Internal.StyleAttribute "border-bottom-style"


{-| -}
borderBottomWidth : String -> Attribute
borderBottomWidth =
    Internal.StyleAttribute "border-bottom-width"


{-| -}
borderColor : String -> Attribute
borderColor =
    Internal.StyleAttribute "border-color"


{-| -}
borderLeft : String -> Attribute
borderLeft =
    Internal.StyleAttribute "border-left"


{-| -}
borderLeftColor : String -> Attribute
borderLeftColor =
    Internal.StyleAttribute "border-left-color"


{-| -}
borderLeftStyle : String -> Attribute
borderLeftStyle =
    Internal.StyleAttribute "border-left-style"


{-| -}
borderLeftWidth : String -> Attribute
borderLeftWidth =
    Internal.StyleAttribute "border-left-width"


{-| -}
borderRight : String -> Attribute
borderRight =
    Internal.StyleAttribute "border-right"


{-| -}
borderRightColor : String -> Attribute
borderRightColor =
    Internal.StyleAttribute "border-right-color"


{-| -}
borderRightStyle : String -> Attribute
borderRightStyle =
    Internal.StyleAttribute "border-right-style"


{-| -}
borderRightWidth : String -> Attribute
borderRightWidth =
    Internal.StyleAttribute "border-right-width"


{-| -}
borderStyle : String -> Attribute
borderStyle =
    Internal.StyleAttribute "border-style"


{-| -}
borderTop : String -> Attribute
borderTop =
    Internal.StyleAttribute "border-top"


{-| -}
borderTopColor : String -> Attribute
borderTopColor =
    Internal.StyleAttribute "border-top-color"


{-| -}
borderWidth : String -> Attribute
borderWidth =
    Internal.StyleAttribute "border-width"


{-| -}
color : String -> Attribute
color =
    Internal.StyleAttribute "color"


{-| -}
width : String -> Attribute
width =
    Internal.StyleAttribute "width"


{-| -}
maxWidth : String -> Attribute
maxWidth =
    Internal.StyleAttribute "max-width"


{-| -}
minWidth : String -> Attribute
minWidth =
    Internal.StyleAttribute "min-width"


{-| -}
height : String -> Attribute
height =
    Internal.StyleAttribute "height"


{-| -}
padding : String -> Attribute
padding =
    Internal.StyleAttribute "padding"


{-| -}
paddingLeft : String -> Attribute
paddingLeft =
    Internal.StyleAttribute "padding-left"


{-| -}
paddingRight : String -> Attribute
paddingRight =
    Internal.StyleAttribute "padding-right"


{-| -}
paddingBottom : String -> Attribute
paddingBottom =
    Internal.StyleAttribute "padding-bottom"


{-| -}
paddingTop : String -> Attribute
paddingTop =
    Internal.StyleAttribute "padding-top"


{-| -}
lineHeight : String -> Attribute
lineHeight =
    Internal.StyleAttribute "line-height"


{-| -}
fontSize : String -> Attribute
fontSize =
    Internal.StyleAttribute "font-size"


{-| -}
fontFamily : String -> Attribute
fontFamily =
    Internal.StyleAttribute "font-family"


{-| -}
fontStyle : String -> Attribute
fontStyle =
    Internal.StyleAttribute "font-style"


{-| -}
fontVariant : String -> Attribute
fontVariant =
    Internal.StyleAttribute "font-variant"


{-| -}
letterSpacing : String -> Attribute
letterSpacing =
    Internal.StyleAttribute "letter-spacing"


{-| -}
textAlign : String -> Attribute
textAlign =
    Internal.StyleAttribute "text-align"


{-| -}
src : String -> Attribute
src =
    Internal.Attribute "src"


{-| -}
alt : String -> Attribute
alt =
    Internal.Attribute "alt"


{-| -}
href : String -> Attribute
href =
    Internal.Attribute "href"


{-| -}
verticalAlign : String -> Attribute
verticalAlign =
    Internal.Attribute "vertical-align"
