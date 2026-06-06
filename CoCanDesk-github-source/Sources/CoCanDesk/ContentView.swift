import Foundation
import SwiftUI
import AppKit

private func adaptiveColor(light: NSColor, dark: NSColor) -> Color {
    Color(NSColor(name: nil) { appearance in
        let match = appearance.bestMatch(from: [.darkAqua, .aqua])
        return match == .darkAqua ? dark : light
    })
}

private let appBackground = adaptiveColor(
    light: NSColor(red: 0.982, green: 0.965, blue: 0.930, alpha: 1),
    dark: NSColor(red: 0.075, green: 0.071, blue: 0.066, alpha: 1)
)
private let sidebarBackground = adaptiveColor(
    light: NSColor(red: 0.990, green: 0.975, blue: 0.945, alpha: 1),
    dark: NSColor(red: 0.095, green: 0.090, blue: 0.082, alpha: 1)
)
private let panelBackground = adaptiveColor(
    light: .white,
    dark: NSColor(red: 0.145, green: 0.135, blue: 0.122, alpha: 1)
)
private let subtlePanel = adaptiveColor(
    light: NSColor(red: 0.995, green: 0.980, blue: 0.945, alpha: 1),
    dark: NSColor(red: 0.190, green: 0.170, blue: 0.145, alpha: 1)
)
private let lineColor = adaptiveColor(
    light: NSColor.black.withAlphaComponent(0.07),
    dark: NSColor.white.withAlphaComponent(0.10)
)
private let accentTeal = Color(red: 1.00, green: 0.33, blue: 0.16)
private let accentTealSoft = adaptiveColor(
    light: NSColor(red: 1.00, green: 0.88, blue: 0.76, alpha: 1),
    dark: NSColor(red: 0.36, green: 0.18, blue: 0.12, alpha: 1)
)
private let accentAmber = Color(red: 0.94, green: 0.58, blue: 0.16)
private let softBlue = adaptiveColor(
    light: NSColor(red: 1.00, green: 0.91, blue: 0.76, alpha: 1),
    dark: NSColor(red: 0.185, green: 0.135, blue: 0.105, alpha: 1)
)
private let quietFill = adaptiveColor(
    light: NSColor.black.withAlphaComponent(0.045),
    dark: NSColor.white.withAlphaComponent(0.075)
)
private let quietDot = adaptiveColor(
    light: NSColor.black.withAlphaComponent(0.18),
    dark: NSColor.white.withAlphaComponent(0.26)
)
private let elevatedShadow = adaptiveColor(
    light: NSColor.black.withAlphaComponent(0.12),
    dark: NSColor.black.withAlphaComponent(0.42)
)

struct LiquidGlassModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 8
    var tint: Color = accentTeal
    var fillOpacity: Double = 0.34
    var useMaterial = true

    func body(content: Content) -> some View {
        let baseOpacity = colorScheme == .dark ? max(fillOpacity * 0.32, 0.06) : max(fillOpacity * 0.46, 0.07)
        let fallbackOpacity = colorScheme == .dark ? max(fillOpacity * 0.40, 0.07) : max(fillOpacity * 0.52, 0.08)
        let highlightOpacity = colorScheme == .dark ? 0.48 : 0.76
        let glassTintOpacity = colorScheme == .dark ? 0.16 : 0.22

        content
            .background {
                ZStack {
                    if useMaterial {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(panelBackground.opacity(useMaterial ? baseOpacity : fallbackOpacity))
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.linearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.09 : 0.30),
                                Color.clear,
                                tint.opacity(colorScheme == .dark ? 0.14 : 0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.26 : 0.50),
                                    tint.opacity(glassTintOpacity),
                                    Color.white.opacity(colorScheme == .dark ? 0.04 : 0.08)
                                ],
                                startPoint: UnitPoint(x: 0.08, y: 0),
                                endPoint: UnitPoint(x: 1, y: 0.92)
                            )
                        )
                        .blendMode(.screen)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            RadialGradient(
                                colors: [
                                    tint.opacity(colorScheme == .dark ? 0.22 : 0.20),
                                    Color.clear
                                ],
                                center: UnitPoint(x: 0.86, y: 0.26),
                                startRadius: 20,
                                endRadius: 260
                            )
                        )
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(highlightOpacity),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: UnitPoint(x: 0.18, y: -0.08),
                                endPoint: UnitPoint(x: 0.68, y: 1.08)
                            )
                        )
                        .opacity(colorScheme == .dark ? 0.82 : 0.72)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.30 : 0.22), lineWidth: 0.8)
                        .opacity(0.70)
                }
            }
            .liquidGlassChrome(cornerRadius: cornerRadius, tint: tint)
    }
}

struct LiquidGlassChromeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 8
    var tint: Color = accentTeal

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.64 : 0.78),
                                tint.opacity(colorScheme == .dark ? 0.50 : 0.42),
                                Color.black.opacity(colorScheme == .dark ? 0.22 : 0.08)
                            ],
                            startPoint: UnitPoint(x: 0.06, y: 0),
                            endPoint: UnitPoint(x: 1, y: 0.94)
                        ),
                        lineWidth: colorScheme == .dark ? 1.45 : 1.2
                    )
            }
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.58 : 0.72), lineWidth: 1.2)
                    .blur(radius: 0.6)
                    .mask(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
            }
            .overlay(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(tint.opacity(colorScheme == .dark ? 0.42 : 0.30), lineWidth: 1.2)
                    .blur(radius: 2.5)
                    .mask(
                        LinearGradient(
                            colors: [.clear, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: elevatedShadow.opacity(colorScheme == .dark ? 0.32 : 0.42), radius: 18, x: 0, y: 10)
            .shadow(color: tint.opacity(colorScheme == .dark ? 0.18 : 0.16), radius: 24, x: 0, y: 6)
    }
}

struct LiquidGlassBackdrop: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                appBackground

                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.88, blue: 0.66).opacity(colorScheme == .dark ? 0.16 : 0.58),
                        Color(red: 0.72, green: 0.93, blue: 1.0).opacity(colorScheme == .dark ? 0.14 : 0.42),
                        Color(red: 1.0, green: 0.66, blue: 0.58).opacity(colorScheme == .dark ? 0.18 : 0.46)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                FlowBand(
                    colors: [
                        Color(red: 1.0, green: 0.34, blue: 0.16).opacity(colorScheme == .dark ? 0.26 : 0.40),
                        Color(red: 0.96, green: 0.58, blue: 0.16).opacity(colorScheme == .dark ? 0.14 : 0.24),
                        Color.clear
                    ],
                    width: proxy.size.width * 1.22,
                    height: 230,
                    rotation: -13
                )
                .offset(x: -proxy.size.width * 0.12, y: -proxy.size.height * 0.16)

                FlowBand(
                    colors: [
                        Color(red: 0.26, green: 0.64, blue: 0.94).opacity(colorScheme == .dark ? 0.24 : 0.32),
                        Color(red: 0.36, green: 0.86, blue: 0.74).opacity(colorScheme == .dark ? 0.16 : 0.20),
                        Color.clear
                    ],
                    width: proxy.size.width * 1.08,
                    height: 210,
                    rotation: 11
                )
                .offset(x: proxy.size.width * 0.06, y: proxy.size.height * 0.22)

                FlowBand(
                    colors: [
                        Color(red: 0.68, green: 0.54, blue: 0.94).opacity(colorScheme == .dark ? 0.23 : 0.24),
                        Color(red: 1.0, green: 0.48, blue: 0.78).opacity(colorScheme == .dark ? 0.14 : 0.14),
                        Color.clear
                    ],
                    width: proxy.size.width * 1.18,
                    height: 190,
                    rotation: -8
                )
                .offset(x: -proxy.size.width * 0.04, y: proxy.size.height * 0.56)

                FlowBand(
                    colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.08 : 0.24),
                        Color(red: 1.0, green: 0.94, blue: 0.84).opacity(colorScheme == .dark ? 0.08 : 0.18),
                        Color.clear
                    ],
                    width: proxy.size.width * 1.30,
                    height: 120,
                    rotation: 3
                )
                .offset(x: proxy.size.width * 0.02, y: proxy.size.height * 0.08)

                FlowBand(
                    colors: [
                        Color(red: 0.42, green: 0.88, blue: 0.86).opacity(colorScheme == .dark ? 0.12 : 0.18),
                        Color.white.opacity(colorScheme == .dark ? 0.05 : 0.16),
                        Color.clear
                    ],
                    width: proxy.size.width * 1.24,
                    height: 135,
                    rotation: -4
                )
                .offset(x: -proxy.size.width * 0.02, y: proxy.size.height * 0.72)
            }
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }
}

struct FlowBand: View {
    var colors: [Color]
    var width: CGFloat
    var height: CGFloat
    var rotation: Double

    var body: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .rotationEffect(.degrees(rotation))
    }
}

