module Pong exposing (..)

import Html.App as App
import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time, second)

import Collision exposing (..)


main : Program Never
main = App.program
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }


-- INIT


init : (Model, Cmd Msg)
init =
  let
    model =
      { ball = ball
      , player1 = player1 
      , player2 = player2
      , width = 500
      , height = 500
      , backgroundColor = "#333333"
      , framesPerSecond = 60
      }
  in
    (model, Cmd.none)


ball : Ball
ball =
    { pos = Point 65 65
    , size = 10
    , velocity = Point -2 0
    , color = "#00FF00"
    }


player1 : Player
player1 =
    { pos = Point 0 50
    , width = 10
    , height = 40
    , speed = 5
    , color = "#FF0000"
    }


player2 : Player
player2 =
    { pos = Point 300 50
    , width = 10
    , height = 40
    , speed = 5
    , color = "#0000FF"
    }


-- MODEL


type alias Model =
  { ball : Ball
  , player1 : Player
  , player2 : Player
  , width : Int
  , height : Int
  , backgroundColor : String
  , framesPerSecond : Float
  }


type alias Ball =
  { pos : Point
  , size : Int
  , velocity : Point
  , color : String
  }


type alias Player =
  { pos : Point
  , width : Int
  , height : Int
  , speed : Int
  , color : String
  }


type alias Point =
  { x : Int
  , y : Int
  }


-- UPDATE


type Msg
  = MoveBall Time


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of 
    MoveBall time ->
      let 
        newModel = { model | ball = updateBall model }
      in 
        (newModel, Cmd.none)


updateBall : Model -> Ball
updateBall model =
  let
    { player1, player2 } = model

    player1Box =
      let
        { pos, width, height } = player1
        { x, y } = pos
      in
        getRectBox x y width height

    player2Box =
      let
        { pos, width, height } = player2
        { x, y } = pos
      in
        getRectBox x y width height

    ballBox =
      let
        { pos, size } = model.ball
        { x, y } = pos
        radius = size // 2
      in
        getCircleBox x y radius

    boundsBox = getRectBox 0 0 model.width model.height

    collision = getCollision ballBox player1Box player2Box boundsBox
    foo = Debug.log(toString collision)

    (dx, dy) =
      case collision of
        Just LeftPaddleCollision ->
          (-1, 1)

        Just RightPaddleCollision ->
          (-1, 1)

        Just TopCollision ->
          (1, -1)

        Just BottomCollision ->
          (1, -1)

        Just LeftCollision ->
          -- TODO: handle scoring
          (-1, 1)

        Just RightCollision ->
          -- TODO: handle scoring
          (-1, 1)

        Nothing ->
          (1, 1)

    newBall =
      let
        ball = model.ball
        { x, y } = ball.velocity
      in
        { ball | velocity = Point (x * dx) (y * dy) }
   in
     moveBall newBall


moveBall : Ball -> Ball
moveBall ball =
  let
    { x, y } = ball.pos
    vx = ball.velocity.x
    vy = ball.velocity.y
    newPos = Point (x + vx) (y + vy)
  in
    { ball | pos = newPos }


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model = Time.every (second / model.framesPerSecond) MoveBall


-- VIEW


view : Model -> Html Msg
view model =
  let
    boxAttrs =
      [ width (toString model.width)
      , height (toString model.height)
      , x "0", y "0"
      ]
  in
    svg boxAttrs 
      [ rect (fill model.backgroundColor :: boxAttrs) []
      , viewPlayer model.player1
      , viewBall model.ball
      , viewPlayer model.player2
      ]


viewPlayer : Player -> Html Msg
viewPlayer player =
  let
    playerWidth = toString player.width
    playerHeight = toString player.height
    playerX = toString player.pos.x
    playerY = toString player.pos.y
  in
    rect
      [ width playerWidth
      , height playerHeight
      , x playerX
      , y playerY
      , fill player.color
      ] []


viewBall : Ball -> Html Msg
viewBall ball =
  let
    radius = toString (ball.size // 2)
    ballX = toString ball.pos.x
    ballY = toString ball.pos.y
  in
    circle [ cx ballX, cy ballY, r radius, fill ball.color ] []

