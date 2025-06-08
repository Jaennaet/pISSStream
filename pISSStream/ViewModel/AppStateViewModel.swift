//
//  AppState.swift
//  pISSStream
//
//  Created by durul dalkanat on 12/25/24.
//

import os
import SwiftUI

@MainActor
class AppStateViewModel: ObservableObject {
    static let shared = AppStateViewModel() // Singleton instance
    @Published var pissAmount: String = "N/A"
    @Published var isConnected: Bool = false // is connection to Lightstreamer OK
    @Published var hasSignal: Bool = false  // ISS telemetry signal acquired

    /// Logger for this class.
    private let logger = Logger(
        subsystem: "social.bsky.jaennaet.pISSStream", category: "AppStateViewModel")
    
    /// Piss actor to handle the piss stream.
    private lazy var pissActor = PissSocket(appState: self)

    /// Initialize the app state.
    init() {
        startPissStream()
    }

    /// Get the status text based on connection and signal state
    func getStatusText() -> String {
        if !isConnected {
            return "Connection Lost"
        }
        return hasSignal ? "Connected" : "Signal Lost (LOS)"
    }
    
    /// Get the status color based on connection and signal state
    func getStatusColor() -> Color {
        if !isConnected {
            return .red
        }
        return hasSignal ? .green : .orange
    }

    /// Start the piss stream.
    private func startPissStream() {
        Task {
            logger.debug("starting pissActor.pissStream() reader")
            for await amount in pissActor.pissStream {
                self.pissAmount = amount
                self.isConnected = true
            }
        }
    }
    
}
