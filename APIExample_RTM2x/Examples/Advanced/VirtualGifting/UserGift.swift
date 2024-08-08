//
//  UserGift.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/8.
//

import Foundation
import AgoraRtmKit

struct UserGift : Identifiable{
    var id: UUID = UUID()
    var userID: String
    var gift: String
    var timestamp: Date
}
