import Foundation
import CoreLocation
import SwiftUI

private let emptyEndpoint = ""
private let placeholderEndpointURL = URL(string: "https://example.invalid/mcp")!
private let devicesStorageKey = "managed.devices"
private let selectedDeviceStorageKey = "managed.selectedDeviceID"
private let energyStorageKey = "managed.energyWh"
private let weatherStorageKey = "weather.scene"
private let foregroundStatusRefreshMilliseconds = 500
private let backgroundStatusRefreshMilliseconds = 3000
private let connectivityRefreshSeconds = 30
private let weatherRefreshSeconds = 600

@MainActor
final class ChargerStore: ObservableObject {
    @AppStorage("endpoint") var endpoint = emptyEndpoint
    @AppStorage("device.displayName") var deviceDisplayName = "我的小电拼"
    @AppStorage("menu.showPower") var menuShowsPower = true
    @AppStorage("menu.showPorts") var menuShowsPorts = true
    @AppStorage("menu.showWarmWarning") var menuShowsWarmWarning = true
    @AppStorage("menu.compact") var menuCompact = false
    @AppStorage("charging.modeName") var chargingModeName = "自由流"
    @Published var status = ChargerStatus.empty
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var allocation = [0, 18, 80, 62, 0]
    @Published var pendingPortIndex: Int?
    @Published var portFeedback: [Int: String] = [:]
    @Published var devices: [ManagedDevice] = []
    @Published var selectedDeviceID: UUID?
    @Published var deviceOnline: [UUID: Bool] = [:]
    @Published var trendSamples: [PowerTrendSample] = []
    @Published var selectedPortIndex: Int?
    @Published var portHistory: [Int: [PortHistorySample]] = [:]
    @Published var loadingHistoryPort: Int?
    @Published var energyByDevice: [UUID: Double] = [:]
    @Published var petMessage = "今天也要甜甜充能。"
    @Published var petPulse = 0
    @Published var weatherScene = WeatherScene.localFallback()
    @Published var isWeatherLoading = false

    private var client: MCPClient
    private let weatherService = WeatherService()
    private let locationService = LocationService()
    private var refreshTask: Task<Void, Never>?
    private var lastEnergySampleAt: Date?
    private var previousStatus: ChargerStatus?
    private var isRefreshingWeather = false
    private var isWindowVisible = false
    private var isAppActive = false
    private var isRealtimeRefreshMode = false
    private var lastConnectivityRefreshAt = Date.distantPast
    private var lastWeatherRefreshAt = Date.distantPast

    init() {
        let savedEndpoint = UserDefaults.standard.string(forKey: "endpoint") ?? emptyEndpoint
        let savedName = UserDefaults.standard.string(forKey: "device.displayName") ?? "我的小电拼"
        let savedDevices = Self.loadDevices()
        let initialSelectedID: UUID?
        if savedDevices.isEmpty {
            initialSelectedID = nil
        } else {
            let savedID = UserDefaults.standard.string(forKey: selectedDeviceStorageKey).flatMap(UUID.init(uuidString:))
            initialSelectedID = savedDevices.contains(where: { $0.id == savedID }) ? savedID : savedDevices.first?.id
        }
        let initialDevice = savedDevices.first { $0.id == initialSelectedID } ?? savedDevices.first
        let initialEndpoint = initialDevice?.endpoint ?? savedEndpoint
        devices = savedDevices
        selectedDeviceID = initialDevice?.id
        endpoint = initialEndpoint
        deviceDisplayName = initialDevice?.name ?? savedName
        energyByDevice = Self.loadEnergy()
        client = MCPClient(endpoint: Self.endpointURL(initialEndpoint) ?? placeholderEndpointURL)
        weatherScene = Self.loadWeather() ?? WeatherScene.localFallback(city: "当前位置")
        if chargingModeName == "无损线补·C1" {
            chargingModeName = "自由流"
        }
        petMessage = initialDevice == nil ? "请先添加你的设备，糖糖会在这里等待充能。" : "欢迎回来，\(deviceDisplayName) 准备充能。"
        saveWidgetSnapshot()
    }

