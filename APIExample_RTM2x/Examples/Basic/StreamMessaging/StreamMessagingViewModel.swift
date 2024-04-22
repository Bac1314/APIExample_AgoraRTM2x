//
//  StreamMessagingViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/18.
//

import Foundation

import Foundation
import SwiftUI
import AgoraRtmKit

class StreamMessagingViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    @Published var customStreamTopicList : [CustomStreamTopic] = []
    @Published var users: [AgoraRtmUserState] = []
    
    let mainChannel = "ChannelA" // to publish the storage
    var agoraStreamChannel: AgoraRtmStreamChannel? = nil
    @Published var tokenRTC: String = ""

    var defaultTopics : [String] = ["topic1", "topic2"] // Topics that you would to publish to
//    @Published var subscribedTopics : [String] = ["topic1", "topic2"] // Topics that you would like to subscribe to
    
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
    
    // Join Stream Channel
    func createAndJoinStreamChannel() async{
        do {
            agoraStreamChannel = try agoraRtmKit?.createStreamChannel(mainChannel) 
                        
            let joinOption = AgoraRtmJoinChannelOption()
            joinOption.features = [.presence]
            joinOption.token = tokenRTC
            
            if let (response, error) = await agoraStreamChannel?.join(joinOption) {
                if error == nil {
                    // Join successful
                    print("Bac's createAndJoinStreamChannel success \(String(describing: response))")
                }else {
                    // Join failed
                    print("Bac's createAndJoinStreamChannel failed \(String(describing: error)) \(error?.reason ?? "")")
                }
            }
            
        } catch {
            print("Bac's createAndJoinStreamChannel error \(error)")
        }
    }
    
    // Pre-join some topics
    func preJoinSubTopics() async {
        for topic in defaultTopics {
            // Join as publisher first, if success then subscribe
            let _ = await JoinAndSubTopic(topic: topic)
        
            
//            if result {
//                Task {
//                    await MainActor.run {
//                        customStreamTopicList.append(CustomStreamTopic(topic: topic, messages: [] , lastMessage: "Latest message would appear here"))
//                    }
//                }
//            }
        }
    }
    
    
    
    // Join a single topic as publisher
    func joinOneTopic(topic: String) async -> Bool{
        // Set publishing options
        let publishTopicOptions = AgoraRtmJoinTopicOption()
        publishTopicOptions.priority = .high
        publishTopicOptions.qos = .ordered
        
        if let (_, error) = await agoraStreamChannel?.joinTopic(topic, option: publishTopicOptions) {
            if error == nil {
                // Join success
                print("Bac's joinOneTopics \(topic) success")
                return true
            }else {
                // Join failed
                print("Bac's joinOneTopics \(topic) failed \(error?.code ?? 0) \(error?.reason ?? "")")
                return false
            }
        }
        return false
    }
    
    // Subscribe to a single topic to receive topic messages
    func subscribeOneTopic(topic: String) async -> Bool{
        // Set subscribing options
        let subscribeTopicOptions = AgoraRtmTopicOption()
        subscribeTopicOptions.users = users.map(\.userId) // get the list of usersID
        
        
        // Subscribe to topic
        if let (response, error) = await agoraStreamChannel?.subscribeTopic(topic, option: subscribeTopicOptions) {
            if error == nil {
                // Subscribe success
                print("Bac's subscribe \(topic) success")
                print("Bac's subscribed Success users \(String(describing: response?.succeedUsers)) AND Failed \(String(describing: response?.failedUsers)) ")

                return true
            }else {
                // Subscribe failed
                print("Bac's subscribe failed \(error?.code ?? 0) \(error?.reason ?? "")")
                return false
            }
        }
        
        return false
    }
    
    // Join and subscribe a topic
    func JoinAndSubTopic(topic: String) async -> Bool{
        if !customStreamTopicList.contains(where: {$0.topic == topic}) {
            let resultA = await joinOneTopic(topic: topic)
            let resultB = resultA ? await subscribeOneTopic(topic: topic) : false
            
            Task {
                await MainActor.run {
                    customStreamTopicList.append(CustomStreamTopic(topic: topic, messages: [] , lastMessage: "Latest message would appear here"))
                }
            }
            
            return resultB // only return true if join and sub is successful
        }
        return false
    }
    
    // Resubscribe when a new user joins
    func reSubscribeNewUsers() async {
        // Set subscribing options
        let subscribeTopicOptions = AgoraRtmTopicOption()
        subscribeTopicOptions.users = users.map(\.userId) // get the list of usersID
        
        for topic in customStreamTopicList.map(\.topic) {
            if let (_, error) = await agoraStreamChannel?.subscribeTopic(topic, option: subscribeTopicOptions) {
                if error == nil {
                    // Subscribe success
                }else {
                    // Subscribe failed
                    print("Bac's subscribeTopics failed \(error?.code ?? 0) \(error?.reason ?? "")")
                }
            }
        }
    }
    
    @MainActor
    func publishToTopic(topic: String, message: String) async -> Bool {
        if let (_, error) = await agoraStreamChannel?.publishTopicMessage(topic: topic, message: message, option: nil) {
            if error == nil {
                // Publish successful, add a local copy for user
                if let index = customStreamTopicList.firstIndex(where: {$0.topic == topic}) {
                    let temp = AgoraRtmMessageEvent()
                    temp.message = AgoraRtmMessage()
                    temp.channelType = .stream
                    temp.channelTopic = topic
                    temp.message.stringData = message
                    temp.publisher = userID
                    
                    customStreamTopicList[index].lastMessage = message
                    customStreamTopicList[index].messages.append(temp)
                    return true
                }
            }else {
                print("Bac's publishToTopic failed topic \(topic) message \(message) error \(String(describing: error))")
                return false
            }
        }
        
        return false
    }
}


extension StreamMessagingViewModel: AgoraRtmClientDelegate {
    
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        switch event.channelType {
        case .message:
            break
        case .stream:
            print("Received stream topic \(event.channelTopic) and message \(event.message.stringData ?? "")")
            if let index = customStreamTopicList.firstIndex(where: {$0.topic == event.channelTopic}) {
                Task {
                    await MainActor.run {
                        customStreamTopicList[index].lastMessage = event.message.stringData ?? ""
                        customStreamTopicList[index].messages.append(event)
                    }
                }
            }
            
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
            print("Bac's didReceivePresenceEvent remoteJoinChannel publisher: \(event.publisher ?? "")")
            // Add user to list if it doesn't exist
            if !users.contains(where: {$0.userId == event.publisher}) && event.publisher != nil {
                let userState = AgoraRtmUserState()
                userState.userId = event.publisher!
                userState.states = event.states
                users.append(userState)
                
                // Resubscribe for new users
                Task {
                    await reSubscribeNewUsers()
                }
            }
            
        }else if event.type == .snapshot {
            users = event.snapshot
        }else if event.type == .remoteStateChanged {
            
        }
    }
    
    // Receive storage event
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveStorageEvent event: AgoraRtmStorageEvent) {
        
    }
    
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveLockEvent event: AgoraRtmLockEvent) {
    }
    
    // Triggers when connection changes
    func rtmKit(_ kit: AgoraRtmClientKit, channel channelName: String, connectionChangedToState state: AgoraRtmClientConnectionState, reason: AgoraRtmClientConnectionChangeReason) {
        print("Bac's connectionChangedToState \(state) reason \(reason.rawValue)")
        connectionState = connectionState
    }
}

