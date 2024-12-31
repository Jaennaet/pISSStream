//
//  PissLabel.swift
//  pISSStream
//
//  Created by durul dalkanat on 12/25/24.
//

import SwiftUI

struct PissLabel: View {
    let amount: String
    let isConnected: Bool

    private var labelSymbols: String {
        isConnected ? "🧑🏽‍🚀🚽" : "🧑🏽‍🚀❗"
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            Text("\(labelSymbols)\(amount)")
                .font(.system(size: 12, weight: .bold, design: .default))
                .opacity(isConnected ? 1.0 : 0.5)
        }
        #if os(iOS)
        .padding(.horizontal)
        #endif
    }
}
