import BackgroundTasks
import LightstreamerClient
import os
import SwiftUI

@main
struct pISSStreamApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppStateViewModel()
    #endif

    var body: some Scene {
        #if os(macOS)
        // MacOS MenuBar Interface
        MenuBarExtra {
            VStack {
                Text(appState.getStatusText())
                    .foregroundColor(appState.getStatusColor())
                    .font(.caption)

                Divider()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        } label: {
            PissLabel(
                amount: appState.pissAmount,
                isConnected: appState.isConnected && appState.hasSignal
            )
        }
        #elseif os(visionOS)
        pISSSceneConfiguration()
        #else
        // iOS Interface
        WindowGroup {
            ContentView()
                .environmentObject(AppStateViewModel())
        }
        #endif
    }
}

extension Color {
    static let pissYellowLight = Color(red: 0.95, green: 0.85, blue: 0.2)
    static let pissYellowDark = Color(red: 0.7, green: 0.6, blue: 0.1)
}
