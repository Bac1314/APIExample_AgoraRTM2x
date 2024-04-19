//
//  LoginAgoraRTMView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/21.
//

import SwiftUI


struct LoginRTMView: View {
    //    @EnvironmentObject var agoraRTMVM: AgoraRTMViewModel
    @Binding var isLoading: Bool
    @Binding var userID: String
    @Binding var token: String
    @Binding var isLoggedIn: Bool
    var icon: String = "message"
    
    var isStreamChannel: Bool = false
    @Binding var streamToken: String
    
    // Rotating logo
    @State var degreesRotating = 0.0
    
    var onButtonTap: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: LOGIN RTM VIEW
                VStack {
                    Image(systemName: icon)
                        .frame(width: 80, height: 80)
                        .aspectRatio(1.0, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .font(.system(size: 60))
                        .padding()
                        .background(LinearGradient(colors: [Color.accentColor.opacity(0.5), Color.accentColor, Color.accentColor.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundStyle(Color.white.gradient)
                        .cornerRadius(24)
                        .shadow(radius: 5)
                        .padding(.vertical, 100)
//                        .rotationEffect(.degrees(degreesRotating))
//                        .onAppear {
//                            withAnimation(.linear(duration: 1)
//                                .speed(0.1).repeatForever(autoreverses: false)) {
//                                    degreesRotating = 360.0
//                                }

                    
                    Spacer()
                    
                    TextField("UserName", text: $userID)
                        .textFieldStyle(.roundedBorder)
                        .font(.headline)
                    
                    TextField("RTM Token", text: $token)
                        .textFieldStyle(.roundedBorder)
                        .font(.headline)
                
                    
                    if isStreamChannel {
                        TextField("RTC Token (for stream channel)", text: $streamToken)
                            .textFieldStyle(.roundedBorder)
                            .font(.headline)
                    }else {
                        HStack {
                            Text("Note: Leave token input empty if app certificate is NOT enabled")
                                .font(.footnote)
                                .foregroundStyle(.gray.opacity(0.7))
                            Spacer()
                        }
                        .padding(.top, 8)
                    }


                    
                    Button {
                        isLoading = true
                        self.onButtonTap?()
                    } label: {
                        Text("Login to Agora")
                    }
                    .padding()
                    .buttonStyle(.bordered)
                    .disabled(userID.isEmpty)
                    
                    
                    Spacer()
                }
                .padding()
                
                // MARK:
                
                // MARK: Loading Icon
                if isLoading {
                    ProgressView()
                        .scaleEffect(CGSize(width: 3.0, height: 3.0))
                }
            }
            .onChange(of: isLoggedIn) { oldValue, newValue in
                if newValue {
                    isLoading = false
                    
                }
            }
//            .toolbar(content: {
//                ToolbarItem(placement: .topBarTrailing){
//                    Button(action: {
//                        // TODO: REMOVE BEFORE PUBLISHING
//                        Task {
//                            isLoading = true
//                            token = try await Personalize().generateRTMToken(userID: userID)
//                            streamToken = isStreamChannel ? try await Personalize().generateRTCToken(channelName: "ChannelA") : ""
//                            isLoading = false
//                        }
//                        
//                    }, label: {
//                        Text("Internal Testing")
//                            .opacity(0.5)
//                    })
//                }
//            })
        }
    }
}

#Preview {
    LoginRTMView(isLoading: .constant(true), userID: .constant("Bac"), token: .constant("jaisodjioajsiodhio1h2312"), isLoggedIn: .constant(false), icon: "person.2", streamToken: .constant(""))
    
}



