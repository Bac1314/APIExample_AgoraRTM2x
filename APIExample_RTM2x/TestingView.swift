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
    @State var value = 0  {
        willSet(newVal) {
            print("NavigationPath new \(newVal)")
        }
        didSet(oldVal) {
            print("NavigationPath old \(oldVal)")
        }
    }

    var body: some View {
        ZStack(alignment: .top){
            Button {
                value += 1
            } label: {
                Text("Tapp me")
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
