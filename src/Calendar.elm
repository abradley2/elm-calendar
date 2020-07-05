module Calendar exposing (fromTime)

import Calendar.Config exposing (Config, defaultConfig)
import Date exposing (Date, Unit(..), add, day, fromCalendarDate, month, weekdayNumber)
import Time exposing (Month(..), Posix, Weekday(..), Zone, toMonth, toYear)


type alias Calendar =
    { month : Month
    , year : Int
    , weekdays : List Weekday
    , dates : List CalendarDate
    }


type alias CalendarDate =
    { dayDisplay : String
    , weekdayNumber : Int
    , date : Date
    }


fromTime : Maybe Config -> Zone -> Posix -> List CalendarDate
fromTime mConfig zone posix =
    fromCalendarDate
        (toYear zone posix)
        (toMonth zone posix)
        1
        |> (\date -> ( date, [ CalendarDate " 1" (weekdayNumber date) date ] ))
        |> fillMonth
        |> padMonthStart (Maybe.withDefault defaultConfig mConfig)
        |> padMonthEnd (Maybe.withDefault defaultConfig mConfig)


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
