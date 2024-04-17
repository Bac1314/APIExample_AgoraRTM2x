//
//  PollCreationView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/3.
//

import SwiftUI

struct PollCreationView: View {
    // Create a state for the text fields
    @State private var arrayOfText = Array<String>.init(repeating: "", count: 4)

    var body: some View {
        // Use ForEach to iterate over the array
        VStack {
            ForEach(0..<arrayOfText.count, id: \.self) { index in
                HStack {
                    Image(systemName: "circle")
                        .padding(.horizontal, 8)
                        .imageScale(.large)
                        .foregroundColor(Color.gray)
                    TextField("Enter option", text: $arrayOfText[index])
                    Spacer()
                }
                .padding(.vertical)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    PollCreationView()
}


//List{
//    ForEach(options.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
//        HStack{
//            Image(systemName: "circle")
//                .padding(.horizontal, 8)
//                .imageScale(.large)
//                .foregroundColor(Color.gray)
//            Text(key)
//            Spacer()
//        }
//        .swipeActions(edge: .trailing) {
//            Button(role: .destructive) {
//                options.removeValue(forKey: key)
//            } label: {
//                Label("Delete", systemImage: "trash")
//            }
//        }
//        .padding(.vertical)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.gray, lineWidth: 1)
//        )
//        
//    }
//}
//.listStyle(.plain)
