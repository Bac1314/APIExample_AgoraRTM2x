//
//  CustomAgoraChannel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/29.
//

import Foundation
import AgoraRtmKit

struct CustomRTMChannel {
    let channelName: String
    var channelMessages: [AgoraRtmMessageEvent]
    var lastMessage: String
    var listOfUsers: [AgoraRtmUserState]
    
}
