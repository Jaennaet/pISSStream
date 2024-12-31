//
//  ContentView.swift
//  pISSStream
//
//  Created by durul dalkanat on 12/25/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppStateViewModel
    
    #if os(visionOS)
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var isImmersive = false
    #endif
    
    var body: some View {
        VStack(spacing: 20) {
            #if os(visionOS)
            // 3D View Toggle Button at the top
            Button(action: {
                Task {
                    if isImmersive {
                        await dismissImmersiveSpace()
                        isImmersive = false
                    } else {
                        await openImmersiveSpace(id: "ISSSpace")
                        isImmersive = true
                    }
                }
            }) {
                Label(
                    isImmersive ? "Exit 3D View" : "View in 3D",
                    systemImage: isImmersive ? "arrow.down.right.and.arrow.up.left" : "view.3d"
                )
                .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
            #endif
            
            // Status indicator
            HStack {
                Circle()
                    .fill(appState.getStatusColor())
                    .frame(width: 12, height: 12)
                Text(appState.getStatusText())
                    .font(.subheadline)
            }
            
            // Main display
            VStack(spacing: 8) {
                Text("ISS Waste Tank Level")
                    .font(.headline)
                
                Text(appState.pissAmount)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.pissYellowDark)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.pissYellowLight.opacity(0.2))
            )
            
            // Astronaut emoji
            Text("🧑🏽‍🚀🚽")
                .font(.system(size: 32))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(visionOS)
            .onAppear {
                // Automatically open immersive space when view appears
                Task {
                    try? await Task.sleep(for: .seconds(1))
                    await openImmersiveSpace(id: "ISSSpace")
                    isImmersive = true
                }
            }
        #endif
    }
}
