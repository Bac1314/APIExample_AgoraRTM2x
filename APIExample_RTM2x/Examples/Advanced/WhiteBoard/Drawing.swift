//
//  Drawing.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/24.
//

import Foundation
import SwiftUI

// For real-time update
struct DrawingPoint: Codable {
    var id: UUID
    var point: CGPoint
}

struct Drawing: Identifiable, Codable {
    var id: UUID  = UUID()
    var points: [CGPoint] = []
    var color: Color = .black
    var lineWidth: CGFloat = 5
    
    init() {
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, points, color, lineWidth
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        points = try container.decode([CGPoint].self, forKey: .points)
        
        let colorString = try container.decode(String.self, forKey: .color)
        color = Color(hex: colorString) ?? .black
        lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(points, forKey: .points)
        
        let colorData = color.toHex()
        try container.encode(colorData, forKey: .color)
        
        try container.encode(lineWidth, forKey: .lineWidth)
    }
}

// This will limit the points/location to 2 decimals and save over 70% of data 
extension CGPoint {
    func roundTo2Decimals() -> CGPoint {
        let newX = (self.x * 100).rounded() / 100
        let newY = (self.y * 100).rounded() / 100
        return CGPoint(x: newX, y: newY)
    }
}
