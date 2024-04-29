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
    
    
    @Published var mainChannel = "ChannelA" // to publish and receive poll questions/answers
    @Published var tokenRTC: String = ""
    var agoraStreamChannel: AgoraRtmStreamChannel? = nil

    // For Channel Channel, Key for new Drawing
    let NewDrawingType = "newDrawing"
    
    // For Stream Channel, Keys for update and deleting drawing
    let UpdateDrawingTopic = "UpdateDrawing"
    let DeleteDrawingTopic = "DeleteDrawing"
    let DeleteAllDrawingTopic = "DeleteAllDrawing"
    
    // For Storage, Keys for storing metadata
    let StorageDrawingKey = "storageDrawingKey"
    
    @Published var drawings: [Drawing] = [Drawing]()
    
//    // MARK: TESTING
//    @Published var fails: Int = 0
    
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
    
    // Subscribe to Message Channel to publish large data (> 1KB)
    func subscribeChannel() async -> Bool {
        let subOptions: AgoraRtmSubscribeOptions = AgoraRtmSubscribeOptions()
        subOptions.features =  [.message]
        
        if let (_, error) = await agoraRtmKit?.subscribe(channelName: mainChannel, option: subOptions){
            if error == nil {
                return true
            }
            return false
        }
        
        return false
    }
    
    // Publish New Drawing with Channel Message (bc new Drawing can be larger than 1KB)
    func publishNewDrawing(drawing: Drawing) async -> Bool{
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.customType = NewDrawingType
        pubOptions.channelType = .message

        if let newDrawingString = convertObjectToJsonString(object: drawing){
            if let (_, error) = await agoraRtmKit?.publish(channelName: mainChannel, message: newDrawingString, option: pubOptions) {
                if error == nil {
                    // Publish successful, save drawing to Agora Storage
                    
                    return true
                }else {
//                    fails += 1
                    return false
                }
            }
        }
        return false
    }

    // Publish new drawing points
    func publishDrawingUpdate(newPoint: DrawingPoint) async -> Bool{
        if let newDrawingPointString = convertObjectToJsonString(object: newPoint){
            if let (_, error) = await agoraStreamChannel?.publishTopicMessage(topic: UpdateDrawingTopic, message: newDrawingPointString, option: nil) {
                if error == nil {
                    // Publish successful
                    return true
                }else {
//                    fails += 1
                    print("Bac's publishToTopic failed topic \(UpdateDrawingTopic) error \(String(describing: error))")
                    return false
                }
            }
            
            return false
        }
        return false
    }

    
    // Publish delete single drawing
    func publishDeleteDrawing(drawingID: UUID) async -> Bool {
        if let (_, error) = await agoraStreamChannel?.publishTopicMessage(topic: DeleteDrawingTopic, message: drawingID.uuidString, option: nil) {
            if error == nil {
                // Publish successful
                let _ = await saveDrawingsToStorage() // Resave current savings to cloud
                return true
            }else {
                // Publish failed
//                fails += 1
               return false
            }
        }
        
        return false
    }
    
    // Publish delete ALL drawings
    @MainActor
    func publishDeleteAllDrawing() async -> Bool {
        if let (_, error) = await agoraStreamChannel?.publishTopicMessage(topic: DeleteAllDrawingTopic, message: "yes", option: nil) {
            if error == nil {
                print("Bac's publishDeleteDrawing Success")
                Task {
                    await MainActor.run {
                        drawings.removeAll()
                    }
                    let _ = await deleteAllDrawingsFromStorage() // Delete All drawings from storage
                }
                return true
            }else {
//                fails += 1

                print("Bac's publishDeleteDrawing failed topic \(DeleteDrawingTopic) error \(String(describing: error))")

               return false
            }
        }
        
        return false
    }
    
    // Pre-join some topics
    func preJoinSubTopics() async {
        for topic in [UpdateDrawingTopic, DeleteDrawingTopic, DeleteAllDrawingTopic] {
            // Join as publisher first, if success then subscribe
            let _ = await JoinAndSubTopic(topic: topic)
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
        let resultA = await joinOneTopic(topic: topic)
        let resultB = resultA ? await subscribeOneTopic(topic: topic) : false
        return resultB // only return true if join and sub is successful
    }
    
    // Resubscribe when a new user joins
    func reSubscribeNewUsers() async {
        // Set subscribing options
        let subscribeTopicOptions = AgoraRtmTopicOption()
        subscribeTopicOptions.users = users.map(\.userId) // get the list of usersID
        
        for topic in [UpdateDrawingTopic, DeleteDrawingTopic, DeleteAllDrawingTopic]  {
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
                // Publish successful
            }else {
                print("Bac's publishToTopic failed topic \(topic) message \(message) error \(String(describing: error))")
                return false
            }
        }
        
        return false
    }
    
    // Storage Methods
    func saveDrawingsToStorage() async -> Bool {
        guard let metaData: AgoraRtmMetadata = agoraRtmKit?.getStorage()?.createMetadata() else { return false }
        guard let drawingsString = convertObjectToJsonString(object: drawings) else {
            print("Bac's saveDrawingsToStorage failed to convertObjectoString")
            return false}
        
        print("Bac's saveDrawingsToStorage success \(drawingsString)")

        let metaDataItem: AgoraRtmMetadataItem = AgoraRtmMetadataItem()
        metaDataItem.key = StorageDrawingKey
        metaDataItem.value = drawingsString
        metaData.setMetadataItem(metaDataItem)
        
        if let (_, error) = await agoraRtmKit?.getStorage()?.setChannelMetadata(channelName: mainChannel, channelType: .message, data: metaData, options: AgoraRtmMetadataOptions(), lock: nil) {
            if error == nil {
                print("Bac's saveDrawingsToStorage saving success")

                return true
            }else {
//                fails += 1
                print("Bac's saveDrawingsToStorage saving failed")

                return false
            }
        }
        
        return false
    }
    
    func getDrawingsFromStorage() async -> Bool {
        if let (response, error) = await agoraRtmKit?.getStorage()?.getChannelMetadata(channelName: mainChannel, channelType: .message) {
            if error == nil {
                // Get Successful, do here
                print("Bac's getDrawingsFromStorage success error")

                guard let drawingsString = response?.data?.getItems().first(where: {$0.key == StorageDrawingKey})?.value else {return false}
                
                print("Bac's getDrawingsFromStorage drawingsString \(drawingsString)")

                
                let newDrawings = convertJsonStringToObject(jsonString: drawingsString, objectType: [Drawing].self) ?? []
                Task {
                    await MainActor.run {
                        drawings = newDrawings
                    }
                }
                return true
            }else {
                print("Bac's getDrawingsFromStorage failed error \(String(describing: error))")
                return false
            }
        }
        
                
        return false
    }
    
    func deleteAllDrawingsFromStorage() async -> Bool {
        guard let metaData: AgoraRtmMetadata = agoraRtmKit?.getStorage()?.createMetadata() else { return false }

        if let (_, error) = await agoraRtmKit?.getStorage()?.removeChannelMetadata(channelName: mainChannel, channelType: .message, data: metaData, options: nil, lock: nil) {
            if error == nil {
                // Delete Successful
                return true
            }else {
                // Delete failed
                return false
            }
        }
        
        return false
    }
    

}

