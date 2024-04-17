//
//  MessageItemLocalView.swift
//  AgoraNGSwiftUI
//
//  Created by BBC on 2024/1/30.
//

import SwiftUI
//import AgoraChat

struct MessageItemLocalView: View {
    var from: String
    var message: String
    
    var body: some View {
        HStack{
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
            VStack(alignment: .leading){
                Text("Me - \(from)")
                    .foregroundStyle(Color.accentColor)
                Text(message)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            Spacer()
            
        }
        .padding(.bottom, 10)
    }
}


//#Preview {
//    MessageItemLocalView()
//}
