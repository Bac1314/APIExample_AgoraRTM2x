//
//  CustomStreamTopic.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/19.
//

import Foundation
import AgoraRtmKit

struct CustomStreamTopic : Identifiable {
    let id = UUID()
    var topic : String
    var messages : [AgoraRtmMessageEvent]
    var lastMessage : String
    var users: [String]
}
