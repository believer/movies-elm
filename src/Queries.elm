module Queries exposing (..)


feedQuery : String
feedQuery =
    """
    query feed {
        feed(userId: 2) {
            id
            title
            poster
            rating
            runtime
            tagline
            view_date
        }
    }
    """


movieQuery : String
movieQuery =
    """
    query movies($movieId: String) {
        movies(movieId: $movieId) {
            id
            title
            poster
            rating
            runtime
            tagline
            view_date
        }
    }
    """
