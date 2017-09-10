module Main.Model exposing (..)

-- MODEL


type alias Movie =
    { title : String
    , poster : String
    , rating : Int
    , view_date : String
    }


type alias Model =
    { movies : List Movie
    , error : String
    }
