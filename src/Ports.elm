port module Ports exposing (..)

import Json.Encode exposing (Value)


port getContributorId : () -> Cmd msg


port gotContributorId : (String -> msg) -> Sub msg


port onCreateQuestion : (Value -> msg) -> Sub msg
