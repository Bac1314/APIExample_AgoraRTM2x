//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI
import AVFoundation

struct TestingView: View {
    @State private var selectedItem: Int? = nil
    @Namespace private var animationNamespace

    let items = Array(1...10) // Sample list items

    var body: some View {
        ZStack {
            // The list of items
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(items, id: \.self) { item in
                        ItemView(item: item)
                            .matchedGeometryEffect(id: item, in: animationNamespace)
                            .onTapGesture {
                                withAnimation(.bouncy) {
                                    selectedItem = item
                                }
                            }
                    }
                }
                .padding()
            }

            // The overlay for the expanded view
            if let selectedItem = selectedItem {
                ExpandedItemView(item: selectedItem)
                    .matchedGeometryEffect(id: selectedItem, in: animationNamespace)
                    .onTapGesture {
                        withAnimation(.bouncy) {
                            self.selectedItem = nil
                        }
                    }
                    .ignoresSafeArea() // Make sure it covers the whole screen
            }
        }
    }
}


#Preview {
    TestingView()
}


var moveAndFade: AnyTransition {
     .asymmetric(
         insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .opacity),
         removal: .push(from: .top).combined(with: .opacity)
     )
 }

struct ItemView: View {
    let item: Int

    var body: some View {
        Text("Item \(item)")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}

struct ExpandedItemView: View {
    let item: Int

    var body: some View {
        VStack {
            Text("Expanded Item \(item)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
