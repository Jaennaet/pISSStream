//
//  PissWidgetView.swift
//  pISSStream
//
//  Created by Schuh, Marcell on 6/9/25.
//

import SwiftUI
import WidgetKit


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
