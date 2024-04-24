//
//  WhiteBoardViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/24.
//

import Foundation
import AgoraRtmKit
import SwiftUI


class WhiteBoardViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var users: [AgoraRtmUserState] = []
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    
    let mainChannel = "ChannelA" // to publish and receive poll questions/answers
    let customWhiteBoardNewType = "newDrawing"
    let customWhiteBoardUpdateType = "drawingUpdate"

    
    @Published var drawings: [Drawing] = [Drawing]()

    
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

    //MARK: MESSAGE CHANNEL / POLL METHODS
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
    

    // Publish to channel in 'MessageChannel'
    func publishNewDrawing(drawing: Drawing) async -> Bool{
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.customType = customWhiteBoardNewType
        pubOptions.channelType = .message

        if let drawingString = convertObjectToJsonString(object: drawing){
            if let (_, error) = await agoraRtmKit?.publish(channelName: mainChannel, message: drawingString, option: pubOptions){
                if error == nil {
                    print("Bac's sendMessageToChannel success \(drawingString)")
                    return true
                }else{
                    print("Bac's sendMessageToChannel error \(String(describing: error))")
                    return false
                }
                
            }
        }
        return false
    }
    
    func publishDrawingUpdate(newPoint: DrawingPoint) async -> Bool{
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.customType = customWhiteBoardUpdateType
        pubOptions.channelType = .message

        if let newDrawingPointString = convertObjectToJsonString(object: newPoint){
            if let (_, error) = await agoraRtmKit?.publish(channelName: mainChannel, message: newDrawingPointString, option: pubOptions){
                if error == nil {
                    print("Bac's sendMessageToChannel success \(newDrawingPointString)")
                    return true
                }else{
                    print("Bac's sendMessageToChannel error \(String(describing: error))")
                    return false
                }
                
            }
        }
        return false
    }
    
    func saveDrawingToRTMStorage(drawing: Drawing) async -> Bool {
        return false
    }
    
    

}

extension WhiteBoardViewModel: AgoraRtmClientDelegate {
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        print("Bac's didReceiveMessageEvent msg = \(event.message.stringData ?? "Empty") from \(event.publisher) type \(String(describing: event.customType))")
        
        switch event.channelType {
        case .message:
            // Main Channel to receive new drawings
            if event.customType == customWhiteBoardNewType {
                // Received new drawing,
                if let jsonString = event.message.stringData, let newDrawing = convertJsonStringToObject(jsonString: jsonString, objectType: Drawing.self) {
                    print("Bac's didReceiveMessageEvent new drawing is \(jsonString)")
                    drawings.append(newDrawing)
                }
            }else if event.customType == customWhiteBoardUpdateType {
                if let jsonString = event.message.stringData, let newDrawingPoint = convertJsonStringToObject(jsonString: jsonString, objectType: DrawingPoint.self) {
                    print("Bac's didReceiveMessageEvent new drawing point is \(jsonString)")
                    if let index = drawings.firstIndex(where: {$0.id == newDrawingPoint.id}) {
                        print("Bac's didReceiveMessageEvent UID FOUND")

                        drawings[index].points.append(newDrawingPoint.point)
                    }else {
                        print("Bac's didReceiveMessageEvent UID NOT FOUND")

                        
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
            
            if let userIndex = users.firstIndex(where: {$0.userId == event.publisher}) {
                // User exist, update the states
                users[userIndex].states = event.states
                
                for state in event.states {
                    print("Bac's didReceivePresenceEvent remoteStateChanged key: \(state.key) value: \(state.value)")
                }

            }
        }
    }
    
    // Triggers when connection changes
    func rtmKit(_ kit: AgoraRtmClientKit, channel channelName: String, connectionChangedToState state: AgoraRtmClientConnectionState, reason: AgoraRtmClientConnectionChangeReason) {
        print("Bac's connectionChangedToState \(state) reason \(reason.rawValue)")
        connectionState = connectionState
    }
    
}

