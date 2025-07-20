//
//  GeomteryProxy+Exgt.swift
//  pISSStream WidgetExtension
//
//  Created by Schuh, Marcell on 6/8/25.
//

import SwiftUI

extension GeometryProxy {
    public var minSize: CGFloat {
        return min(size.width, size.height)
    }
    
    public var maxSize: CGFloat {
        return max(size.width, size.height)
    }
}
