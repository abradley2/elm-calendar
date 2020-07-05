# elm-calendar

A "sorta-port" of the Unix `cal` command to Elm. Outputs a "calendar grid" data structure that is very useful for
creating datepickers, planners, and other UI widgets that are based around calendar months.

This library depends on the [justinmimbs/date package](https://github.com/justinmimbs/date) to represent
dates in a non-timezone specific manner.

```
import Calendar exposing (fromTime)
import Time exposing (utc, Posix, millisToPosix)

utcJune5th2020 : Posix =
    millisToPosix 1593966452506

calendar = 
    fromTime utc utcJune5th2020
```