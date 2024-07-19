//
//  P2PMessagingViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/21.
//

import Foundation
import SwiftUI
import AgoraRtmKit

class P2PMessagingViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var rtmUsersMessages: [AgoraRtmMessageEvent] = [] // Users messages only
    @Published var subscribedUsers: [String : String] = [:] // [username : last_message] for display purposes
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
        agoraRtmKit?.logout()
        agoraRtmKit?.destroy()
        isLoggedIn = false
    }
        
    //MARK: P2P METHODS
    // Publish to specific user
    @MainActor
    func publishToUser(userName: String, messageString: String, customType: String?) async -> Bool{
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.customType = customType ?? ""
        pubOptions.channelType = .user
        
        if let (_, error) = await agoraRtmKit?.publish(channelName: userName, message: messageString, option: pubOptions){
            if error == nil {
                // MARK: if success, create a local message event for display (bc callback doesn't fire for local send)
                let temp = AgoraRtmMessageEvent()
                temp.channelType = .user
                temp.channelName = userName
                temp.message = AgoraRtmMessage()
                temp.message.stringData = messageString
                temp.publisher = userID
                
                rtmUsersMessages.append(temp)
                subscribedUsers[userName] = messageString
                return true
            }else{
                print("Bac's sendMessageToChannel error \(String(describing: error))")
                return false
            }
            
        }
        return false
    }
    
//    @MainActor
//    func checkIfUserIsOnline(remoteUser: String) async -> Bool{
////        if let (response, error) = await agoraRtmKit?.getPresence().user
//    }
    
}

extension P2PMessagingViewModel: AgoraRtmClientDelegate {
    
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        print("Bac's didReceiveMessageEvent msg = \(event.message.stringData ?? "Empty") from \(event.publisher) type \(String(describing: event.customType))")
        
        switch event.channelType {
        case .message:
            break
        case .stream:
            break
        case .user:
            Task {
                await MainActor.run {
                    rtmUsersMessages.append(event)
                    subscribedUsers[event.publisher] = event.message.stringData // Show latest messaage on user list
                }
            }
            break
        case .none:
            break
        @unknown default:
            print("Bac's didReceiveMessageEvent channelType is unknown")
        }
    }
    
    
}
