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
        self.marked[2][2] = true // Set center cell as marked
    }
    
    static func generateNumbers() -> [[Int]] {
        var allNumbers = Array(1...50).shuffled() // Create an array of numbers 1-75 and shuffle it
        var card = [[Int]]()
        
        for _ in 0..<5 {
            // Take the first 5 unique numbers from the shuffled array for each row
            let rowNumbers = Array(allNumbers.prefix(5))
            card.append(rowNumbers)
            allNumbers.removeFirst(5) // Remove the numbers used for this row
        }
        
        // Set the center space to free
        card[2][2] = 0 // Free space
        return card
    }
    
    
    mutating func markNumber(_ number: Int) {
        for row in 0..<5 {
            for column in 0..<5 {
                if numbers[row][column] == number {
                    marked[row][column] = true
                    return // Exit once the number is found and marked
                }
            }
        }
    }
    
    func isBingo() -> Bool {
        // Check rows
        for row in marked {
            if row.allSatisfy({ $0 == true }) { // Corrected here
                return true
            }
        }
        
        // Check columns
        for col in 0..<5 {
            if (0..<5).allSatisfy({ marked[$0][col] }) { // Corrected here
                return true
            }
        }
        
        // Check diagonals
        let diagonal1 = (0..<5).allSatisfy { marked[$0][$0] } // Top-left to bottom-right
        let diagonal2 = (0..<5).allSatisfy { marked[$0][4 - $0] } // Top-right to bottom-left
        
        return diagonal1 || diagonal2
    }
}
