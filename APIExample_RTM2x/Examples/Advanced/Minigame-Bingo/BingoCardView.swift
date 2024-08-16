//
//  BingoCardView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/16.
//

import SwiftUI

struct BingoCardView: View {
    @State private var card = BingoCard()
    var bingoWord: String = "BINGO"
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Text("Bingo")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                ForEach(0..<5) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<5) { column in
                            let number = card.numbers[row][column]
                            Text(number == 0 ? "⭐️" : "\(number)")
                                .minimumScaleFactor(0.3)
                                .frame(width: 60, height: 60)
                                .background(card.marked[row][column] ? Color.mint : Color.white.opacity(0.8))
                                .border(Color.black) // Add border to distinguish cells
                                .foregroundColor(.primary)
                                .font(.title2)
                                .bold()
                                .onTapGesture {
                                    if number != 0 {
                                        card.marked[row][column].toggle()
                                    }
                                }
                        }
                    }
                }
            }
            .padding()
            .background(.brown)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .fontDesign(.rounded)
            
            Button("Reset Game") {
                card = BingoCard()
            }
            .padding()
        }

    }
}

#Preview {
    BingoCardView()
}
