module Name exposing (Error(..), Name(..), anonymous, errorToString, fromString, maxLength, toString)


type Name
    = Name String


type Error
    = NameTooShort
    | NameTooLong


minLength : number
minLength =
    1


maxLength : number
maxLength =
    100


fromString : String -> Result Error Name
fromString text =
    let
        trimmed =
            String.trim text
    in
    if String.length trimmed < minLength then
        Err NameTooShort

    else if String.length trimmed > maxLength then
        Err NameTooLong

    else
        Ok (Name trimmed)


errorToString : Error -> String
errorToString error =
    case error of
        NameTooShort ->
            "Please enter a name"

        NameTooLong ->
            "Name too long"


toString : Name -> String
toString (Name groupName) =
    groupName


anonymous : Name
anonymous =
    Name "Anonymous"