extension WhiteBoardViewModel: AgoraRtmClientDelegate {
    
    
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
//        print("Bac's didReceiveMessageEvent msg = \(event.message.stringData ?? "Empty") from \(event.publisher) Topic \(String(describing: event.channelTopic))")
        
        switch event.channelType {
        case .message:
            print("Bac's didReceiveMessageEvent new drawing \(event.message.stringData ?? "Empty")")

            if event.customType == NewDrawingType {
                // Received new drawing,
                if let jsonString = event.message.stringData, let newDrawing = convertJsonStringToObject(jsonString: jsonString, objectType: Drawing.self) {
                    print("Bac's didReceiveMessageEvent new drawing is \(jsonString)")
                    drawings.append(newDrawing)
                }
            }
            break
        case .stream:
            switch event.channelTopic {
    
            case UpdateDrawingTopic:
                if let jsonString = event.message.stringData, let newDrawingPoint = convertJsonStringToObject(jsonString: jsonString, objectType: DrawingPoint.self) {
                    print("Bac's didReceiveMessageEvent new drawing point is \(jsonString)")
                    if let index = drawings.firstIndex(where: {$0.id == newDrawingPoint.id}) {
                        print("Bac's didReceiveMessageEvent UID FOUND")

                        drawings[index].points.append(newDrawingPoint.point)
                    }else {
                        print("Bac's didReceiveMessageEvent UID NOT FOUND")
                    }
                }
                break
            case DeleteDrawingTopic:
                print("Bac's code DeleteDrawingTopic \(event.message.stringData ?? "")")
                if let convertedUUID = UUID(uuidString: event.message.stringData ?? "") {
                    if let index = drawings.firstIndex(where: {$0.id == convertedUUID}) {
                        print("Bac's code DeleteDrawingTopic reached inside")
                        drawings.remove(at: index)
                    }
                }
                break
                
            case DeleteAllDrawingTopic:
                Task {
                    await MainActor.run {
                        drawings.removeAll()
                    }
                }
                break;
            default:
                break
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
            
            // Add user to list if it doesn't exist
            if !users.contains(where: {$0.userId == event.publisher}) && event.publisher != nil {
                let userState = AgoraRtmUserState()
                userState.userId = event.publisher!
                userState.states = event.states
                users.append(userState)
            }
            
            // StreamChannel - Resubscribe for new users
            Task {
                await reSubscribeNewUsers()
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

