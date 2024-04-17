//
//  CustomAuctionItem.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/11.
//

import Foundation

struct CustomAuctionItem {
    let id = UUID()
    let majorRevision: Int64
    let auctionName: String
    let startingPrice: Int
    let currentBid: Int
    let highestBidder: String
    let lastUpdatedTimeStamp: Int // timestamp e.g. 1711961436
}