    func startAutoRefresh() {
        guard refreshTask == nil else { return }
        refreshTask?.cancel()
        refreshTask = Task {
            await refresh()
            await refreshDeviceConnectivity()
            lastConnectivityRefreshAt = Date()
            await refreshWeather()
            lastWeatherRefreshAt = Date()
            while !Task.isCancelled {
                try? await Task.sleep(for: currentStatusRefreshDelay)
                await refresh(silent: true)

                let now = Date()
                if now.timeIntervalSince(lastConnectivityRefreshAt) >= Double(connectivityRefreshSeconds) {
                    await refreshDeviceConnectivity()
                    lastConnectivityRefreshAt = now
                }
                if now.timeIntervalSince(lastWeatherRefreshAt) >= Double(weatherRefreshSeconds) {
                    await refreshWeather(silent: true)
                    lastWeatherRefreshAt = now
                }
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    func setMainWindowVisible(_ visible: Bool) {
        isWindowVisible = visible
        updateRefreshMode()
    }

    func setAppActive(_ active: Bool) {
        isAppActive = active
        updateRefreshMode()
    }

    private var currentStatusRefreshDelay: Duration {
        .milliseconds(isRealtimeRefreshMode ? foregroundStatusRefreshMilliseconds : backgroundStatusRefreshMilliseconds)
    }

    private func updateRefreshMode() {
        let nextMode = isWindowVisible && isAppActive
        guard isRealtimeRefreshMode != nextMode else { return }
        isRealtimeRefreshMode = nextMode
        if nextMode {
            Task { await refresh(silent: true) }
        }
    }

    var activeDeviceName: String {
        if devices.isEmpty {
            return "未添加设备"
        }
        if !deviceDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return deviceDisplayName
        }
        return status.device.name
    }

    var temperatureModeName: String {
        status.device.temperatureModeRaw == 0 ? "性能温控" : "安心温控"
    }

    var selectedDevice: ManagedDevice? {
        devices.first { $0.id == selectedDeviceID }
    }

    func selectDevice(_ device: ManagedDevice) {
        guard selectedDeviceID != device.id else { return }
        selectedDeviceID = device.id
        UserDefaults.standard.set(device.id.uuidString, forKey: selectedDeviceStorageKey)
        endpoint = device.endpoint
        deviceDisplayName = device.name
        status = .empty
        trendSamples = []
        lastEnergySampleAt = nil
        previousStatus = nil
        allocation = [0, 18, 80, 62, 0]
        chargingModeName = "自由流"
        pendingPortIndex = nil
        portFeedback = [:]
        selectedPortIndex = nil
        portHistory = [:]
        loadingHistoryPort = nil
        petMessage = "\(device.name) 已切换，糖糖重新识别能量节奏。"
        petPulse += 1
        Task {
            if let url = Self.endpointURL(device.endpoint) {
                await client.updateEndpoint(url)
                await refresh()
            } else {
                status = .empty
                saveWidgetSnapshot()
            }
        }
    }

    func saveDevice() {
        let cleanName = deviceDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEndpoint = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        deviceDisplayName = cleanName
        endpoint = cleanEndpoint
        guard let url = Self.endpointURL(endpoint) else {
            error = AppError(message: "请输入有效的设备连接地址")
            return
        }
        let deviceName = cleanName.isEmpty ? "未命名小电拼" : cleanName
        if let selectedID = selectedDeviceID,
           let index = devices.firstIndex(where: { $0.id == selectedID }) {
            devices[index].name = deviceName
            devices[index].endpoint = cleanEndpoint
        } else {
            let device = ManagedDevice(name: deviceName, endpoint: cleanEndpoint)
            devices.append(device)
            selectedDeviceID = device.id
            UserDefaults.standard.set(device.id.uuidString, forKey: selectedDeviceStorageKey)
        }
        Self.saveDevices(devices)
        Task {
            await client.updateEndpoint(url)
            await refresh()
        }
    }

    @discardableResult
    func addDeviceDraft() -> ManagedDevice {
        let device = ManagedDevice(name: "新的小电拼", endpoint: emptyEndpoint)
        devices.append(device)
        Self.saveDevices(devices)
        selectDevice(device)
        return device
    }

    func saveDevice(_ device: ManagedDevice) {
        deviceDisplayName = device.name.trimmingCharacters(in: .whitespacesAndNewlines)
        endpoint = device.endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        saveDevice()
    }

    func deleteDevice(_ device: ManagedDevice) {
        guard devices.count > 1 else { return }
        devices.removeAll { $0.id == device.id }
        Self.saveDevices(devices)
        if selectedDeviceID == device.id, let nextDevice = devices.first {
            selectDevice(nextDevice)
        }
    }

    private static func loadDevices() -> [ManagedDevice] {
        guard let data = UserDefaults.standard.data(forKey: devicesStorageKey) else { return [] }
        return (try? JSONDecoder().decode([ManagedDevice].self, from: data)) ?? []
    }

    private static func saveDevices(_ devices: [ManagedDevice]) {
        guard let data = try? JSONEncoder().encode(devices) else { return }
        UserDefaults.standard.set(data, forKey: devicesStorageKey)
    }

    nonisolated private static func endpointURL(_ endpoint: String) -> URL? {
        let trimmed = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil
        else { return nil }
        return url
    }

    private static func loadEnergy() -> [UUID: Double] {
        guard let data = UserDefaults.standard.data(forKey: energyStorageKey),
              let raw = try? JSONDecoder().decode([String: Double].self, from: data)
        else { return [:] }
        return Dictionary(uniqueKeysWithValues: raw.compactMap { key, value in
            guard let id = UUID(uuidString: key) else { return nil }
            return (id, value)
        })
    }

    private static func saveEnergy(_ energy: [UUID: Double]) {
        let raw = Dictionary(uniqueKeysWithValues: energy.map { ($0.key.uuidString, $0.value) })
        guard let data = try? JSONEncoder().encode(raw) else { return }
        UserDefaults.standard.set(data, forKey: energyStorageKey)
    }

    private static func loadWeather() -> WeatherScene? {
        guard let data = UserDefaults.standard.data(forKey: weatherStorageKey) else { return nil }
        return try? JSONDecoder().decode(WeatherScene.self, from: data)
    }

    private static func saveWeather(_ scene: WeatherScene) {
        guard let data = try? JSONEncoder().encode(scene) else { return }
        UserDefaults.standard.set(data, forKey: weatherStorageKey)
    }

    func saveEndpoint() {
        saveDevice()
    }

    func refresh(silent: Bool = false) async {
        guard let url = Self.endpointURL(endpoint) else {
            status = .empty
            previousStatus = nil
            if let selectedDeviceID {
                deviceOnline[selectedDeviceID] = false
            }
            saveWidgetSnapshot()
            return
        }
        await client.updateEndpoint(url)
        if !silent { isLoading = true }
        defer { isLoading = false }
        do {
            let oldStatus = status
            let newStatus = try await client.status()
            updateEnergyAndPet(previous: previousStatus ?? oldStatus, current: newStatus)
            previousStatus = newStatus
            status = newStatus
            recordTrendSample()
            saveWidgetSnapshot()
            if let selectedDeviceID {
                deviceOnline[selectedDeviceID] = true
            }
        } catch is CancellationError {
            return
        } catch {
            if let selectedDeviceID {
                deviceOnline[selectedDeviceID] = false
            }
            self.error = AppError(message: error.localizedDescription)
        }
    }

    var currentEnergyWh: Double {
        guard let selectedDeviceID else { return 0 }
        return energyByDevice[selectedDeviceID] ?? 0
    }

    var sharedPetEnergyWh: Double {
        energyByDevice.values.reduce(0, +)
    }

    var petLevel: Int {
        min(60, max(1, Int(sharedPetEnergyWh / 50) + 1))
    }

    var petProgress: Double {
        if petLevel >= 60 { return 1 }
        return (sharedPetEnergyWh.truncatingRemainder(dividingBy: 50)) / 50
    }

    var petVitality: Double {
        let maxPower = Double(max(status.device.maxPower, 1))
        let powerScore = min(max(status.totalWatts / min(maxPower, 32), 0), 1) * 26
        let energyScore = min(sharedPetEnergyWh / 500, 1) * 16
        let portScore = min(Double(status.chargingPortCount) / 3, 1) * 10
        let weatherScore: Double
        switch weatherScene.kind {
        case .clear: weatherScore = 4
        case .snow: weatherScore = 2
        case .rain: weatherScore = -2
        case .storm: weatherScore = -6
        case .night: weatherScore = -3
        default: weatherScore = 0
        }
        let nightAdjustment: Double = weatherScene.isDay ? 0 : -3
        let temperaturePenalty: Double = status.hasWarmPort ? -18 : 0
        let idlePenalty: Double = status.totalWatts < 0.3 ? -5 : 0
        let value = 42 + powerScore + energyScore + portScore + weatherScore + nightAdjustment + temperaturePenalty + idlePenalty
        return min(100, max(18, value))
    }

    var petMood: PetMood {
        if status.hasWarmPort { return .warm }
        if weatherScene.kind == .storm { return .alert }
        if weatherScene.kind == .snow { return .snowy }
        if weatherScene.kind == .rain { return .rainy }
        if !weatherScene.isDay && status.totalWatts < 1 { return .sleepy }
        if status.totalWatts > 18 { return .excited }
        if status.totalWatts > 4 { return .happy }
        if status.totalWatts > 0.5 { return .calm }
        return .resting
    }

    var petStageName: String {
        switch petLevel {
        case 1...9: return "糖芽"
        case 10...19: return "糖豆"
        case 20...29: return "糖星"
        case 30...39: return "糖晶"
        case 40...49: return "糖灵"
        default: return "糖能体"
        }
    }

    func petInteract() {
        if status.totalWatts > 8 {
            petMessage = "糖糖吃到大功率了，整颗糖都亮起来。"
        } else if status.totalWatts > 0.5 {
            petMessage = "糖糖正在慢慢吸收能量。"
        } else {
            petMessage = weatherScene.petHint
        }
        petPulse += 1
        saveWidgetSnapshot()
    }

    func refreshWeather(silent: Bool = false) async {
        guard !isRefreshingWeather else { return }
        isRefreshingWeather = true
        if !silent { isWeatherLoading = true }
        defer {
            isRefreshingWeather = false
            isWeatherLoading = false
        }
        do {
            let location = try await locationService.currentLocation()
            let scene = try await weatherService.scene(for: location)
            weatherScene = scene
            Self.saveWeather(scene)
        } catch {
            if weatherScene.temperature == nil {
                weatherScene = WeatherScene.localFallback(city: "定位未开启")
            }
        }
        petMessage = ambientPetMessage(for: status)
        saveWidgetSnapshot()
    }

    private func updateEnergyAndPet(previous: ChargerStatus, current: ChargerStatus) {
        let now = Date()
        defer { lastEnergySampleAt = now }

        if let lastEnergySampleAt, let selectedDeviceID {
            let seconds = min(max(now.timeIntervalSince(lastEnergySampleAt), 0), 60)
            let addedWh = current.totalWatts * seconds / 3600
            if addedWh > 0 {
                energyByDevice[selectedDeviceID] = (energyByDevice[selectedDeviceID] ?? 0) + addedWh
                Self.saveEnergy(energyByDevice)
            }
        }

        let previousConnected = Set(previous.ports.filter(\.connected).map(\.index))
        let currentConnected = Set(current.ports.filter(\.connected).map(\.index))
        let plugged = currentConnected.subtracting(previousConnected)
        let unplugged = previousConnected.subtracting(currentConnected)
        let deltaPower = current.totalWatts - previous.totalWatts

        if !plugged.isEmpty {
            petMessage = "新设备接入，糖糖开始收集能量。"
            petPulse += 1
        } else if !unplugged.isEmpty {
            petMessage = "有设备离开了，糖糖把能量收好。"
            petPulse += 1
        } else if previous.totalWatts <= 0.2 && current.totalWatts > 0.8 {
            petMessage = "开始充电，糖糖醒来了。"
            petPulse += 1
        } else if deltaPower > 3 {
            petMessage = "功率上来了，糖糖正在发光。"
            petPulse += 1
        } else if deltaPower < -3 {
            petMessage = "功率降下来了，糖糖进入稳态。"
            petPulse += 1
        } else if current.totalWatts > 0.5 {
            petMessage = ambientPetMessage(for: current)
        } else {
            petMessage = ambientPetMessage(for: current)
        }
    }

    private func ambientPetMessage(for status: ChargerStatus) -> String {
        if status.hasWarmPort {
            return "温度有点上来，糖糖正在收住能量。"
        }
        if status.totalWatts > 18 {
            return "\(weatherScene.localizedTitle)场景里，糖糖正在高能充电。"
        }
        if status.totalWatts > 4 {
            return "稳定充能中，糖糖状态不错。"
        }
        if status.totalWatts > 0.5 {
            return "\(weatherScene.localizedTitle)里慢慢补能，糖糖很稳。"
        }
        return weatherScene.petHint
    }

    func refreshDeviceConnectivity() async {
        let devicesSnapshot = devices
        await withTaskGroup(of: (UUID, Bool).self) { group in
            for device in devicesSnapshot {
                group.addTask {
                    guard let url = Self.endpointURL(device.endpoint) else {
                        return (device.id, false)
                    }
                    let client = MCPClient(endpoint: url)
                    do {
                        _ = try await client.status()
                        return (device.id, true)
                    } catch {
                        return (device.id, false)
                    }
                }
            }

            var next: [UUID: Bool] = [:]
            for await result in group {
                next[result.0] = result.1
            }
            deviceOnline = next
        }
    }

    var selectedPort: PortStatus? {
        guard let selectedPortIndex else { return nil }
        return status.ports.first { $0.index == selectedPortIndex }
    }

    func showPortDetails(_ port: PortStatus) {
        selectedPortIndex = port.index
        loadPortHistory(port.index)
    }

    func portTrend(for portIndex: Int) -> [Double] {
        trendSamples.map { $0.portWatts[portIndex] ?? 0 }
    }

    private func recordTrendSample() {
        let values = Dictionary(uniqueKeysWithValues: status.ports.map { ($0.index, $0.watts) })
        trendSamples.append(PowerTrendSample(timestamp: Date(), portWatts: values))
        if trendSamples.count > 120 {
            trendSamples.removeFirst(trendSamples.count - 120)
        }
    }

    func loadPortHistory(_ portIndex: Int) {
        loadingHistoryPort = portIndex
        Task {
            do {
                let samples = try await client.portStats(portIndex)
                portHistory[portIndex] = samples
            } catch is CancellationError {
                return
            } catch {
                portHistory[portIndex] = []
            }
            if loadingHistoryPort == portIndex {
                loadingHistoryPort = nil
            }
        }
    }

    func c2Boost() {
        chargingModeName = "C2 预算优先"
        applyAllocation(
            [0, 18, 80, 62, 0],
            feedbackMessage: "已把更多预算留给 C2，实际功率仍由被充设备和线材协商决定。"
        )
    }

    func c3Max() {
        chargingModeName = "C3 预算优先"
        applyAllocation(
            [0, 18, 18, 124, 0],
            feedbackMessage: "已把更多预算留给 C3，实际功率仍由被充设备和线材协商决定。"
        )
    }

    func applyManualAllocation() {
        applyAllocation(allocation)
    }

    func setFast() {
        Task {
            await self.perform {
                try await self.client.setStrategy(0)
                self.chargingModeName = "自由流"
            }
            self.announceMode("自由流已启动，设备会自动回收和分配功率预算。")
        }
    }

    func setHighPerformance() {
        Task {
            await self.perform {
                try await self.client.setStrategy(7)
                self.chargingModeName = "高性能"
            }
            self.announceMode("高性能策略已启动，实际输出仍由设备协议协商决定。")
        }
    }

    func setSlowMode() {
        setSleepCharge()
    }

    func setSleepCharge() {
        Task {
            await self.perform {
                try await self.client.setStrategy(1)
                self.chargingModeName = "睡眠充"
            }
            self.announceMode("睡眠充已启动，适合夜间长时间慢慢补能。")
        }
    }

    func setUltraSinglePort() {
        setUltraC1Mode()
    }

    func setUsbaMode() {
        Task {
            await self.perform {
                try await self.client.setUsbaMode()
                self.chargingModeName = "小家电"
            }
            self.announceMode("小家电模式已启动，适合原本只认 A 口的设备。")
        }
    }

    func setUltraC1Mode() {
        Task {
            await self.perform {
                try await self.client.setStrategy(8)
                try await self.client.setAllocation([0, 140, 0, 0, 0])
                self.allocation = [0, 140, 0, 0, 0]
                self.chargingModeName = "极速单充·C1"
            }
            self.announceMode("极速单充·C1 已启动，C1 获得单口优先预算。")
        }
    }

    func setAppleFamilyMode() {
        let values = [0, 80, 30, 40, 10]
        Task {
            await self.perform {
                try await self.client.setStrategy(0)
                try await self.client.setAllocation(values)
                self.allocation = values
                self.chargingModeName = "苹果全家桶"
            }
            self.announceMode("苹果全家桶预算已应用：C1 MacBook、C2 iPhone、C3 iPad、C4 Watch。")
        }
    }

    func setCustomMode() {
        let values = allocation
        Task {
            await self.perform {
                try await self.client.setAllocation(values)
                self.chargingModeName = "自定义"
            }
            self.announceMode("自定义预算已应用，实际功率会随设备需求变化。")
        }
    }

    func setPowerPriority() {
        Task {
            await self.perform { try await self.client.setTemperatureMode(0) }
            self.announceMode("性能温控已启动，优先释放输出性能。")
        }
    }

    func setCoolPriority() {
        Task {
            await self.perform { try await self.client.setTemperatureMode(1) }
            self.announceMode("安心温控已启动，温度策略会更保守。")
        }
    }

    func setDisplay(_ level: String) {
        Task { await self.perform { try await self.client.setDisplay(level) } }
    }

    func setStatusDisplayMode(_ mode: String) {
        Task { await self.perform { try await self.client.setStatusDisplayMode(mode) } }
    }

    func setIdleDisplay(_ idleDisplay: String) {
        Task { await self.perform { try await self.client.setIdleDisplay(idleDisplay) } }
    }

    func setHourlyChime(_ enabled: Bool) {
        Task { await self.perform { try await self.client.setHourlyChime(enabled) } }
    }

    func turnPort(_ portIndex: Int, enabled: Bool) {
        guard let url = Self.endpointURL(endpoint) else {
            error = AppError(message: "请先添加有效的设备连接地址")
            return
        }
        error = nil
        pendingPortIndex = portIndex
        portFeedback[portIndex] = enabled ? "正在打开" : "正在关闭"
        Task {
            isLoading = true
            defer {
                isLoading = false
                if pendingPortIndex == portIndex {
                    pendingPortIndex = nil
                }
            }
            do {
                await client.updateEndpoint(url)
                try await client.turnPort(portIndex, enabled: enabled)
                try? await Task.sleep(for: .milliseconds(800))
                let newStatus = try await client.status()
                updateEnergyAndPet(previous: previousStatus ?? status, current: newStatus)
                previousStatus = newStatus
                status = newStatus
                recordTrendSample()
                saveWidgetSnapshot()
                if !enabled,
                   status.ports.first(where: { $0.index == portIndex })?.charging == true {
                    throw NSError(domain: "CoCanDesk", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "\(portName(portIndex)) 仍在输出，设备没有确认关闭。"
                    ])
                }
                portFeedback[portIndex] = enabled ? "已打开" : "已关闭"
                try? await Task.sleep(for: .seconds(1.4))
                portFeedback[portIndex] = nil
            } catch is CancellationError {
                return
            } catch {
                portFeedback[portIndex] = nil
                self.error = AppError(message: error.localizedDescription)
            }
        }
    }

    func maximizePort(_ portIndex: Int) {
        let maxValues = [60, 140, 140, 140, 140]
        guard portIndex >= 1 && portIndex <= maxValues.count else { return }
        var values = [0, 0, 0, 0, 0]
        values[portIndex - 1] = maxValues[portIndex - 1]
        chargingModeName = "\(portName(portIndex)) 预算优先"
        applyAllocation(
            values,
            feedbackMessage: "\(portName(portIndex)) 已获得最高预算，能否提高实际瓦数取决于被充设备需求、线材和电池状态。"
        )
    }

    func maxPowerLabel(for portIndex: Int) -> String {
        portIndex == 1 ? "60W" : "140W"
    }

    func portName(_ portIndex: Int) -> String {
        ["A", "C1", "C2", "C3", "C4"][max(0, min(portIndex - 1, 4))]
    }

    private func applyAllocation(_ values: [Int], feedbackMessage: String? = nil) {
        guard values.count == 5 else { return }
        let total = values.reduce(0, +)
        guard total <= status.device.maxPower else {
            error = AppError(message: "总预算不能超过 \(status.device.maxPower)W")
            return
        }
        allocation = values
        Task {
            await self.perform { try await self.client.setAllocation(values) }
            if let feedbackMessage {
                await MainActor.run {
                    self.petMessage = feedbackMessage
                    self.petPulse += 1
                    self.saveWidgetSnapshot()
                }
            }
        }
    }

    private func perform(_ action: @escaping () async throws -> Void) async {
        guard let url = Self.endpointURL(endpoint) else {
            error = AppError(message: "请先添加有效的设备连接地址")
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            await client.updateEndpoint(url)
            try await action()
            let newStatus = try await client.status()
            updateEnergyAndPet(previous: previousStatus ?? status, current: newStatus)
            previousStatus = newStatus
            status = newStatus
            recordTrendSample()
            saveWidgetSnapshot()
        } catch is CancellationError {
            return
        } catch {
            self.error = AppError(message: error.localizedDescription)
        }
    }

    private func announceMode(_ message: String) {
        petMessage = message
        petPulse += 1
        saveWidgetSnapshot()
    }

    private func saveWidgetSnapshot() {
        let snapshot = WidgetSnapshot(
            deviceName: activeDeviceName,
            totalWatts: status.totalWatts,
            activePorts: status.chargingPortCount,
            maxPower: status.device.maxPower,
            temperatureTitle: status.temperatureTitle,
            temperatureDetail: status.temperatureDetail,
            chargingModeName: chargingModeName,
            weather: weatherScene,
            petMessage: petMessage,
            petLevel: petLevel,
            petStageName: petStageName,
            petProgress: petProgress,
            petVitality: petVitality,
            petMood: petMood,
            updatedAt: status.updatedAt
        )
        WidgetSnapshotStore.save(snapshot)
    }
}

enum WidgetSnapshotStore {
    static var snapshotURL: URL? {
        guard let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return support
            .appendingPathComponent("CoCanDesk", isDirectory: true)
            .appendingPathComponent("WidgetSnapshot.json")
    }

