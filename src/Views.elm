module Views exposing (..)

import Bulma.Classes as B
import Bulma.Helpers
import Css exposing (..)
import Css.Global
import Gen.Route exposing (Route(..))
import Html
import Html.Styled as H
    exposing
        ( Attribute
        , Html
        , a
        , button
        , div
        , hr
        , i
        , label
        , p
        , section
        , span
        , strong
        , styled
        , text
        , textarea
        )
import Html.Styled.Attributes as A exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Lazy exposing (..)
import Loading


{-| Form utility.
-}
form : List (Attribute msg) -> List (Html msg) -> Html msg
form =
    styled H.form
        [ borderRadius (px 4)
        , backgroundColor (rgb 255 255 255)
        , border3 (px 1) solid (rgba 30 30 30 0.3)
        , position absolute
        , padding4 (px 10) (px 10) (px 10) (px 10)
        , top (px 30)
        , right (px 30)
        , left (px 30)
        , maxWidth (px 800)
        , margin2 zero auto
        , maxHeight (vh 90)
        , overflow scroll
        ]


backdrop : List (Attribute msg) -> List (Html msg) -> Html msg
backdrop =
    styled div
        [ backgroundColor (rgba 0 0 0 0.5)
        , position fixed
        , Css.width (vw 100)
        , Css.height (vh 100)
        , top zero
        , left zero
        , zIndex (int 100)
        ]


type alias InputArg msg =
    { value : String
    , label : String
    , placeholder : String
    , type_ : String
    , attributes : List (Attribute msg)
    }


defaultInputArg : InputArg msg
defaultInputArg =
    { value = ""
    , label = ""
    , placeholder = ""
    , type_ = "text"
    , attributes = []
    }


input : (InputArg msg -> InputArg msg) -> (String -> msg) -> Html msg
input argBuilder handler =
    let
        arg =
            argBuilder defaultInputArg

        attrs_ =
            [ class B.input
            , type_ arg.type_
            , placeholder arg.placeholder
            , value arg.value
            , onInput handler
            ]
                ++ arg.attributes
    in
    div []
        [ label [] [ text arg.label ]
        , H.input attrs_ []
        ]


type alias TextAreaArg msg =
    { value : String
    , label : String
    , placeholder : String
    , lineHeight : Int
    , attributes : List (Attribute msg)
    }


defaultTextAreaArg : TextAreaArg msg
defaultTextAreaArg =
    { value = ""
    , label = ""
    , placeholder = ""
    , lineHeight = 6
    , attributes = []
    }


textArea :
    (TextAreaArg msg -> TextAreaArg msg)
    -> (String -> msg)
    -> Html msg
textArea argBuilder handler =
    let
        arg =
            argBuilder defaultTextAreaArg

        attrs_ =
            [ placeholder arg.placeholder
            , class B.textarea
            , value arg.value
            , onInput handler
            ]
                ++ arg.attributes
    in
    div []
        [ label [] [ text arg.label ]
        , textarea attrs_ []
        ]


inputUnderLine : List (Attribute msg) -> List (Html msg) -> Html msg
inputUnderLine attrs =
    let
        tag =
            styled H.input
                [ maxWidth inherit
                , borderStyle none
                , borderRadius zero
                , borderBottom3 (px 1) solid (rgba 0 0 0 0.5)
                , boxShadow none
                ]
    in
    tag <| class B.input :: attrs


{-| Layout utility.
-}
oneColumn : Html msg -> Html msg
oneColumn tag =
    div [ class B.columns ] [ div [ class B.column ] [ tag ] ]


oneColumnNoTopMargin : Html msg -> Html msg
oneColumnNoTopMargin tag =
    div [ class B.columns, css [ marginTop zero ] ] [ div [ class B.column ] [ tag ] ]


oneColumnNoTBMargin : Html msg -> Html msg
oneColumnNoTBMargin tag =
    div [ class B.columns, css [ marginTop zero, marginBottom zero ] ] [ div [ class B.column ] [ tag ] ]


twoColumns : Html msg -> Html msg -> Html msg
twoColumns tag1 tag2 =
    div [ class B.columns ]
        [ div [ class B.column ] [ tag1 ]
        , div [ class B.column ] [ tag2 ]
        ]


select :
    { value : Maybe a
    , values : List a
    , valueToString : a -> String
    , valueToLabel : a -> String
    , handler : String -> msg
    , attributes : List (Attribute msg)
    }
    -> Html msg
