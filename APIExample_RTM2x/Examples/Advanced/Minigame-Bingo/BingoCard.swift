//
//  BingoCard.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/16.
//

import Foundation

import SwiftUI

struct BingoCard {
    var numbers: [[Int]] // 5x5 grid of numbers
    var marked: [[Bool]] // 5x5 grid to track marked numbers

    init() {
        self.numbers = BingoCard.generateNumbers()
        self.marked = Array(repeating: Array(repeating: false, count: 5), count: 5)
    }
    
    static func generateNumbers() -> [[Int]] {
        var card = [[Int]](repeating: [Int](), count: 5)
        let ranges = [
            1...15,   // B
            16...30,  // I
            31...45,  // N
            46...60,  // G
            61...75   // O
        ]
        
        for (index, range) in ranges.enumerated() {
            card[index] = Array(range).shuffled().prefix(5).sorted()
        }
        
        // Set the center space to free
        card[2][2] = 0 // Free space
        return card
    }
}
