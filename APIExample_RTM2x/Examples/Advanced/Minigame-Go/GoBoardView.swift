//
//  GoBoardView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/14.
//

import SwiftUI

struct GoBoardView: View {
    @ObservedObject var agoraRTMVM: MiniGoViewModel
    @State var cellSize : CGFloat = 30
    @State var virtualIndex = 0
    var virtualgifts : [String] = [
        "flower1", "flowers2", "present", "fireworks1"
    ]
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        
        ZStack {
            VStack {
                if !agoraRTMVM.goBoardModel.gameStarted {
                    // Player Name Input
                    Text("Enter Game")
                        .font(.title)
                        .padding()
                    
                    Text(agoraRTMVM.goBoardModel.player1Name.isEmpty ? "P1 : Tap To Enter" : "P1: \(agoraRTMVM.goBoardModel.player1Name)")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .foregroundStyle(agoraRTMVM.goBoardModel.player1Name.isEmpty ? Color.gray : Color.white)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(agoraRTMVM.goBoardModel.player1Name.isEmpty ? Color.clear : Color.accentColor)
                                .stroke(agoraRTMVM.goBoardModel.player1Name.isEmpty  ? Color.gray : Color.black, lineWidth: 2)
                            
                        )
                        .contentTransition(.numericText())
                        .padding(8)
                        .onTapGesture {
                            if agoraRTMVM.goBoardModel.player1Name.isEmpty && agoraRTMVM.goBoardModel.player2Name != agoraRTMVM.userID {
                                withAnimation{
                                    agoraRTMVM.goBoardModel.player1Name = agoraRTMVM.userID
                                    publishBoardUpdate()
                                }
                            }
                            else if agoraRTMVM.goBoardModel.player1Name == agoraRTMVM.userID {
                                withAnimation {
                                    agoraRTMVM.goBoardModel.player1Name = ""
                                    publishBoardUpdate()
                                }
                            }
                            
                        }
                    
                    Text(agoraRTMVM.goBoardModel.player2Name.isEmpty ? "P2 : Tap To Enter" : "P2: \(agoraRTMVM.goBoardModel.player2Name)")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .foregroundStyle(agoraRTMVM.goBoardModel.player2Name.isEmpty ? Color.gray : Color.white)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(agoraRTMVM.goBoardModel.player2Name.isEmpty ? Color.clear : Color.accentColor)
                                .stroke(agoraRTMVM.goBoardModel.player2Name.isEmpty  ? Color.gray : Color.black, lineWidth: 2)
                            
                        )
                        .contentTransition(.numericText())
                        .padding(8)
                        .onTapGesture {
                            if agoraRTMVM.goBoardModel.player2Name.isEmpty  && agoraRTMVM.goBoardModel.player1Name != agoraRTMVM.userID {
                                withAnimation{
                                    agoraRTMVM.goBoardModel.player2Name = agoraRTMVM.userID
                                    publishBoardUpdate()
                                }
                            }
                            else if agoraRTMVM.goBoardModel.player2Name == agoraRTMVM.userID {
                                withAnimation {
                                    agoraRTMVM.goBoardModel.player2Name = ""
                                    publishBoardUpdate()
                                }
                            }
                            
                        }
                    
                    Button("Start Game") {
                        startGame()
                        publishBoardUpdate()
                    }
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(agoraRTMVM.goBoardModel.player1Name.isEmpty || agoraRTMVM.goBoardModel.player2Name.isEmpty ? Color.gray : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(8)
                    .disabled(agoraRTMVM.goBoardModel.player1Name.isEmpty || agoraRTMVM.goBoardModel.player2Name.isEmpty)
                }
                
                else {
                    
                    // Spectators
                    HStack(spacing: 0) {
//                        let spectatorCount = agoraRTMVM.users.filter({$0.userId != agoraRTMVM.goBoardModel.player1Name && $0.userId != agoraRTMVM.goBoardModel.player2Name}).count
                        let spectatorCount = agoraRTMVM.users.count
                        
                        if agoraRTMVM.userID != agoraRTMVM.goBoardModel.player1Name && agoraRTMVM.userID != agoraRTMVM.goBoardModel.player2Name {
                            Text("You're spectating. \(spectatorCount) users")
                        }else {
                            Image(systemName: "person.2.fill")
                            Text("\(spectatorCount) users")
                        }
                    }
                    .font(.caption2)
                    .bold()
                    .padding(8)
                    .foregroundStyle(Color.pink)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.pink, lineWidth: 2)
                    )
                    
                    
                    Spacer()
                    
