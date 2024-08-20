//
//  BingoHostView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/19.
//

import SwiftUI

struct BingoHostView: View {
    @State var currentRangeArray : [Int] = []
    @State var currentNumber: Int = 0
    
    var body: some View {
        
        VStack {
//            Text("\(currentNumber)")
//                .font(.largeTitle)
//                .contentTransition(.numericText())
//            Text("\(currentRangeArray)")
//                .padding()
            if currentRangeArray.count > 0 {
                AnimatedNumberView(rangeNumbers: $currentRangeArray, newNumber: $currentNumber, duration: .constant(5))
            }
            

                        
            Button(action: {
                generateRandom()
            }, label: {
                Text("Generate Number")
            })
            .padding()

            
            Button(action: {
                startNewGame()
            }, label: {
                Text("Start New Game")
            })
            .padding()

        }
    }
    
    func startNewGame() {
        currentRangeArray = Array(1...50).shuffled() // Create an array of numbers 1-75 and shuffle it
    }
    
    func generateRandom() {
        if currentRangeArray.count > 0 {
            withAnimation {
                currentRangeArray = currentRangeArray.shuffled()
                currentNumber = currentRangeArray[0]
                currentRangeArray.removeFirst()
            }
        }
        
    }
}

#Preview {
    BingoHostView()
}



struct AnimatedNumberView: View {
    @Binding var rangeNumbers: [Int]
    @Binding var newNumber: Int
    @Binding var duration: TimeInterval
    @State var displayNumber: Int = 0
    @State var timer: Timer?
    
    var body: some View {
        Text("\(displayNumber)")
            .font(.largeTitle)
            .contentTransition(.numericText())
            .onChange(of: newNumber, { oldValue, newValue in
                withAnimation {
                    startAnimating()
                }
            })
            .onDisappear {
                timer?.invalidate() // Stop the timer when the view disappears
            }
    }
    
    private func startAnimating() {
        var elapsedTime: TimeInterval = 0
        let interval: TimeInterval = 0.1 // Change number every 0.1 seconds
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if elapsedTime < duration {
                displayNumber = rangeNumbers.randomElement() ?? 0// Update to a new random number
                elapsedTime += interval
            } else {
                displayNumber = newNumber
                timer?.invalidate() // Stop the timer after 5 seconds
            }
        }
    }
}