struct ContentView: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        NavigationSplitView {
            Sidebar()
        } detail: {
            ZStack {
                LiquidGlassBackdrop()
                ScrollView {
                    VStack(spacing: 18) {
                        HeaderView()
                        OverviewPanel()
                        TemperaturePanel()
                        ModePanel()
                        PortMapPanel()
                        PowerTrendPanel()
                        ControlPanel()
                    }
                    .padding(26)
                    .animation(.snappy(duration: 0.24), value: store.chargingModeName)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .alert(item: $store.error) { error in
            Alert(title: Text("操作失败"), message: Text(error.message), dismissButton: .default(Text("好")))
        }
        .sheet(isPresented: Binding(
            get: { store.selectedPortIndex != nil },
            set: { if !$0 { store.selectedPortIndex = nil } }
        )) {
            PortDetailSheet()
                .environmentObject(store)
        }
    }
}

struct Sidebar: View {
    @EnvironmentObject private var store: ChargerStore
    @State private var editingDevice: ManagedDevice?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(accentTeal)
                    Text(store.activeDeviceName)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                }
                Text(store.status.device.name)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                MetricRow(title: "总输出", value: "\(String(format: "%.1f", store.status.totalWatts))W", icon: "bolt.circle.fill")
                MetricRow(title: "累计电量", value: energyText(store.currentEnergyWh), icon: "battery.100.bolt")
                MetricRow(title: "Wi‑Fi", value: "\(store.status.device.wifi) \(store.status.device.signal)", icon: "wifi")
                MetricRow(title: "固件", value: store.status.device.firmware, icon: "memorychip")
                MetricRow(title: "温控", value: store.temperatureModeName, icon: "thermometer.medium")
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("我的设备")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        editingDevice = store.addDeviceDraft()
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption.bold())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(accentTeal)
                    .help("添加设备")
                }
                VStack(spacing: 8) {
                    ForEach(store.devices) { device in
                        DeviceListRow(
                            device: device,
                            isSelected: device.id == store.selectedDeviceID,
                            isOnline: store.deviceOnline[device.id]
                        ) {
                            store.selectDevice(device)
                        }
                        .contextMenu {
                            Button {
                                editingDevice = device
                            } label: {
                                Label("编辑设备", systemImage: "pencil")
                            }
                            if store.devices.count > 1 {
                                Divider()
                                Button(role: .destructive) {
                                    store.deleteDevice(device)
                                } label: {
                                    Label("删除设备", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(panelBackground.opacity(0.62))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Spacer()

            Button {
                Task { await store.refresh() }
            } label: {
                Label(store.isLoading ? "刷新中" : "刷新", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(accentTeal)
            .disabled(store.isLoading)
        }
        .padding(18)
        .background(sidebarBackground)
        .navigationSplitViewColumnWidth(min: 240, ideal: 260)
        .sheet(item: $editingDevice) { device in
            DeviceEditorSheet(device: device)
                .environmentObject(store)
        }
        .task {
            await store.refreshDeviceConnectivity()
        }
    }
}

struct DeviceListRow: View {
    var device: ManagedDevice
    var isSelected: Bool
    var isOnline: Bool?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                DeviceConnectionIcon(isOnline: isOnline, isSelected: isSelected)
                VStack(alignment: .leading, spacing: 2) {
                    Text(device.name)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                    Text(statusText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(accentTeal)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(isSelected ? accentTealSoft.opacity(0.45) : panelBackground.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var statusText: String {
        switch isOnline {
        case true: return "在线"
        case false: return "连接已断开"
        case nil: return "正在检测连接"
        }
    }
}

struct DeviceConnectionIcon: View {
    var isOnline: Bool?
    var isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 30, height: 30)
            if isOnline == nil {
                ProgressView()
                    .controlSize(.small)
                    .scaleEffect(0.62)
            } else if isOnline == true {
                Circle()
                    .fill(Color.green)
                    .frame(width: 9, height: 9)
            } else {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var backgroundColor: Color {
        if isOnline == true {
            return Color.green.opacity(0.16)
        }
        if isSelected {
            return accentTealSoft.opacity(0.55)
        }
        return quietFill
    }
}

struct HeaderView: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("CoCan Mirror")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(store.activeDeviceName)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                HStack(spacing: 10) {
                    Label("在线", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                    Text("上次刷新 \(store.status.updatedAt.formatted(date: .omitted, time: .standard))")
                        .foregroundStyle(.secondary)
                }
            }
            .layoutPriority(1)
            Spacer()
            CompactPetHeaderPanel()
                .frame(width: 360)
        }
    }
}

struct CompactPetHeaderPanel: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        ZStack {
            PetSceneBackground(scene: store.weatherScene, power: store.status.totalWatts)
            CompactWeatherBackdrop(scene: store.weatherScene)

            HStack(spacing: 12) {
                CandyPetAvatar(
                    power: store.status.totalWatts,
                    level: store.petLevel,
                    mood: store.petMood,
                    pulse: store.petPulse,
                    scene: store.weatherScene
                )
                .frame(width: 86, height: 82)

                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(store.petMessage)
                            .font(.caption.bold())
                            .foregroundStyle(primaryText)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 4)
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("糖糖")
                                .font(.system(size: 19, weight: .black, design: .rounded))
                                .foregroundStyle(primaryText)
                            Text("\(store.petStageName) · Lv.\(store.petLevel)")
                                .font(.caption.bold())
                                .foregroundStyle(accentText)
                        }
                    }

                    MiniWeatherStatus(scene: store.weatherScene, preferredColor: secondaryText)

                    PetEnergyProgress(value: store.petProgress, labelColor: secondaryText, accent: accentText)
                        .frame(height: 28)

                    HStack(spacing: 8) {
                        Label("\(String(format: "%.1f", store.status.totalWatts))W", systemImage: "bolt.fill")
                        Label("\(Int(store.petVitality.rounded()))%", systemImage: "heart.fill")
                        Text(energyText(store.sharedPetEnergyWh))
                            .monospacedDigit()
                    }
                    .font(.caption2.bold())
                    .foregroundStyle(secondaryText)
                    .lineLimit(1)
                }
                .padding(8)
                .background(textScrim)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(12)
        }
        .frame(height: 138)
        .liquidGlassChrome(cornerRadius: 10, tint: accentTeal)
        .shadow(color: accentTeal.opacity(0.10), radius: 14, x: 0, y: 7)
        .animation(.snappy(duration: 0.28), value: store.petPulse)
        .animation(.snappy(duration: 0.28), value: store.weatherScene)
    }

    private var isDarkScene: Bool {
        !store.weatherScene.isDay || store.weatherScene.kind == .night
    }

    private var primaryText: Color {
        isDarkScene ? .white : Color(red: 0.13, green: 0.12, blue: 0.11)
    }

    private var secondaryText: Color {
        isDarkScene ? Color.white.opacity(0.82) : Color(red: 0.34, green: 0.32, blue: 0.29)
    }

    private var accentText: Color {
        isDarkScene ? Color(red: 1.0, green: 0.68, blue: 0.50) : accentTeal
    }

    private var textScrim: Color {
        isDarkScene ? Color.black.opacity(0.18) : Color.white.opacity(0.34)
    }
}

struct CompactWeatherBackdrop: View {
    var scene: WeatherScene

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                Image(systemName: sceneIcon)
                    .font(.system(size: 78, weight: .black))
                    .foregroundStyle(sceneColor.opacity(scene.isDay ? 0.13 : 0.20))
                    .offset(x: 118 + sin(phase * 0.2) * 5, y: -34)

                Canvas { context, size in
                    if scene.kind == .rain || scene.kind == .storm {
                        for index in 0..<7 {
                            let x = size.width * CGFloat(0.12 + Double(index) * 0.12)
                            let y = size.height * CGFloat((phase * 0.16 + Double(index) * 0.17).truncatingRemainder(dividingBy: 1))
                            var path = Path()
                            path.move(to: CGPoint(x: x, y: y))
                            path.addLine(to: CGPoint(x: x + 8, y: y + 18))
                            context.stroke(path, with: .color(Color.white.opacity(0.18)), lineWidth: 1.2)
                        }
                    }

                    if !scene.isDay {
                        for index in 0..<10 {
                            let x = size.width * CGFloat((Double(index) * 0.19).truncatingRemainder(dividingBy: 1))
                            let y = size.height * CGFloat((Double(index) * 0.31).truncatingRemainder(dividingBy: 1))
                            context.fill(
                                Path(ellipseIn: CGRect(x: x, y: y, width: 3, height: 3)),
                                with: .color(Color.white.opacity(0.13 + 0.12 * abs(sin(phase + Double(index)))))
                            )
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var sceneIcon: String {
        if !scene.isDay { return "moon.stars.fill" }
        return scene.iconName
    }

    private var sceneColor: Color {
        switch scene.kind {
        case .clear: return accentAmber
        case .cloudy, .fog: return Color(red: 0.62, green: 0.64, blue: 0.58)
        case .rain, .storm: return Color(red: 0.30, green: 0.57, blue: 0.86)
        case .snow: return Color(red: 0.62, green: 0.82, blue: 0.96)
        case .night: return Color(red: 0.62, green: 0.55, blue: 0.94)
        case .local: return accentTeal
        }
    }
}

struct MiniWeatherStatus: View {
    var scene: WeatherScene
    var preferredColor: Color? = nil

    var body: some View {
        HStack(spacing: 6) {
            Label(scene.isDay ? "白天" : "夜晚", systemImage: scene.isDay ? "sun.max.fill" : "moon.stars.fill")
            Circle()
                .fill(quietDot)
                .frame(width: 4, height: 4)
            Label(scene.displayTitle, systemImage: scene.iconName)
        }
        .font(.caption2.bold())
        .foregroundStyle(preferredColor ?? weatherColor)
        .lineLimit(1)
    }

    private var weatherColor: Color {
        switch scene.kind {
        case .clear: return accentAmber
        case .cloudy, .fog: return Color(red: 0.58, green: 0.60, blue: 0.56)
        case .rain, .storm: return Color(red: 0.27, green: 0.56, blue: 0.86)
        case .snow: return Color(red: 0.52, green: 0.76, blue: 0.92)
        case .night: return Color(red: 0.60, green: 0.54, blue: 0.92)
        case .local: return accentTeal
        }
    }
}

struct EnergyCompanionDashboard: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        ZStack {
            PetSceneBackground(scene: store.weatherScene, power: store.status.totalWatts)
            WeatherStageBackdrop(scene: store.weatherScene, power: store.status.totalWatts)

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 18) {
                    VStack(spacing: 10) {
                        CandyPetAvatar(
                            power: store.status.totalWatts,
                            level: store.petLevel,
                            mood: store.petMood,
                            pulse: store.petPulse,
                            scene: store.weatherScene
                        )
                        .frame(width: 164, height: 150)

                        WeatherMoodStrip(scene: store.weatherScene)
                    }
                    .frame(width: 250)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("糖糖")
                                .font(.system(size: 31, weight: .black, design: .rounded))
                            Text("\(store.petStageName) · Lv.\(store.petLevel)")
                                .font(.headline.bold())
                                .foregroundStyle(accentTeal)
                            Spacer()
                            Button {
                                store.petInteract()
                            } label: {
                                Label("互动", systemImage: "hand.tap.fill")
                                    .font(.subheadline.bold())
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(accentTeal)
                        }

                        Text(store.petMessage)
                            .font(.title3.bold())
                            .lineLimit(2)
                            .contentTransition(.opacity)

                        PetEnergyProgress(value: store.petProgress)

                        HStack(spacing: 8) {
                            PetStatPill(title: "累计电量", value: energyText(store.sharedPetEnergyWh), icon: "battery.100.bolt")
                            PetStatPill(title: "状态值", value: "\(Int(store.petVitality.rounded()))%", icon: "heart.fill")
                            PetStatPill(title: "实时充能", value: "\(String(format: "%.1f", store.status.totalWatts))W", icon: "bolt.fill")
                        }

                        IntegratedPortStrip(ports: store.status.ports)
                    }

                    VStack(spacing: 10) {
                        WeatherSceneCard(scene: store.weatherScene, isLoading: store.isWeatherLoading)
                        Button {
                            Task { await store.refreshWeather() }
                        } label: {
                            if store.isWeatherLoading {
                                ProgressView()
                                    .controlSize(.small)
                                    .frame(width: 18, height: 18)
                            } else {
                                Label("重新定位", systemImage: "location.fill")
                                    .font(.caption.bold())
                            }
                        }
                        .buttonStyle(.bordered)
                        .help("重新获取本机定位天气")
                    }
                }

                HStack(spacing: 12) {
                    IntegratedPowerCard()
                    IntegratedTemperatureCard()
                }
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(accentTeal.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: accentTeal.opacity(0.13), radius: 22, x: 0, y: 10)
        .animation(.snappy(duration: 0.28), value: store.weatherScene)
    }
}

struct WeatherStageBackdrop: View {
    var scene: WeatherScene
    var power: Double

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                Image(systemName: stageIcon)
                    .font(.system(size: 220, weight: .black))
                    .foregroundStyle(stageColor.opacity(scene.isDay ? 0.10 : 0.16))
                    .offset(x: 370 + sin(phase * 0.18) * 10, y: -74)
                    .rotationEffect(.degrees(sin(phase * 0.12) * 4))

                HStack {
                    WeatherStageBadge(scene: scene)
                    Spacer()
                }
                .padding(.leading, 18)
                .padding(.top, 16)
                .frame(maxHeight: .infinity, alignment: .top)

                Canvas { context, size in
                    if scene.kind == .cloudy || scene.kind == .fog {
                        for index in 0..<5 {
                            let x = size.width * (0.18 + CGFloat(index) * 0.18) + CGFloat(sin(phase * 0.13 + Double(index)) * 18)
                            let y = size.height * (0.18 + CGFloat(index % 2) * 0.18)
                            context.draw(
                                Text(Image(systemName: "cloud.fill")).font(.system(size: 44 + CGFloat(index) * 5)).foregroundStyle(Color.white.opacity(0.16)),
                                at: CGPoint(x: x, y: y),
                                anchor: .center
                            )
                        }
                    }

                    if scene.kind == .storm {
                        let flicker = abs(sin(phase * 5.2))
                        context.draw(
                            Text(Image(systemName: "bolt.fill")).font(.system(size: 120)).foregroundStyle(accentAmber.opacity(0.08 + flicker * 0.12)),
                            at: CGPoint(x: size.width * 0.82, y: size.height * 0.54),
                            anchor: .center
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var stageIcon: String {
        if !scene.isDay { return "moon.stars.fill" }
        switch scene.kind {
        case .clear: return "sun.max.fill"
        case .cloudy, .fog: return "cloud.sun.fill"
        case .rain: return "cloud.rain.fill"
        case .snow: return "cloud.snow.fill"
        case .storm: return "cloud.bolt.rain.fill"
        case .night: return "moon.stars.fill"
        case .local: return "sparkles"
        }
    }

    private var stageColor: Color {
        switch scene.kind {
        case .clear: return accentAmber
        case .cloudy, .fog: return Color(red: 0.62, green: 0.64, blue: 0.58)
        case .rain, .storm: return Color(red: 0.30, green: 0.57, blue: 0.86)
        case .snow: return Color(red: 0.62, green: 0.82, blue: 0.96)
        case .night: return Color(red: 0.62, green: 0.55, blue: 0.94)
        case .local: return accentTeal
        }
    }
}

struct WeatherStageBadge: View {
    var scene: WeatherScene

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: scene.isDay ? "sun.max.fill" : "moon.stars.fill")
            Text(scene.isDay ? "白天场景" : "夜晚场景")
            Circle()
                .fill(Color.primary.opacity(0.24))
                .frame(width: 4, height: 4)
            Image(systemName: scene.iconName)
            Text(scene.displayTitle)
        }
        .font(.caption.bold())
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(panelBackground.opacity(0.70))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineColor, lineWidth: 1)
        }
    }
}

