//
//  TicTacToeModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/13.
//

import Foundation


struct TicTacToeModel : Codable {
    var board: [[String]] = [["", "", ""], ["", "", ""], ["", "", ""]]
    var winner: String = ""
    var player1Name: String = ""
    var player2Name: String = ""
    var gameStarted: Bool = false
    var currentXorO: String = "X"

}
