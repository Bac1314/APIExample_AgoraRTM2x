//
//  CustomPoll.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/1.
//

import Foundation
import AgoraRtmKit

struct CustomPoll: Codable, Identifiable {
    var id: UUID  = UUID()
    var question: String
    var options: [String: Int]
    var sender: String
    var totalUsers: Int
    var totalSubmission: Int
    var timestamp: Int // timestamp e.g. 1711961436
}
