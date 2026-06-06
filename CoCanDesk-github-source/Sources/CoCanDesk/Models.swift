import Foundation

struct ManagedDevice: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var endpoint: String

    init(id: UUID = UUID(), name: String, endpoint: String) {
        self.id = id
        self.name = name
        self.endpoint = endpoint
    }
}

struct DeviceSummary: Equatable {
    var name: String = "小电拼"
    var model: String = "--"
    var firmware: String = "--"
    var fpga: String = "--"
    var wifi: String = "--"
    var signal: Int = 0
    var maxPower: Int = 160
    var temperatureMode: String = "--"
    var temperatureModeRaw: Int = 0
}

struct DisplaySummary: Equatable {
    var brightness: String = "--"
    var statusMode: String = "--"
    var idleDisplay: String = "--"
    var hourlyChime: Bool = false
    var supportsAdvancedDisplay: Bool = false
}

struct PortStatus: Identifiable, Equatable {
    var id: Int { index }
    var index: Int
    var name: String
    var connected: Bool
    var charging: Bool
    var device: String
    var protocolName: String
    var watts: Double
    var temperature: String
    var cable: String
    var maxPdp: Int
    var batteryText: String
    var identityText: String
    var pdRevision: String
    var batteryDetail: String
}

struct PowerTrendSample: Identifiable, Equatable {
    var id = UUID()
    var timestamp: Date
    var portWatts: [Int: Double]
}

struct PortHistorySample: Identifiable, Equatable {
    var id = UUID()
    var watts: Double
    var voltage: Double
    var current: Double
}

enum WeatherKind: String, Codable, Equatable, Sendable {
    case clear
    case cloudy
    case fog
    case rain
    case snow
    case storm
    case night
    case local
}

struct WeatherScene: Codable, Equatable, Sendable {
    var city: String
    var temperature: Double?
    var title: String
    var kind: WeatherKind
    var isDay: Bool
    var updatedAt: Date

    var iconName: String {
        switch kind {
        case .clear: return "sun.max.fill"
        case .cloudy: return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case .fog: return "cloud.fog.fill"
        case .rain: return "cloud.rain.fill"
        case .snow: return "cloud.snow.fill"
        case .storm: return "cloud.bolt.rain.fill"
        case .night: return "moon.stars.fill"
        case .local: return isDay ? "sparkles" : "moon.fill"
        }
    }

    var displayTitle: String {
        if let temperature {
            return "\(localizedTitle) · \(Int(temperature.rounded()))°"
        }
        return localizedTitle
    }

    var localizedTitle: String {
        Self.localizedWeatherTitle(title, kind: kind, isDay: isDay)
    }

    static func localizedWeatherTitle(_ rawTitle: String, kind: WeatherKind, isDay: Bool) -> String {
        let cleanTitle = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanTitle.isEmpty {
            return fallbackWeatherTitle(kind: kind, isDay: isDay)
        }
        if cleanTitle.range(of: #"\p{Han}"#, options: .regularExpression) != nil {
            return cleanTitle
        }

        let text = cleanTitle.lowercased()
        if text.contains("thunder") { return "雷雨" }
        if text.contains("blizzard") { return "暴雪" }
        if text.contains("heavy snow") { return "大雪" }
        if text.contains("light snow") || text.contains("patchy snow") { return "小雪" }
        if text.contains("snow") || text.contains("sleet") { return "下雪" }
        if text.contains("heavy rain") { return "大雨" }
        if text.contains("moderate rain") { return "中雨" }
        if text.contains("light rain") || text.contains("drizzle") || text.contains("patchy rain") { return "小雨" }
        if text.contains("shower") { return "阵雨" }
        if text.contains("rain") { return "下雨" }
        if text.contains("overcast") { return "阴" }
        if text.contains("partly cloudy") { return "局部多云" }
        if text.contains("cloud") { return "多云" }
        if text.contains("fog") || text.contains("mist") { return "有雾" }
        if text.contains("clear") || text.contains("sunny") { return isDay ? "晴朗" : "晴夜" }
        return fallbackWeatherTitle(kind: kind, isDay: isDay)
    }