                    // Show Player Turn
                    HStack {
                        Circle()
                            .fill(.black)
                            .shadow(radius: 2)
                            .padding(2)
                            .shadow(radius: 4)
                            .frame(width: cellSize, height: cellSize)
                            .padding(4)
                            .overlay(
                                Capsule().stroke(Color.red, lineWidth: agoraRTMVM.goBoardModel.current1or2 == 1 ? 2 : 0)
                            )
                            .padding(3)
                        
                        
                        Text("\(agoraRTMVM.goBoardModel.player1Name)")
                            .underline(agoraRTMVM.goBoardModel.current1or2 == 1, color: .accentColor)
                            .bold(agoraRTMVM.goBoardModel.current1or2 == 1)
                            .font(agoraRTMVM.goBoardModel.current1or2 == 1 ? .headline : .subheadline)
                            .foregroundStyle(agoraRTMVM.goBoardModel.current1or2 == 1 ? Color.accentColor : Color.primary)
                        
                        Spacer()
                        
                        Circle()
                            .fill(.white)
                            .shadow(radius: 2)
                            .padding(2)
                            .shadow(radius: 4)
                            .frame(width: cellSize, height: cellSize)
                            .padding(4)
                            .overlay(
                                Capsule().stroke(Color.red, lineWidth: agoraRTMVM.goBoardModel.current1or2 == 2 ? 2 : 0)
                            )
                            .padding(3)
                        
                        Text("\(agoraRTMVM.goBoardModel.player2Name)")
                            .underline(agoraRTMVM.goBoardModel.current1or2 == 2, color: .accentColor)
                            .bold(agoraRTMVM.goBoardModel.current1or2 == 2)
                            .font(agoraRTMVM.goBoardModel.current1or2 == 2 ? .headline : .subheadline)
                            .foregroundStyle(agoraRTMVM.goBoardModel.current1or2 == 2 ? Color.accentColor : Color.primary)
                        
                    }
                    .contentTransition(.numericText())
                    .padding()
                    .padding(.horizontal, 20)
                    
