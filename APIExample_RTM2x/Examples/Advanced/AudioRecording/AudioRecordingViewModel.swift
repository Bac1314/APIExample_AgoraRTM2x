//
//  AudioRecordingViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/24.
//

import Foundation
import SwiftUI
import AgoraRtmKit
import AVFoundation

class AudioRecordingViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    @Published var mainChannel = "ChannelA" // to publish and receive poll questions/answers
    
    // Audio Recording Variables
    @Published var isRecording = false
    @Published var audioMessageInfo : [AudioMessage] = []
    @Published var currentRecordinFileName : String = ""
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFileInfoType = "audioFileInfoType"
    var audioChunkType = "audioChunkType"
    var audioChunksReceived : [tempAudioChunks] = []
    
    //MARK: AGORA RELATED METHODS
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
        // delete all recording files
        deleteAllAudioFiles()

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
    func publishToChannel(channelName: String, audioData: Data) async -> Bool{
        // Split the audio into 32KB chunks
        let dataChunks = splitDataIntoChunks(data: audioData)
        
        // PART 1 :  First send the audio file info to receivers to let them know there is an incoming audio file with filesize dataChunks.count
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.channelType = .message
        pubOptions.customType = audioFileInfoType
        
        if let (_, error) = await agoraRtmKit?.publish(channelName: channelName, message: "\(dataChunks.count)", option: pubOptions){
            if error == nil {
                
            }else{
                print("publishToChannel audioFileInfoType failed ")
                return false
            }
        }
        
        
        // PART 2: Then send each datachunk to the remote users
        let pubOptions2 = AgoraRtmPublishOptions()
        pubOptions2.channelType = .message
        pubOptions2.customType = audioChunkType
        
        // Publish each chunk one-by-one
        for dataChunk in dataChunks {
            if let (_, error) = await agoraRtmKit?.publish(channelName: channelName, data: dataChunk, option: pubOptions2){
                if error == nil {
                    
                }else{
                    print("publishToChannel audioChunkType failed \(String(describing: error))")
                }
            }
        }
        

        return false
    }
    
    
    // MARK: MEDIA CONTROL FUNCTIONS
    @MainActor
    func toggleRecording() {
        if !isRecording {
            // Start recording
            let recordingURL = getDocumentsDirectory().appendingPathComponent("\(userID)_\(Date().timeIntervalSince1970)_recording.m4a")
            currentRecordinFileName = recordingURL.lastPathComponent
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
            ]

            do {
                try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)

                audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
                audioRecorder.record()
                isRecording = true
            } catch {
                print("Recording failed")
            }
        } else {
            // Stop recording
            audioRecorder.stop()
            audioRecorder = nil
            isRecording = false
            
//            listAllAudioFiles()
            
            Task {
                if let audioData = convertAudioToData(fileName: currentRecordinFileName)  {
                    
                    let fileURL = getDocumentsDirectory().appendingPathComponent(currentRecordinFileName)
                    
                    let audioPlayer = try? AVAudioPlayer(contentsOf: fileURL)
                    let duration : Int = Int(audioPlayer?.duration ?? 0)
                    
                    // Add a local record
                    audioMessageInfo.append(AudioMessage(id: UUID(), fileName: currentRecordinFileName, fileURL: fileURL, sender: userID, duration: duration))
                    
                    // Send to remote users
                    currentRecordinFileName = ""
                   let _ = await publishToChannel(channelName: mainChannel, audioData: audioData)
                }else {
                    print("Bac's failed to convert audio to data")
                }
            }
        }
    }

    func playAudio(fileURL: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("Failed to play audio file \(fileURL): \(error)")
        }
    }
    
    func pauseAudio(){
        audioPlayer?.pause()
    }

    func resumeAudio() {
        audioPlayer?.play()
    }
    
    
    // MARK: FUNCTION TO RETRIEVE THE ACTUAL RECORDING FILES ON LOCAL DIRECTORY
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
        
    }
    
