//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI
import AVFoundation

struct TestingView: View {
    @State private var board: [[String]] = [["", "", ""], ["", "", ""], ["", "", ""]]
    @State private var currentPlayer: String = "X"
    @State private var winner: String?
    @State private var showAlert: Bool = false

    var body: some View {
        VStack {
            Text("Tic-Tac-Toe")
                .font(.largeTitle)
                .padding()

            // Display the board
            ForEach(0..<3) { row in
                HStack {
                    ForEach(0..<3) { column in
                        Button(action: {
                            self.makeMove(row: row, column: column)
                        }) {
                            Text(self.board[row][column])
                                .font(.largeTitle)
                                .frame(width: 100, height: 100)
                                .background(Color.gray.opacity(0.5))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        .disabled(self.board[row][column] != "" || winner != nil) // Disable button if already chosen or game is over
                    }
                }
            }
            .padding()

            if let winner = winner {
                Text("\(winner) wins!")
                    .font(.title)
                    .padding()
            } else if isBoardFull() {
                Text("It's a draw!")
                    .font(.title)
                    .padding()
            }
            
            Button("Reset Game") {
                resetGame()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Game Over"), message: Text(winner != nil ? "\(winner!) wins!" : "It's a draw!"), dismissButton: .default(Text("OK")) {
                resetGame()
            })
        }
    }

    func makeMove(row: Int, column: Int) {
        guard board[row][column] == "" && winner == nil else { return }
        board[row][column] = currentPlayer
        if checkWinner() {
            winner = currentPlayer
            showAlert = true
        } else if isBoardFull() {
            showAlert = true
        } else {
            currentPlayer = currentPlayer == "X" ? "O" : "X"
        }
    }

    func checkWinner() -> Bool {
        // Check rows, columns, and diagonals
        for i in 0..<3 {
            if board[i][0] == currentPlayer && board[i][1] == currentPlayer && board[i][2] == currentPlayer {
                return true
            }
            if board[0][i] == currentPlayer && board[1][i] == currentPlayer && board[2][i] == currentPlayer {
                return true
            }
        }
        if board[0][0] == currentPlayer && board[1][1] == currentPlayer && board[2][2] == currentPlayer {
            return true
        }
        if board[0][2] == currentPlayer && board[1][1] == currentPlayer && board[2][0] == currentPlayer {
            return true
        }
        return false
    }

    func isBoardFull() -> Bool {
        for row in board {
            if row.contains("") {
                return false
            }
        }
        return true
    }

    func resetGame() {
        board = [["", "", ""], ["", "", ""], ["", "", ""]]
        currentPlayer = "X"
        winner = nil
    }
}


#Preview {
    struct Preview: View {

        var body: some View {
            TestingView()
        }
    }
    
    return Preview()
}
