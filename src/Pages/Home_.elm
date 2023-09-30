module Pages.Home_ exposing (view)

import Bulma.Classes as B
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import View exposing (View)


view : View msg
view =
    { title = "Homepage"
    , body =
        List.map Html.Styled.toUnstyled
            [ h1 [] [ text "Hello, world!" ]
            , button [ class B.button, class B.isWarning ] [ text "hoge" ]
            ]
    }
