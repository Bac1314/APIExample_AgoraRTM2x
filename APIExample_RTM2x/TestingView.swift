//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI
import AVFoundation

struct TestingView: View {
    @State private var scale: CGFloat = 0.1 // Start small
    @State private var offset: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 0) // Offset to the top right

     var body: some View {
         Rectangle()
             .fill(Color.blue) // Change to your desired color or view
             .scaleEffect(scale, anchor: .topTrailing) // Scale from the top right
             .offset(x: offset.width, y: offset.height) // Initial offset
             .onAppear {
                 withAnimation(.easeInOut(duration: 0.5)) {
                     scale = 1.0 // Scale to full size
                     offset = CGSize.zero // Reset offset
                 }
             }
             .edgesIgnoringSafeArea(.all) // Make sure it fills the entire screen
     }
}


#Preview {
    TestingView()
}
