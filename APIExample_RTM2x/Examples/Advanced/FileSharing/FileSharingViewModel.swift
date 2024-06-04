//
//  FileSharingViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/29.
//

import Foundation
import SwiftUI
import AgoraRtmKit

class FileSharingViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    @Published var mainChannel = "ChannelA" // to publish and receive poll questions/answers
    
    @Published var fileInfos : [FileInfo] = []
    @Published var fileChunks : [UUID: [Data]] = [:]
    
    var fileInfoKey = "fileIntoKey"
    var fileChunkKey = "fileChunkKey"
    
    @Published var testingData : Data?
    
    //MARK: AGORA RELATED METHODS
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
        // delete all files
        deleteAllFiles()
        
        agoraRtmKit?.logout()
        agoraRtmKit?.destroy()
        isLoggedIn = false
        
    }
    
    // Subscribe to channel in 'MessageChannel'
    @MainActor
    func subscribeChannel(channelName: String) async -> Bool {
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
    func publishToChannel(channelName: String, fileURL: URL) async -> Bool{
        
        if let fileData = convertFileToData(fileURL: fileURL), !fileURL.pathExtension.isEmpty {
            // Split the file into 32KB chunks
            let dataChunks = splitDataIntoChunks(data: fileData)
            
            // PART 1 :  First send the file info to receivers to let them know there is an incoming  file with filesize dataChunks.count
            let pubOptions = AgoraRtmPublishOptions()
            pubOptions.channelType = .message
            pubOptions.customType = fileInfoKey
            
            let fileInfo = FileInfo(id: UUID(), name: fileURL.lastPathComponent, countOf32KB: dataChunks.count, type: fileURL.pathExtension, url: "", owner: userID)
            
            if let JSONString = convertObjectToJsonString(object: fileInfo) {
                if let (_, error) = await agoraRtmKit?.publish(channelName: channelName, message: JSONString, option: pubOptions){
                    if error == nil {
                      // Add local record
                        fileInfos.append(fileInfo)
                        fileChunks[fileInfo.id] = []
                    }else{
                        print("publishToChannel fileInfoKey failed")
                        return false
                    }
                }
            }
    
            
            // PART 2 : Send the chunk files one by one
            let pubOptions2 = AgoraRtmPublishOptions()
            pubOptions2.channelType = .message
            pubOptions2.customType = fileChunkKey
    
            // Publish each chunk one-by-one
            for dataChunk in dataChunks {
                if let (_, error) = await agoraRtmKit?.publish(channelName: channelName, data: dataChunk, option: pubOptions2){
                    if error == nil {
                        // Append to local record
                        if let index = fileInfos.firstIndex(where: {$0.id == fileInfo.id}), fileChunks.keys.contains(fileInfos[index].id){
                            fileChunks[fileInfos[index].id]?.append(dataChunk)
                            
                            if fileChunks[fileInfos[index].id]?.count == fileInfos[index].countOf32KB {
                                let mergeData = combineDataChunks(chunks: fileChunks[fileInfos[index].id]!)
                                
                                Task {
                                    await MainActor.run {
                                        testingData = mergeData
                                    }
                                }
                                
                                let url = convertSaveDataToFile(data: mergeData, fileName: fileInfos[index].name, fileType: fileInfos[index].type, sender: fileInfos[index].owner)

//                                fileChunks.removeValue(forKey: fileInfos[index].id)
                                fileInfos[index].url = url?.absoluteString ?? ""
                            }
                        }
                        
                    }else{
                        print("publishToChannel fileChunkKey failed \(String(describing: error))")
                    }
                }
            }
            
            return true
        }
        
        return false
    }
        
    // MARK: FUNCTION TO RETRIEVE THE ACTUAL FILES ON LOCAL DIRECTORY
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
        
    }
    
    // MARK: FILE AND DATA CONVERSION
    func convertFileToData(fileURL: URL) -> Data? {
//        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let fileData = try Data(contentsOf: fileURL)
            return fileData
        } catch {
            print("Failed to get data from file \(error)")
        }
        return nil
    }
    
    
    func convertSaveDataToFile(data: Data, fileName: String, fileType: String, sender: String) -> URL? {
        do {
            let tempFileURL = getDocumentsDirectory().appendingPathComponent("\(fileName)")
            
            try data.write(to: tempFileURL)
            
            return tempFileURL
        } catch {
            print("Failed to convert data to file: \(error)")
        }
        
        return nil
    }
    
    func splitDataIntoChunks(data: Data, chunkSize: Int = 32000) -> [Data] {
        var offset = 0
        var chunks = [Data]()
        
        while offset < data.count {
            let length = min(chunkSize, data.count - offset)
            let chunk = data.subdata(in: offset..<(offset+length))
            chunks.append(chunk)
            offset += length
        }
        return chunks
    }
    
    func combineDataChunks(chunks: [Data]) -> Data {
        var combinedData = Data()
        for chunk in chunks {
            combinedData.append(chunk)
        }
        return combinedData
    }
    
    
    func deleteAllFiles() {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
//            let audioFileURLs = fileURLs.filter({ $0.pathExtension == "m4a" })
            
            for file in fileURLs {
                try fileManager.removeItem(at: file)
                print("File \(file.lastPathComponent) was deleted.")
            }
            
        } catch {
            print("An error occurred while deleting files: \(error)")
        }
    }
}

extension FileSharingViewModel: AgoraRtmClientDelegate {
    
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        print("Bac's didReceiveMessageEvent msg = \(event.message.stringData ?? "Empty") from \(event.publisher) type \(String(describing: event.customType))")
        
        switch event.channelType {
        case .message:
            if event.customType == fileInfoKey {
                // Incoming file
                if let jsonString = event.message.stringData, let fileInfo = convertJsonStringToObject(jsonString: jsonString, objectType: FileInfo.self) {
                    print("Bac's didReceiveMessageEvent is \(jsonString)")
                    fileInfos.append(fileInfo)
                    fileChunks[fileInfo.id] = []
                }
                
            }else if event.customType == fileChunkKey {
                //  Data chunks from remote user
                
                if let index = fileInfos.firstIndex(where: {$0.id == fileInfos.last(where: {$0.owner == event.publisher})?.id}), fileChunks.keys.contains(fileInfos[index].id), let dataChunk = event.message.rawData {
                    fileChunks[fileInfos[index].id]?.append(dataChunk)
                    
                    if fileChunks[fileInfos[index].id]?.count == fileInfos[index].countOf32KB {
                        let mergeData = combineDataChunks(chunks: fileChunks[fileInfos[index].id]!)
                        let url = convertSaveDataToFile(data: mergeData, fileName: fileInfos[index].name, fileType: fileInfos[index].type, sender: fileInfos[index].owner)
                        print("Bac's saved to \(String(describing: url))")

//                        fileChunks.removeValue(forKey: fileInfos[index].id)
                        fileInfos[index].url = url?.absoluteString ?? ""
                        
                        Task {
                            await MainActor.run {
                                testingData = mergeData
                            }
                        }
                        
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
            
        }else if event.type == .remoteJoinChannel && event.publisher != nil {
            
            
        }else if event.type == .snapshot {
            
            
        }else if event.type == .remoteStateChanged {
            
        }
        
    }
    
    // Triggers when connection changes
    func rtmKit(_ kit: AgoraRtmClientKit, channel channelName: String, connectionChangedToState state: AgoraRtmClientConnectionState, reason: AgoraRtmClientConnectionChangeReason) {
        print("Bac's connectionChangedToState \(state) reason \(reason.rawValue)")
        connectionState = connectionState
    }
    
    
}

