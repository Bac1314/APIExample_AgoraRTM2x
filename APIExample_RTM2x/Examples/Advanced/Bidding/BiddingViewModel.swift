//
//  BiddingViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/11.
//


import Foundation
import SwiftUI
import AgoraRtmKit

class BiddingViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var currentAuctionItem: CustomAuctionItem? = nil
    //= CustomAuctionItem(majorRevision: 123456, auctionName: "Pokemon Card - Mew Two", startingPrice: 100, currentBid: 100, highestBidder: "Bac", lastUpdatedTimeStamp: Int(Date().addingTimeInterval(-15).timeIntervalSince1970))
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    
//    let mainChannel = "biddingChannel" // to publish the storage
    @Published var mainChannel = "ChannelA" // to publish the storage

    
    @MainActor
    func loginRTM() async throws {
        do {
            if userID.isEmpty {
                throw customError.emptyUIDLoginError
            }
            
            // Initialize RTM instance
            if agoraRtmKit == nil {
                let config = AgoraRtmClientConfig(appId: Configurations.agora_AppdID , userId: userID)
                agoraRtmKit = try AgoraRtmClientKit(config, delegate: self)
            }
            
            // Login to RTM server
            // Use AppID to login if app certificate is NOT enabled for project
            if let (response, error) = await agoraRtmKit?.login(token.isEmpty ? Configurations.agora_AppdID : token) {
                if error == nil{
                    isLoggedIn = true
                }else{
                    print("Bac's code loginRTM login result = \(String(describing: response?.description)) | error \(String(describing: error))")
                    await agoraRtmKit?.logout()
                    throw error ?? customError.loginRTMError
                }
            } else {
                // Handle any cases where login fails or error is present
                print("Bac's code loginRTM login result = \(userID)")
            }
            
        }catch {
            print("Bac's Some other error occurred: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Logout RTM server
    func logoutRTM(){
        agoraRtmKit?.logout()
        agoraRtmKit?.destroy()
        isLoggedIn = false
    }
    
    //MARK: Storage/MetaData/Bidding functions
    @MainActor
    func subscribeChannel(channelName: String) async -> Bool {
        let subOptions: AgoraRtmSubscribeOptions = AgoraRtmSubscribeOptions()
        subOptions.features =  [.metadata]
                
        if let (_, error) = await agoraRtmKit?.subscribe(channelName: channelName, option: subOptions){
            if error == nil {
                return true
            }
            return false
        }
        
        return false
    }
    
    func sendBidPrice(price: Int) async -> Bool {
        if let currentAuctionItem = currentAuctionItem {
            // Add a safety to prevent user from sending a lower bid than current
            if price < currentAuctionItem.currentBid {
                print("sendBidPrice currentAuctionItem false \(price) vs \(currentAuctionItem.currentBid)")

                return false
            }
            
            print("sendBidPrice currentAuctionItem true")

            
            // Try to update the metadata with user bid price
            guard let metaData: AgoraRtmMetadata = agoraRtmKit?.getStorage()?.createMetadata() else { return false }
            
            let metaDataItem: AgoraRtmMetadataItem = AgoraRtmMetadataItem()
            metaDataItem.key = "auctionName"
            metaDataItem.value = currentAuctionItem.auctionName
            
            let metaDataItem3: AgoraRtmMetadataItem = AgoraRtmMetadataItem()
            metaDataItem3.key = "currentBid"
            metaDataItem3.value = String(price)
            
            let metaDataItem4: AgoraRtmMetadataItem = AgoraRtmMetadataItem()
            metaDataItem4.key = "highestBidder"
            metaDataItem4.value = userID
            
            let metaDataItem5: AgoraRtmMetadataItem = AgoraRtmMetadataItem()
            metaDataItem5.key = "lastUpdatedTimeStamp"
            metaDataItem5.value = String(Date().timeIntervalSince1970)
            
            // Update the metadata item
            metaData.setMetadataItem(metaDataItem)
            metaData.setMetadataItem(metaDataItem3)
            metaData.setMetadataItem(metaDataItem4)
            metaData.setMetadataItem(metaDataItem5)
            metaData.setMajorRevision(currentAuctionItem.majorRevision)

            // Metadata options
            let metaDataOption: AgoraRtmMetadataOptions = AgoraRtmMetadataOptions()
            metaDataOption.recordUserId = true
            metaDataOption.recordTs = true
            
            if let (_, error) = await agoraRtmKit?.getStorage()?.updateChannelMetadata(channelName: mainChannel, channelType: .message, data: metaData, options: metaDataOption, lock: nil){
                if error == nil {
                    return true //await fetchUpdateAuction()
                }
            }
        }
    
        return false
    }
    
    func publishNewAuction(auctionName: String, startingPrice: Int) async -> Bool {
        
        // Try to update the metadata with user bid price
        guard let metaData: AgoraRtmMetadata = agoraRtmKit?.getStorage()?.createMetadata() else { return false }
        
        let metaDataItem: AgoraRtmMetadataItem = AgoraRtmMetadataItem()
        metaDataItem.key = "auctionName"
        metaDataItem.value = auctionName
        
        let metaDataItem2: AgoraRtmMetadataItem = AgoraRtmMetadataItem()
        metaDataItem2.key = "startingPrice"
        metaDataItem2.value = String(startingPrice)
        
        let metaDataItem3: AgoraRtmMetadataItem = AgoraRtmMetadataItem()
        metaDataItem3.key = "currentBid"
        metaDataItem3.value = String(startingPrice)
        
        let metaDataItem4: AgoraRtmMetadataItem = AgoraRtmMetadataItem()
        metaDataItem4.key = "highestBidder"
        metaDataItem4.value = userID
        
        let metaDataItem5: AgoraRtmMetadataItem = AgoraRtmMetadataItem()
        metaDataItem5.key = "lastUpdatedTimeStamp"
        metaDataItem5.value = String(Date().timeIntervalSince1970)
        
        // Update the metadata item
        metaData.setMetadataItem(metaDataItem)
        metaData.setMetadataItem(metaDataItem3)
        metaData.setMetadataItem(metaDataItem4)
        metaData.setMetadataItem(metaDataItem5)
//        metaData.setMajorRevision(1)
        
        let majorRevision = await fetchMajorRevision()
        metaData.setMajorRevision(majorRevision)
        
        print("Bac's majorrevision = \(majorRevision)")
        
        // Metadata options
        let metaDataOption: AgoraRtmMetadataOptions = AgoraRtmMetadataOptions()
        metaDataOption.recordUserId = true
        metaDataOption.recordTs = true
        
        if let (_, error) = await agoraRtmKit?.getStorage()?.setChannelMetadata(channelName: mainChannel, channelType: .message, data: metaData, options: metaDataOption, lock: nil) {
            if error == nil {
                print("Bac's publishNewAuction success")
                return true
                //return await fetchUpdateAuction()
            }else  {
                print("Bac's publishNewAuction failed error \(error?.code ?? 0) \(error?.reason ?? "")")

            }
        }
        
        return false
        
    }
    
    
    func fetchMajorRevision() async -> Int64 {
        if let (response, error) = await agoraRtmKit?.getStorage()?.getChannelMetadata(channelName: mainChannel, channelType: .message){
            if error == nil {
                return response?.data?.getMajorRevision() ?? 0
            }else{
                return 0
            }
        }
        
        return 0
    }
    
    @MainActor
    func UpdateAuctionFromRemoteUsers(metadataItems : [AgoraRtmMetadataItem], majorRevision: Int64) {
        // When auction is updated
        
        if let auctionName = metadataItems.first(where: {$0.key == "auctionName"})?.value, let auctionStartingPrice = Int(metadataItems.first(where: {$0.key == "startingPrice"})?.value ?? "0") {
            print("UpdateAuction name \(auctionName) starting \(auctionStartingPrice)")
            let auctionName : String = auctionName
            let startPrice : Int = auctionStartingPrice
            let currentBid : Int = Int(metadataItems.first(where: {$0.key == "currentBid"})?.value ?? "0") ?? startPrice
            let highestBidder : String = metadataItems.first(where: {$0.key == "highestBidder"})?.value ?? ""
            let lastUpdatedTimeStamp : Int = Int(metadataItems.first(where: {$0.key == "timeIntervalSince1970"})?.value ?? "0") ?? 0
            
            currentAuctionItem = CustomAuctionItem(majorRevision: majorRevision, auctionName: auctionName, startingPrice: startPrice, currentBid: currentBid, highestBidder: highestBidder, lastUpdatedTimeStamp: lastUpdatedTimeStamp)
        }
        
    }
    
    
    func deleteAuctionStorage() async -> Bool {
        guard let metaData: AgoraRtmMetadata = agoraRtmKit?.getStorage()?.createMetadata() else { return false }
        metaData.setMajorRevision(currentAuctionItem?.majorRevision ?? -1)

        if let (_, error) = await agoraRtmKit?.getStorage()?.removeChannelMetadata(channelName: mainChannel, channelType: .message, data: metaData, options: nil, lock: nil) {
            if error == nil {
                print("deleteAuctionStorage success" )
                Task {
                    await MainActor.run {
                        currentAuctionItem = nil
                    }
                }
                return true
            }else {
                print("deleteAuctionStorage fail" )

                return false
            }
        }
        print("deleteAuctionStorage fail" )

        return false
    }
    
}


extension BiddingViewModel: AgoraRtmClientDelegate {
    
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        
        switch event.channelType {
        case .message:
            
            break
        case .stream:
            break
        case .user:
            break
        case .none:
            break
        @unknown default:
            print("Bac's didReceiveMessageEvent channelType is unknown")
        }
    }
    
    // Receive presence event notifications in subscribed message channels and joined stream channels.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceivePresenceEvent event: AgoraRtmPresenceEvent) {
        print("Bac's didReceivePresenceEvent channelType \(event.channelType) publisher \(String(describing: event.publisher)) channel \(event.channelName) type \(event.type) ")
        
        if event.type == .remoteLeaveChannel || event.type == .remoteConnectionTimeout {

        }else if event.type == .remoteJoinChannel && event.publisher != nil {
            print("Bac's didReceivePresenceEvent remoteJoinChannel publisher: \(event.publisher ?? "")")

            
        }else if event.type == .snapshot {
            print("Bac's didReceivePresenceEvent snapshot")
 
            
        }else if event.type == .remoteStateChanged {
            print("Bac's didReceivePresenceEvent remoteStateChanged user:\(event.publisher ?? "")")

        }
    }
    
    // Receive storage event
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveStorageEvent event: AgoraRtmStorageEvent) {
        if event.storageType == .channel {
            // Channel Metadata is udpated
            print("Bac's didReceiveStorageEvent updated \(event.eventType)")
            
            if event.eventType == .snapshot ||  event.eventType == .update || event.eventType == .set {
                // snapshot: update current auction with the snapshot when user joins
                // update: metadata is updated e.g. remote user placed new bid
                // set: metadata is set e.g. user added an auction (this app should only receive this 0 or 1 times, because we are only using 1 auction at a time)

                Task {
                    await MainActor.run {
                        UpdateAuctionFromRemoteUsers(metadataItems: event.data.getItems(), majorRevision: event.data.getMajorRevision())
                    }
                }
            }
        }
    }
    
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveLockEvent event: AgoraRtmLockEvent) {
    }
    
    // Triggers when connection changes
    func rtmKit(_ kit: AgoraRtmClientKit, channel channelName: String, connectionChangedToState state: AgoraRtmClientConnectionState, reason: AgoraRtmClientConnectionChangeReason) {
        print("Bac's connectionChangedToState \(state) reason \(reason.rawValue)")
        connectionState = connectionState
    }
}


