//
//  BingoCardView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/16.
//

import SwiftUI

struct BingoCardView: View {
    @State var card = BingoCard()
    @State var isBingo: Bool = false
    @State var randomNumber: Int = 0
    
    var body: some View {
        VStack {
//            Button(action: {
//                withAnimation {
//                    randomNumber = Int.random(in: 1...50)
//                    card.markNumber(randomNumber)
//                    isBingo = card.isBingo()
//                }
//
//            }, label: {
//                Text("Generate Random Number: \(randomNumber)")
//            })
//            
//            if isBingo {
//                Text("BINGO!")
//                    .font(.largeTitle)
//            }
//            
            VStack(spacing: 0) {
     
                // Header for BINGO
                HStack(spacing: 0) {
                    let bingoLetters = Array("BINGO") // Convert string to array of characters
                    ForEach(0..<5) { index in
                        Text(String(bingoLetters[index])) // Convert character back to string
                            .minimumScaleFactor(0.3)
                            .frame(width: 60, height: 60)
                            .font(.title)
                            .foregroundStyle(.white)
                            .bold()
                    }
                }
                
                ForEach(0..<5) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<5) { column in
                            
                            let number = card.numbers[row][column]
                            Text(number == 0 ? "⭐️" : "\(number)")
                                .minimumScaleFactor(0.3)
                                .frame(width: 60, height: 60)
                                .background(card.marked[row][column] || number == 0 ? Color.orange : Color.white.opacity(0.8))
                                .border(Color.black) // Add border to distinguish cells
                                .foregroundColor(card.marked[row][column] || number == 0  ? .white : .primary)
                                .font(.title2)
                                .bold()
                                .onTapGesture {
                                    if number != 0 {
                                        withAnimation {
                                            card.marked[row][column].toggle()
                                            isBingo = card.isBingo()
                                        }
                                    }
                                }
                        }
                    }
                }
                
            }
            .padding()
            .background(.brown)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .fontDesign(.rounded)
            
            Button("Reset Game") {
                withAnimation {
                    card = BingoCard()
                }
            }
            .padding()
        }

    }
}

#Preview {
    BingoCardView()
}
