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
            VStack{
                HStack {
                    Text("B")
                        .frame(width: 30, height: 30)
                        .padding(12)
                        .background(LinearGradient(colors: [.blue, .pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    
                    VStack(alignment: .leading) {
                        Text("Incoming call")
                            .font(.footnote)
                            .foregroundStyle(Color.white.opacity(0.7))
                        
                        Text("Bac Huang")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    // Decline call
                    Image(systemName: "phone.down.fill")
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .padding(12)
                        .background(Color.red)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .onTapGesture {
                            withAnimation {
                            }
                        }
                    
//                    NavigationLink(destination: CallingView(caller: agoraVM.incomingUserID, callee: agoraVM.userID).environmentObject(agoraVM)) {
                        Image(systemName: "phone.arrow.up.right")
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .padding(12)
                            .background(Color.green)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
//                    }
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 8)
                .padding()
                Spacer()
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
