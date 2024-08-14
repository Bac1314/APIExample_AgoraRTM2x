//
//  GoBoardView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/14.
//

import SwiftUI

struct GoBoardView: View {
    @State var board: [[Int]]
    @State var currentPlayer: Int = 1
    @State var cellSize : CGFloat = 30
    let boardSize: Int = 15
    
    init(){
        board = Array(repeating: Array(repeating: 0, count: boardSize), count: boardSize)
    }
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width

        VStack {
            Text("Gomoku")
                .font(.largeTitle)
                .padding()

            
            // Display the board
            VStack(spacing: 0) {
                ForEach(0..<boardSize, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<boardSize, id: \.self) { col in
                            Rectangle()
                                .fill(.brown)
                                .frame(width: cellSize, height: cellSize)
                                .border(Color.black) // Add border to distinguish cells
                                .overlay(alignment: .center) {
                                    Circle()
                                        .fill(self.colorForCell(row: row, col: col))
                                        .padding(4)

                                }
                                .onTapGesture {
                                    makeMove(row: row, col: col)
                                }
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                cellSize = (screenWidth - 50) / CGFloat(boardSize)
            }
            

            
        }
    }
    
    func makeMove(row: Int, col: Int) {
        guard board[row][col] == 0 else { return }
        board[row][col] = currentPlayer
        if checkWinner(player: currentPlayer, row: row, col: col) {
            print("Player \(currentPlayer) wins!")
        }
        currentPlayer = currentPlayer == 1 ? 2 : 1
    }

    func checkWinner(player: Int, row: Int, col: Int) -> Bool {
        withAnimation {
            return checkDirection(player: player, row: row, col: col, deltaRow: 1, deltaCol: 0) || // Vertical
                   checkDirection(player: player, row: row, col: col, deltaRow: 0, deltaCol: 1) || // Horizontal
                   checkDirection(player: player, row: row, col: col, deltaRow: 1, deltaCol: 1) || // Diagonal \
                   checkDirection(player: player, row: row, col: col, deltaRow: 1, deltaCol: -1)   // Diagonal /
        }

    }

     func checkDirection(player: Int, row: Int, col: Int, deltaRow: Int, deltaCol: Int) -> Bool {
        var count = 0
        for i in -4...4 {
            let newRow = row + i * deltaRow
            let newCol = col + i * deltaCol
            if newRow >= 0, newRow < boardSize, newCol >= 0, newCol < boardSize, board[newRow][newCol] == player {
                count += 1
                if count == 5 {
                    return true
                }
            } else {
                count = 0
            }
        }
        return false
    }
    
    private func colorForCell(row: Int, col: Int) -> Color {
        switch board[row][col] {
        case 1:
            return .black
        case 2:
            return .white
        default:
            return .brown
        }
    }
}

#Preview {
    GoBoardView()
}
