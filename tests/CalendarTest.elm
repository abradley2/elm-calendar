module CalendarTest exposing (..)

import Array
import Calendar exposing (fromDate, fromTime, print)
import Date
import Expect exposing (Expectation)
import Test exposing (Test, describe, test)
import Time exposing (Posix, Month(..), Weekday(..), millisToPosix, utc)


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
        ]
