//
//  MessageRemoteView.swift
//  AgoraNGSwiftUI
//
//  Created by BBC on 2023/11/30.
//

import SwiftUI
//import AgoraChat

struct MessageItemRemoteView: View {
    var from: String
    var message: String
    
    var body: some View {
        HStack{
            
            Spacer()
            VStack(alignment: .trailing){
                Text(from)
                    .foregroundStyle(Color.accentColor)
                Text(message)
                    .padding(10)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            
            Image(systemName: "person")
                .imageScale(.large)
        }
        .padding(.bottom, 10)
    }
}


//#Preview {
//    let message = AgoraChatMessage(conversationID: "conversationid", from: "fromuser", to: "touser", body: AgoraChatTextMessageBody(text:"How are you"), ext: nil)
//
////    MessageLocalView(message:  message)
//    MessageRemoteView(message:  message)
//}
