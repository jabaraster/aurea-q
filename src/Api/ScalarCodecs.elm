-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.ScalarCodecs exposing (..)

import Api.Scalar exposing (defaultCodecs)
import Json.Decode as Decode exposing (Decoder)


type alias AWSDateTime =
    Api.Scalar.AWSDateTime


type alias Id =
    Api.Scalar.Id


codecs : Api.Scalar.Codecs AWSDateTime Id
codecs =
    Api.Scalar.defineCodecs
        { codecAWSDateTime = defaultCodecs.codecAWSDateTime
        , codecId = defaultCodecs.codecId
        }