struct IntegratedPowerCard: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                StatusBadge(title: store.status.totalWatts > 0.3 ? "正在充电" : "待机", subtitle: "实时监控功率、接口", icon: "smallcircle.filled.circle")
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text("\(store.status.totalWatts, specifier: "%.1f")W")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .foregroundStyle(accentTeal)
                    Text("\(store.status.chargingPortCount) 个接口 · \(store.status.device.maxPower)W 上限")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
            ProgressView(value: store.status.totalWatts, total: Double(max(store.status.device.maxPower, 1)))
                .tint(store.status.hasWarmPort ? accentAmber : accentTeal)
                .animation(.easeInOut(duration: 0.35), value: store.status.totalWatts)
            PowerFlowBar(isActive: store.status.totalWatts > 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 156)
        .background(panelBackground.opacity(0.76))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineColor, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct IntegratedTemperatureCard: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: store.status.hasWarmPort ? "thermometer.high" : "thermometer.medium")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(store.status.hasWarmPort ? accentAmber : accentTeal)
                .frame(width: 54, height: 54)
                .background((store.status.hasWarmPort ? accentAmber : accentTeal).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text("设备温度")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(store.status.temperatureTitle)
                    .font(.title2.bold())
                Text(store.status.temperatureDetail)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(store.temperatureModeName)
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(subtlePanel.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 156)
        .background(panelBackground.opacity(0.76))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(store.status.hasWarmPort ? accentAmber.opacity(0.34) : lineColor, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct IntegratedPortStrip: View {
    var ports: [PortStatus]

    var body: some View {
        HStack(spacing: 7) {
            ForEach(ports) { port in
                PortChip(port: port)
            }
        }
    }
}

struct CandyPetPanel: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        HStack(spacing: 18) {
            CandyPetAvatar(
                power: store.status.totalWatts,
                level: store.petLevel,
                mood: store.petMood,
                pulse: store.petPulse,
                scene: store.weatherScene
            )
            .frame(width: 148, height: 134)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("糖糖")
                        .font(.system(size: 27, weight: .black, design: .rounded))
                    Text("\(store.petStageName) · Lv.\(store.petLevel)")
                        .font(.headline.bold())
                        .foregroundStyle(accentTeal)
                    Spacer()
                    Button {
                        store.petInteract()
                    } label: {
                        Label("互动", systemImage: "hand.tap.fill")
                            .font(.subheadline.bold())
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(accentTeal)
                }

                Text(store.petMessage)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .contentTransition(.opacity)

                WeatherMoodStrip(scene: store.weatherScene)

                PetEnergyProgress(value: store.petProgress)

                HStack(spacing: 8) {
                    PetStatPill(title: "累计电量", value: energyText(store.sharedPetEnergyWh), icon: "battery.100.bolt")
                    PetStatPill(title: "状态值", value: "\(Int(store.petVitality.rounded()))%", icon: "heart.fill")
                    PetStatPill(title: "实时充能", value: "\(String(format: "%.1f", store.status.totalWatts))W", icon: "bolt.fill")
                }
            }

            VStack(alignment: .trailing, spacing: 10) {
                WeatherSceneCard(scene: store.weatherScene, isLoading: store.isWeatherLoading)
                Button {
                    Task { await store.refreshWeather() }
                } label: {
                    if store.isWeatherLoading {
                        ProgressView()
                            .controlSize(.small)
                            .frame(width: 18, height: 18)
                    } else {
                        Label("重新定位", systemImage: "location.fill")
                            .font(.caption.bold())
                    }
                }
                .buttonStyle(.bordered)
                .help("重新获取本机定位天气")
                Text(store.weatherScene.petHint)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 210, alignment: .trailing)
            }
        }
        .padding(18)
        .background {
            PetSceneBackground(scene: store.weatherScene, power: store.status.totalWatts)
        }
        .liquidGlassChrome(cornerRadius: 10, tint: accentTeal)
        .shadow(color: accentTeal.opacity(0.12), radius: 18, x: 0, y: 8)
        .animation(.snappy(duration: 0.28), value: store.petPulse)
        .animation(.snappy(duration: 0.28), value: store.weatherScene)
    }
}

struct CandyPetAvatar: View {
    var power: Double
    var level: Int
    var mood: PetMood
    var pulse: Int
    var scene: WeatherScene
    @State private var spin = false
    @State private var bob = false

    private var intensity: Double {
        min(max(power / 32, 0), 1)
    }

    private var stage: Int {
        min(5, max(0, level / 10))
    }

    private var candySize: CGFloat {
        82 + CGFloat(stage) * 4
    }

    private var ringCount: Int {
        3 + min(stage, 4)
    }

    private var wrapperSize: CGSize {
        CGSize(width: 46 + CGFloat(stage) * 3, height: 42 + CGFloat(stage) * 2)
    }

    private var wrapperOffset: CGFloat {
        51 + CGFloat(stage) * 4
    }

    var body: some View {
        ZStack {
            ForEach(0..<ringCount, id: \.self) { index in
                Circle()
                    .stroke(stageAccent.opacity(ringOpacity(for: index)), lineWidth: stage >= 4 ? 2.4 : 2)
                    .frame(width: ringSize(for: index), height: ringSize(for: index))
                    .scaleEffect(bob ? ringActiveScale(for: index) : 0.88)
                    .opacity(power > 0.4 ? 1 : 0.34)
                    .animation(
                        .easeInOut(duration: 1.2 + Double(index) * 0.35)
                        .repeatForever(autoreverses: true),
                        value: bob
                    )
            }

            CandyWrapper(stage: stage, side: -1, gradient: wrapperGradient)
                .frame(width: wrapperSize.width, height: wrapperSize.height)
                .rotationEffect(.degrees(-18 - Double(stage) * 1.4))
                .offset(x: -wrapperOffset)
                .shadow(color: stageAccent.opacity(0.18), radius: 9, x: 0, y: 5)

            CandyWrapper(stage: stage, side: 1, gradient: wrapperGradient)
                .frame(width: wrapperSize.width, height: wrapperSize.height)
                .rotationEffect(.degrees(18 + Double(stage) * 1.4))
                .offset(x: wrapperOffset)
                .shadow(color: stageAccent.opacity(0.18), radius: 9, x: 0, y: 5)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.96),
                            Color(red: 1.0, green: 0.74, blue: 0.52),
                            stageAccent
                        ],
                        center: .topLeading,
                        startRadius: 4,
                        endRadius: candySize * 0.78
                    )
                )
                .frame(width: candySize, height: candySize)
                .shadow(color: stageAccent.opacity(0.28 + intensity * 0.22), radius: 18 + intensity * 18, x: 0, y: 9)

            Circle()
                .fill(
                    AngularGradient(
                        colors: candyColors,
                        center: .center,
                        angle: .degrees(spin ? 360 : 0)
                    )
                )
                .frame(width: candySize, height: candySize)
                .opacity(0.58)

            Circle()
                .stroke(Color.white.opacity(0.72), lineWidth: 2)
                .frame(width: candySize - 8, height: candySize - 8)

            Circle()
                .trim(from: 0.60, to: 0.84)
                .stroke(Color.white.opacity(0.82), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: candySize - 18, height: candySize - 18)
                .rotationEffect(.degrees(-24))
                .blur(radius: 0.2)

            if stage >= 1 {
                Circle()
                    .stroke(stageAccent.opacity(0.18), style: StrokeStyle(lineWidth: 1.4, dash: [5, 8], dashPhase: spin ? 28 : 0))
                    .frame(width: candySize + 12, height: candySize + 12)
                    .rotationEffect(.degrees(spin ? 360 : 0))
            }

            if stage >= 1 {
                ForEach(0..<min(16, stage * 3 + 2), id: \.self) { index in
                    Image(systemName: index % 2 == 0 ? "sparkle" : "diamond.fill")
                        .font(.system(size: 7 + CGFloat(stage) * 1.6, weight: .bold))
                        .foregroundStyle(index % 2 == 0 ? accentAmber : stageAccent)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .offset(
                            x: CGFloat(cos(Double(index) * 2.09) * (56 + Double(stage) * 9)),
                            y: CGFloat(sin(Double(index) * 2.09) * (48 + Double(stage) * 6))
                        )
                        .opacity(0.45 + intensity * 0.35)
                }
            }

            if stage >= 2 {
                Circle()
                    .trim(from: 0.06, to: 0.44)
                    .stroke(Color.white.opacity(0.55), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: candySize + 17, height: candySize + 17)
                    .rotationEffect(.degrees(spin ? 360 : -20))
                Circle()
                    .trim(from: 0.58, to: 0.88)
                    .stroke(stageAccent.opacity(0.42), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: candySize + 26, height: candySize + 26)
                    .rotationEffect(.degrees(spin ? -360 : 18))
            }

            if stage >= 3 {
                StageTopper(stage: stage, color: stageAccent)
                    .offset(y: -candySize / 2 - 13)
                    .shadow(color: stageAccent.opacity(0.35), radius: 10, x: 0, y: 4)
            }

            if stage >= 4 {
                ForEach(0..<2, id: \.self) { index in
                    Capsule()
                        .fill(LinearGradient(colors: [Color.white.opacity(0.66), stageAccent.opacity(0.54)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 8, height: 28 + CGFloat(stage) * 2)
                        .rotationEffect(.degrees(index == 0 ? -32 : 32))
                        .offset(x: index == 0 ? -candySize * 0.34 : candySize * 0.34, y: candySize * 0.02)
                        .opacity(0.55)
                }
            }

            CandyFace(mood: mood, intensity: intensity)
                .frame(width: candySize * 0.54, height: candySize * 0.40)
                .offset(y: 7)

            Image(systemName: scene.iconName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(8)
                .background(stageAccent.opacity(0.88))
                .clipShape(Circle())
                .offset(x: 43, y: -43)
                .shadow(color: stageAccent.opacity(0.28), radius: 10, x: 0, y: 5)

        }
        .scaleEffect(1 + CGFloat(intensity) * 0.04 + (pulse % 2 == 0 ? 0 : 0.035))
        .rotationEffect(.degrees(bob ? 1.6 : -1.6))
        .onAppear {
            withAnimation(.linear(duration: max(3.2 - intensity, 1.4)).repeatForever(autoreverses: false)) {
                spin = true
            }
            withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                bob = true
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.58), value: pulse)
        .animation(.easeInOut(duration: 0.35), value: power)
        .animation(.snappy(duration: 0.24), value: mood)
    }

    private var wrapperGradient: LinearGradient {
        LinearGradient(
            colors: wrapperColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var stageAccent: Color {
        switch stage {
        case 0: return accentTeal
        case 1: return Color(red: 1.0, green: 0.52, blue: 0.28)
        case 2: return Color(red: 0.96, green: 0.62, blue: 0.18)
        case 3: return Color(red: 0.46, green: 0.68, blue: 0.96)
        case 4: return Color(red: 0.66, green: 0.54, blue: 0.94)
        default: return Color(red: 1.0, green: 0.42, blue: 0.24)
        }
    }

    private var wrapperColors: [Color] {
        switch stage {
        case 0:
            return [accentTeal.opacity(0.66), Color(red: 1.0, green: 0.77, blue: 0.50).opacity(0.84), Color.white.opacity(0.72)]
        case 1:
            return [Color(red: 1.0, green: 0.62, blue: 0.36).opacity(0.86), accentAmber.opacity(0.70), Color.white.opacity(0.76)]
        case 2:
            return [accentAmber.opacity(0.88), Color(red: 1.0, green: 0.92, blue: 0.58).opacity(0.84), Color.white.opacity(0.78)]
        case 3:
            return [Color(red: 0.55, green: 0.72, blue: 0.96).opacity(0.80), Color.white.opacity(0.86), accentTeal.opacity(0.58)]
        case 4:
            return [Color(red: 0.66, green: 0.56, blue: 0.95).opacity(0.82), Color(red: 0.98, green: 0.76, blue: 1.0).opacity(0.72), Color.white.opacity(0.82)]
        default:
            return [Color(red: 1.0, green: 0.50, blue: 0.28).opacity(0.88), accentAmber.opacity(0.88), Color.white.opacity(0.86)]
        }
    }

    private var candyColors: [Color] {
        let weatherAccent: Color
        switch scene.kind {
        case .rain, .storm: weatherAccent = Color(red: 0.35, green: 0.63, blue: 0.94)
        case .snow: weatherAccent = Color(red: 0.74, green: 0.91, blue: 1.0)
        case .night: weatherAccent = Color(red: 0.62, green: 0.54, blue: 0.92)
        case .cloudy, .fog: weatherAccent = Color(red: 0.72, green: 0.72, blue: 0.66)
        default: weatherAccent = accentAmber
        }

        switch stage {
        case 0:
            return [accentTeal, Color.white.opacity(0.96), accentAmber, accentTeal, Color.white.opacity(0.92), accentTeal]
        case 1:
            return [accentTeal, weatherAccent, Color.white.opacity(0.98), accentAmber, accentTeal, Color.white.opacity(0.88), weatherAccent]
        case 2:
            return [accentTeal, accentAmber, weatherAccent, Color.white.opacity(0.98), accentTeal, Color(red: 1.0, green: 0.48, blue: 0.25), Color.white.opacity(0.9)]
        case 3:
            return [Color(red: 0.42, green: 0.68, blue: 0.96), Color.white.opacity(0.98), weatherAccent, accentAmber, Color(red: 0.28, green: 0.82, blue: 0.74), Color.white.opacity(0.94)]
        case 4:
            return [Color(red: 0.62, green: 0.50, blue: 0.92), weatherAccent, Color.white.opacity(0.98), Color(red: 1.0, green: 0.76, blue: 0.90), accentAmber, Color.white.opacity(0.92)]
        default:
            return [Color(red: 1.0, green: 0.42, blue: 0.24), accentAmber, weatherAccent, Color.white.opacity(0.98), Color(red: 1.0, green: 0.70, blue: 0.30), Color.white.opacity(0.94), accentTeal]
        }
    }

    private func ringOpacity(for index: Int) -> Double {
        max(0.035, 0.12 - Double(index) * 0.025)
    }

    private func ringSize(for index: Int) -> CGFloat {
        82 + CGFloat(index) * 32
    }

    private func ringActiveScale(for index: Int) -> CGFloat {
        1.12 + CGFloat(index) * 0.03
    }
}

struct CandyWrapper: View {
    var stage: Int
    var side: Int
    var gradient: LinearGradient

    var body: some View {
        ZStack {
            baseShape
                .fill(gradient)

            if stage >= 2 {
                VStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { _ in
                        Capsule()
                            .fill(Color.white.opacity(0.18))
                            .frame(height: 3)
                    }
                }
                .padding(.horizontal, 10)
                .rotationEffect(.degrees(Double(side) * 14))
            }

            if stage >= 4 {
                Image(systemName: stage >= 5 ? "sparkles" : "diamond.fill")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Color.white.opacity(0.66))
                    .offset(x: CGFloat(side) * 8, y: -7)
            }

            baseShape
                .stroke(Color.white.opacity(0.32), lineWidth: stage >= 3 ? 1.4 : 1)
        }
    }

    private var baseShape: CandyWrapperShape {
        CandyWrapperShape(stage: stage)
    }
}

