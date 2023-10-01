module Pages.Home_ exposing (Model, Msg, page)

import Api exposing (PagingList, PublicAccessParam, Question, RemoteResource)
import Api.Scalar exposing (AWSDateTime(..), Id(..))
import Bulma.Classes as B
import Css exposing (..)
import Domain exposing (AppConfig)
import Gen.Params.Home_ exposing (Params)
import Html.Styled as H exposing (Html, h1, h2, hr, li, p, text, textarea, th, ul)
import Html.Styled.Attributes as A exposing (..)
import Html.Styled.Events as H exposing (..)
import Html.Styled.Lazy as H exposing (lazy)
import Iso8601
import Page
import Ports
import RemoteData exposing (RemoteData(..))
import Request
import Shared
import Task
import Time
import View exposing (View)
import Views exposing (submitter)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared _ =
    Page.element
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
    , contributorId : String
    , questionText : String
    , questionList : List Question
    , inProgress : Bool
    }


init : Shared.Model -> ( Model, Cmd Msg )
init shared =
    ( { appConfig = shared
      , contributorId = ""
      , questionText = ""
      , questionList = []
      , inProgress = False
      }
    , Ports.getContributorId ()
    )



-- UPDATE


type Msg
    = GotNow ( Time.Zone, Time.Posix )
    | GotContributorId String
    | LoadedQuestions (RemoteResource (PagingList Question))
    | ChangeQustionText String
    | ClickedSend
    | Saved (RemoteResource (Maybe Question))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotContributorId id ->
            ( { model | contributorId = id }
            , Api.listQuestions
                (toPublicAccessParam model.appConfig)
                (Api.firstPagingParam loadLimit)
                id
                LoadedQuestions
            )

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
                    , Api.listQuestions
                        (toPublicAccessParam model.appConfig)
                        (Api.nextPagingParam t loadLimit)
                        model.contributorId
                        LoadedQuestions
                    )

        LoadedQuestions _ ->
            fail model

        ChangeQustionText s ->
            ( { model | questionText = s }, Cmd.none )

        ClickedSend ->
            if String.trim model.questionText == "" then
                ( model, Cmd.none )

            else
                ( { model | inProgress = True }
                , Task.perform GotNow <| Task.map2 Tuple.pair Time.here Time.now
                )

        GotNow ( _, d ) ->
            ( model
            , Api.createQuestion
                (toPublicAccessParam model.appConfig)
                { id = Id ""
                , text = model.questionText
                , contributorId = model.contributorId
                , contributionDatetime = AWSDateTime <| Iso8601.fromTime d
                }
                Saved
            )

        Saved (Success (Just q)) ->
            ( { model
                | inProgress = False
                , questionList = q :: model.questionList
                , questionText = ""
              }
            , Cmd.none
            )

        Saved _ ->
            fail model


fail : Model -> ( Model, Cmd Msg )
fail model =
    ( model, Cmd.none )


sortQuestions : List Question -> List Question
sortQuestions =
    List.sortBy
        (\q ->
            case q.contributionDatetime of
                AWSDateTime s ->
                    s
        )
        >> List.reverse


toPublicAccessParam : AppConfig -> PublicAccessParam
toPublicAccessParam appConfig =
    { graphqlEndpoint = appConfig.graphqlEndpoint, apiKey = appConfig.apiKey }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Ports.gotContributorId GotContributorId



-- VIEW


view : Model -> View Msg
view model =
    { title = "Home"
    , body =
        List.map H.toUnstyled <| viewCore model
    }


viewCore : Model -> List (Html Msg)
viewCore model =
    [ h1 [] [ text "スピーカーに聞きたいことをどうぞ！" ]
    , p [] [ text "ここから聞けばスピーカーにあなたの名前は伝わりませんので、気軽に聞いてくださいね。" ]
    , p [] [ text "ただ、時間の関係や問いの中身によっては、この場で全部答えられるとは限りません。そうなった時はごめんなさい。" ]
    , H.form [ css [ margin (px 10) ] ]
        [ textarea
            [ class B.input
            , value model.questionText
            , onInput ChangeQustionText
            , css [ Css.height (px 120), marginBottom (em 1) ]
            , A.disabled model.inProgress
            ]
            []
        , submitter ClickedSend model.inProgress "スピーカーに送る"
        , hr [] []
        ]
    , h2 [] [ text "これまでの質問" ]
    , ul [] <| List.map viewQuestion model.questionList
    , lazy (\_ -> Views.globalStyle) ()
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
