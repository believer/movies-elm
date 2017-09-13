module MainTests exposing (..)

import Main exposing (..)
import Test exposing (..)
import Expect exposing (..)
import String
import ElmTestBDDStyle exposing (..)


all : Test
all =
    describe "Main"
        [ describe "#parseRuntime"
            [ it "it should parse a runtime" <|
                expect (parseRuntime 118) to equal "1 h 58 min"
            ]
        ]
