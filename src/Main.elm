module Main exposing (..)

import Http exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes.Aria exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Queries exposing (..)
import Date exposing (..)
import Date.Extra as DE
import Navigation


-- MODEL


type alias Movie =
    { title : String
    , poster : String
    , rating : Int
    , runtime : Int
    , tagline : String
    , view_date : String
    }


type alias Movies =
    List Movie


type alias Model =
    { history : List Navigation.Location
    , movies : List Movie
    , error : String
    , selectedMovie : Maybe Movie
    }


baseUrl : String
baseUrl =
    "http://movies-graphql-postgres.a8a18d40.svc.dockerapp.io:3000/graphql?query="


movieDecoder : Decode.Decoder Movie
movieDecoder =
    Pipeline.decode Movie
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "poster" Decode.string
        |> Pipeline.required "rating" Decode.int
        |> Pipeline.required "runtime" Decode.int
        |> Pipeline.required "tagline" Decode.string
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



-- UPDATE


type Msg
    = FetchMovies (Result Http.Error Movies)
    | SelectMovie Movie
    | ResetSelectedMovie
    | UrlChange Navigation.Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchMovies (Ok movies) ->
            ( { model | movies = movies }, Cmd.none )

        FetchMovies (Err err) ->
            ( { model | error = toString err }, Cmd.none )

        SelectMovie movie ->
            ( { model | selectedMovie = Just movie }, Cmd.none )

        ResetSelectedMovie ->
            ( { model | selectedMovie = Nothing }, Cmd.none )

        UrlChange location ->
            ( { model | history = location :: model.history }
            , Cmd.none
            )



-- VIEW


parseDate : String -> String
parseDate date =
    Date.fromString date
        |> Result.withDefault (Date.fromTime 0)
        |> DE.toFormattedString "YYYY-MM-dd"


parseRuntime : Int -> String
parseRuntime runtime =
    let
        hours =
            runtime // 60

        minutes =
            (toFloat hours)
                |> (-) (toFloat runtime / 60)
                |> (*) 60
                |> round
    in
        toString hours ++ " h " ++ toString minutes ++ " min"


listItem : Movie -> Html Msg
listItem movie =
    li
        [ class "movies__movie"
        , onClick (SelectMovie movie)
        , role "button"
        ]
        [ img
            [ class "movies__movie-poster"
            , src ("https://image.tmdb.org/t/p/w500" ++ movie.poster)
            ]
            []
        , a [ href "#test" ] [ text "Test" ]
        , div [ class "movies__movie-content" ]
            [ text movie.title
            , b [] [ text (toString movie.rating) ]
            ]
        ]


displayFeed : Model -> Html Msg
displayFeed model =
    div []
        [ List.map listItem model.movies
            |> ul [ class "movies" ]
        ]


displayMovie : Movie -> Html Msg
displayMovie movie =
    div [ class "selected" ]
        [ a [ onClick ResetSelectedMovie ] [ text "Back" ]
        , div [ class "selected-movie" ]
            [ div [ class "selected-movie__poster" ]
                [ img
                    [ class "movies__movie-poster"
                    , src ("https://image.tmdb.org/t/p/w500" ++ movie.poster)
                    ]
                    []
                ]
            , div [ class "selected-movie__content" ]
                [ h2 [ class "selected-movie__title" ] [ text movie.title ]
                , div []
                    [ text movie.tagline ]
                , div []
                    [ text (parseDate movie.view_date) ]
                , div []
                    [ text (parseRuntime movie.runtime) ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    case model.selectedMovie of
        Just movie ->
            displayMovie movie

        Nothing ->
            displayFeed model



-- INIT


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( Model [ location ] [] "" Nothing
    , Http.send FetchMovies request
    )


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }
