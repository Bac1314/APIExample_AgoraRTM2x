//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI

struct TestingView: View {
    

    var body: some View {

        VStack(spacing: 50){
            Text("Hello World!")
                .frame(width: 300)
                .background(
                    LinearGradient(colors: [Color.indigo, Color.white], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Hello World! 90%")
                .frame(width: 300)
                .background(
                    LinearGradient(colors: [Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.white], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Hello World! 80%")
                .frame(width: 300)
                .background(
                    LinearGradient(colors: [Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.white, Color.white], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Hello World! 70%")
                .frame(width: 300)
                .background(
                    LinearGradient(colors: [Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.indigo, Color.white, Color.white, Color.white], startPoint: .leading, endPoint: .trailing)
                )
            
            VStack {
                Text("Hello World! 70%")
                    .background(
                        ProgressView(value: 0.5)
                        .scaleEffect(CGSize(width: 1.0, height: 2.0))
                    )
     
            }
            .padding()
            .frame(height: 100)
      
        }
        

        
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
