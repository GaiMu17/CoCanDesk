import Foundation

actor MCPClient {
    private let urlSession = URLSession.shared
    private var sessionId = ""
    private var rpcId = 1

    var endpoint: URL

    init(endpoint: URL) {
        self.endpoint = endpoint
    }

    func updateEndpoint(_ url: URL) {
        endpoint = url
        sessionId = ""
        rpcId = 1
    }

    func status() async throws -> ChargerStatus {
        let machine = try await callTool("get_machine_facts")
        let device = try await callTool("get_device_info")
        let details = try await callTool("get_port_details")
        let charging = try await callTool("get_charging_status")
        let temperature = try await callTool("get_temperature_mode")
        let display = try await callTool("get_display_config")
        let pd = try await callTool("get_port_pd_status")

        return try buildStatus(
            machine: machine,
            device: device,
            details: details,
            charging: charging,
            temperature: temperature,
            display: display,
            pd: pd
        )
    }

    func setAllocation(_ values: [Int]) async throws {
        _ = try await callTool("set_port_power_allocation", arguments: [
            "power_allocation": values
        ])
    }

    func setStrategy(_ strategy: Int) async throws {
        _ = try await callTool("set_charging_strategy", arguments: [
            "strategy": strategy
        ])
    }

    func setUsbaMode() async throws {
        _ = try await callTool("set_usba_charging_mode")
    }

    func turnPort(_ portIndex: Int, enabled: Bool) async throws {
        _ = try await callTool(enabled ? "turn_on_port" : "turn_off_port", arguments: [
            "ports": [portIndex]
        ])
    }

    func setTemperatureMode(_ mode: Int) async throws {
        _ = try await callTool("set_temperature_mode", arguments: [
            "mode": mode
        ])
    }

    func setDisplay(_ level: String) async throws {
        _ = try await callTool("set_display_intensity", arguments: [
            "level": level
        ])
    }

    func setStatusDisplayMode(_ mode: String) async throws {
        _ = try await callTool("set_status_display_mode", arguments: [
            "mode": mode
        ])
    }

    func setIdleDisplay(_ idleDisplay: String) async throws {
        _ = try await callTool("set_idle_display", arguments: [
            "idle_display": idleDisplay
        ])
    }

    func setHourlyChime(_ enabled: Bool) async throws {
        _ = try await callTool("set_hourly_chime", arguments: [
            "enabled": enabled
        ])
    }

    func portStats(_ port: Int) async throws -> [PortHistorySample] {
        let result = try await callTool("get_port_stats", arguments: [
            "port": port
        ])
        let samples = result["samples"] as? [[String: Any]] ?? []
        return samples.map { sample in
            PortHistorySample(
                watts: double(sample["power_mw"]) / 1000,
                voltage: double(sample["voltage_mv"]) / 1000,
                current: double(sample["current_ma"]) / 1000
            )
        }
    }

    private func ensureSession() async throws {
        if !sessionId.isEmpty { return }

        _ = try await rpc(method: "initialize", params: [
            "protocolVersion": "2025-03-26",
            "capabilities": [:],
            "clientInfo": [
                "name": "CoCanDesk",
                "version": "0.1.0"
            ]
        ])

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionId, forHTTPHeaderField: "Mcp-Session-Id")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "jsonrpc": "2.0",
            "method": "notifications/initialized",
            "params": [:]
        ])
        _ = try await urlSession.data(for: request)
    }

    private func callTool(_ name: String, arguments: [String: Any] = [:]) async throws -> [String: Any] {
        try await ensureSession()
        let result = try await rpc(method: "tools/call", params: [
            "name": name,
            "arguments": arguments
        ])

        guard
            let content = result["content"] as? [[String: Any]],
            let text = content.first(where: { $0["type"] as? String == "text" })?["text"] as? String
        else {
            return result
        }

        guard let data = text.data(using: .utf8) else { return ["message": text] }
        do {
            return (try JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? ["message": text]
        } catch {
            return ["message": text]
        }
    }

    private func rpc(method: String, params: [String: Any]) async throws -> [String: Any] {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !sessionId.isEmpty {
            request.setValue(sessionId, forHTTPHeaderField: "Mcp-Session-Id")
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "jsonrpc": "2.0",
            "id": rpcId,
            "method": method,
            "params": params
        ])
        rpcId += 1

        let (data, response) = try await urlSession.data(for: request)
        if let http = response as? HTTPURLResponse,
           let nextSession = http.value(forHTTPHeaderField: "mcp-session-id") {
            sessionId = nextSession
        }

        let payload: [String: Any]?
        do {
            payload = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch {
            throw NSError(domain: "CoCanDesk", code: -3, userInfo: [
                NSLocalizedDescriptionKey: "设备连接地址返回的数据格式不对，请确认这是小电拼的设备连接地址。"
            ])
        }
        if let error = payload?["error"] as? [String: Any] {
            throw NSError(domain: "CoCanDesk", code: -1, userInfo: [
                NSLocalizedDescriptionKey: error["message"] as? String ?? "设备请求失败"
            ])
        }

        return payload?["result"] as? [String: Any] ?? [:]
    }

    private func buildStatus(
        machine: [String: Any],
        device: [String: Any],
        details: [String: Any],
        charging: [String: Any],
        temperature: [String: Any],
        display: [String: Any],
        pd: [String: Any]
    ) throws -> ChargerStatus {
        let pdPorts = pd["ports"] as? [[String: Any]] ?? []
        let pdByPort = Dictionary(uniqueKeysWithValues: pdPorts.compactMap { item -> (Int, [String: Any])? in
            guard let port = item["port"] as? Int else { return nil }
            return (port, item)
        })

        let chargingPorts = charging["charging_ports"] as? [String: Bool] ?? [:]
        let detailPorts = details["ports"] as? [[String: Any]] ?? []

        let ports = detailPorts.compactMap { item -> PortStatus? in
            guard let index = item["port"] as? Int else { return nil }
            let pdInfo = pdByPort[index] ?? [:]
            let vout = double(item["vout_mv"])
            let current = double(item["iout_ma"])
            let connected = bool(item["connected"])
            let manufacturerVid = firstNonZeroInt(item["manufacturer_vid"], pdInfo["manufacturer_vid"], pdInfo["battery_vid"])
            let manufacturerPid = firstNonZeroInt(item["manufacturer_pid"], pdInfo["manufacturer_pid"], pdInfo["battery_pid"])
            let pdRevision = string(pdInfo["pd_revision"]) ?? "--"
            let batteryText: String
            if bool(pdInfo["battery_present"]) {
                batteryText = "\(int(pdInfo["battery_present_capacity"]))/\(int(pdInfo["battery_design_capacity"]))"
            } else {
                batteryText = ""
            }
            let batteryDetail: String
            if bool(pdInfo["battery_present"]) {
                batteryDetail = "电池 \(int(pdInfo["battery_present_capacity"]))/\(int(pdInfo["battery_design_capacity"]))"
            } else {
                batteryDetail = ""
            }
            let explicitDeviceName = string(item["device_name_zh"])
                ?? string(item["device_name_en"])
                ?? string(pdInfo["device_name_zh"])
                ?? string(pdInfo["device_name_en"])
            let inferredName = inferDeviceName(
                connected: connected,
                explicitName: explicitDeviceName,
                manufacturerVid: manufacturerVid,
                batteryVid: int(pdInfo["battery_vid"]),
                hasBattery: bool(pdInfo["battery_present"])
            )

            return PortStatus(
                index: index,
                name: portName(index),
                connected: connected,
                charging: chargingPorts["port_\(index)"] ?? false,
                device: inferredName,
                protocolName: string(item["fc_protocol"]) ?? "Unknown",
                watts: ((vout * current) / 1_000_000).rounded(toPlaces: 1),
                temperature: string(item["die_temperature"]) ?? "unknown",
                cable: string(pdInfo["cable_name_zh"]) ?? string(pdInfo["cable_name_en"]) ?? "",
                maxPdp: int(pdInfo["sink_maximum_pdp"]),
                batteryText: batteryText,
                identityText: identityText(vid: manufacturerVid, pid: manufacturerPid),
                pdRevision: pdRevision,
                batteryDetail: batteryDetail
            )
        }

        return ChargerStatus(
            device: DeviceSummary(
                name: string(machine["friendly_name_zh"]) ?? string(machine["friendly_name_en"]) ?? "小电拼",
                model: string(device["model"]) ?? "--",
                firmware: string(device["app_version"]) ?? "--",
                fpga: string(device["fpga_version"]) ?? "--",
                wifi: string(device["ssid"]) ?? "--",
                signal: int(device["rssi"]),
                maxPower: int(machine["max_power_budget"]),
                temperatureMode: string(temperature["mode_name"]) ?? "--",
                temperatureModeRaw: int(temperature["mode"])
            ),
            display: DisplaySummary(
                brightness: string(display["level"]) ?? string(display["intensity"]) ?? "--",
                statusMode: string(display["mode"]) ?? string(display["display_mode"]) ?? "--",
                idleDisplay: string(display["idle_display"]) ?? "--",
                hourlyChime: bool(display["hourly_chime"]) || bool(display["hourly_chime_enabled"]),
                supportsAdvancedDisplay: string(display["mode"]) != nil
                    || string(display["display_mode"]) != nil
                    || string(display["idle_display"]) != nil
                    || display["hourly_chime"] != nil
                    || display["hourly_chime_enabled"] != nil
            ),
            ports: ports,
            updatedAt: Date()
        )
    }
}

