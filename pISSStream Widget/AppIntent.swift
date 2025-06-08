//
//  AppIntent.swift
//  pISSStream Widget
//
//  Created by Marcell Schuh on 6/7/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }

    // An example configurable parameter.
    @Parameter(title: "Astronaut Emoji", default: "👩‍🚀")
    var astronaut: String
}
