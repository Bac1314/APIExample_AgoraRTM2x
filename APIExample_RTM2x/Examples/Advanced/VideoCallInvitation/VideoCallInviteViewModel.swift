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
import AVFoundation
import CallKit


class VideoCallInviteViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    @Published var users: [AgoraRtmUserState] = []
    @Published var mainChannel = "ChannelA" // to publish and receive poll questions/answers
    
    var agoraRTCKit: AgoraRtcEngineKit? = nil
    @Published var localRtcUID: UInt = 0
    @Published var remoteRtcUID: UInt = 0
    @Published var enableCamera: Bool = false
    @Published var enableMic: Bool = false
    
    // Call variables
    @Published var currentCallState: CallState = .none
    @Published var incomingUserID: String = ""
    var callType = "callType"
    
    // CallKit Variables
    let provider = CXProvider(configuration: CXProviderConfiguration())
    let callController = CXCallController()

    override init() {
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    func initRTMRTC() async throws {
        //Init RTM
        try await loginRTM()
        _ = await subscribeRTMChannel(channelName: mainChannel)
        
        //Init RTC
        await initRtc()
    }
    
    func deinitRTMRTC() {
        logoutAll()
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
    func logoutAll(){
        agoraRtmKit?.logout()
        agoraRtmKit?.destroy()
        isLoggedIn = false
        
        // Leave RTC
        agoraRTCKit?.disableAudio()
        agoraRTCKit?.disableVideo()
        agoraRTCKit?.leaveChannel()
        agoraRTCKit = nil

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
        let callKitID = UUID()
        
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.customType = callType
        pubOptions.channelType = .user
        
        if let (_, error) = await agoraRtmKit?.publish(channelName: userID, message: "\(callKitID)", option: pubOptions){
            if error == nil {
                // MARK: if success
                Task {
                    await MainActor.run {
                        withAnimation {
                            currentCallState = .calling
                        }
                    }
                    try? await startCall(id: callKitID, handle: userID)
                }

                return true
            }else{
                print("Bac's sendMessageToChannel error \(String(describing: error))")
                return false
            }
            
        }
        return false
    }
    
    func startCall(id: UUID, handle: String) async throws {
        print("Bac's startCall called")
        do {
            let handle = CXHandle(type: .generic, value: handle)
            let action = CXStartCallAction(call: id, handle: handle)
//            action.isVideo = true
            
            try await callController.requestTransaction(with: action)
        }catch {
            print("Bac's startCall \(error)")
        }
    }
    
    func reportIncomingCall(id: UUID, handle: String) async throws {
        print("Bac's reportIncomingCall called")

        do {
            let handle = CXHandle(type: .generic, value: handle)
            let update = CXCallUpdate()
            update.remoteHandle = handle
            
            try await provider.reportNewIncomingCall(with: id, update: update)
        } catch {
            print("Bac's reportIncomingCall \(error)")
        }
    }

    // MARK: RTC Functions
    func initRtc() async {
    
        let config = AgoraRtcEngineConfig()
        config.appId = Configurations.agora_AppdID
        agoraRTCKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        agoraRTCKit?.setChannelProfile(.liveBroadcasting)
        agoraRTCKit?.setClientRole(.broadcaster)

    }
    
    func joinRTCChannel(channelName: String) {
        let _ = agoraRTCKit?.joinChannel(byToken: nil, channelId: channelName, info: nil, uid: 0)
    }
    
    func leaveRTCChannel(){
        agoraRTCKit?.leaveChannel()
    }
    
    func setupLocalView(localView: UIView) {
        agoraRTCKit?.enableVideo()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        agoraRTCKit?.startPreview()
        agoraRTCKit?.setupLocalVideo(videoCanvas)
        
        // Set Resolution
        agoraRTCKit?.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(
            size: CGSize(width: 720, height: 1280),
            frameRate: AgoraVideoFrameRate(rawValue: 30) ?? .fps30,
            bitrate: AgoraVideoBitrateStandard,
            orientationMode: .adaptative, mirrorMode: .auto))
    }
    
    func setupRemoteView(remoteView: UIView) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = remoteRtcUID
        // the view to be binded
        videoCanvas.view = remoteView
        videoCanvas.renderMode = .hidden
        agoraRTCKit?.setupRemoteVideo(videoCanvas)
    }
    
    
    @MainActor
    func switchCamera(){
        agoraRTCKit?.switchCamera()
    }
    
    @MainActor
    func toggleCamera(){
        enableCamera = !enableCamera
        agoraRTCKit?.enableLocalVideo(!enableCamera)
    }
    
    @MainActor
    func toggleMic(){
        enableMic = !enableMic
        agoraRTCKit?.enableLocalAudio(!enableMic)
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
            if event.customType == callType {
                Task {
                    let callKitID = UUID(uuidString: event.message.stringData!) ?? UUID()
                    try? await reportIncomingCall(id: callKitID, handle: userID)
                    
//                    await MainActor.run {
//                        incomingUserID = event.publisher
//                        currentCallState = .incoming
//                        AudioServicesPlaySystemSound(SystemSoundID(1009))
//                    }
                }
            }
            
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
        Task {
            await MainActor.run {
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
        print("Bac's Joined channel success uid is \(uid)")
    }
    

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        Task {
            await MainActor.run {
                withAnimation {
                    remoteRtcUID = uid
                    currentCallState = .incall
                    print("Bac's didJoinedOfUid is \(uid)")
                }

            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, permissionError type: AgoraPermissionType) {
        print("Bac's permissionError is \(type)")

    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("Bac's didOccurError is \(errorCode)")

    }

}


extension VideoCallInviteViewModel: CXProviderDelegate {
    /// Called when the provider has been reset. Delegates must respond to this callback by cleaning up all internal call state (disconnecting communication channels, releasing network resources, etc.). This callback can be treated as a request to end all calls without the need to respond to any actions
    func providerDidReset(_ provider: CXProvider){
        print("Bac's providerDidReset")
    }
    
    /// Called when the provider has been fully created and is ready to send actions and receive updates
     func providerDidBegin(_ provider: CXProvider) {
         print("Bac's providerDidBegin")

    }

    /// Called whenever a new transaction should be executed. Return whether or not the transaction was handled:
    ///
    /// - NO: the transaction was not handled indicating that the perform*CallAction methods should be called sequentially for each action in the transaction
    /// - YES: the transaction was handled and the perform*CallAction methods should not be called sequentially
    ///
    /// If the method is not implemented, NO is assumed.
    func provider(_ provider: CXProvider, execute transaction: CXTransaction) -> Bool {
        print("Bac's execute transaction")

         return false
    }

    // If provider:executeTransaction:error: returned NO, each perform*CallAction method is called sequentially for each action in the transaction
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("Bac's  perform action: CXStartCallAction")
        joinRTCChannel(channelName: "\(mainChannel)_\(remoteRtcUID)_\(localRtcUID)")
        action.fulfill()
    }

     func provider(_ provider: CXProvider, perform action: CXAnswerCallAction){
         print("Bac's  perform action: CXAnswerCallAction")
         joinRTCChannel(channelName: "\(mainChannel)_\(localRtcUID)_\(remoteRtcUID)")
         
         do {
             let audioSession = AVAudioSession.sharedInstance()
             
             try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: []) // Use appropriate category and mode
             
             try audioSession.setActive(true)
         } catch {
             // Handle audio session configuration error
         }
         action.fulfill()
    }

     func provider(_ provider: CXProvider, perform action: CXEndCallAction){
         print("Bac's  perform action: CXEndCallAction")
         currentCallState = .ended
         leaveRTCChannel()
         action.fulfill()
    }

     func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction){
         print("Bac's  perform action: CXSetHeldCallAction")
         action.fulfill()
    }

     func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
         print("Bac's  perform action: CXSetMutedCallAction")
         action.fulfill()
    }

     func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction){
         print("Bac's  perform action: CXSetGroupCallAction")
         action.fulfill()
    }

     func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction){
         print("Bac's  perform action: CXPlayDTMFCallAction")
         action.fulfill()
    }

    /// Called when an action was not performed in time and has been inherently failed. Depending on the action, this timeout may also force the call to end. An action that has already timed out should not be fulfilled or failed by the provider delegate
     func provider(_ provider: CXProvider, timedOutPerforming action: CXAction){
         print("Bac's  perform action: timedOutPerforming")
         action.fulfill()
    }

    /// Called when the provider's audio session activation state changes.
     func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession){
         print("Bac's  perform didActivate: audioSession")
    }

     func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession)
    {
        print("Bac's  perform didDeactivate: audioSession")
    }
}
