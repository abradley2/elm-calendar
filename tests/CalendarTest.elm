module CalendarTest exposing (..)

import Array
import Calendar exposing (fromDate, fromTime, print)
import Date exposing (day)
import Expect exposing (Expectation)
import Test exposing (Test, describe, test)
import Time exposing (Month(..), Posix, Weekday(..), millisToPosix, utc)


july14th2020 =
    millisToPosix 1594725024442


july14th2020calendar =
    fromTime Nothing utc july14th2020


suite : Test
suite =
    describe "initializes calendar"
        [ test "First day is sunday" <|
            \_ ->
                july14th2020calendar
                    |> List.head
                    |> Maybe.andThen List.head
                    |> Maybe.map .weekdayNumber
                    |> Maybe.map (Expect.equal 7)
                    |> Maybe.withDefault (Expect.fail "Did not generate calendar")
        , test "July 1st is wednesday" <|
            \_ ->
                july14th2020calendar
                    |> List.head
                    |> Maybe.map Array.fromList
                    |> Maybe.andThen (Array.get 3)
                    |> Maybe.map .date
                    |> Maybe.map Date.weekday
                    |> Maybe.map (Expect.equal Wed)
                    |> Maybe.withDefault (Expect.fail "Did not generate calendar")
        , test "Print functionality" <|
            \_ ->
                july14th2020calendar
                    |> print
                    |> (\_ -> Expect.pass)
        , test "Can initialize from time" <|
            \_ ->
                Date.fromCalendarDate 2020 Jul 14
                    |> fromDate Nothing
                    |> print
                    |> Expect.equal (print july14th2020calendar)
        , test "Correctly populates the correct days" <|
            \_ ->
                let
                    expected =
                        [ [ 25, 26, 27, 28, 29, 30, 1 ]
                        , [ 2, 3, 4, 5, 6, 7, 8 ]
                        , [ 9, 10, 11, 12, 13, 14, 15 ]
                        , [ 16, 17, 18, 19, 20, 21, 22 ]
                        , [ 23, 24, 25, 26, 27, 28, 29 ]
                        , [ 30, 31, 1, 2, 3, 4, 5 ]
                        ]
                in
                Date.fromCalendarDate 2021 May 1
                    |> fromDate (Just { startWeekday = Sun })
                    |> List.map (List.map (.date >> day))
                    |> Expect.equal expected
        , test "Correctly adjusts calendar for starting day" <|
            \_ ->
                let
                    expected =
                        [ [ 26, 27, 28, 29, 30, 1, 2 ]
                        , [ 3, 4, 5, 6, 7, 8, 9 ]
                        , [ 10, 11, 12, 13, 14, 15, 16 ]
                        , [ 17, 18, 19, 20, 21, 22, 23 ]
                        , [ 24, 25, 26, 27, 28, 29, 30 ]
                        , [ 31, 1, 2, 3, 4, 5, 6 ]
                        ]
                in
                Date.fromCalendarDate 2021 May 1
                    |> fromDate (Just { startWeekday = Mon })
                    |> List.map (List.map (.date >> day))
                    |> Expect.equal expected
        ]
