//
//  AudioRecordingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/24.
//

import SwiftUI
import AgoraRtmKit
import AVFoundation

struct AudioRecordingView: View {
    // Agora RTM
    @StateObject var agoraRTMVM: AudioRecordingViewModel = AudioRecordingViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    @State var isLoading: Bool = false
    var serviceIcon: String = "waveform"

    // Show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    
    // To Play audio files
//    @State private var player: AVPlayer?

    
    var body: some View {
        ZStack(alignment: .center){
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, channelName: $agoraRTMVM.mainChannel, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon, isStreamChannel: false, streamToken: .constant((""))) {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
                        }catch {
                            if let agoraError = error as? AgoraRtmErrorInfo {
                                alertMessage = "\(agoraError.code) : \(agoraError.reason)"
                            }else{
                                alertMessage = error.localizedDescription
                            }
                            withAnimation {
                                isLoading = false
                                showAlert.toggle()
                            }
                        }
                    }
                }
            }
            
            // MARK: Main View
            if agoraRTMVM.isLoggedIn {
                
                VStack {
                    Button(action: {
                        agoraRTMVM.listAllAudioFiles()
                    }, label: {
                        Text("List files")
                            .padding()
                    })
                    
                    
                    Button(action: {
                        agoraRTMVM.deleteAllAudioFiles()
                    }, label: {
                        Text("Delete All Files")
                            .padding()
                    })
                    
                    ForEach(agoraRTMVM.audioFiles, id: \.self) { audioFile in
                        Text(audioFile)
                            .onTapGesture {
                                agoraRTMVM.playAudio(audioFileName: audioFile)
                            }
                    }
                    
                    Spacer()

                    Button(action: {
                        agoraRTMVM.toggleRecording()
                    }, label: {
                        Image(systemName: "waveform")
                            .symbolEffect(.bounce, options: .speed(3).repeat(agoraRTMVM.isRecording ? 60 : 0), value: agoraRTMVM.isRecording)
                            .font(.title)

                    })
                    
                    
                }

            
            }
            
            
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "AudioRecordingView" : "Login")
        .toolbar{
            // Back button
            ToolbarItem(placement: .topBarLeading) {
                Button(action : {
                    agoraRTMVM.logoutRTM()
                    self.mode.wrappedValue.dismiss()
                }){
                    HStack{
                        Image(systemName: "arrow.left")
                        Text(agoraRTMVM.isLoggedIn ? "Logout"  : "Back")
                    }
                }
            }

            
        }
    }
    
//    
//    func playAudio(audioFileName: String) {
//        guard let fileURL = Bundle.main.url(forResource: audioFileName, withExtension: "m4a") else {
//            return
//        }
//        
//        let playerItem = AVPlayerItem(url: fileURL)
//        player = AVPlayer(playerItem: playerItem)
//        player?.play()
//    }
//    
//    func pauseAudio(){
//        player?.pause()
//    }
//    
//    func resumeAudio() {
//        player?.play()
//    }
//    
//    func stopAudio() {
//        player = nil
//    }
}

#Preview {
    AudioRecordingView()
}
