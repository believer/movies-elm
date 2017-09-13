module Queries exposing (..)


movieQuery : String
movieQuery =
    """
    query feed {
        feed(userId: 2) {
            title
            poster
            rating
            view_date
            tagline
            runtime
        }
    }
    """