struct CandyWrapperShape: Shape {
    var stage: Int

    func path(in rect: CGRect) -> Path {
        if stage >= 4 {
            return Capsule().path(in: rect)
        }
        if stage >= 2 {
            return RoundedRectangle(cornerRadius: 15).path(in: rect)
        }
        return RoundedRectangle(cornerRadius: 9).path(in: rect)
    }
}

struct StageTopper: View {
    var stage: Int
    var color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(stage >= 5 ? 0.42 : 0.24))
                .frame(width: stage >= 5 ? 30 : 24, height: stage >= 5 ? 30 : 24)
                .blur(radius: 1)

            Image(systemName: iconName)
                .font(.system(size: iconSize, weight: .black))
                .foregroundStyle(color)
        }
    }

    private var iconName: String {
        switch stage {
        case 3: return "sparkles"
        case 4: return "diamond.fill"
        default: return "crown.fill"
        }
    }

    private var iconSize: CGFloat {
        stage >= 5 ? 21 : 18
    }
}

struct CandyFace: View {
    var mood: PetMood
    var intensity: Double

    var body: some View {
        ZStack {
            HStack(spacing: eyeSpacing) {
                eye
                eye
            }
            .offset(y: -7)

            CandyMouth(mood: mood, intensity: intensity)
                .stroke(faceColor, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .frame(width: mouthWidth, height: 18)
                .offset(y: 12)

            if mood == .sleepy {
                Text("z")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(faceColor.opacity(0.72))
                    .offset(x: 28, y: -24)
            }

            if mood == .warm {
                Image(systemName: "drop.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.blue.opacity(0.78))
                    .offset(x: 28, y: -6)
            }
        }
    }

    @ViewBuilder
    private var eye: some View {
        switch mood {
        case .excited:
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(faceColor)
        case .sleepy:
            Capsule()
                .fill(faceColor.opacity(0.78))
                .frame(width: 13, height: 4)
                .rotationEffect(.degrees(-6))
        case .alert:
            RoundedRectangle(cornerRadius: 2)
                .fill(faceColor)
                .frame(width: 6, height: 12)
        case .happy:
            Circle()
                .fill(faceColor)
                .frame(width: 8, height: 8)
                .overlay(alignment: .topLeading) {
                    Circle()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 2.5, height: 2.5)
                }
        default:
            Circle()
                .fill(faceColor.opacity(0.90))
                .frame(width: 7, height: 7)
        }
    }

    private var faceColor: Color {
        Color(red: 0.18, green: 0.13, blue: 0.10).opacity(mood == .sleepy ? 0.64 : 0.82)
    }

    private var eyeSpacing: CGFloat {
        mood == .alert ? 17 : 15
    }

    private var mouthWidth: CGFloat {
        switch mood {
        case .excited, .happy: return 32 + CGFloat(intensity) * 8
        case .warm, .alert: return 24
        case .sleepy: return 18
        default: return 24 + CGFloat(intensity) * 5
        }
    }
}

struct CandyMouth: Shape {
    var mood: PetMood
    var intensity: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        let start = CGPoint(x: rect.minX + 2, y: midY)
        let end = CGPoint(x: rect.maxX - 2, y: midY)
        path.move(to: start)

        switch mood {
        case .happy:
            path.addQuadCurve(to: end, control: CGPoint(x: rect.midX, y: rect.maxY - 1))
        case .excited:
            path.addQuadCurve(to: end, control: CGPoint(x: rect.midX, y: rect.maxY + 2 + CGFloat(intensity) * 4))
        case .warm, .alert:
            path.addQuadCurve(to: end, control: CGPoint(x: rect.midX, y: rect.minY + 2))
        case .sleepy:
            path.addLine(to: end)
        case .rainy:
            path.addQuadCurve(to: end, control: CGPoint(x: rect.midX, y: rect.midY + 3))
        case .snowy:
            path.addQuadCurve(to: end, control: CGPoint(x: rect.midX, y: rect.midY + 1))
        case .resting, .calm:
            path.addQuadCurve(to: end, control: CGPoint(x: rect.midX, y: rect.midY + CGFloat(intensity) * 4))
        }
        return path
    }
}

struct PetSceneBackground: View {
    var scene: WeatherScene
    var power: Double

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                LinearGradient(
                    colors: sceneColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Canvas { context, size in
                    let energy = min(max(power / 24, 0), 1)
                    for index in 0..<22 {
                        let indexValue = Double(index)
                        let xSeed = indexValue * 0.137 + sin(phase * 0.18 + indexValue) * 0.045
                        let ySpeed = 0.006 + Double(index % 4) * 0.002
                        let ySeed = indexValue * 0.219 + phase * ySpeed
                        let x = size.width * CGFloat(xSeed.truncatingRemainder(dividingBy: 1))
                        let y = size.height * CGFloat(ySeed.truncatingRemainder(dividingBy: 1))
                        let radius = CGFloat(3 + (index % 4) * 2) + CGFloat(energy) * 3
                        let color = index % 3 == 0 ? accentTeal : Color.white
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                            with: .color(color.opacity(0.08 + energy * 0.12))
                        )
                    }

                    if scene.kind == .rain || scene.kind == .storm {
                        for index in 0..<16 {
                            let x = size.width * CGFloat(Double(index) / 16.0)
                            let y = size.height * CGFloat((phase * 0.18 + Double(index) * 0.11).truncatingRemainder(dividingBy: 1))
                            var path = Path()
                            path.move(to: CGPoint(x: x, y: y))
                            path.addLine(to: CGPoint(x: x + 12, y: y + 30))
                            context.stroke(path, with: .color(Color.white.opacity(0.18)), lineWidth: 1.4)
                        }
                    }

                    if scene.kind == .snow {
                        for index in 0..<18 {
                            let x = size.width * CGFloat((Double(index) * 0.061 + sin(phase * 0.24 + Double(index)) * 0.025).truncatingRemainder(dividingBy: 1))
                            let y = size.height * CGFloat((phase * 0.045 + Double(index) * 0.097).truncatingRemainder(dividingBy: 1))
                            context.draw(
                                Text("✦").font(.system(size: 10)).foregroundStyle(Color.white.opacity(0.28)),
                                at: CGPoint(x: x, y: y),
                                anchor: .center
                            )
                        }
                    }

                    if !scene.isDay {
                        for index in 0..<20 {
                            let x = size.width * CGFloat((Double(index) * 0.173).truncatingRemainder(dividingBy: 1))
                            let y = size.height * CGFloat((Double(index) * 0.271).truncatingRemainder(dividingBy: 1))
                            let twinkle = 0.12 + 0.18 * abs(sin(phase + Double(index)))
                            context.fill(
                                Path(ellipseIn: CGRect(x: x, y: y, width: 3, height: 3)),
                                with: .color(Color.white.opacity(twinkle))
                            )
                        }
                    }
                }
            }
        }
    }

    private var sceneColors: [Color] {
        if !scene.isDay {
            switch scene.kind {
            case .rain, .storm:
                return [Color(red: 0.11, green: 0.16, blue: 0.24), Color(red: 0.19, green: 0.24, blue: 0.32), Color(red: 0.34, green: 0.22, blue: 0.18)]
            case .snow:
                return [Color(red: 0.13, green: 0.18, blue: 0.26), Color(red: 0.24, green: 0.29, blue: 0.34), Color(red: 0.42, green: 0.32, blue: 0.24)]
            default:
                return [Color(red: 0.16, green: 0.13, blue: 0.23), Color(red: 0.26, green: 0.21, blue: 0.30), Color(red: 0.38, green: 0.25, blue: 0.18)]
            }
        }
        switch scene.kind {
        case .clear:
            return [Color(red: 1.0, green: 0.93, blue: 0.72), Color(red: 1.0, green: 0.76, blue: 0.50), panelBackground]
        case .cloudy, .fog:
            return [Color(red: 0.86, green: 0.89, blue: 0.84), Color(red: 1.0, green: 0.87, blue: 0.70), panelBackground]
        case .rain, .storm:
            return [Color(red: 0.66, green: 0.82, blue: 0.94), Color(red: 0.84, green: 0.89, blue: 0.86), panelBackground]
        case .snow:
            return [Color(red: 0.78, green: 0.93, blue: 1.0), Color(red: 0.94, green: 0.97, blue: 1.0), panelBackground]
        case .night:
            return [Color(red: 0.18, green: 0.17, blue: 0.23), Color(red: 0.34, green: 0.25, blue: 0.20), panelBackground]
        case .local:
            return [softBlue.opacity(0.92), accentTealSoft.opacity(0.52), panelBackground]
        }
    }
}