select { value, values, valueToString, valueToLabel, handler, attributes } =
    H.select
        (attributes
            ++ [ onInput handler
               , A.value <| Maybe.withDefault "" <| Maybe.map valueToString value
               , class B.input
               ]
        )
    <|
        List.map
            (\optionValue ->
                let
                    valueS =
                        Maybe.withDefault "" <| Maybe.map valueToString value

                    optionValueS =
                        valueToString optionValue
                in
                H.option
                    [ A.value optionValueS
                    , selected <| valueS == optionValueS
                    ]
                    [ text <| valueToLabel optionValue ]
            )
            values


type alias DialogArg msg =
    { html : List (Html msg)
    , cancel : msg
    , ok : msg
    }


dialog : DialogArg msg -> Html msg
dialog arg =
    backdrop []
        [ form [] <|
            arg.html
                ++ [ hr [] []
                   , button [ onClick arg.cancel ] [ text "キャンセル" ]
                   , button [ class B.isDanger, onClick arg.ok ] [ icon Check, span [] [ text "OK" ] ]
                   ]
        ]


concatClass : List String -> Attribute msg
concatClass =
    A.fromUnstyled << Bulma.Helpers.classList


type IconKind
    = Redo
    | Plus
    | Search
    | Pen
    | Trash
    | ArrowRight
    | Check
    | Save
    | Download
    | Eye
    | User
    | Home
    | Globe
    | ExternalLinkAlt
    | Image
    | Bars
    | WindowClose


iconName : IconKind -> String
iconName kind =
    case kind of
        Redo ->
            "redo"

        Plus ->
            "plus"

        Search ->
            "search"

        Pen ->
            "pen"

        Trash ->
            "trash"

        Check ->
            "check"

        ArrowRight ->
            "arrow-right"

        Save ->
            "save"

        Download ->
            "download"

        Eye ->
            "eye"

        User ->
            "user"

        Home ->
            "home"

        Globe ->
            "globe"

        ExternalLinkAlt ->
            "external-link-alt"

        Image ->
            "image"

        Bars ->
            "bars"

        WindowClose ->
            "window-close"


icon : IconKind -> Html msg
icon s =
    iconS (iconName s)


iconS : String -> Html msg
iconS s =
    span [ class B.icon ]
        [ i [ class <| "fas fa-" ++ s ] []
        ]


submitter : msg -> Bool -> String -> Html msg
submitter handler loading labelText =
    H.button
        [ type_ B.button
        , class B.button
        , onClick handler
        , A.disabled loading
        ]
        [ if loading then
            H.fromUnstyled <| Loading.render Loading.DoubleBounce Loading.defaultConfig Loading.On

          else
            text labelText
        ]


type ViewElement msg
    = Tag (Html msg)
    | Tags (List (Html msg))
    | Empty


build : List (ViewElement msg) -> List (Html msg)
build =
    List.foldr
        (\elem list ->
            case elem of
                Tag a ->
                    a :: list

                Tags a ->
                    a ++ list

                Empty ->
                    list
        )
        []


signInLayout : List (Html msg) -> List (Html.Html msg)
signInLayout content =
    List.map
        H.toUnstyled
        [ lazy (\_ -> adminPageHeader) ()
        , section
            [ class B.card
            , css
                [ maxWidth (px 600)
                , margin auto
                , padding (px 14)
                ]
            ]
            content
        , lazy (\_ -> adminPageFooter) ()
        ]


adminPageFooter : Html msg
adminPageFooter =
    H.footer [ class B.footer ]
        [ div [ class B.content, class B.hasTextCentered ]
            [ strong [] [ text "@jabaraster" ]
            ]
        ]


adminPageHeader : Html msg
adminPageHeader =
    section [ class B.hero, class B.isWarning, class B.isSmall ]
        [ div [ class B.heroBody ]
            [ p [ class B.title ] [ text "aurea Question" ]
            ]
        ]


globalStyle : Html msg
globalStyle =
    Css.Global.global
        [ Css.Global.selector "html"
            [ backgroundColor (rgb 0 0 0)
            ]
        , Css.Global.selector "html > body"
            [ color (rgb 230 230 230)
            ]
        , Css.Global.selector "html > body > h1"
            [ fontSize (pct 120)
            , fontWeight bold
            , color (rgb 230 230 230)
            , backgroundColor (rgb 0 0 0)
            ]
        , Css.Global.selector "html > body > h2"
            [ fontSize (pct 110)
            , fontWeight bold
            , color (rgb 230 230 230)
            , backgroundColor (rgb 0 0 0)
            ]
        ]
