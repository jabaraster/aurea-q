module Api exposing (..)

import Api.InputObject exposing (..)
import Api.Mutation
import Api.Object
import Api.Object.ModelQuestionConnection
import Api.Object.Question
import Api.Query
import Api.Scalar exposing (AWSDateTime, Id)
import Api.Subscription
import Domain
import Graphql.Http exposing (Request, mutationRequest, queryRequest, send, withHeader)
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Maybe.Extra as Maybe
import RemoteData exposing (RemoteData)


type alias RemoteResource a =
    RemoteData (Graphql.Http.Error a) a


type alias PagingParam =
    { limit : Int
    , nextToken : Maybe String
    }


firstPagingParam : Int -> PagingParam
firstPagingParam limit =
    { nextToken = Nothing, limit = limit }


nextPagingParam : String -> Int -> PagingParam
nextPagingParam nextToken limit =
    { nextToken = Just nextToken, limit = limit }


type alias PagingList a =
    { nextToken : Maybe String
    , items : List a
    }


mapRemoteResource : (a -> b) -> RemoteData (Graphql.Http.Error a) a -> RemoteData (Graphql.Http.Error b) b
mapRemoteResource f =
    RemoteData.mapBoth f (Graphql.Http.mapError f)


type alias PublicAccessParam =
    { graphqlEndpoint : String
    , apiKey : String
    }


withPublicAccessHeader : PublicAccessParam -> Request decodesTo -> Request decodesTo
withPublicAccessHeader param =
    withHeader "X-API-Key" param.apiKey


type alias ProtectedAccessParam =
    { graphqlEndpoint : String
    , jwtToken : Domain.JwtToken
    }


withProtectedAccessHeader : ProtectedAccessParam -> Request decodesTo -> Request decodesTo
withProtectedAccessHeader param =
    withHeader "Authorization" param.jwtToken


type alias PagingListResponse a =
    { nextToken : Maybe String
    , items : List (Maybe a)
    }


type alias Question =
    { id : Id
    , text : String
    , contributorId : String
    , contributionDatetime : AWSDateTime
    }


type alias ContributorId =
    String


listAllQuestions :
    PublicAccessParam
    -> PagingParam
    -> (RemoteResource (PagingList Question) -> msg)
    -> Cmd msg
listAllQuestions param pagingParam handler =
    let
        filter =
            \optArg ->
                { optArg
                    | limit = Present pagingParam.limit
                    , nextToken = Maybe.withDefault Null <| Maybe.map Present pagingParam.nextToken
                }
    in
    sendListQuery param handler <| listQuestionsQuery filter


listQuestions :
    PublicAccessParam
    -> PagingParam
    -> ContributorId
    -> (RemoteResource (PagingList Question) -> msg)
    -> Cmd msg
listQuestions param pagingParam contributorId handler =
    let
        filter =
            \optArg ->
                { optArg
                    | limit = Present pagingParam.limit
                    , nextToken = Maybe.withDefault Null <| Maybe.map Present pagingParam.nextToken
                    , filter =
                        Present <|
                            buildModelQuestionFilterInput
                                (\opt ->
                                    { opt
                                        | contributorId =
                                            Present <| buildModelStringInput (\o -> { o | eq = Present contributorId })
                                    }
                                )
                }
    in
    sendListQuery param handler <| listQuestionsQuery filter


listQuestionsQuery :
    (Api.Query.ListQuestionsOptionalArguments -> Api.Query.ListQuestionsOptionalArguments)
    -> SelectionSet (Maybe (PagingListResponse Question)) RootQuery
listQuestionsQuery filter =
    Api.Query.listQuestions
        filter
        (SelectionSet.succeed PagingListResponse
            |> with Api.Object.ModelQuestionConnection.nextToken
            |> with (Api.Object.ModelQuestionConnection.items questionSelection)
        )


createQuestion :
    PublicAccessParam
    -> Question
    -> (RemoteResource (Maybe Question) -> msg)
    -> Cmd msg
createQuestion param input handler =
    Api.Mutation.createQuestion
        identity
        { input =
            Api.InputObject.buildCreateQuestionInput
                { text = input.text
                , contributorId = input.contributorId
                , contributionDatetime = input.contributionDatetime
                }
                identity
        }
        questionSelection
        |> sendMutation param handler


onCreateQuestion : SelectionSet (Maybe Question) Graphql.Operation.RootSubscription
onCreateQuestion =
    Api.Subscription.onCreateQuestion
        (\opt -> opt)
        questionSelection


questionSelection : SelectionSet Question Api.Object.Question
questionSelection =
    SelectionSet.succeed Question
        |> with Api.Object.Question.id
        |> with Api.Object.Question.text
        |> with Api.Object.Question.contributorId
        |> with Api.Object.Question.contributionDatetime


sendListQuery :
    PublicAccessParam
    -> (RemoteResource (PagingList a) -> msg)
    -> SelectionSet (Maybe (PagingListResponse a)) RootQuery
    -> Cmd msg
sendListQuery param handler =
    queryRequest param.graphqlEndpoint
        >> withPublicAccessHeader param
        >> send
            (RemoteData.fromResult
                >> mapRemoteResource normalize
                >> handler
            )


normalize : Maybe (PagingListResponse a) -> PagingList a
normalize =
    h >> j


h : Maybe (PagingListResponse a) -> Maybe (PagingList a)
h =
    Maybe.map (\src -> { nextToken = src.nextToken, items = Maybe.values src.items })


j : Maybe (PagingList a) -> PagingList a
j =
    Maybe.withDefault
        { nextToken = Nothing, items = [] }


sendMutation :
    PublicAccessParam
    -> (RemoteResource a -> msg)
    -> SelectionSet a RootMutation
    -> Cmd msg
sendMutation param handler =
    mutationRequest param.graphqlEndpoint
        >> withPublicAccessHeader param
        >> send (RemoteData.fromResult >> handler)
