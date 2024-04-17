//
//  AgoraToken.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/15.
//

import Foundation

struct AgoraToken: Codable {
    let statusCode: Int
    let body: Body
}

// MARK: - Body
struct Body: Codable {
    let token: String
    let userid: String? // For rtm
    let uid: Int? // for rtc

}

