//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI
import AVFoundation

struct TestingView: View {
    let items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]

    var body: some View {
        NavigationView {
            List(items, id: \.self) { item in
                Text(item)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.vertical, 5) // Adds spacing between items
                    .onTapGesture {
                        
                        print("Hello World \(item)")
                    }

                
            }
            .listStyle(.plain)
            .navigationTitle("Items List")
        }
    }
}


#Preview {
    TestingView()
}
