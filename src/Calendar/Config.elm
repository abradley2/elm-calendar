module Calendar.Config exposing (Config, defaultConfig)


defaultConfig : Config
defaultConfig =
    { startWeekdayNumber = 7
    }


type alias Config =
    { startWeekdayNumber : Int
    }
