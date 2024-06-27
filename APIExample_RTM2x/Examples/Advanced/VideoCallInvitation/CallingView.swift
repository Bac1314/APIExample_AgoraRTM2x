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
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    
    @EnvironmentObject var agoraVM: VideoCallInviteViewModel
    @State var agoraRemoteUIView : AgoraRemoteUIView?
    @State var agoraLocalUIView : AgoraLocalUIView?
    @State var remoteViewLarge: Bool = true
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geo in
                // MARK: UI Views to display local and remote users
                agoraRemoteUIView
                    .opacity(agoraVM.currentCallState == .incall ? 1 : 0)
                    .disabled(agoraVM.currentCallState == .incall ? false : true)
                    .frame(width: agoraVM.currentCallState == .incall && !remoteViewLarge ? 150 : nil, height: agoraVM.currentCallState == .incall && !remoteViewLarge ? 150 : nil, alignment: .topTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: remoteViewLarge ? 0 : 2)
                    )
                    .ignoresSafeArea(.all)
                    .position(x: agoraVM.currentCallState == .incall && !remoteViewLarge ? geo.size.width-100 : geo.size.width/2, y: agoraVM.currentCallState == .incall && !remoteViewLarge ? 100 : geo.size.height/2)
                    .zIndex(remoteViewLarge ? 1 : 2 )
                    .onTapGesture {
                        if !remoteViewLarge {
                            withAnimation {
                                remoteViewLarge.toggle()
                            }
                        }
                    }
                    .overlay(alignment: .bottom) {
                        Text("")
                    }
                    
                
                agoraLocalUIView
                    .ignoresSafeArea(.all)
                    .frame(width: agoraVM.currentCallState == .incall && remoteViewLarge ? 150 : nil, height: agoraVM.currentCallState == .incall && remoteViewLarge ? 150 : nil, alignment: .topTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth:  remoteViewLarge ? 2 : 0)
                    )
                    .ignoresSafeArea(.all)
                    .position(x: agoraVM.currentCallState == .incall && remoteViewLarge ? geo.size.width-100 : geo.size.width/2, y: agoraVM.currentCallState == .incall && remoteViewLarge ? 100 : geo.size.height/2)
                    .zIndex(remoteViewLarge ? 2 : 1)
                    .onTapGesture {
                        if remoteViewLarge {
                            withAnimation {
                                remoteViewLarge.toggle()
                            }
                        }
                    }
            }
            
            // MARK: Stream Controls
            VStack(alignment: .center) {
                Spacer()
                HStack(alignment: .center) {
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
                        mode.wrappedValue.dismiss()
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
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // When first appeared, do something
            let _ = await agoraVM.callUser(userID: callee)
//            agoraVM.joinRTCChannel(channelName: "\(agoraVM.mainChannel)_\(caller)_\(callee)")
//            agoraVM.currentCallState = .calling
//            agoraLocalUIView = AgoraLocalUIView()
        }
        .onChange(of: agoraVM.remoteRtcUID) { oldValue, newValue in
            if newValue != 0 {
                // setup remote view when remote user joins
                agoraRemoteUIView = AgoraRemoteUIView()
            }
        }
    }
}

#Preview {
    CallingView()
}
