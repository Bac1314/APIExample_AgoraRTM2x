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
    var sender: String
}
