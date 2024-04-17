//
//  MessageItemFullView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/20.
//

import SwiftUI
import AgoraRtmKit

struct MessageItemFullView: View {
    var agoramessage : AgoraRtmMessageEvent
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
//                Text("Timestamp: \(agoramessage)")
                Text("Publisher: \(agoramessage.publisher)")
                Text("Channel: \(agoramessage.channelName)")
                Text("Message: \(agoramessage.message.stringData ?? "")")
                Text("ChannelType: \(agoramessage.channelType)")
                Text("CustomType: \(agoramessage.customType ?? "")")
                Text("ChannelTopic: \(agoramessage.channelTopic)")
            }
            
            Spacer()
        }
        .foregroundColor(Color.white)
        .textCase(.lowercase)
        .padding(10)
        .background(Color.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
        .padding(10)

    }
}

//#Preview {
//    MessageItemFullView()
//}
