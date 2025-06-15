//
//  File.swift
//  pISSStream
//
//  Created by Schuh, Marcell on 6/9/25.
//

import SwiftUI
import WidgetKit

#if !os(macOS)
struct PissCircularAccessoryView: View {
    let entry: PissTimelineProvider.Entry
    
    var body: some View {
        let progress: Double = (Double(entry.pissData.pissValue) ?? 0.0) / 100.0
        
        Gauge(value: progress) {
            Text("\(entry.configuration.astronaut)🚽")
        } currentValueLabel: {
            Text("\(Int(progress * 100))%")
        }
        .gaugeStyle(.accessoryCircular)
    }
}

struct PissRectengularAccessoryView: View {
    let entry: PissTimelineProvider.Entry
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("ISS Waste")
                Text("\(entry.pissData.getShortStatusText()) • \(entry.date, style: .time)")
            }
            .font(.system(size: 11))
            Spacer()
            PissCircularAccessoryView(entry: entry)
        }
    }
}

struct PissInlineAccessoryView: View {
    let entry: PissTimelineProvider.Entry

    var body: some View {
        HStack(alignment: .center) {
            Text("ISS Waste: \(entry.pissData.pissValue)% • \(entry.pissData.getShortStatusText())")
        }
    }
}

struct PissCornerAccessoryView: View {
    let entry: PissTimelineProvider.Entry

    var body: some View {
        let progress: Double = (Double(entry.pissData.pissValue) ?? 0.0) / 100.0
        let gradient = LinearGradient(stops: [.init(color: .pissYellowLight, location: 0), .init(color: .pissYellowDark, location: 1)], startPoint: .topTrailing, endPoint: .bottomLeading)

        ZStack {
            AccessoryWidgetBackground()
            Text("\(entry.configuration.astronaut)🚽\(entry.pissData.getShortStatusText())")
                .multilineTextAlignment(.center)
        }
        .widgetLabel {
            Gauge(value: progress) {
            } currentValueLabel: {
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            }
        }
        .tint(gradient)
    }
}

#Preview("Accessory Circular", as: .accessoryCircular) {
    pISSStream_Widget()
} timeline: {
    PissEntry(date: .now, pissData: PissData(isConnected: false, pissValue: "1"), configuration: .woman)
    PissEntry(date: .now + 60, pissData: PissData(isConnected: false, pissValue: "16"), configuration: .woman)
    PissEntry(date: .now + 120, pissData: PissData(isConnected: true, pissValue: "100"), configuration: .woman)
}

#Preview("Accessory Rectangular", as: .accessoryRectangular) {
    pISSStream_Widget()
} timeline: {
    PissEntry(date: .now, pissData: PissData(isConnected: false, pissValue: "1"), configuration: .woman)
    PissEntry(date: .now + 60, pissData: PissData(isConnected: false, pissValue: "16"), configuration: .woman)
    PissEntry(date: .now + 120, pissData: PissData(isConnected: true, pissValue: "100"), configuration: .woman)
}

#Preview("Accessory Inline", as: .accessoryInline) {
    pISSStream_Widget()
} timeline: {
    PissEntry(date: .now, pissData: PissData(isConnected: false, pissValue: "1"), configuration: .woman)
    PissEntry(date: .now + 60, pissData: PissData(isConnected: false, pissValue: "16"), configuration: .woman)
    PissEntry(date: .now + 120, pissData: PissData(isConnected: true, pissValue: "100"), configuration: .woman)
}
#endif

#if os(watchOS)
#Preview("Accessory Corner", as: .accessoryCorner) {
    pISSStream_Widget()
} timeline: {
    PissEntry(date: .now, pissData: PissData(isConnected: false, pissValue: "1"), configuration: .woman)
    PissEntry(date: .now + 60, pissData: PissData(isConnected: false, pissValue: "16"), configuration: .woman)
    PissEntry(date: .now + 120, pissData: PissData(isConnected: true, pissValue: "100"), configuration: .woman)
}
#endif
