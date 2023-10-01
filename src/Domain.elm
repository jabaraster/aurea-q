module Domain exposing (..)


type alias JwtToken =
    String


type alias SignInUser =
    { userId : String
    , jwtToken : JwtToken
    }


type alias AppConfig =
    { graphqlEndpoint : String
    , apiKey : String
    , user : Maybe SignInUser
    }
