//
//  pISSSceneConfiguration.swift
//  pISSStream
//
//  Created by durul dalkanat on 12/25/24.
//

import SwiftUI

struct pISSSceneConfiguration: Scene {
    @StateObject private var appState = AppStateViewModel()

    var body: some Scene {
        #if os(visionOS)
            WindowGroup {
                ContentView()
                    .environmentObject(appState)
            }

            .windowStyle(.plain)
            .defaultSize(width: 400, height: 300)

            ImmersiveSpace(id: "ISSSpace") {
                pISSImmersiveView()
                    .environmentObject(appState)
            }

            .immersionStyle(selection: .constant(.full), in: .full)
        #endif
    }
}
