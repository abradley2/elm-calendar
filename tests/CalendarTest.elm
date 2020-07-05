module CalendarTest exposing (..)

import Calendar exposing (fromTime)
import Expect exposing (Expectation)
import Test exposing (Test, describe, test)
import Time exposing (Posix, millisToPosix, utc)


june5th2020 =
    millisToPosix 1593966452506


suite : Test
suite =
    describe "initializes calendar"
        [ test "june 5th" <|
            \_ ->
                let
                    cal =
                        fromTime Nothing utc june5th2020
                            |> Debug.log "CAL"
                in
                Expect.pass
        ]
