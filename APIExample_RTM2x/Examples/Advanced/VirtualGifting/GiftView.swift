//
//  GiftView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/9.
//

import SwiftUI

struct GiftView: View {
    @State var offset: CGSize = .zero
    @State var opacity: Double = 1.0
    @State var scale: Double = 1.0
    var gift : Gift

    var body: some View {
        VStack {
            Image(gift.gift)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .opacity(opacity)
                .offset(offset)
                .scaleEffect(CGSize(width: 1.0*scale, height: 1.0*scale))
                .onAppear {
                    animateGift()
                }
        }
    }

    private func animateGift() {
        withAnimation(.interactiveSpring(duration: 8)) {
            offset = CGSize(width: Int.random(in: -100..<100), height: -600) // Adjust height as needed
            opacity = 0.0
            scale = 1.5
        }
        
    }
}

#Preview {
    GiftView(gift: Gift(userID: "bac", gift: "yougo", timestamp: Date()))
}
