module Main exposing (..)

import Http exposing (..)
import Html
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Queries exposing (..)
import Main.Update exposing (..)
import Main.View exposing (view)
import Main.Model exposing (Model, Movie)


baseUrl : String
baseUrl =
    "http://movies-graphql-postgres.a8a18d40.svc.dockerapp.io:3000/graphql?query="


movieDecoder : Decode.Decoder Movie
movieDecoder =
    Pipeline.decode Movie
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "poster" Decode.string
        |> Pipeline.required "rating" Decode.int
        |> Pipeline.required "view_date" Decode.string


request : Http.Request (List Movie)
request =
    let
        encodedQuery =
            Http.encodeUri Queries.movieQuery

        decoder =
            Decode.at [ "data", "feed" ] <|
                Decode.list movieDecoder
    in
        Http.get (baseUrl ++ encodedQuery) decoder



-- INIT


init : ( Model, Cmd Msg )
init =
    { movies = []
    , error = ""
    }
        ! [ Http.send FetchMovies request ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
