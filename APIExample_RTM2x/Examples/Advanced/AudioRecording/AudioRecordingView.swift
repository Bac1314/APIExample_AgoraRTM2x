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
    @State var isLoading: Bool = false
    var serviceIcon: String = "waveform"

    // Show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack(alignment: .center){
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, channelName: $agoraRTMVM.mainChannel, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon, isStreamChannel: false, streamToken: .constant((""))) {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
                            let _ = await agoraRTMVM.subscribeChannel(channelName: agoraRTMVM.mainChannel)
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
                    ForEach(agoraRTMVM.audioMessageInfo) { audioFile in
                        AudioItemView(audioMessage: audioFile, currentUser: agoraRTMVM.userID)
                            .onTapGesture {
                                agoraRTMVM.playAudio(fileURL: audioFile.fileURL)
                            }

                    }
                    
                    Spacer()

                    Text("Tap once to record, tap again to stop")
                        .font(.subheadline)
                    
                    
                    Button(action: {
                        agoraRTMVM.toggleRecording()
                    }, label: {
                        Image(systemName: "waveform")
                            .symbolEffect(.bounce, options: .speed(3).repeat(agoraRTMVM.isRecording ? 60 : 0), value: agoraRTMVM.isRecording)
                            .font(.title)
                            .foregroundStyle(Color.white)
                            .padding()
                            .background(
                                agoraRTMVM.isRecording ?
                                LinearGradient(colors: [Color.green.opacity(0.5), Color.green, Color.green.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color.accentColor.opacity(0.5), Color.accentColor, Color.accentColor.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) 
                            )
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)

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
                    if path.count > 0 {
                        path.removeLast()
                    }
                }){
                    HStack{
                        Image(systemName: "arrow.left")
                        Text(agoraRTMVM.isLoggedIn ? "Logout"  : "Back")
                    }
                }
            }
            
//            ToolbarItem(placement: .topBarTrailing) {
//                Button(action: {
//                    agoraRTMVM.deleteAllAudioFiles()
//                }, label: {
//                    Text("Delete all files")
//                        .padding()
//                })
//                
//            }

            
        }
    }
}

#Preview {
    AudioRecordingView(path: .constant(NavigationPath()))
}