private func string(_ value: Any?) -> String? {
    guard let value = value as? String, !value.isEmpty else { return nil }
    return value
}

private func int(_ value: Any?) -> Int {
    if let value = value as? Int { return value }
    if let value = value as? Double { return Int(value) }
    return 0
}

private func firstNonZeroInt(_ values: Any?...) -> Int {
    values.map(int).first { $0 != 0 } ?? 0
}

private func inferDeviceName(
    connected: Bool,
    explicitName: String?,
    manufacturerVid: Int,
    batteryVid: Int,
    hasBattery: Bool
) -> String {
    if let explicitName { return explicitName }
    guard connected else { return "无" }
    let vid = manufacturerVid != 0 ? manufacturerVid : batteryVid
    if let vendor = vendorName(vid) {
        return hasBattery ? "\(vendor) 设备" : "\(vendor) 充电设备"
    }
    return hasBattery ? "带电池设备" : "未知设备"
}

private func identityText(vid: Int, pid: Int) -> String {
    guard vid != 0 || pid != 0 else { return "" }
    let vendor = vendorName(vid)
    let vidText = vid == 0 ? "--" : hex4(vid)
    let pidText = pid == 0 ? "--" : hex4(pid)
    if let vendor {
        return "\(vendor) · VID \(vidText) · PID \(pidText)"
    }
    return "VID \(vidText) · PID \(pidText)"
}

private func vendorName(_ vid: Int) -> String? {
    switch vid {
    case 1452: return "Apple"
    case 10703: return "Apple"
    case 6353: return "Google"
    case 1003: return "Samsung"
    case 4817: return "Huawei"
    case 2717: return "Xiaomi"
    default: return nil
    }
}

private func hex4(_ value: Int) -> String {
    String(format: "%04X", value)
}

private func double(_ value: Any?) -> Double {
    if let value = value as? Double { return value }
    if let value = value as? Int { return Double(value) }
    return 0
}

private func bool(_ value: Any?) -> Bool {
    return value as? Bool ?? false
}

private func portName(_ index: Int) -> String {
    [1: "A", 2: "C1", 3: "C2", 4: "C3", 5: "C4"][index] ?? "P\(index)"
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
