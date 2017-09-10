module Main.Update exposing (..)

import Http exposing (..)
import Main.Model exposing (Model, Movie)


-- UPDATE


type Msg
    = FetchMovies (Result Http.Error (List Movie))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchMovies (Ok movies) ->
            { model | movies = movies } ! []

        FetchMovies (Err err) ->
            { model | error = toString err } ! []
