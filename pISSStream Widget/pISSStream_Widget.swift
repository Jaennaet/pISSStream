//
//  pISSStream_Widget.swift
//  pISSStream Widget
//
//  Created by Marcell Schuh on 6/7/25.
//

import WidgetKit
import SwiftUI

struct pISSStream_WidgetEntryView : View {
    var entry: PissTimelineProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch(family) {
            case .systemSmall, .systemMedium:
                PissWidgetView(family: family, entry: entry)
            #if !os(macOS)
            case .accessoryCircular:
                PissCircularAccessoryView(entry: entry)
            case .accessoryRectangular:
                PissRectangularAccessoryView(entry: entry)
            case .accessoryInline:
                PissInlineAccessoryView(entry: entry)
            case .accessoryCorner:
                PissCornerAccessoryView(entry: entry)
            #endif
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
                .containerBackground(.background, for: .widget)
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
