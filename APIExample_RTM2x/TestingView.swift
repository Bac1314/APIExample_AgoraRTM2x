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
        "yougo", "flower1", "flowers2", "present", "gold1", "gold2", "heart1", "fireworks1"
    ]
    @State var newGift: String = "yougo"
    @State var newGiftPosition: CGFloat = 0.0
    @State var animateGift = false
    

    var body: some View {
        ZStack(alignment: .bottom){
    
            VStack{
                Image("yougo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .offset(y: animateGift ? -300 : 0)
                    .rotationEffect(animateGift ? .degrees(180) : .zero, anchor: .bottom)
//                    .rotationEffect(animateGift ? .degrees(180) : .zero)
                    .animation(.bouncy, value: animateGift)
                
                Button {
                    // Do something
                    withAnimation {
                        animateGift.toggle()
                    }
                } label: {
                    Text("Tap me")
                }
            }
  
            
     

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