                    // MARK: Board Display
                    VStack(spacing: 0) {
                        ForEach(0..<agoraRTMVM.goBoardModel.boardSize, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<agoraRTMVM.goBoardModel.boardSize, id: \.self) { col in
                                    ZStack {
                                        
                                        // BACKGROUND
                                        if row != agoraRTMVM.goBoardModel.boardSize-1 && col != agoraRTMVM.goBoardModel.boardSize-1 {
                                            Rectangle()
                                                .fill(.brown)
                                                .frame(width: cellSize, height: cellSize)
                                                .border(Color.black) // Add border to distinguish cells
                                                .offset(x: cellSize/2, y: cellSize/2)

                                        }
        
                                        
                                        // ACTUAL ITEMS
                                        Rectangle()
                                            .fill(.white.opacity(0.01))
                                            .frame(width: cellSize, height: cellSize)
                                            .overlay(alignment: .center) {
                                                Circle()
                                                    .fill(self.colorForCell(row: row, col: col))
                                                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                                                    .padding(2)
                                                    .transition(.scaleAndFade) // Use the custom transition
                                                
                                            }
                                            .onTapGesture {
                                                print("row \(row) col \(col)")
                                                    makeMove(row: row, col: col)
                                                    publishBoardUpdate()
    
                                            }
                                            .disabled(agoraRTMVM.goBoardModel.board[row][col] != 0 || !agoraRTMVM.goBoardModel.winner.isEmpty || (agoraRTMVM.goBoardModel.current1or2 == 1 && agoraRTMVM.goBoardModel.player1Name != agoraRTMVM.userID) || (agoraRTMVM.goBoardModel.current1or2 == 2 && agoraRTMVM.goBoardModel.player2Name != agoraRTMVM.userID)) // Disable button if already chosen or game is over
                                    }
                                    .onAppear {
                                        cellSize = (screenWidth - 50) / CGFloat(agoraRTMVM.goBoardModel.boardSize)
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    .padding()
                    
                    if !agoraRTMVM.goBoardModel.winner.isEmpty {
                        Text("\(agoraRTMVM.goBoardModel.winner) wins!")
                            .font(.title)
                            .padding()
                        
                    }
                    
                    Spacer()
                    
                    // Reset Game
                    if agoraRTMVM.goBoardModel.gameStarted {
                        
                        
                        // Show restart and reset if you are player
                        if !(agoraRTMVM.userID != agoraRTMVM.goBoardModel.player1Name && agoraRTMVM.userID != agoraRTMVM.goBoardModel.player2Name) {
                            VStack {
                                HStack {
                                    Button("Restart") {
                                        restart()
                                        publishBoardUpdate()
                                    }
                                    .padding(10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    
                                    Button("Reset") {
                                        agoraRTMVM.ResetLocalBoard()
                                        publishBoardUpdate()
                                    }
                                    .padding(10)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    
                                }
                                
                            }
                        }else {
                            // Show reset if you are spectator but only if player1 and player2 are NOT onlien
                            
                            if !agoraRTMVM.users.contains(where: {$0.userId == agoraRTMVM.goBoardModel.player1Name || $0.userId == agoraRTMVM.goBoardModel.player2Name}) {
                                Button("Reset") {
                                    agoraRTMVM.ResetLocalBoard()
                                    publishBoardUpdate()

                                }
                                .padding(10)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        
                    }
                    
                    
                    
                }
                
            }
            
            
            
            // Show virtual gift when someone wins
            if !agoraRTMVM.goBoardModel.winner.isEmpty {
                GiftView(gift: Gift(userID: "", gift: virtualgifts[virtualIndex], timestamp: Date()))
                    .transition(.move(edge: .top))
                    .zIndex(1)
                    .id(virtualIndex)
                
            }
        }
    }
    
    
    func startGame() {
        guard !agoraRTMVM.goBoardModel.player1Name.isEmpty, !agoraRTMVM.goBoardModel.player2Name.isEmpty else { return }
        agoraRTMVM.goBoardModel.current1or2 = 1 // Start with 1
        agoraRTMVM.goBoardModel.gameStarted = true
        restart() // Reset the game state
    }
    
    func makeMove(row: Int, col: Int) {
        guard agoraRTMVM.goBoardModel.board[row][col] == 0 else { return }
        withAnimation {
            agoraRTMVM.goBoardModel.board[row][col] = agoraRTMVM.goBoardModel.current1or2
            if checkWinner(player: agoraRTMVM.goBoardModel.current1or2, row: row, col: col) {
                agoraRTMVM.goBoardModel.winner = agoraRTMVM.goBoardModel.current1or2 == 1 ? agoraRTMVM.goBoardModel.player1Name : agoraRTMVM.goBoardModel.player2Name
                print("\(agoraRTMVM.goBoardModel.winner ) wins!")
            }
            agoraRTMVM.goBoardModel.current1or2 = agoraRTMVM.goBoardModel.current1or2 == 1 ? 2 : 1
            agoraRTMVM.tokVibrate()
        }
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
            if newRow >= 0, newRow < agoraRTMVM.goBoardModel.boardSize, newCol >= 0, newCol < agoraRTMVM.goBoardModel.boardSize, agoraRTMVM.goBoardModel.board[newRow][newCol] == player {
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
    
    func restart() {
        withAnimation {
            agoraRTMVM.goBoardModel.board = Array(repeating: Array(repeating: 0, count: agoraRTMVM.goBoardModel.boardSize), count: agoraRTMVM.goBoardModel.boardSize)
            agoraRTMVM.goBoardModel.winner = ""
            agoraRTMVM.goBoardModel.current1or2 = 1 // Reset to player X
        }
    }
    
  
    func publishBoardUpdate() {
        Task {
            await agoraRTMVM.PublishBoardUpdate()
            
        }
    }
    
    func colorForCell(row: Int, col: Int) -> Color {
        switch agoraRTMVM.goBoardModel.board[row][col] {
        case 1:
            return .black
        case 2:
            return .white
        default:
            return .clear
        }
    }
}

#Preview {
    GoBoardView(agoraRTMVM: MiniGoViewModel())
}

extension AnyTransition {
    static var scaleAndFade: AnyTransition {
        AnyTransition.scale(scale: 0.1, anchor: .center)
            .combined(with: .opacity)
    }
}
