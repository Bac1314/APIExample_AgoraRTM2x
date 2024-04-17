//
//  PollingViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/29.
//


import Foundation
import SwiftUI
import AgoraRtmKit

class PollingViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @AppStorage("userToken") var token: String = ""
    @Published var currentPoll: CustomPoll = CustomPoll(question: "(Example) Which one do you prefer?", options: ["MacOS":10, "Windows OS":5, "Linux":9], sender: "User1", totalUsers: 30, totalSubmission: 24, timestamp: Int(Date().addingTimeInterval(-15).timeIntervalSince1970))
    @Published var users: [AgoraRtmUserState] = []
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    
    let mainChannel = "ChannelA" // to publish and receive poll questions/answers
    let customPollQuestionType = "pollquestion"
    let customPollResultType = "pollresult"
    
    let defaultPollTime = 15
    
    @MainActor
    func loginRTM() async throws {
        do {
            if userID.isEmpty {
                throw customError.emptyUIDLoginError
            }
            
            if token.isEmpty {
                throw customTokenError.tokenEmptyError
            }
            
            // Initialize RTM instance
            if agoraRtmKit == nil {
                let config = AgoraRtmClientConfig(appId: Configurations.agora_AppdID , userId: userID)
                agoraRtmKit = try AgoraRtmClientKit(config, delegate: self)
            }
            
            if let (response, error) = await agoraRtmKit?.login(token) {
                if error == nil{
                    isLoggedIn = true
                }else{
                    print("Bac's code loginRTM login result = \(String(describing: response?.description)) | error \(String(describing: error))")
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
        subOptions.features =  [.message, .presence]
        
        if let (_, error) = await agoraRtmKit?.subscribe(channelName: channelName, option: subOptions){
            if error == nil {
                // object doesn't exist. Append a new object
//                numberOfUsers = await getListOfusers(channelName: channelName).count
            }
            return false
        }
        return false
    }
    

    // Publish to channel in 'MessageChannel'
    @MainActor
    func publishPollQuestion(question: String, options: [String: Int]) async -> Bool{
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.customType = customPollQuestionType
        pubOptions.channelType = .message
        
        let newPoll = CustomPoll(question: question, options: options, sender: userID, totalUsers: users.count, totalSubmission: 0, timestamp: Int(Date().addingTimeInterval(TimeInterval(defaultPollTime)).timeIntervalSince1970))

        if let pollString = convertObjectToJsonString(object: newPoll){
            if let (_, error) = await agoraRtmKit?.publish(channelName: mainChannel, message: pollString, option: pubOptions){
                if error == nil {
                    print("Bac's sendMessageToChannel success \(pollString)")
                    currentPoll = newPoll // Update local
                    return true
                }else{
                    print("Bac's sendMessageToChannel error \(String(describing: error))")
                    return false
                }
                
            }
        }
        return false
    }
    
    @MainActor
    func publishPollResponse(channelName: String, answer: String) async -> Bool {
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.customType = customPollResultType
        pubOptions.channelType = .message
        
        if let (_, error) = await agoraRtmKit?.publish(channelName: channelName, message: answer, option: pubOptions){
            if error == nil {
                print("Bac's sendMessageToChannel success \(answer)")

                // Update local's poll
                if (currentPoll.options[answer] != nil) {
                    currentPoll.options[answer]! += 1
                    currentPoll.totalSubmission += 1
                    print("Bac's localUser answered '\(answer)'")
                }
                return true
            }else{
                print("Bac's sendMessageToChannel error \(String(describing: error))")
                return false
            }
            
        }
        return false
    }

    @MainActor
    func getListOfusers(channelName: String) async -> [AgoraRtmUserState] {
        let onlineOptions = AgoraRtmGetOnlineUsersOptions()
        onlineOptions.includeUserId = true
        onlineOptions.includeState = true
        
        if let (response, error) = await agoraRtmKit?.getPresence()?.getOnlineUser(channelName: channelName, channelType: .message, options: onlineOptions){
            if error == nil {
                return response?.userStateList ?? []
            }
        }
        return []
    }
    



}

extension PollingViewModel: AgoraRtmClientDelegate {
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        print("Bac's didReceiveMessageEvent msg = \(event.message.stringData ?? "Empty") from \(event.publisher) type \(String(describing: event.customType))")
        
        switch event.channelType {
        case .message:
            // Main Channel to receive POLL question or POLL result
            if event.customType == customPollQuestionType {
                // Received new poll, replace current poll
                if let jsonString = event.message.stringData, let newPoll = convertJsonStringToObject(jsonString: jsonString, objectType: CustomPoll.self) {
                    print("Bac's didReceiveMessageEvent new poll is \(jsonString)")

                    currentPoll = newPoll
                }
            }else if event.customType == customPollResultType {
                // Update poll
                if let answer = event.message.stringData {
                    if (currentPoll.options[answer] != nil) {
                        currentPoll.options[answer]! += 1
                        currentPoll.totalSubmission += 1
                        print("Bac's remoteUser \(event.publisher) answered '\(answer)'")
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

