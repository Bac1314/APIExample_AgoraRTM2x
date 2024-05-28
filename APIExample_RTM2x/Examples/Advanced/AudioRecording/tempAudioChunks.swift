//
//  tempAudioChunks.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/28.
//

import Foundation

struct tempAudioChunks {
    var sender: String
    var chunkLength: Int
    var chunks = [Data]()
}
