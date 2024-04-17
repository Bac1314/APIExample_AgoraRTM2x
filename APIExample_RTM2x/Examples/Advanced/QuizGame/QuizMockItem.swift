//
//  CustomQuizMockItem.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/9.
//

import Foundation

struct QuizMockItem: Codable {
    let type: TypeEnum
    let difficulty: Difficulty
    let category: Category
    let question, correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case type, difficulty, category, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

enum Category: String, Codable {
    case generalKnowledge = "General Knowledge"
    case scienceGadgets = "Science: Gadgets"
}


enum Difficulty: String, Codable {
    case easy = "easy"
    case hard = "hard"
    case medium = "medium"
}

enum TypeEnum: String, Codable {
    case boolean = "boolean"
    case multiple = "multiple"
}

typealias Welcome = [QuizMockItem]


