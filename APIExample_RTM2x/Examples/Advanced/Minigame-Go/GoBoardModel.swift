//
//  GoBoardModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/15.
//

import Foundation


struct GoBoardModel : Codable {
    var boardSize: Int = 14
    var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 14), count: 14)
    var winner: String = ""
    var player1Name: String = ""
    var player2Name: String = ""
    var gameStarted: Bool = false
    var current1or2: Int = 1

}

//
//@State var board: [[Int]]
//@State var currentPlayer: Int = 1
//let boardSize: Int = 12
