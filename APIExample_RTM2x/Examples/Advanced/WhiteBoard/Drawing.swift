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
    var points: [CGPoint] = [CGPoint]()
    var color: Color = .black
    var lineWidth: CGFloat = 5
    
    init() {}
    
    private enum CodingKeys: String, CodingKey {
        case id, points, color, lineWidth
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        points = try container.decode([CGPoint].self, forKey: .points)
        
//        if let colorData = try container.decode(Data?.self, forKey: .color) {
//            do {
//                if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
//                   self.color = Color(color)
//                } else {
//                   self.color = .black
//                }
//            } catch {
//                self.color = .black
//            }
//        }
        let colorString = try container.decode(String.self, forKey: .color)
        color = Color(hex: colorString) ?? .black
        lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(points, forKey: .points)
        
//        let colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
        let colorData = color.toHex()
        try container.encode(colorData, forKey: .color)
        
        try container.encode(lineWidth, forKey: .lineWidth)
    }
}