struct WeatherMoodStrip: View {
    var scene: WeatherScene

    var body: some View {
        HStack(spacing: 8) {
            MoodToken(
                title: scene.isDay ? "白天" : "夜晚",
                icon: scene.isDay ? "sun.max.fill" : "moon.stars.fill",
                color: scene.isDay ? accentAmber : Color(red: 0.60, green: 0.54, blue: 0.92)
            )
            MoodToken(
                title: scene.title,
                icon: scene.iconName,
                color: weatherColor
            )
            MoodToken(
                title: weatherActionText,
                icon: weatherActionIcon,
                color: accentTeal
            )
        }
    }

    private var weatherColor: Color {
        switch scene.kind {
        case .clear: return accentAmber
        case .cloudy, .fog: return Color(red: 0.58, green: 0.60, blue: 0.56)
        case .rain, .storm: return Color(red: 0.27, green: 0.56, blue: 0.86)
        case .snow: return Color(red: 0.52, green: 0.76, blue: 0.92)
        case .night: return Color(red: 0.60, green: 0.54, blue: 0.92)
        case .local: return accentTeal
        }
    }

    private var weatherActionText: String {
        switch scene.kind {
        case .clear: return "闪亮"
        case .cloudy, .fog: return "柔和"
        case .rain, .storm: return "护罩"
        case .snow: return "保暖"
        case .night: return "静光"
        case .local: return "同步"
        }
    }

    private var weatherActionIcon: String {
        switch scene.kind {
        case .clear: return "sparkles"
        case .cloudy, .fog: return "cloud.fill"
        case .rain, .storm: return "shield.fill"
        case .snow: return "thermometer.snowflake"
        case .night: return "lightbulb.fill"
        case .local: return "waveform.path"
        }
    }
}

struct MoodToken: View {
    var title: String
    var icon: String
    var color: Color

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(panelBackground.opacity(0.62))
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(color.opacity(0.18), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

struct WeatherSceneCard: View {
    var scene: WeatherScene
    var isLoading: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(weatherColor.opacity(0.14))
                        .frame(width: 42, height: 42)
                    Image(systemName: scene.iconName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(weatherColor)
                }
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.caption2.bold())
                        Text(scene.city)
                            .font(.caption.bold())
                    }
                    .foregroundStyle(.secondary)
                    Text(scene.displayTitle)
                        .font(.title3.bold())
                        .monospacedDigit()
                }
            }
            HStack(spacing: 6) {
                Text(scene.isDay ? "白天场景" : "夜晚场景")
                Circle()
                    .fill(quietDot)
                    .frame(width: 4, height: 4)
                Text(weatherStateName)
            }
            .font(.caption.bold())
            .foregroundStyle(.secondary)
            if isLoading {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(14)
        .frame(width: 214, alignment: .trailing)
        .background(panelBackground.opacity(0.76))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(weatherColor.opacity(0.22), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var weatherColor: Color {
        switch scene.kind {
        case .clear: return accentAmber
        case .cloudy, .fog: return Color(red: 0.58, green: 0.60, blue: 0.56)
        case .rain, .storm: return Color(red: 0.27, green: 0.56, blue: 0.86)
        case .snow: return Color(red: 0.52, green: 0.76, blue: 0.92)
        case .night: return Color(red: 0.60, green: 0.54, blue: 0.92)
        case .local: return accentTeal
        }
    }

    private var weatherStateName: String {
        switch scene.kind {
        case .clear: return "晴朗互动"
        case .cloudy: return "云层互动"
        case .fog: return "雾气互动"
        case .rain: return "雨天互动"
        case .snow: return "雪天互动"
        case .storm: return "雷雨互动"
        case .night: return "夜光互动"
        case .local: return "本地互动"
        }
    }
}

struct PetEnergyProgress: View {
    var value: Double
    var labelColor: Color = .secondary
    var accent: Color = accentTeal

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("进化进度")
                    .font(.caption.bold())
                    .foregroundStyle(labelColor)
                Spacer()
                Text("\(Int((min(max(value, 0), 1) * 100).rounded()))%")
                    .font(.caption.bold())
                    .monospacedDigit()
                    .foregroundStyle(accent)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(quietFill)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [accent, accentAmber],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(10, proxy.size.width * CGFloat(min(max(value, 0), 1))))
                        .animation(.spring(response: 0.45, dampingFraction: 0.76), value: value)
                }
            }
            .frame(height: 10)
        }
    }
}

struct PetStatPill: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(accentTeal)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.caption.bold())
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panelBackground.opacity(0.72))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineColor, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct WeatherPill: View {
    var scene: WeatherScene

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: scene.iconName)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(weatherColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(scene.city)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(scene.displayTitle)
                    .font(.subheadline.bold())
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .background(panelBackground.opacity(0.74))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(weatherColor.opacity(0.20), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var weatherColor: Color {
        switch scene.kind {
        case .clear: return accentAmber
        case .cloudy, .fog: return Color(red: 0.58, green: 0.60, blue: 0.56)
        case .rain, .storm: return Color(red: 0.27, green: 0.56, blue: 0.86)
        case .snow: return Color(red: 0.52, green: 0.76, blue: 0.92)
        case .night: return Color(red: 0.60, green: 0.54, blue: 0.92)
        case .local: return accentTeal
        }
    }
}

struct OverviewPanel: View {
    @EnvironmentObject private var store: ChargerStore
    @State private var ambientBolt = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                StatusBadge(title: "正在充电", subtitle: "实时监控功率、温度", icon: "smallcircle.filled.circle")
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(String(format: "%.1f", store.status.totalWatts))W")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .foregroundStyle(accentTeal)
                    Text("\(store.status.chargingPortCount) 个接口 · \(store.status.device.maxPower)W 上限")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: store.status.totalWatts, total: Double(max(store.status.device.maxPower, 1)))
                    .tint(store.status.hasWarmPort ? accentAmber : accentTeal)
                    .animation(.easeInOut(duration: 0.35), value: store.status.totalWatts)
                PowerFlowBar(isActive: store.status.totalWatts > 0)
                HStack(spacing: 8) {
                    ForEach(store.status.ports) { port in
                        PortChip(port: port)
                    }
                }
            }
        }
        .panelSurface()
        .overlay(alignment: .topTrailing) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 82, weight: .black))
                .foregroundStyle(accentTeal.opacity(0.055))
                .rotationEffect(.degrees(ambientBolt ? 10 : -8))
                .scaleEffect(ambientBolt ? 1.06 : 0.94)
                .padding(18)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                        ambientBolt = true
                    }
                }
        }
    }
}

struct TemperaturePanel: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: store.status.hasWarmPort ? "thermometer.high" : "thermometer.medium")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(store.status.hasWarmPort ? accentAmber : accentTeal)
                .frame(width: 54, height: 54)
                .background((store.status.hasWarmPort ? accentAmber : accentTeal).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text("设备温度")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(store.status.temperatureTitle)
                    .font(.title2.bold())
                Text(store.status.temperatureDetail)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(store.temperatureModeName)
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(subtlePanel)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .panelSurface()
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(store.status.hasWarmPort ? accentAmber.opacity(0.34) : lineColor, lineWidth: 1)
        }
    }
}

struct ModePanel: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "模式", subtitle: "温控模式和充电模式是两个独立维度")

            HStack(spacing: 12) {
                ModeStatusCard(
                    icon: store.status.device.temperatureModeRaw == 0 ? "thermometer.sun.fill" : "snowflake",
                    eyebrow: "温控模式",
                    title: store.temperatureModeName,
                    detail: store.status.device.temperatureModeRaw == 0 ? "更高性能，适合多数充电场景" : "更少发热，达到阈值会调节功率"
                )
                ModeStatusCard(
                    icon: "bolt.circle.fill",
                    eyebrow: "充电模式",
                    title: store.chargingModeName,
                    detail: chargingModeDetail
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "温控模式", subtitle: "只决定温度阈值和散热策略", compact: true)
                HStack(spacing: 10) {
                    ModeSwitchButton(
                        title: "性能温控",
                        subtitle: "高效率输出",
                        icon: "thermometer.sun.fill",
                        isActive: store.status.device.temperatureModeRaw == 0
                    ) {
                        store.setPowerPriority()
                    }
                    ModeSwitchButton(
                        title: "安心温控",
                        subtitle: "低温阈值",
                        icon: "snowflake",
                        isActive: store.status.device.temperatureModeRaw != 0
                    ) {
                        store.setCoolPriority()
                    }
                }
                ModeExplainCard(
                    items: [
                        ("性能温控", "更高效率，适合绝大多数充电场景；搭配支架或散热环境更能释放性能。"),
                        ("安心温控", "更少发热，达到温度阈值后会自动调节充电功率。")
                    ]
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "智能模式", subtitle: "官方推荐的通用充电策略", compact: true)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 310), spacing: 12)], spacing: 12) {
                    OfficialModeCard(
                        title: "自由流",
                        badge: "FluxAI",
                        detail: "功率无级回收复用，最大化按需供能，全时输出收放自如。",
                        icon: "bolt.circle.fill",
                        tint: accentAmber,
                        isRecommended: true,
                        isActive: store.chargingModeName == "自由流"
                    ) {
                        store.setFast()
                    }
                    OfficialModeCard(
                        title: "睡眠充",
                        badge: "夜间",
                        detail: "避免电池长时间满电，延长使用寿命，适用于夜间充电场景。",
                        icon: "moon.fill",
                        tint: Color(red: 0.58, green: 0.54, blue: 0.86),
                        isActive: store.chargingModeName == "睡眠充" || store.chargingModeName == "慢充"
                    ) {
                        store.setSleepCharge()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "场景模式", subtitle: "按官方场景快速切换策略和预算", compact: true)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 310), spacing: 12)], spacing: 12) {
                    OfficialModeCard(
                        title: "小家电模拟",
                        badge: "魔拟充",
                        detail: "原本只能用 A 口充电的小家电设备，可以使用 C 口充电。",
                        icon: "powerplug.fill",
                        tint: Color(red: 0.50, green: 0.52, blue: 0.46),
                        isActive: store.chargingModeName == "小家电"
                    ) {
                        store.setUsbaMode()
                    }
                    OfficialModeCard(
                        title: "极速单充·C1",
                        badge: "单口",
                        detail: "释放 C1 满血性能，一键关闭其他端口预算，为 C1 开启专属通道。",
                        icon: "arrow.right.circle.fill",
                        tint: accentTeal,
                        isActive: store.chargingModeName == "极速单充·C1"
                    ) {
                        store.setUltraC1Mode()
                    }
                    OfficialModeCard(
                        title: "苹果全家桶",
                        badge: "Apple",
                        detail: "C1 MacBook、C2 iPhone、C3 iPad、C4 Apple Watch 的常用预算组合。",
                        icon: "apple.logo",
                        tint: Color(red: 0.33, green: 0.35, blue: 0.34),
                        isActive: store.chargingModeName == "苹果全家桶"
                    ) {
                        store.setAppleFamilyMode()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "功率自定义", subtitle: "保留你手动设置的端口预算方案", compact: true)
                OfficialModeCard(
                    title: "自定义",
                    badge: "预算",
                    detail: "使用下方手动分配里的 A/C1/C2/C3/C4 预算，适合个性化充电策略。",
                    icon: "slider.horizontal.3",
                    tint: accentTeal,
                    buttonTitle: store.chargingModeName == "自定义" ? "已应用" : "应用预算",
                    isActive: store.chargingModeName == "自定义"
                ) {
                    store.setCustomMode()
                }
                ManualAllocationPanel()
            }
        }
        .panelSurface()
    }

    private var chargingModeDetail: String {
        switch store.chargingModeName {
        case "自由流":
            return "功率无级回收复用"
        case "睡眠充", "慢充":
            return "夜间均衡慢充"
        case "小家电":
            return "小家电模拟兼容"
        case "极速单充·C1":
            return "C1 单口满血"
        case "苹果全家桶":
            return "苹果设备组合预算"
        case "自定义":
            return "手动端口预算"
        default:
            return "当前输出策略"
        }
    }
}

