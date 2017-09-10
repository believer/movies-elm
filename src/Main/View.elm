module Main.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Main.Model exposing (Model, Movie)
import Main.Update exposing (Msg)
import Date exposing (..)
import Date.Extra as DE


-- VIEW


parseDate : String -> String
parseDate date =
    Date.fromString date
        |> Result.withDefault (Date.fromTime 0)
        |> DE.toFormattedString "YYYY-MM-dd"


listItem : Movie -> Html Msg
listItem movie =
    li [ class "movies__movie" ]
        [ img
            [ class "movies__movie-poster"
            , src ("https://image.tmdb.org/t/p/w500" ++ movie.poster)
            ]
            []
        , div [ class "movies__movie-content" ]
            [ text movie.title
            , b [] [ text (toString movie.rating) ]
            ]
        , div []
            [ text (parseDate movie.view_date) ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ List.map listItem model.movies
            |> ul [ class "movies" ]
        ]
