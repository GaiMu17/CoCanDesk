import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

@main
struct CoCanDeskApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = ChargerStore()

    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 980, minHeight: 680)
                .task { store.startAutoRefresh() }
                .onAppear {
                    store.setMainWindowVisible(true)
                    store.setAppActive(scenePhase == .active)
                }
                .onDisappear {
                    store.setMainWindowVisible(false)
                }
                .onChange(of: scenePhase) { _, phase in
                    store.setAppActive(phase == .active)
                }
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        MenuBarExtra {
            MenuBarView()
                .environmentObject(store)
                .frame(width: 620)
        } label: {
            MenuBarStatusLabel()
                .environmentObject(store)
                .task { store.startAutoRefresh() }
        }
        .menuBarExtraStyle(.window)
    }
}