    private static func fallbackWeatherTitle(kind: WeatherKind, isDay: Bool) -> String {
        switch kind {
        case .clear: return "晴朗"
        case .cloudy: return "多云"
        case .fog: return "有雾"
        case .rain: return "下雨"
        case .snow: return "下雪"
        case .storm: return "雷雨"
        case .night: return "夜晚"
        case .local: return isDay ? "本地白天" : "本地夜晚"
        }
    }

    var petHint: String {
        switch kind {
        case .clear: return "阳光很好，糖糖充能更闪亮。"
        case .cloudy: return "云层很软，糖糖进入柔和状态。"
        case .fog: return "外面有雾，糖糖把光收得更稳。"
        case .rain: return "下雨天，糖糖窝在能量罩里。"
        case .snow: return "雪天模式，糖糖保持暖暖充能。"
        case .storm: return "雷雨场景，糖糖需要稳定输出。"
        case .night: return "夜晚场景，糖糖安静发光。"
        case .local: return "本地场景，糖糖跟随你的使用节奏。"
        }
    }

    static func localFallback(city: String = "上海") -> WeatherScene {
        let hour = Calendar.current.component(.hour, from: Date())
        let isDay = (7...18).contains(hour)
        return WeatherScene(
            city: city,
            temperature: nil,
            title: isDay ? "本地白天" : "本地夜晚",
            kind: isDay ? .local : .night,
            isDay: isDay,
            updatedAt: Date()
        )
    }
}

struct ChargerStatus: Equatable {
    var device = DeviceSummary()
    var display = DisplaySummary()
    var ports: [PortStatus] = []
    var updatedAt = Date()

    var totalWatts: Double {
        ports.reduce(0) { $0 + $1.watts }
    }

    var chargingPortCount: Int {
        ports.filter(\.charging).count
    }

    var hasWarmPort: Bool {
        ports.contains { $0.temperature == "warm" }
    }

    var temperatureTitle: String {
        if ports.contains(where: { $0.temperature == "warm" }) {
            return "偏热"
        }
        if ports.contains(where: { $0.temperature == "moderate" }) {
            return "正常"
        }
        return "清凉"
    }

    var temperatureDetail: String {
        let warm = ports.filter { $0.temperature == "warm" }.count
        let moderate = ports.filter { $0.temperature == "moderate" }.count
        if warm > 0 {
            return "\(warm) 个接口偏热"
        }
        if moderate > 0 {
            return "\(moderate) 个接口温和"
        }
        return "接口温度较低"
    }

    static let empty = ChargerStatus()
}

struct AppError: Identifiable {
    var id = UUID()
    var message: String
}

enum PetMood: String, Codable, Equatable, Sendable {
    case resting
    case calm
    case happy
    case excited
    case warm
    case sleepy
    case rainy
    case snowy
    case alert
}

struct WidgetSnapshot: Codable, Equatable, Sendable {
    var deviceName: String
    var totalWatts: Double
    var activePorts: Int
    var maxPower: Int
    var temperatureTitle: String
    var temperatureDetail: String
    var chargingModeName: String
    var weather: WeatherScene
    var petMessage: String
    var petLevel: Int
    var petStageName: String
    var petProgress: Double
    var petVitality: Double
    var petMood: PetMood
    var updatedAt: Date

    static let placeholder = WidgetSnapshot(
        deviceName: "小电拼",
        totalWatts: 0,
        activePorts: 0,
        maxPower: 160,
        temperatureTitle: "待机",
        temperatureDetail: "等待设备数据",
        chargingModeName: "自由流",
        weather: .localFallback(city: "当前位置"),
        petMessage: "糖糖正在等待充能。",
        petLevel: 1,
        petStageName: "糖芽",
        petProgress: 0,
        petVitality: 32,
        petMood: .resting,
        updatedAt: Date()
    )
}
