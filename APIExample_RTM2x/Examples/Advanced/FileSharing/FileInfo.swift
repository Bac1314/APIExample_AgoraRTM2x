//
//  FileInfo.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/29.
//

import Foundation

struct FileInfo : Codable, Hashable, Identifiable{
    var id = UUID()
    var name: String
    var countOf32KB: Int
    var type: String
    var url: String
    var owner: String 
}
