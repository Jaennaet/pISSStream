//
//  PissTankView.swift
//  pISSStream
//
//  Created by Schuh, Marcell on 6/9/25.
//

import SwiftUI
import WidgetKit

struct PissTankView: View {
    let pissData: PissData
    let family: WidgetFamily
    
    var body: some View {
        let bars = family.isSmall() ? 10 : 20
        
        let pissPercentage: Double = (Double(pissData.pissValue) ?? 0.0) / 100.0
        GeometryReader { geometry in
            let barWidth = geometry.size.width / CGFloat(bars) - 4.0
            let barHeight: CGFloat = 35.0
            let tickPosition: CGFloat = (floor(Double(pissPercentage - 0.01) * Double(bars)) * geometry.size.width / CGFloat(bars)) + barWidth / 2.0
            
            ForEach(0..<bars, id: \.self) { index in
                let pissColor = pissPercentage <= (Double(index) / Double(bars)) ? Color.pissYellowDark.opacity(0.5) : Color.pissYellowLight
                RoundedRectangle(cornerRadius: 10)
                    .fill(pissColor)
                    .frame(width: barWidth, height: barHeight)
                    .position(x: Double(index) * (geometry.size.width / Double(bars)) + barWidth / 2.0, y: geometry.size.height / 2)
            }
            

            RoundedRectangle(cornerRadius: 10)
                .fill()
                .frame(width: 1, height: family.isSmall() ? 10 : 15)
                .position(x: tickPosition, y: geometry.size.height - 20.0)

            Text("\(pissData.pissValue)%")
                .frame(width: 45, height: 30, alignment: .center)
                .position(x: tickPosition, y: geometry.size.height - 5.0)
        }
    }
}

#if !os(watchOS)
#Preview("System Small", as: .systemSmall) {
    pISSStream_Widget()
} timeline: {
    PissEntry(date: .now, pissData: PissData(isConnected: false, pissValue: "1"), configuration: .woman)
    PissEntry(date: .now + 60, pissData: PissData(isConnected: false, pissValue: "16"), configuration: .woman)
    PissEntry(date: .now + 120, pissData: PissData(isConnected: true, pissValue: "100"), configuration: .woman)
}

#Preview("System Medium", as: .systemMedium) {
    pISSStream_Widget()
} timeline: {
    PissEntry(date: .now, pissData: PissData(isConnected: false, pissValue: "1"), configuration: .woman)
    PissEntry(date: .now + 60, pissData: PissData(isConnected: false, pissValue: "16"), configuration: .woman)
    PissEntry(date: .now + 120, pissData: PissData(isConnected: true, pissValue: "100"), configuration: .woman)
}
#endif
