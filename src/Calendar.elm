module Calendar exposing (CalendarDate, Config, fromDate, fromTime, print)

import Date exposing (Date, Unit(..), add, day, fromCalendarDate, month, weekdayNumber, year)
import Time exposing (Month(..), Posix, Weekday(..), Zone, toMonth, toYear)


{-| A "sorta-port" of the Unix `cal` command to Elm. Outputs a "calendar grid" data structure that is very useful for
creating datepickers, planners, and other UI widgets that are based around calendar months.


# Main functionality

@docs fromDate, fromTime


# Definitions

@docs CalendarDate


# Configuration

@docs Config


# Silly stuff

@docs print

-}
defaultConfig : Config
defaultConfig =
    { startWeekdayNumber = 7
    }


{-| Optional configuration for the `fromTime` and `fromDate` functions. Can be
used to configure the starting weekday number for each "Week row" of the calendar output.
It is a 1-7 value with 1 representing Monday and 7 representing Sunday.

    import Calendar exposing (fromTime)
    import Time exposing (Posix, millisToPosix, utc)

    july14th2020 =
        millisToPosix 1594725024442

    startOnMonday =
        fromTime
            (Just { startWeekdayNumber = 1 })
            utc
            july14th2020

-}
type alias Config =
    { startWeekdayNumber : Int
    }


{-| The data structure used to represent individual "squares" on the calendar.
A placeholder date will have a `dayDisplay` value of `"  "` and it's `.date` will be the
month for which that week overflows from/into.
-}
type alias CalendarDate =
    { dayDisplay : String
    , weekdayNumber : Int
    , date : Date
    }


{-| Outputs a calendar using a [Posix time](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix).
A calendar is a List representing a Month, with each item being a List of
[Dates](https://package.elm-lang.org/packages/justinmimbs/date/latest/Date#Date) representing individual weeks.
Each week is always 7 day exactly, padded with dates from the previous or next month if that span of week dates
overlaps with another month. This padding is useful for creating most traditional calendar displays.

    import Calendar exposing (fromTime)
    import Time exposing (Posix, millisToPosix, utc)

    july14th2020 =
        millisToPosix 1594725024442

    july14th2020calendar =
        fromTime Nothing utc july14th2020

-}
fromTime : Maybe Config -> Zone -> Posix -> List (List CalendarDate)
fromTime mConfig zone posix =
    fromCalendarDate
        (toYear zone posix)
        (toMonth zone posix)
        1
        |> (\date -> ( date, [ CalendarDate " 1" (weekdayNumber date) date ] ))
        |> fillMonth
        |> padMonthStart (Maybe.withDefault defaultConfig mConfig)
        |> padMonthEnd (Maybe.withDefault defaultConfig mConfig)
        |> List.foldl partitionWeeks []


{-| A version of the `fromTime` function that accepts a
[Date](https://package.elm-lang.org/packages/justinmimbs/date/latest/Date#Date).

    import Calendar exposing (fromDate)
    import Date exposing (fromCalendarDate)
    import Time exposing (Month(..))

    july14th2020 =
        fromCalendarDate 2020 Jul 14

    july14th2020calendar =
        fromDate Nothing july14th2020

-}
fromDate : Maybe Config -> Date -> List (List CalendarDate)
fromDate mConfig date =
    let
        startOfMonth =
            fromCalendarDate
                (year date)
                (month date)
                1
    in
    ( startOfMonth, [ CalendarDate " 1" (weekdayNumber startOfMonth) startOfMonth ] )
        |> fillMonth
        |> padMonthStart (Maybe.withDefault defaultConfig mConfig)
        |> padMonthEnd (Maybe.withDefault defaultConfig mConfig)
        |> List.foldl partitionWeeks []


fillMonth : ( Date, List CalendarDate ) -> List CalendarDate
fillMonth ( currentDate, currentList ) =
    let
        nextDate =
            add Days 1 currentDate
    in
    if month nextDate == month currentDate then
        fillMonth
            ( nextDate
            , currentList
                ++ [ { dayDisplay = day nextDate |> String.fromInt |> String.padLeft 2 ' '
                     , weekdayNumber = weekdayNumber nextDate
                     , date = nextDate
                     }
                   ]
            )

    else
        currentList


padMonthStart : Config -> List CalendarDate -> List CalendarDate
padMonthStart config currentList =
    case
        currentList
            |> List.head
            |> Maybe.map .date
            |> Maybe.andThen
                (\date ->
                    if weekdayNumber date == config.startWeekdayNumber then
                        Nothing

                    else
                        Just (add Days -1 date)
                )
    of
        Just padDate ->
            padMonthStart
                config
                ({ dayDisplay = "  "
                 , weekdayNumber = weekdayNumber padDate
                 , date = padDate
                 }
                    :: currentList
                )

        Nothing ->
            currentList


padMonthEnd : Config -> List CalendarDate -> List CalendarDate
padMonthEnd config currentList =
    case
        currentList
            |> List.reverse
            |> List.head
            |> Maybe.map .date
            |> Maybe.andThen
                (\date ->
                    if weekdayNumber date == endWeekdayNumber config.startWeekdayNumber then
                        Nothing

                    else
                        Just (add Days 1 date)
                )
    of
        Just padDate ->
            padMonthStart
                config
                (List.append
                    currentList
                    [ { dayDisplay = "  "
                      , weekdayNumber = weekdayNumber padDate
                      , date = padDate
                      }
                    ]
                )

        Nothing ->
            currentList


endWeekdayNumber : Int -> Int
endWeekdayNumber startWeekdayNumber =
    if startWeekdayNumber - 1 == 0 then
        7

    else
        startWeekdayNumber - 1


partitionWeeks : CalendarDate -> List (List CalendarDate) -> List (List CalendarDate)
partitionWeeks curDate partitioned =
    case partitioned |> List.reverse |> List.head of
        Just curWeek ->
            case List.length curWeek of
                7 ->
                    partitioned ++ [ [ curDate ] ]

                _ ->
                    partitioned
                        |> List.take (List.length partitioned - 1)
                        |> (\month -> month ++ [ curWeek ++ [ curDate ] ])

        Nothing ->
            partitioned ++ [ [ curDate ] ]


{-| Prints out a string representation of the calendar.
For example, July 2020 (starting on Sunday):

              1  2  3  4
     5  6  7  8  9 10 11
    12 13 14 15 16 17 18
    19 20 21 22 23 24 25
    26 27 28 29 30 31

This really isn't useful for anything but it felt obligatory to
include given the source of inspiration for this package.

-}
print : List (List CalendarDate) -> String
print month =
    List.map
        (\week ->
            List.foldr
                (++)
                ""
                (week |> List.map .dayDisplay |> List.intersperse " ")
        )
        month
        |> List.intersperse "\n"
        |> List.foldr (++) ""
