

module ElmUIExampleTwo where

import StartApp exposing (start)

import Effects exposing (Effects, Never)
import Task
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Time exposing (Time, second)
import Signal exposing (Address)

import ElmUI as UI
import Animation exposing (..)



-- MODEL

type alias Model = { menuAnimation : UI.Model }

-- UPDATE

type Action = Show 
            | Hide
            | Animate UI.Action



update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Show ->
      let 
        (anim, fx) = UI.animate [ UI.fadeIn (0.3*second)
                                , UI.Left UI.Px
                                      (animation 0 
                                        |> from -300 
                                        |> to 0
                                        |> duration (0.3*second))
                                ] model.menuAnimation
      in
        ( { model | menuAnimation = anim }
        , Effects.map Animate fx )

    Hide ->
        let 
          (anim, fx) = UI.animate [ UI.fadeOut (5.0*second)
                                  , UI.Left UI.Px
                                          (animation 0 
                                            |> from 0 
                                            |> to -300
                                            |> duration (0.3*second))
                                  ] model.menuAnimation  
        in
          ( { model | menuAnimation = anim }
          , Effects.map Animate fx )

    Animate action ->
      let
        (anim, fx) = UI.update action model.menuAnimation
      in
        ( { model | menuAnimation = anim }
        , Effects.map Animate fx )




-- VIEW


view : Address Action -> Model -> Html
view address model =
            let
              triggerStyle = [ ("position", "absolute")
                             , ("left", "0px")
                             , ("top", "0px")
                             , ("width", "350px")
                             , ("height", "100%")
                             , ("background-color", "#AAA")
                            ]
            in
              div [ onMouseEnter address Show
                  , onMouseLeave address Hide
                  , style triggerStyle  
                  ]

                  [ h1 [ style [("padding","25px")]] 
                       [ text "Hover here to see menu!"]
                  , viewMenu address model 
                  ]

viewMenu : Address Action -> Model -> Html
viewMenu address model =
                let
                  menuStyle = [ ("opacity", "0")
                                , ("position", "absolute")
                                , ("left", "-300px")
                                , ("top", "0px")
                                , ("padding", "25px")
                                , ("width", "300px")
                                , ("height", "100%")
                                , ("background-color", "rgb(58,40,69)")
                                , ("color", "white")
                              ]
                in
                  div [ style (menuStyle ++ (UI.render model.menuAnimation)) ]
                      [ h1 [] [ text "Hidden Menu"]
                      , ul [] 
                           [ li [] [text "Some things"]
                           , li [] [text "in a list"]
                            ]
                      ]



init : ( Model, Effects Action )
init = ( { menuAnimation=UI.empty }
       , Effects.none )

app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }

main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks