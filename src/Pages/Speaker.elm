module Pages.Speaker exposing (Model, Msg, page)

import Css exposing (..)
import Api exposing (PagingList, PublicAccessParam, Question, RemoteResource)
import Api.Scalar exposing (AWSDateTime(..), Id(..))
import Domain exposing (AppConfig)
import Gen.Params.Speaker exposing (Params)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Json.Decode exposing (Value, andThen, field, string, succeed)
import Page
import Ports
import RemoteData exposing (RemoteData(..))
import Request
import Shared
import View exposing (View)
import Views


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared _ =
    Page.protected.element <|
        \_ ->
            { init = init shared
            , update = update
            , view = view
            , subscriptions = subscriptions
            }


loadLimit : Int
loadLimit =
    50



-- INIT


type alias Model =
    { appConfig : AppConfig
    , questionList : List Question
    }


init : Shared.Model -> ( Model, Cmd Msg )
init shared =
    ( { appConfig = shared
      , questionList = []
      }
    , Api.listAllQuestions
        (toPublicAccessParam shared)
        (Api.firstPagingParam loadLimit)
        LoadedQuestions
    )



-- UPDATE


type Msg
    = LoadedQuestions (RemoteResource (PagingList Question))
    | OnCreateQuestion Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadedQuestions (Success pagingList) ->
            let
                newList =
                    model.questionList ++ pagingList.items
            in
            case pagingList.nextToken of
                Nothing ->
                    ( { model | questionList = sortQuestions newList }, Cmd.none )

                Just t ->
                    ( { model | questionList = newList }
                    , Api.listAllQuestions
                        (toPublicAccessParam model.appConfig)
                        (Api.nextPagingParam t loadLimit)
                        LoadedQuestions
                    )

        LoadedQuestions _ ->
            fail model

        OnCreateQuestion val ->
            case decodeQuestion val of
                Ok q ->
                    ( { model | questionList = q :: model.questionList }, Cmd.none )

                Err _ ->
                    fail model


fail : Model -> ( Model, Cmd Msg )
fail model =
    ( model, Cmd.none )


decodeQuestion : Value -> Result Json.Decode.Error Question
decodeQuestion =
    Json.Decode.decodeValue
        questionDecoder


questionDecoder : Json.Decode.Decoder Question
questionDecoder =
    Json.Decode.map4 Question
        (field "id" (andThen (succeed << Id) string))
        (field "text" string)
        (field "contributorId" string)
        (field "contributionDatetime" (andThen (succeed << AWSDateTime) string))


toPublicAccessParam : AppConfig -> PublicAccessParam
toPublicAccessParam appConfig =
    { graphqlEndpoint = appConfig.graphqlEndpoint, apiKey = appConfig.apiKey }


sortQuestions : List Question -> List Question
sortQuestions =
    List.sortBy
        (\q ->
            case q.contributionDatetime of
                AWSDateTime s ->
                    s
        )
        >> List.reverse



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Ports.onCreateQuestion OnCreateQuestion



-- VIEW


view : Model -> View Msg
view model =
    { title = "スピーカー向け画面"
    , body =
        List.map toUnstyled <| viewCore model
    }


viewCore : Model -> List (Html Msg)
viewCore model =
    [ h1 [] [ text "スピーカー向け画面" ]
    , ul [] <| List.map viewQuestion model.questionList
    , Views.globalStyle
    ]


viewQuestion : Question -> Html Msg
viewQuestion q =
    li
        [ css
            [ borderBottom3 (px 1) solid (rgba 130 130 130 0.5)
            , marginBottom (px 5)
            ]
        ]
        [ text q.text ]

