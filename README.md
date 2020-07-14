# elm-calendar

A "sorta-port" of the Unix `cal` command to Elm. Outputs a "calendar grid" data structure that is very useful for
creating datepickers, planners, and other UI widgets that are based around calendar months.

This library depends on the [justinmimbs/date package](https://github.com/justinmimbs/date) to represent
dates in a non-timezone specific manner.

The `fromDate` and `fromTime` functions output a List of Lists of
data structures containing a [Date](https://package.elm-lang.org/packages/justinmimbs/date/latest/Date#Date).
Each List has a length of exactly seven and is padded as necessary with dates from the next/previous month.

```
import Calendar exposing (fromTime)
import Time exposing (utc, Posix, millisToPosix)

july14th2020 =
    millisToPosix 1594725024442


july14th2020calendar =
    fromTime Nothing utc july14th2020
```

You can also initialize a calendar from a `Date`.

```
import Calendar exposing (fromDate)
import Date exposing (fromCalendarDate)
import Time exposing (Month(..))

july14th2020 =
    fromCalendarDate 2020 Jul 14

july14th2020calendar =
    fromDate Nothing july14th2020
```

By default the week starts on Sunday, which is `weekdayNumber == 7`. This is configurable
via the first argument to either `fromTime` or `fromDate`

[Weekday numbers is 1-7 starting with Monday and ending with Sunday](https://package.elm-lang.org/packages/justinmimbs/date/latest/Date#weekdayNumber).

```
import Calendar exposing (fromTime)
import Time exposing (utc, Posix, millisToPosix)

july14th2020 =
    millisToPosix 1594725024442


startOnMonday =
    fromTime
        (Just { startWeekdayNumber = 1 })
        utc
        july14th2020
```


The `print` function can output a visualization of the calendar. For example, the calendar for July 2020
would print:
```
          1  2  3  4
 5  6  7  8  9 10 11
12 13 14 15 16 17 18
19 20 21 22 23 24 25
26 27 28 29 30 31   
```