//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI
import AVFoundation


struct TestingView: View {
    @State private var isTopRightCorner = true

    var body: some View {
        ZStack(alignment: .top){
            GeometryReader { geo in
                    VStack {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: isTopRightCorner ? 150 : nil, height: isTopRightCorner ? 150 : nil, alignment: .topTrailing)
                            .edgesIgnoringSafeArea(.all)
                            .position(x: isTopRightCorner ? geo.size.width-100 : geo.size.width/2, y: isTopRightCorner ? 100 : geo.size.height/2)

                    }
                }
                
            
//            Rectangle()
//                .background(Color.red)
//                .frame(width: isTopRightCorner ? 150 : nil, height: isTopRightCorner ? 150 : nil, alignment: .topTrailing)
//                .edgesIgnoringSafeArea(.all)
            
//            Button("Switch") {
//                withAnimation {
//                    self.isTopRightCorner.toggle()
//                    AudioServicesPlaySystemSound(SystemSoundID(1016))
//                    // 1004 sendMessage 1009 tingting 1013 ding 1016 tweet
//                      // 1022 calypso 1052 1054 1055
//                      // 1060 1110
//                      // 1004 tweet, 1052 duang, 1055 fuwu
//
//                }
//            }
            
            Button {
                AudioServicesPlaySystemSound(SystemSoundID(1016))
            } label: {
                Text("Play")
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
