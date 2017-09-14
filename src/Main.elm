module Main exposing (..)

import Http exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes.Aria exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as JD exposing (int, string, float, nullable, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required, optional, hardcoded)
import Queries exposing (..)
import Date exposing (..)
import Date.Extra as DE
import Navigation


-- MODEL


type alias Movie =
    { id : String
    , title : String
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


movieDecoder : Decoder Movie
movieDecoder =
    decode Movie
        |> Pipeline.required "id" string
        |> Pipeline.required "title" string
        |> Pipeline.required "poster" string
        |> Pipeline.optional "rating" int 0
        |> Pipeline.required "runtime" int
        |> Pipeline.required "tagline" string
        |> Pipeline.optional "view_date" string "0000-01-01"


feedRequest : Http.Request (List Movie)
feedRequest =
    let
        encodedQuery =
            Http.encodeUri Queries.feedQuery

        decoder =
            JD.at [ "data", "feed" ] <|
                JD.list movieDecoder
    in
        Http.get (baseUrl ++ encodedQuery) decoder


movieRequest : Movie -> Http.Request (List Movie)
movieRequest movie =
    let
        encodedQuery =
            Http.encodeUri Queries.movieQuery ++ "&variables={\"movieId\":" ++ movie.id ++ "}"

        decoder =
            JD.at [ "data", "movies" ] <|
                JD.list movieDecoder
    in
        Http.get (baseUrl ++ encodedQuery) decoder



-- UPDATE


type Msg
    = FetchMovies (Result Http.Error Movies)
    | FetchMovie (Result Http.Error Movies)
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

        FetchMovie (Ok movies) ->
            ( { model | selectedMovie = List.head movies }, Cmd.none )

        FetchMovie (Err err) ->
            ( { model | error = toString err }, Cmd.none )

        SelectMovie movie ->
            ( model, Http.send FetchMovie (movieRequest movie) )

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
    , Http.send FetchMovies feedRequest
    )


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }
