//
//  TicTacToeView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/12.
//

import SwiftUI

struct TicTacToeView: View {

    @EnvironmentObject var agoraRTMVM: MiniTicTacToeViewModel
    @State var virtualIndex = 0
    var virtualgifts : [String] = [
        "flower1", "flowers2", "present", "fireworks1"
    ]

    var body: some View {
        ZStack {
            VStack {
                if !agoraRTMVM.tiktaktoeModel.gameStarted {
                    // Player Name Input
                    Text("Enter Game")
                        .font(.title)
                        .padding()

                    Text(agoraRTMVM.tiktaktoeModel.player1Name.isEmpty ? "P1 : Tap To Enter" : "P1: \(agoraRTMVM.tiktaktoeModel.player1Name)")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .foregroundStyle(agoraRTMVM.tiktaktoeModel.player1Name.isEmpty ? Color.gray : Color.white)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(agoraRTMVM.tiktaktoeModel.player1Name.isEmpty ? Color.clear : Color.accentColor)
                                .stroke(agoraRTMVM.tiktaktoeModel.player1Name.isEmpty  ? Color.gray : Color.black, lineWidth: 2)
                            
                        )
                        .contentTransition(.numericText())
                        .padding(8)
                        .onTapGesture {
                            if agoraRTMVM.tiktaktoeModel.player1Name.isEmpty && agoraRTMVM.tiktaktoeModel.player2Name != agoraRTMVM.userID {
                                withAnimation{
                                    agoraRTMVM.tiktaktoeModel.player1Name = agoraRTMVM.userID
                                }
                            }
                            else if agoraRTMVM.tiktaktoeModel.player1Name == agoraRTMVM.userID {
                                withAnimation {
                                    agoraRTMVM.tiktaktoeModel.player1Name = ""
                                }
                            }
                            
                            publishBoardUpdate()
                        }
                    
                    Text(agoraRTMVM.tiktaktoeModel.player2Name.isEmpty ? "P2 : Tap To Enter" : "P2: \(agoraRTMVM.tiktaktoeModel.player2Name)")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .foregroundStyle(agoraRTMVM.tiktaktoeModel.player2Name.isEmpty ? Color.gray : Color.white)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(agoraRTMVM.tiktaktoeModel.player2Name.isEmpty ? Color.clear : Color.accentColor)
                                .stroke(agoraRTMVM.tiktaktoeModel.player2Name.isEmpty  ? Color.gray : Color.black, lineWidth: 2)
                            
                        )
                        .contentTransition(.numericText())
                        .padding(8)
                        .onTapGesture {
                            if agoraRTMVM.tiktaktoeModel.player2Name.isEmpty  && agoraRTMVM.tiktaktoeModel.player1Name != agoraRTMVM.userID {
                                withAnimation{
                                    agoraRTMVM.tiktaktoeModel.player2Name = agoraRTMVM.userID
                                }
                            }
                            else if agoraRTMVM.tiktaktoeModel.player2Name == agoraRTMVM.userID {
                                withAnimation {
                                    agoraRTMVM.tiktaktoeModel.player2Name = ""
                                }
                            }
                            
                            publishBoardUpdate()
                        }
                    
                    Button("Start Game") {
                        startGame()
                        publishBoardUpdate()
                    }
                    .buttonBorderShape(.roundedRectangle(radius: 16.0))
                    .disabled(agoraRTMVM.tiktaktoeModel.player1Name.isEmpty || agoraRTMVM.tiktaktoeModel.player2Name.isEmpty)
                } else {
                    // Spectator
                    if agoraRTMVM.userID != agoraRTMVM.tiktaktoeModel.player1Name && agoraRTMVM.userID != agoraRTMVM.tiktaktoeModel.player2Name {
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
                        Text("X: \(agoraRTMVM.tiktaktoeModel.player1Name)")
                            .underline(agoraRTMVM.tiktaktoeModel.currentXorO == "X", color: .accentColor)
                            .bold(agoraRTMVM.tiktaktoeModel.currentXorO == "X")
                            .font(agoraRTMVM.tiktaktoeModel.currentXorO == "X" ? .headline : .subheadline)
                            .foregroundStyle(agoraRTMVM.tiktaktoeModel.currentXorO == "X" ? Color.accentColor : Color.primary)

                        Spacer()
                        Text("O: \(agoraRTMVM.tiktaktoeModel.player2Name)")
                            .underline(agoraRTMVM.tiktaktoeModel.currentXorO == "O", color: .accentColor)
                            .bold(agoraRTMVM.tiktaktoeModel.currentXorO == "O")
                            .font(agoraRTMVM.tiktaktoeModel.currentXorO == "O" ? .headline : .subheadline)
                            .foregroundStyle(agoraRTMVM.tiktaktoeModel.currentXorO == "O" ? Color.accentColor : Color.primary)

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
                                        publishBoardUpdate()
                                    }) {
                                        Text(agoraRTMVM.tiktaktoeModel.board[row][column])
                                            .font(.largeTitle)
                                            .frame(width: 100, height: 100)
                                            .background(Color.gray.opacity(0.5))
                                            .foregroundColor(.black)
                                            .cornerRadius(10)
                                            .contentTransition(.numericText())
                                    }
                                    .disabled(agoraRTMVM.tiktaktoeModel.board[row][column] != "" || !agoraRTMVM.tiktaktoeModel.winner.isEmpty || (agoraRTMVM.tiktaktoeModel.currentXorO == "X" && agoraRTMVM.tiktaktoeModel.player1Name != agoraRTMVM.userID) || (agoraRTMVM.tiktaktoeModel.currentXorO == "O" && agoraRTMVM.tiktaktoeModel.player2Name != agoraRTMVM.userID)) // Disable button if already chosen or game is over
                                    .padding(8)
                                }
                            }
                        }
       
                    }
                    .padding()
                    
                    if !agoraRTMVM.tiktaktoeModel.winner.isEmpty {
                        Text("\(agoraRTMVM.tiktaktoeModel.winner) wins!")
                            .font(.title)
                            .padding()
                        
                    } else if isBoardFull() {
                        Text("It's a draw!")
                            .font(.title)
                            .padding()
                    }


                    Button("Restart Game") {
                        restart()
                        publishBoardUpdate()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            // Reset Game
            if agoraRTMVM.tiktaktoeModel.gameStarted {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            reset()
                            Task {
                                await agoraRTMVM.PublishBoardUpdate()
                            }
                        }, label: {
                            Text("Reset")
                                .foregroundStyle(Color.red)
                        })
                        .padding()
                    }
                    Spacer()

                }
            }
            
            if !agoraRTMVM.tiktaktoeModel.winner.isEmpty {
                GiftView(gift: Gift(userID: "", gift: virtualgifts[virtualIndex], timestamp: Date()))
                    .transition(.move(edge: .top))
                    .zIndex(1)
                    .id(virtualIndex)
                
            }
        }
    }

    func startGame() {
        guard !agoraRTMVM.tiktaktoeModel.player1Name.isEmpty, !agoraRTMVM.tiktaktoeModel.player2Name.isEmpty else { return }
        agoraRTMVM.tiktaktoeModel.currentXorO = "X" // Start with X
        agoraRTMVM.tiktaktoeModel.gameStarted = true
        restart() // Reset the game state
    }

    func makeMove(row: Int, column: Int) {
        withAnimation {
            guard agoraRTMVM.tiktaktoeModel.board[row][column] == "" && agoraRTMVM.tiktaktoeModel.winner.isEmpty else { return }
            agoraRTMVM.tiktaktoeModel.board[row][column] = agoraRTMVM.tiktaktoeModel.currentXorO
            if checkWinner() {
                agoraRTMVM.tiktaktoeModel.winner = agoraRTMVM.tiktaktoeModel.currentXorO == "X" ? agoraRTMVM.tiktaktoeModel.player1Name : agoraRTMVM.tiktaktoeModel.player2Name // Determine winner name
                virtualIndex = Int.random(in: 0...virtualgifts.count)
            } else if isBoardFull() {
                // Handle draw
            } else {
                agoraRTMVM.tiktaktoeModel.currentXorO = agoraRTMVM.tiktaktoeModel.currentXorO == "X" ? "O" : "X" // Switch players
            }
        }

    }

    func checkWinner() -> Bool {
        withAnimation {
            for i in 0..<3 {
                if agoraRTMVM.tiktaktoeModel.board[i][0] == agoraRTMVM.tiktaktoeModel.currentXorO && agoraRTMVM.tiktaktoeModel.board[i][1] == agoraRTMVM.tiktaktoeModel.currentXorO && agoraRTMVM.tiktaktoeModel.board[i][2] == agoraRTMVM.tiktaktoeModel.currentXorO {
                    return true
                }
                if agoraRTMVM.tiktaktoeModel.board[0][i] == agoraRTMVM.tiktaktoeModel.currentXorO && agoraRTMVM.tiktaktoeModel.board[1][i] == agoraRTMVM.tiktaktoeModel.currentXorO && agoraRTMVM.tiktaktoeModel.board[2][i] == agoraRTMVM.tiktaktoeModel.currentXorO {
                    return true
                }
            }
            if agoraRTMVM.tiktaktoeModel.board[0][0] == agoraRTMVM.tiktaktoeModel.currentXorO && agoraRTMVM.tiktaktoeModel.board[1][1] == agoraRTMVM.tiktaktoeModel.currentXorO && agoraRTMVM.tiktaktoeModel.board[2][2] == agoraRTMVM.tiktaktoeModel.currentXorO {
                return true
            }
            if agoraRTMVM.tiktaktoeModel.board[0][2] == agoraRTMVM.tiktaktoeModel.currentXorO && agoraRTMVM.tiktaktoeModel.board[1][1] == agoraRTMVM.tiktaktoeModel.currentXorO && agoraRTMVM.tiktaktoeModel.board[2][0] == agoraRTMVM.tiktaktoeModel.currentXorO {
                return true
            }
            return false
        }

    }

    func isBoardFull() -> Bool {
        for row in agoraRTMVM.tiktaktoeModel.board {
            if row.contains("") {
                return false
            }
        }
        return true
    }

    func restart() {
        withAnimation {
            agoraRTMVM.tiktaktoeModel.board = [["", "", ""], ["", "", ""], ["", "", ""]]
            agoraRTMVM.tiktaktoeModel.winner = ""
            agoraRTMVM.tiktaktoeModel.currentXorO = "X" // Reset to player X
            
            //Swap players
            let tempPlayer = agoraRTMVM.tiktaktoeModel.player1Name
            agoraRTMVM.tiktaktoeModel.player1Name = agoraRTMVM.tiktaktoeModel.player2Name
            agoraRTMVM.tiktaktoeModel.player2Name = tempPlayer
        }
    }
    
    func reset() {
        withAnimation {
            agoraRTMVM.tiktaktoeModel = TicTacToeModel()
        }
    }
    
    func publishBoardUpdate() {
        Task {
            await agoraRTMVM.PublishBoardUpdate()

        }
    }
}


#Preview {
    TicTacToeView()
        .environmentObject(MiniTicTacToeViewModel())
}
