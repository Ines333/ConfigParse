enum Theme: String, Codable {
    case nixie
}

struct Time: Codable {
    var hour: Int
    var minute: Int
    var second: Int
    var millisecond: Int
}

// dayOfWeek:
// 0 sunday, 1 Monday, 2 tuesday, 3 wednesday, 4 thursday, 5 friday, 6 saturday
struct Date: Codable {
    var year: Int
    var month: Int
    var day: Int
    var dayOfWeek: Int
}


// alarm:       alarm0 (on/off, time: hhmm),
//              alarm1 (on/off, time: hhmm),
//              alarm2 (on/off, time: hhmm),
//              alarm3 (on/off, time: hhmm),
//              0-59s
//
// 24h:         0-59s, on/off
// weather:     0-59s
// date:        0-59s
// tempHumi:    0-59s
struct ClockFaceConfig: Codable {
    struct AlarmInfo: Codable  {
        struct AlarmSetting: Codable  {
            var time: Time
            var on: Bool
        }

        var alarmSetting: [AlarmSetting]
        var duration: Int
    }

    struct HourInfo: Codable {
        var hourFormat: HourFormat
        var duration: Int

        enum HourFormat: String, Codable {
            case hour24 = "24-hour"
            case hour12 = "12-hour"
        }
    }

    struct GeneralInfo: Codable {
        var duration: Int
    }

    struct Info: Codable {
        var alarms: AlarmInfo
        var hour: HourInfo
        var weather: GeneralInfo
        var date: GeneralInfo
        var tempHumi: GeneralInfo
    }

    var theme: Theme = .nixie
    var info: Info = Info(
        alarms: AlarmInfo(
            alarmSetting: [
                AlarmInfo.AlarmSetting(time: Time(hour: 8, minute: 30, second: 0, millisecond: 0), on: true),
                AlarmInfo.AlarmSetting(time: Time(hour: 0, minute: 0, second: 0, millisecond: 0), on: false),
                AlarmInfo.AlarmSetting(time: Time(hour: 0, minute: 0, second: 0, millisecond: 0), on: false),
                AlarmInfo.AlarmSetting(time: Time(hour: 0, minute: 0, second: 0, millisecond: 0), on: false)],
            duration: 0),
        hour: HourInfo(hourFormat: .hour24, duration: 1),
        weather: GeneralInfo(duration: 0),
        date: GeneralInfo(duration: 0),
        tempHumi: GeneralInfo(duration: 0))
}



// timer: 59min 59sec
// pomodoro: interval (1-9), timer (1-59min), short break (1-59min), long break (1-59min)
//struct TimerFaceConfig: Codable {
//    var theme: Theme = .nixie
//    var timer: Time = Time(hour: 0, minute: 25, second: 30, millisecond: 0)
//
//    var interval: Int = 0
//    var longBreak: Int = 10
//    var shortBreak: Int = 5
//}


struct TimerFaceConfig: Codable {
    var theme: Theme = .nixie
    var timer: TimerType = .countdownTimer(CountdownTimer())


    struct PomodoroTimer: Codable {
        var pomodoro: Int = 25
        var interval: Int = 4
        var shortBreak: Int = 5
        var longBreak: Int = 10
    }

    struct CountdownTimer: Codable {
        var minute: Int = 25
        var second: Int = 30
    }

    enum TimerType: Codable {
        case countdownTimer(CountdownTimer)
        case pomodoroTimer(PomodoroTimer)

        enum CodingKeys: String, CodingKey {
            case type
        }

        enum ConfigKeys: String, Codable {
            case countdownTimer
            case pomodoroTimer
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(ConfigKeys.self, forKey: .type)

            switch type {
            case .pomodoroTimer:
                let pomodoro = try PomodoroTimer(from: decoder)
                self = .pomodoroTimer(pomodoro)
            case .countdownTimer:
                let countdown = try CountdownTimer(from: decoder)
                self = .countdownTimer(countdown)
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .countdownTimer(let countdown):
                try container.encode(ConfigKeys.countdownTimer, forKey: .type)
                try countdown.encode(to: encoder)
            case .pomodoroTimer(let pomodoro):
                try container.encode(ConfigKeys.pomodoroTimer, forKey: .type)
                try pomodoro.encode(to: encoder)
            }
        }
    }


}





// duration: 0-59s
// TODO - animation (effect + duration)
struct AlbumFaceConfig: Codable {
    var duration: Int = 30
}



enum FaceConfig: Codable {
    case clockFaceConfig(ClockFaceConfig)
    case albumFaceConfig(AlbumFaceConfig)
    case timerFaceConfig(TimerFaceConfig)

    enum CodingKeys: String, CodingKey {
        case face
    }

    enum ConfigKeys: String, Codable {
        case clockFaceConfig
        case albumFaceConfig
        case timerFaceConfig
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ConfigKeys.self, forKey: .face)

        switch type {
        case .clockFaceConfig:
            let clock = try ClockFaceConfig(from: decoder)
            self = .clockFaceConfig(clock)
        case .albumFaceConfig:
            let album = try AlbumFaceConfig(from: decoder)
            self = .albumFaceConfig(album)
        case .timerFaceConfig:
            let timer = try TimerFaceConfig(from: decoder)
            self = .timerFaceConfig(timer)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .clockFaceConfig(let clock):
            try container.encode(ConfigKeys.clockFaceConfig, forKey: .face)
            try clock.encode(to: encoder)
        case .albumFaceConfig(let album):
            try container.encode(ConfigKeys.albumFaceConfig, forKey: .face)
            try album.encode(to: encoder)
        case .timerFaceConfig(let timer):
            try container.encode(ConfigKeys.timerFaceConfig, forKey: .face)
            try timer.encode(to: encoder)
        }
    }
}

struct GlobalConfig: Codable {
    var faceConfigs: [FaceConfig] = [
        .clockFaceConfig(ClockFaceConfig()),
        .timerFaceConfig(TimerFaceConfig()),
        .timerFaceConfig(TimerFaceConfig(timer: .pomodoroTimer(TimerFaceConfig.PomodoroTimer()))),
        .albumFaceConfig(AlbumFaceConfig())]
    var temperatureFormat: TemperatureFormat = .celcius
    var wifiSSID: String? = nil
    var wifiPassword: String? = nil
    var timezone: Int = 0
    var backlight: BacklightEffect = .solid
    var brightness: Int = 5
    var volume: Int = 5
}


enum BacklightEffect: String, Codable {
    case solid
    case marquee
}

enum TemperatureFormat: String, Codable {
    case celcius
    case fahrenheit
}

