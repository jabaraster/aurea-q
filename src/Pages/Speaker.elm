module Pages.Speaker exposing (Model, Msg, page)

import Api exposing (PagingList, PublicAccessParam, Question, RemoteResource)
import Api.Scalar exposing (AWSDateTime(..), Id(..))
import Domain exposing (AppConfig)
import Gen.Params.Speaker exposing (Params)
import Html.Styled exposing (..)
import Page
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
            , subscriptions = \_ -> Sub.none
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
    = ReplaceMe
    | LoadedQuestions (RemoteResource (PagingList Question))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Cmd.none )

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


fail : Model -> ( Model, Cmd Msg )
fail model =
    ( model, Cmd.none )


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
subscriptions model =
    Sub.none



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
    li [] [ text q.text ]