    static func save(_ snapshot: WidgetSnapshot) {
        guard let url = snapshotURL else { return }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: url, options: [.atomic])
        } catch {
            return
        }
    }
}

private actor WeatherService {
    func scene(for location: WeatherLocation) async throws -> WeatherScene {
        do {
            return try await wttrScene(for: location)
        } catch {
            return try await openMeteoScene(for: location)
        }
    }

    private func wttrScene(for location: WeatherLocation) async throws -> WeatherScene {
        let url = try wttrURL(latitude: location.latitude, longitude: location.longitude)
        let (data, _) = try await URLSession.shared.data(from: url)
        guard
            let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let current = (payload["current_condition"] as? [[String: Any]])?.first
        else {
            throw NSError(domain: "CoCanDeskWeather", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "天气数据格式不可用"
            ])
        }

        let code = int(current["weatherCode"])
        let isDay = localIsDay()
        let temperature = double(current["temp_C"])
        let rawTitle = wttrDescription(from: current)
        let kind = weatherKind(wttrCode: code, title: rawTitle, isDay: isDay)
        let title = WeatherScene.localizedWeatherTitle(
            rawTitle ?? weatherTitle(code: code, kind: kind, isDay: isDay),
            kind: kind,
            isDay: isDay
        )

        return WeatherScene(
            city: location.name.isEmpty ? (wttrCity(from: payload) ?? "当前位置") : location.name,
            temperature: temperature,
            title: title,
            kind: kind,
            isDay: isDay,
            updatedAt: Date()
        )
    }

    private func openMeteoScene(for location: WeatherLocation) async throws -> WeatherScene {
        let forecastURL = try openMeteoURL(latitude: location.latitude, longitude: location.longitude)
        let (data, _) = try await URLSession.shared.data(from: forecastURL)
        guard
            let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let current = payload["current"] as? [String: Any]
        else {
            throw NSError(domain: "CoCanDeskWeather", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "天气数据格式不可用"
            ])
        }

        let code = int(current["weather_code"])
        let isDay = int(current["is_day"]) == 1
        let temperature = double(current["temperature_2m"])
        let kind = weatherKind(code: code, isDay: isDay)

        return WeatherScene(
            city: location.name,
            temperature: temperature,
            title: weatherTitle(code: code, kind: kind, isDay: isDay),
            kind: kind,
            isDay: isDay,
            updatedAt: Date()
        )
    }

    func scene(for city: String) async throws -> WeatherScene {
        let location = try await geocode(city: city)
        return try await scene(for: location)
    }

    private func geocode(city: String) async throws -> WeatherLocation {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
        components.queryItems = [
            URLQueryItem(name: "name", value: city),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "language", value: "zh"),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = components.url else {
            throw NSError(domain: "CoCanDeskWeather", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "天气城市格式不可用"
            ])
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard
            let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let results = payload["results"] as? [[String: Any]],
            let first = results.first
        else {
            throw NSError(domain: "CoCanDeskWeather", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "没有找到这个城市"
            ])
        }
        return WeatherLocation(
            name: string(first["name"]) ?? city,
            latitude: double(first["latitude"]),
            longitude: double(first["longitude"])
        )
    }

    private func wttrURL(latitude: Double, longitude: Double) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "wttr.in"
        components.path = "/\(latitude),\(longitude)"
        components.queryItems = [
            URLQueryItem(name: "format", value: "j1"),
            URLQueryItem(name: "lang", value: "zh")
        ]
        guard let url = components.url else {
            throw NSError(domain: "CoCanDeskWeather", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "天气地址不可用"
            ])
        }
        return url
    }

    private func openMeteoURL(latitude: Double, longitude: Double) throws -> URL {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code,is_day")
        ]
        guard let url = components.url else {
            throw NSError(domain: "CoCanDeskWeather", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "天气地址不可用"
            ])
        }
        return url
    }

    private func wttrDescription(from current: [String: Any]) -> String? {
        valueText(current["lang_zh"])
            ?? valueText(current["weatherDesc"])
    }

    private func wttrCity(from payload: [String: Any]) -> String? {
        guard let nearest = (payload["nearest_area"] as? [[String: Any]])?.first else { return nil }
        return valueText(nearest["areaName"]) ?? valueText(nearest["region"])
    }

    private func valueText(_ value: Any?) -> String? {
        if let text = value as? String, !text.isEmpty {
            return text
        }
        if let items = value as? [[String: Any]],
           let text = items.first?["value"] as? String,
           !text.isEmpty {
            return text
        }
        return nil
    }

    private func weatherKind(code: Int, isDay: Bool) -> WeatherKind {
        switch code {
        case 0: return isDay ? .clear : .night
        case 1...3: return .cloudy
        case 45, 48: return .fog
        case 51...67, 80...82: return .rain
        case 71...77, 85...86: return .snow
        case 95...99: return .storm
        default: return isDay ? .local : .night
        }
    }

    private func weatherKind(wttrCode code: Int, title: String?, isDay: Bool) -> WeatherKind {
        switch code {
        case 113: return isDay ? .clear : .night
        case 116, 119, 122: return .cloudy
        case 143, 248, 260: return .fog
        case 176, 185, 263, 266, 281, 284, 293, 296, 299, 302, 305, 308, 311, 314, 317, 320, 353, 356, 359: return .rain
        case 179, 182, 227, 230, 323, 326, 329, 332, 335, 338, 350, 362, 365, 368, 371, 374, 377: return .snow
        case 200, 386, 389, 392, 395: return .storm
        default:
            let text = (title ?? "").lowercased()
            if text.contains("thunder") { return .storm }
            if text.contains("snow") || text.contains("sleet") || text.contains("blizzard") { return .snow }
            if text.contains("rain") || text.contains("drizzle") || text.contains("shower") { return .rain }
            if text.contains("fog") || text.contains("mist") { return .fog }
            if text.contains("cloud") || text.contains("overcast") { return .cloudy }
            if text.contains("clear") || text.contains("sunny") { return isDay ? .clear : .night }
            if text.contains("雷") { return .storm }
            if text.contains("雪") { return .snow }
            if text.contains("雨") { return .rain }
            if text.contains("雾") { return .fog }
            if text.contains("云") || text.contains("阴") { return .cloudy }
            if text.contains("晴") { return isDay ? .clear : .night }
            return isDay ? .local : .night
        }
    }

    private func weatherTitle(code: Int, kind: WeatherKind, isDay: Bool) -> String {
        switch kind {
        case .clear: return "晴朗"
        case .cloudy: return "多云"
        case .fog: return "有雾"
        case .rain: return "下雨"
        case .snow: return "下雪"
        case .storm: return "雷雨"
        case .night: return code == 0 ? "晴夜" : "夜晚"
        case .local: return isDay ? "本地白天" : "本地夜晚"
        }
    }

    private func localIsDay() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return (7...18).contains(hour)
    }
}