//    func listAllAudioFiles() {
//        let documentsURL = getDocumentsDirectory()
//        
//        do {
//            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
//            
//            let tempAudioFiles = fileURLs.filter({ $0.pathExtension == "m4a" })
//            
//            audioMessageInfo.removeAll()
//            for audioFileURL in tempAudioFiles {
//                do {
//                    let audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
//                    let duration = audioPlayer.duration
//                    
//                    let audioMessage = AudioMessage(id: UUID(), fileName: audioFileURL.lastPathComponent, fileURL: audioFileURL.absoluteURL, sender: userID, duration: Int(duration)) // Fix sender later with local document/database. right now all files will have sender as owner
//                    audioMessageInfo.append(audioMessage)
//                } catch {
//                    print("Error initializing audio player: \(error)")
//                }
//            }
//        } catch {
//            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
//        }
//    }
    
    
    func deleteAudioFile(fileName: String) {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
                print("File \(fileName) was deleted.")
                audioMessageInfo.removeAll(where: {$0.fileName == fileName})
            } else {
                print("File \(fileName) does not exist.")
            }
        } catch {
            print("An error occurred while deleting file \(fileName): \(error)")
        }
    }
    
    func deleteAllAudioFiles() {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            let audioFileURLs = fileURLs.filter({ $0.pathExtension == "m4a" })
            
            for audioFileURL in audioFileURLs {
                try fileManager.removeItem(at: audioFileURL)
                print("File \(audioFileURL.lastPathComponent) was deleted.")
            }
            
            audioMessageInfo.removeAll()
        } catch {
            print("An error occurred while deleting files: \(error)")
        }
    }

    
    // MARK: AUDIO AND DATA CONVERSION
    func convertAudioToData(fileName: String) -> Data? {
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let audioData = try Data(contentsOf: audioFileURL)
            return audioData
        } catch {
            print("Failed to get data from audio file")
        }
        return nil
    }
    
    
    func convertDataToAudio(data: Data, sender: String) -> URL? {
        do {
            let tempFileURL = getDocumentsDirectory().appendingPathComponent("\(sender)_\(Date().timeIntervalSince1970)_recording.m4a")
            
            try data.write(to: tempFileURL)
                
            return tempFileURL
        } catch {
            print("Failed to convert data to audio: \(error)")
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
    
    
    //    // MARK: LOCAL FILE FOR SAVING THE AUDIO FILE LOCATIONS/URLS
    //    func fileURLForAudioMessagesListFile() throws -> URL {
    //        try FileManager.default.url(for: .documentDirectory,
    //                                    in: .userDomainMask,
    //                                    appropriateFor: nil,
    //                                    create: false)
    //        .appendingPathComponent("audioMessagesList.data")
    //    }
    //
    //
    //    func loadMessagesFromLocalStorage() async throws {
    //        let task = Task<[AudioMessage], Error> {
    //            let fileURL = try fileURLForAudioMessagesListFile()
    //            guard let data = try? Data(contentsOf: fileURL) else {
    //                return []
    //            }
    //            let customMessages = try JSONDecoder().decode([AudioMessage].self, from: data)
    //            return customMessages
    //        }
    //        let loadedAudioMessages = try await task.value
    //
    //        Task {
    //            await MainActor.run {
    //                self.audioMessageInfo = loadedAudioMessages
    //            }
    //        }
    //    }
    //
    //    func saveMessagesToLocalStorage(messages: [AudioMessage]) async throws {
    //        let task = Task {
    //            let data = try JSONEncoder().encode(audioMessageInfo)
    //            let outfile = try fileURLForAudioMessagesListFile()
    //            try data.write(to: outfile)
    //        }
    //        _ = try await task.value
    //    }
    
}

extension AudioRecordingViewModel: AgoraRtmClientDelegate {
    
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        print("Bac's didReceiveMessageEvent msg = \(event.message.stringData ?? "Empty") from \(event.publisher) type \(String(describing: event.customType))")
        
        switch event.channelType {
        case .message:
            if event.customType == audioFileInfoType {
                // Incoming audio file
                if let messageSize = Int(event.message.stringData ?? "0"), messageSize > 0 {
                    let tempAudioChunk = tempAudioChunks(sender: event.publisher, chunkLength: messageSize, chunks: [])
                    audioChunksReceived.append(tempAudioChunk)
                }
                
            }else if event.customType == audioChunkType {
                // Audio chunks from remote user
                if let index = audioChunksReceived.firstIndex(where: {$0.sender == event.publisher}), let audioChunk = event.message.rawData{
                    audioChunksReceived[index].chunks.append(audioChunk)
                    
                    if audioChunksReceived[index].chunks.count == audioChunksReceived[index].chunkLength {
                        let combineData = combineDataChunks(chunks: audioChunksReceived[index].chunks)
                        
                        if let convertedAudioFileURL = convertDataToAudio(data: combineData, sender: event.publisher) {
                            let audioPlayer = try? AVAudioPlayer(contentsOf: convertedAudioFileURL)
                            let duration : Int = Int(audioPlayer?.duration ?? 0)
                            
                            audioMessageInfo.append(AudioMessage(id: UUID(), fileName: convertedAudioFileURL.lastPathComponent, fileURL: convertedAudioFileURL, sender: event.publisher, duration: duration))
                            
                            audioChunksReceived.remove(at: index)
                        }else {
                            print("Bac's cannot convert data to audio, get URL failed")
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

