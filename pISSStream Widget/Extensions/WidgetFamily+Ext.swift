//
//  WidgetFamily+Ext.swift
//  pISSStream WidgetExtension
//
//  Created by Schuh, Marcell on 6/8/25.
//

import WidgetKit

extension WidgetFamily {
    #if !os(watchOS)
    func isSmall() -> Bool {
        self == .systemSmall
    }
    
    func isMedium() -> Bool {
        self == .systemMedium
    }
    
    func isLarge() -> Bool {
        self == .systemLarge
    }
    #else
    func isSmall() -> Bool {
        false
    }
    
    func isMedium() -> Bool {
        false
    }
    
    func isLarge() -> Bool {
        false
    }
    #endif
}