private struct WeatherLocation: Sendable {
    var name: String
    var latitude: Double
    var longitude: Double
}

@MainActor
private final class LocationService: NSObject, @preconcurrency CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<WeatherLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func currentLocation() async throws -> WeatherLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation?.resume(throwing: NSError(domain: "CoCanDeskLocation", code: -3, userInfo: [
                NSLocalizedDescriptionKey: "新的定位请求已开始"
            ]))
            self.continuation = continuation
            requestLocationIfPossible()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocationIfPossible()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            finish(with: .failure(NSError(domain: "CoCanDeskLocation", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "没有获取到当前位置"
            ])))
            return
        }

        Task { @MainActor in
            let name = await Self.placeName(for: location)
            finish(with: .success(WeatherLocation(
                name: name,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(with: .failure(error))
    }

    private func requestLocationIfPossible() {
        guard continuation != nil else { return }
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            finish(with: .failure(NSError(domain: "CoCanDeskLocation", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "定位权限未开启"
            ])))
        @unknown default:
            finish(with: .failure(NSError(domain: "CoCanDeskLocation", code: -4, userInfo: [
                NSLocalizedDescriptionKey: "定位状态不可用"
            ])))
        }
    }

    private func finish(with result: Result<WeatherLocation, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        switch result {
        case let .success(location):
            continuation.resume(returning: location)
        case let .failure(error):
            continuation.resume(throwing: error)
        }
    }

    private static func placeName(for location: CLLocation) async -> String {
        await withCheckedContinuation { continuation in
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
                let placemark = placemarks?.first
                let name = placemark?.locality
                    ?? placemark?.subLocality
                    ?? placemark?.administrativeArea
                    ?? "当前位置"
                continuation.resume(returning: name)
            }
        }
    }
}

private func string(_ value: Any?) -> String? {
    guard let value = value as? String, !value.isEmpty else { return nil }
    return value
}

private func int(_ value: Any?) -> Int {
    if let value = value as? Int { return value }
    if let value = value as? Double { return Int(value) }
    if let value = value as? String { return Int(value) ?? 0 }
    return 0
}

private func double(_ value: Any?) -> Double {
    if let value = value as? Double { return value }
    if let value = value as? Int { return Double(value) }
    if let value = value as? String { return Double(value) ?? 0 }
    return 0
}
