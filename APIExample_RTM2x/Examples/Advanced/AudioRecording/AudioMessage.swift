//
//  AudioMessage.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/24.
//

import Foundation
import AVFoundation

struct AudioMessage : Identifiable, Codable {
    var id: UUID
    var fileName: String
    var fileURL: URL
    var sender: String
    var duration: Int // In Seconds
//    var timestamp: Date
//    var channel: String
}
