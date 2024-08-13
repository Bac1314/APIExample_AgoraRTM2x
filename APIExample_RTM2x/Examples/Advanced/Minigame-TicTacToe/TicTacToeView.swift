//
//  TicTacToeView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/12.
//

import SwiftUI

struct TicTacToeView: View {
    @State var board: [[String]] = [["", "", ""], ["", "", ""], ["", "", ""]]
    @State var currentXorO: String = "X"
    @State var winner: String?
    @State var player1Name: String = ""
    @State var player2Name: String = ""
    @State var userName: String = "Bac" // Could player1, player2, or spectator
    @State var gameStarted: Bool = false
    
    var virtualgifts : [String] = [
        "flower1", "flowers2", "present", "fireworks1"
    ]
    @State var virtualIndex = 0

    var body: some View {
        ZStack {
            VStack {
                if !gameStarted {
                    // Player Name Input
                    Text("Enter Game")
                        .font(.title)
                        .padding()

                    Text(player1Name.isEmpty ? "P1 : Tap To Enter" : "P1: \(player1Name)")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .foregroundStyle(player1Name.isEmpty ? Color.gray : Color.accentColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(player1Name.isEmpty  ? Color.gray : Color.accentColor, lineWidth: 2)
                        )
                        .contentTransition(.numericText())
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background()
                        .onTapGesture {
                            if player1Name.isEmpty && player2Name != userName {
                                withAnimation{
                                    player1Name = userName
                                }
                            }
                            else if player1Name == userName {
                                withAnimation {
                                    player1Name = ""
                                }
                            }
                        }
                    
                    Text(player2Name.isEmpty ? "P2 : Tap To Enter" : "P2: \(player2Name)")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .foregroundStyle(player2Name.isEmpty  ? Color.gray : Color.accentColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(player2Name.isEmpty  ? Color.gray : Color.accentColor, lineWidth: 2)
                        )
                        .contentTransition(.numericText())
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .onTapGesture {
                            if player2Name.isEmpty  && player1Name != userName {
                                withAnimation{
                                    player2Name = userName
                                }
                            }
                            else if player2Name == userName {
                                withAnimation {
                                    player2Name = ""
                                }
                            }
                        }
                    
                    Button("Start Game") {
                        startGame()
                    }
                    .buttonBorderShape(.roundedRectangle(radius: 16.0))
                    .disabled(player1Name.isEmpty || player2Name.isEmpty)
                } else {
                    // Spectator
                    if userName != player1Name && userName != player2Name {
                        Text("You are spectating")
                            .font(.caption2)
                            .bold()
                            .padding(8)
                            .foregroundStyle(Color.pink)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.pink, lineWidth: 2)
                            )
                    }
                    
                    Text("Tic-Tac-Toe")
                        .font(.largeTitle)
                        .padding()
                    
                    HStack {
                        Text("X: \(player1Name)")
                            .underline(currentXorO == "X", color: .accentColor)
                            .bold(currentXorO == "X")
                            .font(currentXorO == "X" ? .headline : .subheadline)
                            .foregroundStyle(currentXorO == "X" ? Color.accentColor : Color.primary)

                        Spacer()
                        Text("O: \(player2Name)")
                            .underline(currentXorO == "O", color: .accentColor)
                            .bold(currentXorO == "O")
                            .font(currentXorO == "O" ? .headline : .subheadline)
                            .foregroundStyle(currentXorO == "O" ? Color.accentColor : Color.primary)

                    }
                    .contentTransition(.numericText())
                    .padding()
                    .padding(.horizontal, 20)

                    // Display the board
                    VStack(spacing: 0) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 0) {
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
                                            .contentTransition(.numericText())
                                    }
                                    .disabled(self.board[row][column] != "" || winner != nil || (currentXorO == "X" && player1Name != userName) || (currentXorO == "O" && player2Name != userName)) // Disable button if already chosen or game is over
                                    .padding(8)
                                }
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
            }
            
            
            if let winner = winner {
    
                GiftView(gift: Gift(userID: "", gift: virtualgifts[virtualIndex], timestamp: Date()))
                    .transition(.move(edge: .top))
                    .zIndex(1)
                    .id(virtualIndex)
                
            }
        }
    }

    func startGame() {
        guard !player1Name.isEmpty, !player2Name.isEmpty else { return }
        currentXorO = "X" // Start with X
        gameStarted = true
        resetGame() // Reset the game state
    }

    func makeMove(row: Int, column: Int) {
        withAnimation {
            guard board[row][column] == "" && winner == nil else { return }
            board[row][column] = currentXorO
            if checkWinner() {
                winner = currentXorO == "X" ? player1Name : player2Name // Determine winner name
                virtualIndex = Int.random(in: 0...virtualgifts.count)
            } else if isBoardFull() {
                // Handle draw
            } else {
                currentXorO = currentXorO == "X" ? "O" : "X" // Switch players
            }
        }

    }

    func checkWinner() -> Bool {
        withAnimation {
            for i in 0..<3 {
                if board[i][0] == currentXorO && board[i][1] == currentXorO && board[i][2] == currentXorO {
                    return true
                }
                if board[0][i] == currentXorO && board[1][i] == currentXorO && board[2][i] == currentXorO {
                    return true
                }
            }
            if board[0][0] == currentXorO && board[1][1] == currentXorO && board[2][2] == currentXorO {
                return true
            }
            if board[0][2] == currentXorO && board[1][1] == currentXorO && board[2][0] == currentXorO {
                return true
            }
            return false
        }

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
        withAnimation {
            board = [["", "", ""], ["", "", ""], ["", "", ""]]
            winner = nil
            currentXorO = "X" // Reset to player X
            
            //Swap players
            let tempPlayer = player1Name
            player1Name = player2Name
            player2Name = tempPlayer
        }

    }
}


#Preview {
    TicTacToeView()
}
