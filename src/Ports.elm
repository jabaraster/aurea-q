port module Ports exposing (..)


port getContributorId : () -> Cmd msg


port gotContributorId : (String -> msg) -> Sub msg
