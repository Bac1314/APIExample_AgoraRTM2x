//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI
import AVFoundation

struct TestingView: View {
    var virtualgifts : [String] = [
        "flower1", "flowers2", "present", "fireworks1"
    ]
    @State var virtualIndex : Int = 0
    var body: some View {
        ZStack {
            Text("SPECTATING")
                .font(.caption2)
                .bold()
                .padding(8)
                .foregroundStyle(Color.pink)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.pink, lineWidth: 2)
                )
                .onTapGesture {
                    virtualIndex = Int.random(in: 0...virtualgifts.count-1)
                    print("Bac's virtual index \(virtualIndex)")
                }
            
            
            Text("wins!")
                .font(.title)
                .padding()
                .background(Color.white.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            GiftView(gift: Gift(userID: "", gift: virtualgifts[virtualIndex], timestamp: Date()))
                .transition(.move(edge: .top))
                .zIndex(1)
                .id(virtualIndex)
            
        }

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
