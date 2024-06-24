//
//  CallingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/6/21.
//

import SwiftUI
import Foundation

enum CallState {
    case none
    case calling
    case incoming
    case incall
    case ended
}

struct CallingView: View {
    var caller: String = "caller"
    var callee: String = "callee"
    @StateObject var agoraVM: VideoCallInviteViewModel = VideoCallInviteViewModel()
    @State var agoraRemoteUIView : AgoraRemoteUIView?
    @State var agoraLocalUIView : AgoraLocalUIView?
    
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: UI Views to display local and remote users
            if agoraVM.currentCallState == .calling {
                agoraLocalUIView
                    .ignoresSafeArea(.all)
                
            }else if agoraVM.currentCallState == .incall {
                agoraRemoteUIView
                    .ignoresSafeArea(.all)
                
                HStack {
                    Spacer()
                    agoraLocalUIView
                        .frame(width: 300, height: 300)
                }
                .padding()
            }
            
            
            
            // MARK: Stream Controls
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        // Flip Camera
                        agoraVM.switchCamera()
                    }, label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    })
                    
                    Button(action: {
                        // Camera
                        agoraVM.toggleCamera()
                    }, label: {
                        Image(systemName: agoraVM.enableCamera ? "video.slash" : "video.fill")
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    })
                    
                    Button(action: {
                        // Mic
                        agoraVM.toggleMic()
                    }, label: {
                        Image(systemName:  agoraVM.enableMic ? "mic.slash" : "mic.fill")
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    })
                    
                    
                    
                    Button(action: {
                        // End call
                        agoraVM.leaveRTCChannel()
                    }, label: {
                        Image(systemName: "phone.arrow.up.right")
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .padding(12)
                            .background(Color.red)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    })
                    
                }
                .font(.title2)
                .padding(10)
                .background(Color.black.opacity(0.5).blur(radius: 12))
                .cornerRadius(15)
            }
        }
        .task {
            // When first appeared, do something
            await agoraVM.callUser(userID: callee)
            agoraVM.joinRTCChannel(channelName: "\(agoraVM.mainChannel)_\(caller)_\(callee)")
            agoraVM.currentCallState = .calling
            agoraLocalUIView = AgoraLocalUIView()
        }
    }
}

#Preview {
    CallingView()
}