struct StatusBadge: View {
    var title: String
    var subtitle: String
    var icon: String
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accentTeal.opacity(0.18))
                    .frame(width: 56, height: 56)
                    .scaleEffect(pulse ? 1.35 : 0.75)
                    .opacity(pulse ? 0.08 : 0.65)
                Circle()
                    .stroke(accentTeal.opacity(pulse ? 0.18 : 0.42), lineWidth: 2)
                    .frame(width: 48, height: 48)
                    .scaleEffect(pulse ? 1.08 : 0.94)
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(accentTeal)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.bold())
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct PowerFlowBar: View {
    var isActive: Bool
    @State private var phase = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(accentTealSoft.opacity(0.18))
                if isActive {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    accentTeal.opacity(0),
                                    accentTeal.opacity(0.28),
                                    accentTeal.opacity(0.72),
                                    accentAmber.opacity(0.55),
                                    accentTeal.opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(130, proxy.size.width * 0.42))
                        .offset(x: phase ? proxy.size.width : -proxy.size.width * 0.48)
                        .blur(radius: 0.5)
                }
            }
        }
        .frame(height: 10)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .opacity(isActive ? 1 : 0.45)
        .onAppear {
            withAnimation(.linear(duration: 1.7).repeatForever(autoreverses: false)) {
                phase = true
            }
        }
    }
}

struct PortChip: View {
    var port: PortStatus

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(port.charging ? accentTeal : quietDot)
                .frame(width: 7, height: 7)
            Text(port.name)
                .font(.caption.bold())
            Text("\(Int(port.watts.rounded()))W")
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(port.charging ? accentTealSoft.opacity(0.55) : quietFill)
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

struct PortMapPanel: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "接口图谱", subtitle: "实时输出、协议与连接设备")

            GeometryReader { proxy in
                ZStack {
                    CableLayer(ports: store.status.ports)
                    VStack(spacing: 24) {
                HStack(spacing: 10) {
                    ForEach(store.status.ports) { port in
                        PortMapNode(port: port) {
                            store.showPortDetails(port)
                        }
                    }
                        }
                        Spacer(minLength: 8)
                        DeviceHubView(
                            deviceName: store.activeDeviceName,
                            totalWatts: store.status.totalWatts,
                            maxPower: store.status.device.maxPower,
                            activePorts: store.status.chargingPortCount
                        )
                        .frame(maxWidth: min(proxy.size.width * 0.64, 560))
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                }
            }
            .frame(minHeight: 380)
        }
        .panelSurface()
    }
}

struct CableLayer: View {
    var ports: [PortStatus]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let count = max(ports.count, 1)
                let topY: CGFloat = 84
                let hubY = size.height - 94
                let hubWidth = min(size.width * 0.64, 560)
                let hubLeft = (size.width - hubWidth) / 2
                let hubStep = hubWidth / CGFloat(count + 1)
                let phase = timeline.date.timeIntervalSinceReferenceDate * 58

                for item in ports.enumerated() {
                    let index = item.offset
                    let port = item.element
                    let topX = size.width * (CGFloat(index) + 0.5) / CGFloat(count)
                    let bottomX = hubLeft + hubStep * CGFloat(index + 1)
                    var path = Path()
                    path.move(to: CGPoint(x: topX, y: topY))
                    path.addCurve(
                        to: CGPoint(x: bottomX, y: hubY),
                        control1: CGPoint(x: topX, y: topY + 78),
                        control2: CGPoint(x: bottomX, y: hubY - 92)
                    )

                    let baseColor = port.charging ? accentTeal.opacity(0.84) : accentTealSoft.opacity(0.34)
                    let powerRatio = min(max(port.watts / 140, 0), 1)
                    let lineWidth: CGFloat = port.charging ? 3.5 + CGFloat(powerRatio) * 8.5 : 2.2
                    context.stroke(path, with: .color(baseColor), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                    if port.charging {
                        context.stroke(
                            path,
                            with: .color(Color.white.opacity(0.62)),
                            style: StrokeStyle(
                                lineWidth: max(1.6, lineWidth * 0.32),
                                lineCap: .round,
                                dash: [18, 30],
                                dashPhase: phase
                            )
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct PortMapNode: View {
    var port: PortStatus
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(port.name)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text("\(port.watts, specifier: "%.1f")W")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                            .allowsTightening(true)
                            .contentTransition(.numericText())
                            .foregroundStyle(port.charging ? accentTeal : .secondary)
                    }
                    .layoutPriority(1)
                    Spacer(minLength: 0)
                    Image(systemName: port.charging ? "bolt.circle.fill" : "info.circle")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(port.charging ? accentTeal : quietDot)
                }

                Text(port.device)
                    .font(.caption.bold())
                    .lineLimit(1)
                Text(port.protocolName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .allowsTightening(true)
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
            .background(port.charging ? accentTealSoft.opacity(0.46) : panelBackground.opacity(0.88))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(port.charging ? accentTeal.opacity(0.22) : lineColor, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: port.charging ? accentTeal.opacity(0.14) : .clear, radius: 12, x: 0, y: 6)
            .scaleEffect(port.charging ? 1.015 : 1)
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(.snappy(duration: 0.25), value: port.charging)
        .animation(.snappy(duration: 0.25), value: port.watts)
    }
}

struct DeviceHubView: View {
    var deviceName: String
    var totalWatts: Double
    var maxPower: Int
    var activePorts: Int

    var body: some View {
        VStack(spacing: 10) {
            ProductDeviceImage()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 18)
                .padding(.top, 8)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(totalWatts, specifier: "%.1f")W")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .foregroundStyle(accentTeal)
                Text("\(activePorts) 口 · \(maxPower)W")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Label(deviceName, systemImage: "bolt.circle.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
        .background(
            LinearGradient(
                colors: [panelBackground.opacity(0.98), subtlePanel.opacity(0.82)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(accentTeal.opacity(0.14), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: accentTeal.opacity(0.10), radius: 18, x: 0, y: 8)
    }
}

struct PowerTrendPanel: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "最近功率趋势", subtitle: "App 运行期间的实时采样")
            PowerTrendChart(samples: store.trendSamples, ports: store.status.ports)
                .frame(height: 170)
                .padding(12)
                .background(subtlePanel)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .panelSurface()
    }
}

struct PowerTrendChart: View {
    var samples: [PowerTrendSample]
    var ports: [PortStatus]

    private let palette: [Color] = [
        accentTeal,
        Color(red: 0.95, green: 0.58, blue: 0.16),
        Color(red: 0.24, green: 0.68, blue: 0.45),
        Color(red: 0.35, green: 0.50, blue: 0.94),
        Color(red: 0.68, green: 0.42, blue: 0.86)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Canvas { context, size in
                let maxWatts = max(1, samples.flatMap { $0.portWatts.values }.max() ?? 1)
                let left: CGFloat = 6
                let right = size.width - 6
                let top: CGFloat = 8
                let bottom = size.height - 24
                let width = max(1, right - left)
                let height = max(1, bottom - top)

                var grid = Path()
                for step in 0...3 {
                    let y = top + height * CGFloat(step) / 3
                    grid.move(to: CGPoint(x: left, y: y))
                    grid.addLine(to: CGPoint(x: right, y: y))
                }
                context.stroke(grid, with: .color(lineColor), style: StrokeStyle(lineWidth: 1))

                guard samples.count > 1 else {
                    let text = Text("等待更多采样").font(.caption).foregroundStyle(.secondary)
                    context.draw(text, at: CGPoint(x: size.width / 2, y: size.height / 2), anchor: .center)
                    return
                }

                for item in ports.enumerated() {
                    let port = item.element
                    var path = Path()
                    for sampleIndex in samples.indices {
                        let x = left + width * CGFloat(sampleIndex) / CGFloat(max(samples.count - 1, 1))
                        let watts = samples[sampleIndex].portWatts[port.index] ?? 0
                        let y = bottom - height * CGFloat(watts / maxWatts)
                        if sampleIndex == samples.startIndex {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    context.stroke(
                        path,
                        with: .color(palette[item.offset % palette.count].opacity(port.charging ? 0.95 : 0.42)),
                        style: StrokeStyle(lineWidth: port.charging ? 2.4 : 1.4, lineCap: .round, lineJoin: .round)
                    )
                }
            }

            HStack(spacing: 10) {
                ForEach(Array(ports.enumerated()), id: \.element.id) { index, port in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(palette[index % palette.count])
                            .frame(width: 7, height: 7)
                        Text(port.name)
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }
}

struct PortDetailSheet: View {
    @EnvironmentObject private var store: ChargerStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let port = store.selectedPort {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(port.name) 接口详情")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                        Text(port.device)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(port.watts, specifier: "%.1f")W")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(accentTeal)
                        Button {
                            store.selectedPortIndex = nil
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help("关闭")
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 10)], spacing: 10) {
                    DetailMetric(title: "协议", value: port.protocolName, icon: "bolt.badge.checkmark")
                    DetailMetric(title: "温度", value: port.temperature, icon: "thermometer.medium")
                    DetailMetric(title: "PD", value: port.pdRevision, icon: "cable.connector")
                    DetailMetric(title: "线材", value: port.cable.isEmpty ? "--" : port.cable, icon: "cable.connector.horizontal")
                    DetailMetric(title: "电池", value: port.batteryDetail.isEmpty ? "--" : port.batteryDetail, icon: "battery.75percent")
                    DetailMetric(title: "身份", value: port.identityText.isEmpty ? "--" : port.identityText, icon: "number")
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "功率曲线", subtitle: store.loadingHistoryPort == port.index ? "正在读取设备历史" : "本地趋势与设备历史", compact: true)
                    PowerLineChart(values: historyValues(for: port), accent: accentTeal)
                        .frame(height: 190)
                        .padding(12)
                        .background(subtlePanel)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(22)
        .frame(width: 720)
        .background(appBackground)
    }

    private func historyValues(for port: PortStatus) -> [Double] {
        let deviceHistory = store.portHistory[port.index]?.map(\.watts) ?? []
        if deviceHistory.count > 2 { return deviceHistory }
        return store.portTrend(for: port.index)
    }
}

struct DetailMetric: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(accentTeal)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.bold())
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(12)
        .background(panelBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineColor, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct PowerLineChart: View {
    var values: [Double]
    var accent: Color

    var body: some View {
        Canvas { context, size in
            guard values.count > 1 else {
                context.draw(Text("暂无足够数据").font(.caption).foregroundStyle(.secondary), at: CGPoint(x: size.width / 2, y: size.height / 2), anchor: .center)
                return
            }
            let maxValue = max(1, values.max() ?? 1)
            let left: CGFloat = 6
            let right = size.width - 6
            let top: CGFloat = 8
            let bottom = size.height - 18
            let width = right - left
            let height = bottom - top

            var area = Path()
            var line = Path()
            for index in values.indices {
                let x = left + width * CGFloat(index) / CGFloat(max(values.count - 1, 1))
                let y = bottom - height * CGFloat(values[index] / maxValue)
                if index == values.startIndex {
                    line.move(to: CGPoint(x: x, y: y))
                    area.move(to: CGPoint(x: x, y: bottom))
                    area.addLine(to: CGPoint(x: x, y: y))
                } else {
                    line.addLine(to: CGPoint(x: x, y: y))
                    area.addLine(to: CGPoint(x: x, y: y))
                }
            }
            area.addLine(to: CGPoint(x: right, y: bottom))
            area.closeSubpath()
            context.fill(area, with: .linearGradient(
                Gradient(colors: [accent.opacity(0.24), accent.opacity(0.02)]),
                startPoint: CGPoint(x: 0, y: top),
                endPoint: CGPoint(x: 0, y: bottom)
            ))
            context.stroke(line, with: .color(accent), style: StrokeStyle(lineWidth: 2.8, lineCap: .round, lineJoin: .round))
        }
    }
}

struct ProductDeviceImage: View {
    var body: some View {
        Group {
            if let image = loadProductImage() {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(accentTealSoft.opacity(0.35))
                    .overlay {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 36, weight: .black))
                            .foregroundStyle(accentTeal)
                    }
            }
        }
        .shadow(color: elevatedShadow, radius: 14, x: 0, y: 8)
    }

    private func loadProductImage() -> NSImage? {
        guard let path = Bundle.main.path(forResource: "ProductDevice", ofType: "png") else { return nil }
        return NSImage(contentsOfFile: path)
    }
}

struct PortGrid: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 12)], spacing: 12) {
            ForEach(store.status.ports) { port in
                PortCard(port: port)
            }
        }
    }
}

