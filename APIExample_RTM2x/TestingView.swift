//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI

struct TestingView: View {
    @State var degreesRotating = 0.0

    
    var body: some View {
        Image(systemName: "bolt")
            .frame(width: 80, height: 80)
            .aspectRatio(1.0, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
            .font(.system(size: 60))
            .padding(16)
            .background(LinearGradient(colors: [Color.accentColor.opacity(0.5), Color.accentColor, Color.accentColor.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .foregroundStyle(Color.white.gradient)
            .clipShape(Circle())
            .shadow(radius: 5)
            .padding(.vertical, 100)
            .rotationEffect(.degrees(degreesRotating))
            .onAppear {
                withAnimation(.linear(duration: 1).speed(0.1).repeatForever(autoreverses: false)) {
                    degreesRotating = 360.0
                }
            }
    }
}

#Preview {
    TestingView()
}
