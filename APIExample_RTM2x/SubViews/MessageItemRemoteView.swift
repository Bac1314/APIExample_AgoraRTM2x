//
//  MessageRemoteView.swift
//  AgoraNGSwiftUI
//
//  Created by BBC on 2023/11/30.
//

import SwiftUI

struct MessageItemRemoteView: View {
    var from: String
    var message: String?
    var imageData: Data?
    
    var body: some View {
        HStack{
            
            Spacer()
            VStack(alignment: .trailing){
                Text(from)
                    .foregroundStyle(Color.accentColor)
                
                // Display text
                if let message = message  {
                    Text(message)
                        .padding(10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                
                // Display image
                if let imageData = imageData, let img = UIImage(data: imageData) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 100)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
                }
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
