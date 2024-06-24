//
//  VideoCallInviteViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/6/14.
//


import Foundation
import SwiftUI
import AgoraRtmKit
import AgoraRtcKit


class VideoCallInviteViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    @Published var users: [AgoraRtmUserState] = []
    @Published var mainChannel = "ChannelA" // to publish and receive poll questions/answers
    
    final var agoraKit: AgoraRtcEngineKit = AgoraRtcEngineKit()
    @Published var localRtcUID: UInt = 0
    @Published var remoteRtcUID: UInt = 0
    @Published var enableCamera: Bool = false
    @Published var enableMic: Bool = false
    
    // Call variables
    @Published var currentCallState: CallState = .none

    
    func initRTMRTC() async throws {
        //Init RTM
        try await loginRTM()
        _ = await subscribeRTMChannel(channelName: mainChannel)
        
        //Init RTC
        initRtc()
    }
    
    func deinitRTMRTC() {
        logoutRTM()
        leaveRTCChannel()
    }
    
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
        
        // Leave RTC
        agoraKit.leaveChannel()

    }
    
    //MARK: MESSAGE CHANNEL METHODS
    @MainActor
    func subscribeRTMChannel(channelName: String) async -> Bool {
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
    
    func callUser(userID: String) async -> Bool {
        let pubOptions = AgoraRtmPublishOptions()
//        pubOptions.customType = customType ?? ""
        pubOptions.channelType = .user
        
        if let (_, error) = await agoraRtmKit?.publish(channelName: userID, message: "calling", option: pubOptions){
            if error == nil {
                // MARK: if success
                return true
            }else{
                print("Bac's sendMessageToChannel error \(String(describing: error))")
                return false
            }
            
        }
        return false
    }
    

    // MARK: RTC Functions
    func initRtc() {
        let config = AgoraRtcEngineConfig()
        config.appId = Configurations.agora_AppdID
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(.broadcaster)
        
    }
    
    func joinRTCChannel(channelName: String) {
        agoraKit.joinChannel(byToken: nil, channelId: channelName, info: nil, uid: 0)
    }
    
    func leaveRTCChannel(){
        agoraKit.leaveChannel()
    }
    
    func setupLocalView(localView: UIView) {
        agoraKit.enableVideo()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        agoraKit.startPreview()
        agoraKit.setupLocalVideo(videoCanvas)
    }
    
    func setupRemoteView(remoteView: UIView) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = remoteRtcUID
        // the view to be binded
        videoCanvas.view = remoteView
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
    }
    
    func switchCamera(){
        agoraKit.switchCamera()
    }
    
    func toggleCamera(){
        enableCamera = !enableCamera
        agoraKit.enableLocalVideo(!enableCamera)
    }
    
    func toggleMic(){
        enableMic = !enableMic
        agoraKit.enableLocalAudio(!enableMic)
    }

    


}

extension VideoCallInviteViewModel: AgoraRtmClientDelegate {
    
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

extension VideoCallInviteViewModel: AgoraRtcEngineDelegate {
    // When local user joined
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        localRtcUID = uid
        print("Joined channel success uid is \(uid)")
    }
    
    // When local user leaves
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, permissionError type: AgoraPermissionType) {
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
    }

 
    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStateChanged state: AgoraAudioLocalState, reason: AgoraAudioLocalReason) {
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localVideoStateChangedOf state: AgoraVideoLocalState, reason: AgoraLocalVideoStreamReason, sourceType: AgoraVideoSourceType) {
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionState, reason: AgoraConnectionChangedReason) {
    }
}

