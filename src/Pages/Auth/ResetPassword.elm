module Pages.Auth.ResetPassword exposing (Model, Msg, page)

import Bulma.Classes as B
import Css exposing (..)
import Effect exposing (Effect)
import Gen.Params.Auth.ResetPassword exposing (Params)
import Gen.Route
import Html.Styled exposing (a, div, form, hr, input, label, p, text)
import Html.Styled.Attributes exposing (class, css, href, type_, value)
import Html.Styled.Events exposing (onInput)
import Json.Encode as Json
import Page
import Ports.Auth.ResetPassword as Ports
import Request
import Shared
import View exposing (View)
import Views exposing (submitter)



-- VIEW


view : Model -> View Msg
view model =
    { title = "パスワードリセット"
    , body =
        Views.signInLayout
            [ label [] [ text "ユーザID" ]
            , input [ value model.input.userId, onInput <| ChangeInput setUserId, class B.input ] []
            , label [] [ text "メールで送信したコード" ]
            , input [ value model.input.code, onInput <| ChangeInput setCode, class B.input ] []
            , label [] [ text "新しいパスワード" ]
            , input [ value model.input.password, onInput <| ChangeInput setPassword, class B.input, type_ "password" ] []
            , hr [] []
            , submitter OnSubmit model.loading "変更を実施"
            , p [] [ text model.errorMessage ]
            , div [] [ a [ href <| Gen.Route.toHref Gen.Route.Auth__ForgotPassword ] [ text "コード送信画面に戻る" ] ]
            , div [] [ a [ href <| Gen.Route.toHref Gen.Route.Auth__SignIn ] [ text "サインイン画面に戻る" ] ]
            ]
    }


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ req =
    Page.advanced
        { init = init req
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Input =
    { userId : String
    , code : String
    , password : String
    }


type alias Model =
    { request : Request.With Params
    , input : Input
    , errorMessage : String
    , loading : Bool
    }


init : Request.With Params -> ( Model, Effect Msg )
init req =
    ( { request = req
      , input = { userId = "", code = "", password = "" }
      , errorMessage = ""
      , loading = False
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = ChangeInput (String -> Input -> Input) String
    | OnSubmit
    | SucceedResetPassword Json.Value
    | FailResetPassword Shared.AuthError


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ChangeInput ope v ->
            let
                input =
                    model.input
            in
            ( { model | input = ope v input }, Effect.none )

        OnSubmit ->
            ( { model | loading = True }, Effect.fromCmd <| Ports.resetPassword model.input )

        FailResetPassword err ->
            fail { model | loading = False } err

        SucceedResetPassword _ ->
            ( model, Effect.fromCmd <| Request.pushRoute Gen.Route.Auth__SignIn model.request )


fail : Model -> Shared.AuthError -> ( Model, Effect Msg )
fail model err =
    case err.code of
        "Confirmation code cannot be empty" ->
            ( { model | errorMessage = "全ての欄は入力必須です。" }, Effect.none )

        "Username cannot be empty" ->
            ( { model | errorMessage = "全ての欄は入力必須です。" }, Effect.none )

        "Password cannot be empty" ->
            ( { model | errorMessage = "全ての欄は入力必須です。" }, Effect.none )

        "UserNotFoundException" ->
            ( { model | errorMessage = "ユーザIDがまちがっているようです。" }, Effect.none )

        "InvalidPasswordException" ->
            ( { model | errorMessage = "パスワードには英小文字、英小文字、数字を含めてください。" }, Effect.none )

        "CodeMismatchException" ->
            ( { model | errorMessage = "コードがまちがっているようです。" }, Effect.none )

        _ ->
            ( { model | errorMessage = "失敗しました。" }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.succeedResetPassword SucceedResetPassword
        , Ports.failResetPassword FailResetPassword
        ]


setUserId : String -> Input -> Input
setUserId s i =
    { i | userId = s }


setCode : String -> Input -> Input
setCode s i =
    { i | code = s }


setPassword : String -> Input -> Input
setPassword s i =
    { i | password = s }
