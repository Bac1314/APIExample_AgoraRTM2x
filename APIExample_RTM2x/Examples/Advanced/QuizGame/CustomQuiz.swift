//
//  CustomQuiz.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/8.
//

import Foundation

struct CustomQuiz: Codable, Identifiable {
    var id: UUID  = UUID()
    var question: String
    var options: [String]
    var answer: String
    var sender: String
    var totalUsers: Int
    var totalSubmission: Int
    var timestamp: Int // timestamp e.g. 1711961436
}
