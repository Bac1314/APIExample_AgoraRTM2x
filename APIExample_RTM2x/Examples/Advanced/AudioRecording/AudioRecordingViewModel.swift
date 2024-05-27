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
    
    let channelTypeImage = "imageType"
    
    // Audio Recording Variables
    //    @Published var listOfRecordingMessages : [AudioMessage] = []
    //    @Published var currentAudioFile = AudioMessage(fileName: "recording.m4a", sender: "")
    @Published var isRecording = false
    @Published var audioFiles : [String] = []
    var audioRecorder: AVAudioRecorder!
//    var player: AVPlayer?
    var audioPlayer: AVAudioPlayer!

    
    
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
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.channelType = .message
        if let (_, error) = await agoraRtmKit?.publish(channelName: channelName, data: audioData, option: pubOptions){
            if error == nil {
                return true
            }else{
                return false
            }
            
        }
        return false
    }
    
    
    func toggleRecording() {
        if !isRecording {
            // Start recording
            //            let audioFilename = getDocumentsDirectory().appendingPathComponent("\(userID)_\(Date().formatted(date: .abbreviated, time: .shortened))_recording.m4a")
            let audioFilename = getDocumentsDirectory().appendingPathComponent("\(userID)_\(Date().timeIntervalSince1970)_recording.m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
            ]
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
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
        }
    }
    
    func listAllAudioFiles() {
        let documentsURL = getDocumentsDirectory()
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            let tempAudioFiles = fileURLs.filter({ $0.pathExtension == "m4a" })
            
            audioFiles.removeAll()
            
            for audioFile in tempAudioFiles {
                audioFiles.append(audioFile.lastPathComponent)
                print("Bac's audio file absolute \(audioFile.absoluteString)")
                print("Bac's audio file relative \(audioFile.relativePath)")
                print("Bac's audio file url lastPath \(audioFile.lastPathComponent)")
            }
            print(audioFiles)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func convertAudioToData(fileName: String) -> Data? {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let audioData = try Data(contentsOf: audioFilename)
            return audioData
        } catch {
            print("Failed to get data from audio file")
        }
        return nil
    }
    
    func convertDataToAudio(data: Data) -> AVAudioFile? {
        do {
            let tempPath = FileManager.default.temporaryDirectory
            let tempFileURL = tempPath.appendingPathComponent("recording.m4a")
            
            try data.write(to: tempFileURL)
            
            let audioFile = try AVAudioFile(forReading: tempFileURL)
            return audioFile
        } catch {
            print("Failed to convert data to audio: \(error)")
        }
        return nil
    }
    
    func deleteAudioFile(fileName: String) {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
                print("File \(fileName) was deleted.")
                audioFiles.removeAll(where: {$0.contains(fileName)})
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
            
            audioFiles.removeAll()
        } catch {
            print("An error occurred while deleting files: \(error)")
        }
    }
    
    
    func playAudio(audioFileName: String) {
        
        let documentsURL = getDocumentsDirectory()
        let fileURL = documentsURL.appendingPathComponent(audioFileName)
        
        print("Play audio \(fileURL)")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("Failed to play audio file \(audioFileName): \(error)")
        }
    }
    
}

extension AudioRecordingViewModel: AgoraRtmClientDelegate {
    
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

