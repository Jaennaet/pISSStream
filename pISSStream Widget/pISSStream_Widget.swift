//
//  pISSStream_Widget.swift
//  pISSStream Widget
//
//  Created by Marcell Schuh on 6/7/25.
//

import WidgetKit
import SwiftUI


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

struct PissWidgetView: View {
    let family: WidgetFamily
    let entry: PissTimelineProvider.Entry
    
    
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                VStack (alignment: .trailing) {
                    HStack(alignment: .center ) {
                        Text("\(entry.configuration.astronaut)🚽 \(family.isSmall() ? "" : "ISS Waste Tank Level ")")
                            .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.1))
                            .frame(alignment: .leading)
                        Spacer()
                        
                        Circle()
                            .fill(entry.pissData.getStatusColor())
                            .frame(width: geometry.size.width * 0.025, height: geometry.size.width * 0.025)
                        
                        if (!family.isSmall()) {
                            Text(entry.pissData.getStatusText())
                                .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.08))
                        } else {
                            VStack(alignment: .trailing) {
                                Text(entry.pissData.getShortStatusText())
                                Text(entry.date, style: .time)
                            }
                            .font(.system(size: geometry.minSize * 0.05))
                        }
                        
                    }
                    if (!family.isSmall()) {
                        Text("Updated @ \(entry.date, style: .time)")
                            .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.05))
                    }
                }
                PissTankView(pissData: entry.pissData, family: family)
            }
            
        }
    }
    
}

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

struct pISSStream_WidgetEntryView : View {
    var entry: PissTimelineProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch(family) {
            case .systemSmall, .systemMedium:
                PissWidgetView(family: family, entry: entry)
            case .accessoryCircular:
                PissCircularAccessoryView(entry: entry)
            case .accessoryRectangular:
                PissRectengularAccessoryView(entry: entry)
            case .accessoryInline:
                PissInlineAccessoryView(entry: entry)
            case .accessoryCorner:
                PissCornerAccessoryView(entry: entry)
            default:
                PissWidgetView(family: family, entry: entry)
        }
    }
}

public struct pISSStream_Widget: Widget {
    let kind: String = "pISSStream_Widget"
    
    public init() {
        
    }
    
    public var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: PissTimelineProvider()) { entry in
            pISSStream_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        #if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
        #elseif os(macOS)
            .supportedFamilies([.systemSmall, .systemMedium])
        #else
            .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline,
                            .systemSmall, .systemMedium])
        #endif
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

#if !os(macOS)
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
