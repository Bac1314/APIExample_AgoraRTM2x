//
//  AuctionItemView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/12.
//

import SwiftUI

struct AuctionItemView: View {
    
    var currentAuction : CustomAuctionItem = CustomAuctionItem(majorRevision: 123456, auctionName: "Pokemon Card - Charizard PSA 10", startingPrice: 100, currentBid: 100, highestBidder: "Bac", lastUpdatedTimeStamp: Int(Date().addingTimeInterval(10000).timeIntervalSince1970))
    var startDate: Date = Date()

    var body: some View {
        VStack{
            HStack(alignment: .top){
                Image("charizard") // Replace `.building` with your image's name
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .cornerRadius(10)
                
                VStack(alignment: .leading){
                    HStack(alignment: .bottom){
                        Text("ENDING IN").font(.caption)
//                        Text(timerInterval: startDate...Date(timeIntervalSince1970: TimeInterval(currentAuction.lastUpdatedTimeStamp)))
//                            .font(.headline)
//                            .bold()
                        Text("365 days")
                            .font(.headline)
                            .bold()
                    }
                    .padding(.bottom)
                    
                    Text(currentAuction.auctionName)
                        .font(.headline).bold()
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                        .padding(.bottom)
                    
                    
                    Text("Current bid")
                    Text("$\(currentAuction.currentBid)")
                        .font(.title)
                        .bold()
                    
                    Text("by \(currentAuction.highestBidder)")
                        .font(.subheadline)
                }
            }
            
        }
        .aspectRatio(4/3, contentMode: .fit)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
    
}

#Preview {
    AuctionItemView()
}
