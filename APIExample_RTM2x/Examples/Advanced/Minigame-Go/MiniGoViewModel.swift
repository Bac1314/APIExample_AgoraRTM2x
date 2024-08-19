//
//  MiniGoViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/15.
//


import Foundation
import SwiftUI
import AgoraRtmKit

class MiniGoViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    @Published var users: [AgoraRtmUserState] = []
    @Published var mainChannel = "GoChannel"
    
    @Published var goBoardModel : GoBoardModel = GoBoardModel()
    @Published var currentMajorRevision : Int64?
    let customTTT = "miniGoMessage"
    
    
    @MainActor
    func loginRTM() async throws {
        do {
            if userID.isEmpty {
                throw customError.emptyUIDLoginError
            }
            
            // Initialize RTM instance
            if agoraRtmKit == nil {
                let config = AgoraRtmClientConfig(appId: Configurations.agora_AppID , userId: userID)
                agoraRtmKit = try AgoraRtmClientKit(config, delegate: self)
            }
            
            // Login to RTM server
            // Use AppID to login if app certificate is NOT enabled for project
            if let (response, error) = await agoraRtmKit?.login(token.isEmpty ? Configurations.agora_AppID : token) {
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
        Task {
            // If player logs out, reset the board
            if goBoardModel.player1Name == userID || goBoardModel.player2Name == userID {
                await DeleteBoard() // Delete board from cloud
            }
            await agoraRtmKit?.logout()
            await MainActor.run {
                agoraRtmKit?.destroy()
                isLoggedIn = false
            }
        }

    }
    
    //MARK: MESSAGE CHANNEL METHODS
    // Subscribe to channel in 'MessageChannel'
    @MainActor
    func subscribeChannel(channelName: String) async -> Bool {
        let subOptions: AgoraRtmSubscribeOptions = AgoraRtmSubscribeOptions()
        subOptions.features =  [.message, .presence, .metadata]
        
        if let (_, error) = await agoraRtmKit?.subscribe(channelName: channelName, option: subOptions){
            if error == nil {
                return true
            }
            return false
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
    
    
    func PublishBoardUpdate() async {
        print("Bac's PublishBoardUpdate ")
        if let boardJSONString = convertObjectToJsonString(object: goBoardModel) {
            print("Bac's PublishBoardUpdate boardJSONSTRING success")
            
            guard let metaData: AgoraRtmMetadata = agoraRtmKit?.getStorage()?.createMetadata()
            else {return }
            
            let metaDataItem : AgoraRtmMetadataItem = AgoraRtmMetadataItem()
            metaDataItem.key = customTTT
            metaDataItem.value = boardJSONString
            
            metaData.setMetadataItem(metaDataItem)
            
            // Metadata options
            let metaDataOption: AgoraRtmMetadataOptions = AgoraRtmMetadataOptions()
            metaDataOption.recordUserId = true
            metaDataOption.recordTs = true
            
            // Update or Set New ChannelMetadata
            if let currentMajorRevision = currentMajorRevision {
                print("Bac's PublishBoardUpdate currentMajorRevision")

                metaData.setMajorRevision(currentMajorRevision )
                
                if let (_, error) = await agoraRtmKit?.getStorage()?.updateChannelMetadata(channelName: mainChannel, channelType: .message, data: metaData, options: metaDataOption, lock: nil){
                    if error == nil {
            
                    }
                }
            }else {
                print("Bac's PublishBoardUpdate else")

                metaData.setMajorRevision(await fetchMajorRevision())
                
                if let (_, error) = await agoraRtmKit?.getStorage()?.setChannelMetadata(channelName: mainChannel, channelType: .message, data: metaData, options: metaDataOption, lock: nil){
                    if error == nil {
            
                    }
                }
                
            }
            

        }
    }
    
    @MainActor
    func UpdateLocalBoard(metadataItems : [AgoraRtmMetadataItem], majorRevision: Int64) {
        if let newTTTBoardString = metadataItems.first(where: {$0.key == customTTT})?.value,  let newTTTBoard = convertJsonStringToObject(jsonString: newTTTBoardString, objectType: GoBoardModel.self) {
            goBoardModel = newTTTBoard
            currentMajorRevision = majorRevision
        }
    }
    
    @MainActor
    func ResetLocalBoard(){
        withAnimation {
            goBoardModel = GoBoardModel()
            currentMajorRevision = nil
        }
    }
    
    func DeleteBoard() async  {
        guard let metaData: AgoraRtmMetadata = agoraRtmKit?.getStorage()?.createMetadata() else { return }

        if let (_, error) = await agoraRtmKit?.getStorage()?.removeChannelMetadata(channelName: mainChannel, channelType: .message, data: metaData, options: nil, lock: nil) {
            if error == nil {
                // Delete Successful
            }else {
                // Delete failed
                print("Delete Failed with error \(String(describing: error))")
            }
        }
        
    }

    
    
}

extension MiniGoViewModel: AgoraRtmClientDelegate {
    
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        print("Bac's didReceiveMessageEvent msg = \(event.message.stringData ?? "Empty") from \(event.publisher) type \(String(describing: event.customType))")
        
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
    
    // Receive storage event
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveStorageEvent event: AgoraRtmStorageEvent) {
        if event.storageType == .channel {
            // Channel Metadata is udpated
            print("Bac's didReceiveStorageEvent updated \(event.eventType)")
            
            if event.eventType == .snapshot ||  event.eventType == .update || event.eventType == .set {
                
                if event.data.getItems().count > 0 {
                    Task {
                        await UpdateLocalBoard(metadataItems: event.data.getItems(), majorRevision: event.data.getMajorRevision())
                    }
                }else {
                    // Remote user deleted board, reset the local board
                    Task {
                        await ResetLocalBoard()
                    }
                }

            }else if event.eventType == .remove {
                // MARK: NOT TRIGGERING
                Task {
                    await ResetLocalBoard()
                }
            }
        }
    }
    
    // Receive presence event notifications in subscribed message channels and joined stream channels.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceivePresenceEvent event: AgoraRtmPresenceEvent) {
        print("Bac's didReceivePresenceEvent channelType \(event.channelType) publisher \(String(describing: event.publisher)) channel \(event.channelName) type \(event.type) ")
        
        if event.type == .remoteLeaveChannel || event.type == .remoteConnectionTimeout {
            
            // Remove user from list
            if let userIndex = users.firstIndex(where: {$0.userId == event.publisher}) {
                users.remove(at: userIndex)
            }
        }else if event.type == .remoteJoinChannel && event.publisher != nil {
            
            // Add user to list if it doesn't exist
            if !users.contains(where: {$0.userId == event.publisher}) && event.publisher != nil {
                let userState = AgoraRtmUserState()
                userState.userId = event.publisher!
                userState.states = event.states
                users.append(userState)
            }
            
        }else if event.type == .snapshot {
            print("Bac's didReceivePresenceEvent snapshot")
            users = event.snapshot
        }else if event.type == .remoteStateChanged {
            print("Bac's didReceivePresenceEvent remoteStateChanged")
        }
    }
    // Triggers when connection changes
    func rtmKit(_ kit: AgoraRtmClientKit, channel channelName: String, connectionChangedToState state: AgoraRtmClientConnectionState, reason: AgoraRtmClientConnectionChangeReason) {
        print("Bac's connectionChangedToState \(state) reason \(reason.rawValue)")
        connectionState = connectionState
    }
    
    
}

