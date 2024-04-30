//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI

struct TestingView: View {
    

    var body: some View {
        Button(action: {
            withAnimation {
            }
        }, label: {
            Image(systemName: "photo")
                .foregroundColor(Color.white)
                .textCase(.lowercase)
                .padding(4)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
        })
    }
}


#Preview {
    struct Preview: View {
//        @State private var currentDrawing: Drawing = Drawing()
//        @State private var drawings: [Drawing] = [Drawing]()
//        
        var body: some View {
            TestingView()
        }
    }
    
    return Preview()
}
