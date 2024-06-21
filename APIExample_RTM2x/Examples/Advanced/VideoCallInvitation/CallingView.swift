//
//  CallingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/6/21.
//

import SwiftUI
import Foundation

enum CallState {
    case incoming
    case incall
    case ended
}

struct CallingView: View {
    var caller: String = "Bac"
    var callee: String = "Brandon"
    @Binding var currentCallState: CallState
    @State var agoraRemoteUIView = AgoraUIView()
    @State var agoraLocalUIView = AgoraUIView()
    @State var enableCamera: Bool = false
    @State var enableMic: Bool = false

    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Incoming call
            if currentCallState == .incoming {
                Image(systemName: "person")
                    .font(.largeTitle)
                    .padding(24)
                    .foregroundStyle(Color.white)
                    .background(Color.blue.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
            }else if currentCallState == .incall {
                agoraRemoteUIView
                    .ignoresSafeArea(.all)
                
                HStack {
                    Spacer()
                    agoraLocalUIView
                        .frame(width: 300, height: 300)
                }
                .padding()
                
                // MARK: Stream Controls
                HStack {
                    
                    Button(action: {
                        // Flip Camera
                    }, label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .foregroundStyle(.white)
                            .imageScale(.large)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    })
                    
                    Button(action: {
                        // Camera
                    }, label: {
                        Image(systemName: enableCamera ? "video.slash" : "video.fill")
                            .foregroundStyle(.white)
                            .imageScale(.large)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    })
                    
                    Button(action: {
                        // Mic
                    }, label: {
                        Image(systemName:  enableMic ? "mic.slash" : "mic.fill")
                            .foregroundStyle(.white)
                            .imageScale(.large)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    })

                    

                    Button(action: {
                        // End call
                    }, label: {
                        Image(systemName: "phone.arrow.up.right")
                            .foregroundStyle(.white)
                            .imageScale(.large)
                            .padding(12)
                            .background(Color.red)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    })
                    
                }
                .font(.title2)
                .padding(10)
                .background(Color.gray.blur(radius: 12))
                .cornerRadius(15)
            }

        }
    }
}

#Preview {
    CallingView(currentCallState: .constant(.incall))
}
