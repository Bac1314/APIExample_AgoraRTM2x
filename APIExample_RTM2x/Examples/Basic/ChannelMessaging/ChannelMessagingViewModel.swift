//
//  ChannelMessagingViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/21.
//

import Foundation
import SwiftUI
import AgoraRtmKit

class ChannelMessagingViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var customRTMChannelList: [CustomRTMChannel] = [] // Show list of subscribed channels (list of messages, last message, userList)
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
        
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
    
    //MARK: MESSAGE CHANNEL METHODS
    // Subscribe to channel in 'MessageChannel'
    @MainActor
    func subscribeChannel(channelName: String) async -> Bool {
        // Create new channel if it doesn't exist.
        if let _ = customRTMChannelList.firstIndex(where: { $0.channelName == channelName }) {
            // Object exists, do nothing
        } else {
            // Object doesn't exist. Append a new object
            let newChannel = CustomRTMChannel(channelName: channelName, channelMessages: [], lastMessage: "Latest message would appear here", listOfUsers: [])
            customRTMChannelList.append(newChannel)
        }
        
        
        let subOptions: AgoraRtmSubscribeOptions = AgoraRtmSubscribeOptions()
        subOptions.features =  [.message, .presence]
                
        if let (_, error) = await agoraRtmKit?.subscribe(channelName: channelName, option: subOptions){
            if error == nil {
                //subscribe success
                return true
            }else {
                //subscribe failed
                print("Bac's subscribeChannel failed \(channelName)")
            }
            return false
        }
        
        return false
    }
    
    // Publish to channel in 'MessageChannel'
    @MainActor
    func publishToChannel(channelName: String, messageString: String, customType: String?) async -> Bool{
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.customType = customType ?? ""
        pubOptions.channelType = .message
        
        
        if let (_, error) = await agoraRtmKit?.publish(channelName: channelName, message: messageString, option: pubOptions){
            if error == nil {
                if let index = customRTMChannelList.firstIndex(where: { $0.channelName == channelName }) {
                    // Channel Exist, Add to channel list of messages
                    
                    // MARK: if success, create a local message event for display (bc callback doesn't fire for local send)
                    let temp = AgoraRtmMessageEvent()
                    temp.channelType = .message
                    temp.channelName = channelName
                    temp.message = AgoraRtmMessage()
                    temp.message.stringData = messageString
                    temp.publisher = userID
                    
                    customRTMChannelList[index].channelMessages.append(temp)
                    customRTMChannelList[index].lastMessage = messageString

                }

                return true
            }else{
                print("Bac's sendMessageToChannel error \(String(describing: error))")
                return false
            }
            
        }
        return false
    }
    
//    @MainActor
//    func getListOfusers(channelName: String) async -> [AgoraRtmUserState] {
//        let onlineOptions = AgoraRtmGetOnlineUsersOptions()
//        onlineOptions.includeUserId = true
//        onlineOptions.includeState = true
//                
//        if let (response, error) = await agoraRtmKit?.getPresence()?.getOnlineUser(channelName: channelName, channelType: .message, options: onlineOptions){
//            if error == nil {
//                return response?.userStateList ?? []
//            }
//        }
//        
//        return []
//    }
}

extension ChannelMessagingViewModel: AgoraRtmClientDelegate {
    
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        print("Bac's didReceiveMessageEvent msg = \(event.message.stringData ?? "Empty") from \(event.publisher) type \(String(describing: event.customType))")
        
        switch event.channelType {
        case .message:
            if let index = customRTMChannelList.firstIndex(where: { $0.channelName == event.channelName }) {
                // Channel Exist
                Task {
                    await MainActor.run {
                        customRTMChannelList[index].channelMessages.append(event)
                        customRTMChannelList[index].lastMessage = event.message.stringData ?? ""
                    }
                }
            }
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
        // Check channelIndex exists.
        guard let channeIndex = customRTMChannelList.firstIndex(where: { $0.channelName == event.channelName }) else { 
            print("Bac's didReceivePresenceEvent channelIndex doesn't exist ")

            return }
        
        if event.type == .remoteLeaveChannel || event.type == .remoteConnectionTimeout {
        // A remote user left the channel
            guard let userIndex = customRTMChannelList[channeIndex].listOfUsers.firstIndex(where: { $0.userId == event.publisher}) else { return }
            customRTMChannelList[channeIndex].listOfUsers.remove(at: userIndex) // Remove user from list
            
        }else if event.type == .remoteJoinChannel && event.publisher != nil {
         // A remote user subscribe the channel
            let newUser = AgoraRtmUserState()
            newUser.userId = event.publisher!
            newUser.states = event.states
            
            customRTMChannelList[channeIndex].listOfUsers.append(newUser) // Add new user to list
            
        }else if event.type == .snapshot {
        // Get a snapshot of all the subscribed users' 'presence' data (aka temporary key-value pairs storage)
            customRTMChannelList[channeIndex].listOfUsers = event.snapshot
            
        }else if event.type == .remoteStateChanged {
        // A remote user's 'presence' data was changed
        }
        
    }

    // Triggers when connection changes
    func rtmKit(_ kit: AgoraRtmClientKit, channel channelName: String, connectionChangedToState state: AgoraRtmClientConnectionState, reason: AgoraRtmClientConnectionChangeReason) {
        print("Bac's connectionChangedToState \(state) reason \(reason.rawValue)")
        connectionState = connectionState
    }

    
}