struct PortCard: View {
    var port: PortStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text(port.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .frame(width: 52, height: 42)
                    .foregroundStyle(port.charging ? accentTeal : .secondary)
                    .background(port.charging ? accentTealSoft.opacity(0.62) : quietFill)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Spacer()
                Text("\(port.watts, specifier: "%.1f")W")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }

            Text(port.device)
                .font(.headline)
                .lineLimit(2)
            if !port.identityText.isEmpty {
                Text(port.identityText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .monospacedDigit()
            }
            Text(port.protocolName)
                .foregroundStyle(.secondary)
            HStack {
                Label(port.temperature, systemImage: "thermometer.medium")
                if port.pdRevision != "--" {
                    Label(port.pdRevision, systemImage: "bolt.badge.checkmark")
                }
                if !port.cable.isEmpty {
                    Label(port.cable, systemImage: "cable.connector")
                }
                if !port.batteryDetail.isEmpty {
                    Label(port.batteryDetail, systemImage: "battery.75percent")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .panelSurface()
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(port.charging ? accentTeal.opacity(0.28) : lineColor, lineWidth: 1)
        }
        .shadow(color: port.charging ? accentTeal.opacity(0.14) : .clear, radius: 14, x: 0, y: 7)
        .scaleEffect(port.charging ? 1.01 : 1)
        .animation(.snappy(duration: 0.24), value: port.charging)
        .animation(.snappy(duration: 0.24), value: port.watts)
    }
}

struct ControlPanel: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "接口与功率", subtitle: "按接口快速控制输出")

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "单口预算优先", subtitle: "快速把电源预算留给某个接口，实际功率由设备协商决定", compact: true)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 10)], spacing: 10) {
                    ForEach(1...5, id: \.self) { index in
                        PortBoostButton(
                            name: store.portName(index),
                            watts: store.maxPowerLabel(for: index),
                            isActive: store.chargingModeName == "\(store.portName(index)) 预算优先"
                        ) {
                            store.maximizePort(index)
                        }
                    }
                }
            }
            .padding(14)
            .background(subtlePanel)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "接口通断", subtitle: "单独关闭或恢复某个接口输出", compact: true)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 124), spacing: 10)], spacing: 10) {
                    ForEach(store.status.ports) { port in
                        PortPowerToggle(
                            port: port,
                            isPending: store.pendingPortIndex == port.index,
                            feedback: store.portFeedback[port.index]
                        ) { enabled in
                            store.turnPort(port.index, enabled: enabled)
                        }
                    }
                }
            }
            .padding(14)
            .background(subtlePanel)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "状态屏", subtitle: "亮度与显示内容", compact: true)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], spacing: 8) {
                    ForEach(["关", "低", "中", "高"], id: \.self) { level in
                        DisplayButton(title: level, isActive: store.status.display.brightness == level) {
                            store.setDisplay(level)
                        }
                    }
                }
                if store.status.display.supportsAdvancedDisplay {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: 8)], spacing: 8) {
                        DisplayOptionButton(
                            title: "动画优先",
                            subtitle: "待机更好看",
                            icon: "sparkles",
                            isActive: store.status.display.statusMode == "待机动画优先"
                        ) {
                            store.setStatusDisplayMode("待机动画优先")
                        }
                        DisplayOptionButton(
                            title: "功率优先",
                            subtitle: "先看输出",
                            icon: "bolt.circle.fill",
                            isActive: store.status.display.statusMode == "功率显示优先"
                        ) {
                            store.setStatusDisplayMode("功率显示优先")
                        }
                        ForEach(["流星", "落花", "康威的生命游戏", "时间"], id: \.self) { item in
                            DisplayOptionButton(
                                title: item,
                                subtitle: "待机显示",
                                icon: idleIcon(item),
                                isActive: store.status.display.idleDisplay == item
                            ) {
                                store.setIdleDisplay(item)
                            }
                        }
                        DisplayOptionButton(
                            title: "整点报时",
                            subtitle: store.status.display.hourlyChime ? "已开启" : "已关闭",
                            icon: "bell.fill",
                            isActive: store.status.display.hourlyChime
                        ) {
                            store.setHourlyChime(!store.status.display.hourlyChime)
                        }
                    }
                } else {
                    Text("这台设备当前只开放亮度控制。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .background(subtlePanel)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .panelSurface()
    }
}

private func idleIcon(_ name: String) -> String {
    switch name {
    case "流星": return "sparkle"
    case "落花": return "leaf.fill"
    case "康威的生命游戏": return "square.grid.3x3.fill"
    case "时间": return "clock.fill"
    default: return "display"
    }
}

private func energyText(_ wh: Double) -> String {
    if wh >= 1000 {
        return "\(String(format: "%.2f", wh / 1000)) kWh"
    }
    return "\(String(format: "%.1f", wh)) Wh"
}

struct DeviceEditorSheet: View {
    @EnvironmentObject private var store: ChargerStore
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ManagedDevice

