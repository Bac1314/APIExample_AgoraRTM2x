//
//  CustomRTMUser.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/29.
//

import Foundation
import AgoraRtmKit

struct CustomRTMUser {
    let username: String
    var userMessage: String?
    var isOnline: Bool
    var channelMessages: [AgoraRtmMessageEvent]
    var lastMessage: String
    
}
