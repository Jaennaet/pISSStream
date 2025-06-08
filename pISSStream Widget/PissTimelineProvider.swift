//
//  PissTimelineProvider.swift
//  pISSStream WidgetExtension
//
//  Created by Marcell Schuh on 6/8/25.
//

import Foundation
import WidgetKit
import os
import SwiftUI


struct PissData {
    let isConnected: Bool
    let pissValue: String
}

struct PissEntry: TimelineEntry {
    let date: Date
    let pissData: PissData
    let configuration: ConfigurationAppIntent
}


struct PissTimelineProvider: AppIntentTimelineProvider {
    let logger = Logger(
        subsystem: "social.bsky.jaennaet.pISSStream", category: "PissTimelineProvider"
    )

    func placeholder(in context: Context) -> PissEntry {
        PissEntry(date: Date(), pissData: PissData(isConnected: false, pissValue: "75"), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> PissEntry {
        
        PissEntry(date: Date(), pissData: PissData(isConnected: true, pissValue: "75"), configuration: ConfigurationAppIntent())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<PissEntry> {
        let pissData = await fetchData()
        
        let entry = PissEntry(date: Date(), pissData: pissData, configuration: configuration)
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()

        return Timeline(entries: [entry], policy: .after(next))
    }
    
    private func fetchData() async -> PissData {
        let pissRequest = getUrlRequest(for: "NODE3000005", schema: "Value")
        let statusRequest = getUrlRequest(for: "TIME_000001", schema: "Status.Class")
        
        do {
            let (pissData, _) = try await URLSession.shared.data(for: pissRequest)
            let (statusData, _) = try await URLSession.shared.data(for: statusRequest)
            
            
            if let pissStringRaw = String(data: pissData, encoding: .utf8),
               let statusStringRaw = String(data: statusData, encoding: .utf8)
            {
                let pissString = pissStringRaw.parseLightstreamerResponse()
                let statusString = statusStringRaw.parseLightstreamerResponse()
                
                return PissData(isConnected: statusString == "24", pissValue: pissString)
            }
        } catch {}
        
        return PissData(isConnected: false, pissValue: "")
    }
    
    
    private func getUrlRequest(for item: String, schema: String) -> URLRequest {
        var urlRequest = URLRequest(url: URL(string: "https://push.lightstreamer.com/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0")!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = "LS_user=&LS_adapter_set=ISSLIVE&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_op=add&LS_subId=1&LS_group=\(item)&LS_schema=\(schema)&LS_mode=MERGE&LS_snapshot=true&LS_polling=true&LS_polling_millis=1000".data(using: .utf8)
        
        return urlRequest
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
    
    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        return [AppIntentRecommendation(intent: .woman, description: "Astronaut 1"), AppIntentRecommendation(intent: .man, description: "Astronaut 2")]
    }
}


private extension String {
    func parseLightstreamerResponse() -> String {
        return String(split(whereSeparator: \.isNewline).first(where: { $0.starts(with: "U,")})?.split(separator: ",")[3] ?? "")
    }
}


extension PissData {
    /// Get the status text based on connection and signal state
    func getStatusText() -> String {
        return isConnected ? "Connected" : "Signal Lost (LOS)"
    }
    
    /// Get the status color based on connection and signal state
    func getStatusColor() -> Color {
        return isConnected ? .green : .orange
    }
}