    init(device: ManagedDevice) {
        _draft = State(initialValue: device)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("设备设置")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(accentTeal)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("编辑设备")
                            .font(.headline)
                        Text("修改名称和设备连接地址，保存后会自动连接。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("设备名称")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    TextField("例如：办公室小电拼", text: $draft.name)
                        .textFieldStyle(.roundedBorder)
                    Text("设备连接地址")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    SecureField("粘贴你的设备连接地址", text: $draft.endpoint)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Button {
                        store.saveDevice(draft)
                        dismiss()
                    } label: {
                        Label("保存", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(accentTeal)

                    Spacer()
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .padding(14)
            .background(subtlePanel)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .panelSurface()
        .padding(20)
        .frame(width: 560)
    }
}

struct MetricRow: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 26)
                .foregroundStyle(accentTeal)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(12)
        .background(panelBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineColor, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct SectionHeader: View {
    var title: String
    var subtitle: String
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 2 : 4) {
            Text(title)
                .font(.system(size: compact ? 15 : 22, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(compact ? .caption : .subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct PillAction: View {
    var title: String
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(accentTeal)
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }
}

struct ModeStatusCard: View {
    var icon: String
    var eyebrow: String
    var title: String
    var detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(accentTeal)
                .frame(width: 50, height: 50)
                .background(accentTealSoft.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text(eyebrow)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.title3.bold())
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(subtlePanel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ModeSwitchButton: View {
    var title: String
    var subtitle: String
    var icon: String
    var isActive: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(isActive ? Color.white.opacity(0.78) : .secondary)
                }
                Spacer(minLength: 0)
                if isActive {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .foregroundStyle(isActive ? Color.white : .primary)
            .background(isActive ? accentTeal : panelBackground)
            .shadow(color: isActive ? accentTeal.opacity(0.26) : .clear, radius: 12, x: 0, y: 6)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? accentTeal.opacity(0) : lineColor, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct OfficialModeCard: View {
    var title: String
    var badge: String
    var detail: String
    var icon: String
    var tint: Color
    var buttonTitle: String? = nil
    var isRecommended = false
    var isActive: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isActive ? tint : panelBackground.opacity(0.68))
                        .frame(width: 84, height: 84)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isActive ? Color.white.opacity(0.24) : tint.opacity(0.20), lineWidth: 1)
                        }
                    VStack(spacing: 5) {
                        Image(systemName: icon)
                            .font(.system(size: 26, weight: .semibold))
                        Text(title)
                            .font(.caption.bold())
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                    .foregroundStyle(isActive ? Color.white : tint)
                    .padding(6)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 7) {
                        Text(isRecommended ? "推荐模式" : badge)
                            .font(.caption.bold())
                            .foregroundStyle(isActive ? tint : .secondary)
                        if isRecommended {
                            Image(systemName: "sparkles")
                                .font(.caption.bold())
                                .foregroundStyle(tint)
                        }
                    }
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Text(buttonTitle ?? (isActive ? "已启动" : "启动模式"))
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .foregroundStyle(isActive ? Color.white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(isActive ? tint : panelBackground.opacity(0.64))
                    .overlay {
                        Capsule()
                            .stroke(isActive ? Color.clear : lineColor, lineWidth: 1)
                    }
                    .clipShape(Capsule())
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 122, alignment: .leading)
            .liquidGlass(cornerRadius: 12, tint: tint, fillOpacity: isActive ? 0.10 : 0.08, useMaterial: false)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? tint.opacity(0.50) : lineColor, lineWidth: isActive ? 1.3 : 1)
            }
            .shadow(color: isActive ? tint.opacity(0.18) : .clear, radius: 16, x: 0, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ModeExplainCard: View {
    var items: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: index == 0 ? "heat.waves" : "snowflake")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(index == 0 ? accentTeal : Color(red: 0.34, green: 0.64, blue: 0.92))
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.0)
                            .font(.subheadline.bold())
                        Text(item.1)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                if index < items.count - 1 {
                    Divider()
                }
            }
        }
        .padding(14)
        .background(panelBackground.opacity(0.58))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineColor, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ManualAllocationPanel: View {
    @EnvironmentObject private var store: ChargerStore

    private var totalBudget: Int {
        store.allocation.reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("手动分配功率")
                        .font(.headline.bold())
                    Text("总预算 \(totalBudget)W / \(store.status.device.maxPower)W")
                        .font(.caption)
                        .foregroundStyle(totalBudget > store.status.device.maxPower ? accentTeal : .secondary)
                }
                Spacer()
                Button {
                    store.setCustomMode()
                } label: {
                    Label("应用自定义", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .frame(minHeight: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(accentTeal)
                .disabled(totalBudget > store.status.device.maxPower)
            }

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(["A", "C1", "C2", "C3", "C4"].enumerated()), id: \.offset) { index, name in
                    AllocationControl(name: name, value: $store.allocation[index])
                }
            }
        }
        .padding(14)
        .background(panelBackground.opacity(0.54))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(totalBudget > store.status.device.maxPower ? accentTeal.opacity(0.42) : lineColor, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct PortBoostButton: View {
    var name: String
    var watts: String
    var isActive: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(name)
                        .font(.headline.bold())
                    Spacer()
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 15, weight: .bold))
                }
                Text("预算优先")
                    .font(.caption.bold())
                Text(watts)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .monospacedDigit()
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
            .foregroundStyle(isActive ? Color.white : .primary)
            .background(isActive ? accentTeal : panelBackground)
            .shadow(color: isActive ? accentTeal.opacity(0.28) : .clear, radius: 16, x: 0, y: 8)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? accentTeal.opacity(0) : lineColor, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ControlTile: View {
    var title: String
    var subtitle: String
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(accentTeal)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary.opacity(0.65))
                }
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
            .background(accentTealSoft.opacity(0.46))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(accentTeal.opacity(0.16), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct AllocationControl: View {
    var name: String
    @Binding var value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Stepper(value: $value, in: 0...140, step: 1) {
                Text("\(value)W")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .frame(width: 56, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PortPowerToggle: View {
    var port: PortStatus
    var isPending: Bool
    var feedback: String?
    var action: (Bool) -> Void

    private var isConfirmed: Bool {
        feedback == "已打开" || feedback == "已关闭"
    }

    private var statusText: String {
        if let feedback { return feedback }
        return port.charging ? "正在输出" : (port.connected ? "已连接待机" : "空闲")
    }

    var body: some View {
        Button {
            action(!port.charging)
        } label: {
            HStack(spacing: 9) {
                ZStack {
                    Image(systemName: port.charging ? "power.circle.fill" : "power.circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(port.charging || isPending || isConfirmed ? accentTeal : .secondary)
                    if isPending {
                        ProgressView()
                            .controlSize(.small)
                            .scaleEffect(0.72)
                    }
                }
                .frame(width: 30, height: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text(port.name)
                        .font(.headline.bold())
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(isConfirmed ? accentTeal : .secondary)
                }
                Spacer()
                if isConfirmed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(accentTeal)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(isPending ? accentTealSoft.opacity(0.34) : panelBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(port.charging || isPending || isConfirmed ? accentTeal.opacity(0.26) : lineColor, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: isPending || isConfirmed ? accentTeal.opacity(0.18) : .clear, radius: 12, x: 0, y: 6)
        }
        .disabled(isPending)
        .buttonStyle(ScaleButtonStyle())
        .animation(.snappy(duration: 0.22), value: isPending)
        .animation(.snappy(duration: 0.22), value: feedback)
    }
}

struct DisplayButton: View {
    var title: String
    var isActive = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 36)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isActive ? Color.white : .primary)
        .background(isActive ? accentTeal : panelBackground)
        .shadow(color: isActive ? accentTeal.opacity(0.24) : .clear, radius: 10, x: 0, y: 5)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? accentTeal.opacity(0) : lineColor, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct DisplayOptionButton: View {
    var title: String
    var subtitle: String
    var icon: String
    var isActive: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(isActive ? Color.white.opacity(0.78) : .secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .foregroundStyle(isActive ? Color.white : .primary)
            .background(isActive ? accentTeal : panelBackground)
            .shadow(color: isActive ? accentTeal.opacity(0.22) : .clear, radius: 12, x: 0, y: 6)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? accentTeal.opacity(0) : lineColor, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct PetWidgetWindow: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        ZStack {
            PetSceneBackground(scene: store.weatherScene, power: store.status.totalWatts)
            HStack(spacing: 14) {
                CandyPetAvatar(
                    power: store.status.totalWatts,
                    level: store.petLevel,
                    mood: store.petMood,
                    pulse: store.petPulse,
                    scene: store.weatherScene
                )
                .frame(width: 118, height: 118)

                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(store.deviceOnline[store.selectedDeviceID ?? UUID()] == false ? Color.gray : Color.green)
                            .frame(width: 8, height: 8)
                        Text(store.activeDeviceName)
                            .font(.headline.bold())
                            .lineLimit(1)
                    }

                    Text("\(store.status.totalWatts, specifier: "%.1f")W")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(accentTeal)
                        .contentTransition(.numericText())

                    HStack(spacing: 8) {
                        Label(store.weatherScene.displayTitle, systemImage: store.weatherScene.iconName)
                            .font(.caption.bold())
                            .lineLimit(1)
                        Label(store.status.chargingPortCount > 0 ? "充电中" : "待机", systemImage: store.status.chargingPortCount > 0 ? "bolt.fill" : "pause.fill")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(.secondary)

                    PetEnergyProgress(value: store.petProgress)
                        .frame(maxWidth: 180)
                }
                Spacer(minLength: 0)
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            Task {
                if store.status.ports.isEmpty {
                    await store.refresh()
                }
                await store.refreshWeather(silent: true)
            }
        }
    }
}

extension View {
    func panelSurface() -> some View {
        self
            .padding(16)
            .liquidGlass(cornerRadius: 10, tint: accentTeal, fillOpacity: 0.10, useMaterial: false)
    }

    func liquidGlass(cornerRadius: CGFloat = 8, tint: Color = accentTeal, fillOpacity: Double = 0.34, useMaterial: Bool = true) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius, tint: tint, fillOpacity: fillOpacity, useMaterial: useMaterial))
    }

    func liquidGlassChrome(cornerRadius: CGFloat = 8, tint: Color = accentTeal) -> some View {
        modifier(LiquidGlassChromeModifier(cornerRadius: cornerRadius, tint: tint))
    }
}

struct MenuBarView: View {
    @EnvironmentObject private var store: ChargerStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(accentTeal)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.activeDeviceName)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .lineLimit(1)
                    Text(store.status.device.model == "--" ? "CoCan Mirror" : store.status.device.model)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 5) {
                    Circle()
                        .fill(isOnline ? Color.green : quietDot)
                        .frame(width: 7, height: 7)
                    Text(isOnline ? "在线" : "离线")
                        .font(.caption.bold())
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background((isOnline ? Color.green : quietDot).opacity(0.13))
                .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("实时总功率")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("\(store.status.totalWatts, specifier: "%.1f")")
                                .font(.system(size: 46, weight: .black, design: .rounded))
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .foregroundStyle(accentTeal)
                            Text("W")
                                .font(.headline.bold())
                                .foregroundStyle(accentTeal)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        MenuStatusPill(text: "\(store.status.chargingPortCount)/\(max(store.status.ports.count, 5)) 端口", color: Color.green, icon: "powerplug.fill")
                        MenuStatusPill(text: store.chargingModeName, color: accentAmber, icon: "bolt.badge.clock.fill")
                    }
                }
                ProgressView(value: store.status.totalWatts, total: Double(max(store.status.device.maxPower, 1)))
                    .tint(powerRatio > 0.72 ? accentAmber : accentTeal)
                HStack {
                    Text("功率预算")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int((powerRatio * 100).rounded()))% / \(store.status.device.maxPower)W")
                        .font(.caption.bold())
                        .monospacedDigit()
                }
            }
            .padding(14)
            .background(menuCardFill)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineColor, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Label("端口详情", systemImage: "powerplug.fill")
                        .font(.headline.bold())
                    Spacer()
                    Label("同步 \(store.status.updatedAt.formatted(date: .omitted, time: .shortened))", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(Color.green)
                }
                VStack(spacing: 6) {
                    ForEach(store.status.ports) { port in
                        MenuPortRow(port: port)
                    }
                }
            }
            .padding(12)
            .background(menuCardFill.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 8) {
                Label("充电记录", systemImage: "waveform.path.ecg")
                    .font(.headline.bold())
                HStack(spacing: 10) {
                    Image(systemName: "circle.hexagongrid.circle.fill")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(accentAmber)
                        .frame(width: 42, height: 42)
                        .background(accentAmber.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(recordTitle)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                        Text("累计 \(energyText(store.currentEnergyWh)) · 已采 \(store.trendSamples.count) 点")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .padding(12)
            .background(menuCardFill.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack(spacing: 10) {
                Button {
                    Task { await store.refresh() }
                } label: {
                    Label(store.isLoading ? "刷新中" : "刷新", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(store.isLoading)

                Button {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                } label: {
                    Label("打开监控", systemImage: "rectangle.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(accentTeal)
            }
        }
        .padding(14)
        .frame(width: 620)
        .background(menuBackground)
    }

    private var isOnline: Bool {
        if let id = store.selectedDeviceID, let value = store.deviceOnline[id] {
            return value
        }
        return !store.status.ports.isEmpty
    }

    private var powerRatio: Double {
        store.status.totalWatts / Double(max(store.status.device.maxPower, 1))
    }

    private var recordTitle: String {
        guard let port = store.status.ports.max(by: { $0.watts < $1.watts }), port.watts > 0 else {
            return "\(store.activeDeviceName) · 暂无输出"
        }
        return "\(store.activeDeviceName) · \(port.name) 峰值 \(String(format: "%.1f", port.watts))W"
    }

    private var menuBackground: Color {
        adaptiveColor(
            light: NSColor(red: 0.985, green: 0.950, blue: 0.895, alpha: 0.98),
            dark: NSColor(red: 0.080, green: 0.073, blue: 0.064, alpha: 0.98)
        )
    }

    private var menuCardFill: Color {
        adaptiveColor(
            light: NSColor(red: 1.000, green: 0.975, blue: 0.920, alpha: 0.92),
            dark: NSColor(red: 0.165, green: 0.140, blue: 0.110, alpha: 0.92)
        )
    }
}

struct MenuStatusPill: View {
    var text: String
    var color: Color
    var icon: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct MenuPortRow: View {
    var port: PortStatus

    var body: some View {
        HStack(spacing: 11) {
            RoundedRectangle(cornerRadius: 3)
                .fill(port.charging ? Color.green : accentTeal.opacity(port.connected ? 0.7 : 0.35))
                .frame(width: 4, height: 32)
            Image(systemName: port.index == 1 ? "cable.connector" : "cable.connector.horizontal")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(port.charging ? Color.green : accentTeal)
                .frame(width: 28)
            Text(port.name)
                .font(.subheadline.bold())
                .frame(width: 32, alignment: .leading)
            Circle()
                .fill(port.charging ? Color.green : quietDot)
                .frame(width: 6, height: 6)
            Text(portStatusText)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .frame(width: 56, alignment: .leading)
            Text(port.protocolName)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("温度 \(temperatureText)")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .frame(width: 72, alignment: .leading)
            Text(port.charging ? "OUTPUT" : "NOT_CHARGING")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
                .frame(width: 88, alignment: .trailing)
            Text("\(port.watts, specifier: "%.1f")W")
                .font(.headline.bold())
                .monospacedDigit()
                .foregroundStyle(port.charging ? Color.green : .primary)
                .contentTransition(.numericText())
                .frame(width: 74, alignment: .trailing)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(port.charging ? Color.green.opacity(0.08) : quietFill.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var portStatusText: String {
        if port.charging { return "正在供电" }
        if port.connected { return "已连接" }
        return "未接入"
    }

    private var temperatureText: String {
        switch port.temperature {
        case "warm": return "偏热"
        case "moderate": return "正常"
        case "cool": return "清凉"
        default: return port.temperature
        }
    }
}

struct MenuRoundButton: View {
    var title: String
    var icon: String
    var action: () -> Void

    init(icon: String, title: String, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.vertical, 10)
            .foregroundStyle(.primary)
            .background(panelBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineColor, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct MenuToggleChip: View {
    var icon: String
    var title: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                Text(title)
                Spacer(minLength: 0)
            }
            .font(.caption.bold())
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity)
            .foregroundStyle(isOn ? Color.white : .secondary)
            .background(isOn ? accentTeal : panelBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isOn ? accentTeal.opacity(0) : lineColor, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct MenuBarStatusLabel: View {
    @EnvironmentObject private var store: ChargerStore

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: menuIcon)
            if store.menuShowsPower {
                Text("\(Int(store.status.totalWatts.rounded()))W")
                    .monospacedDigit()
            }
            if store.menuShowsPower && store.menuShowsPorts && store.status.chargingPortCount > 0 && !store.menuCompact {
                Text("· \(store.status.chargingPortCount)口")
            }
            if !store.menuShowsPower && store.menuShowsPorts && store.status.chargingPortCount > 0 {
                Text("\(store.status.chargingPortCount)口")
            }
            if store.isLoading {
                ProgressView()
                    .controlSize(.small)
                    .scaleEffect(0.58)
                    .frame(width: 12, height: 12)
            }
        }
        .foregroundStyle(labelColor)
        .task {
            if store.status.ports.isEmpty {
                await store.refresh()
            }
        }
    }

    private var menuIcon: String {
        if store.menuShowsWarmWarning && store.status.hasWarmPort {
            return "thermometer.medium"
        }
        return "bolt.fill"
    }

    private var labelColor: Color {
        if store.menuShowsWarmWarning && store.status.hasWarmPort {
            return accentAmber
        }
        return .primary
    }
}
