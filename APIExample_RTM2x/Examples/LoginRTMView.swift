//
//  LoginAgoraRTMView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/21.
//

import SwiftUI


struct LoginRTMView: View {
    @Binding var isLoading: Bool
    @Binding var userID: String
    @Binding var token: String
    @Binding var channelName: String
    @Binding var isLoggedIn: Bool
    var icon: String = "message"
    
    var isStreamChannel: Bool = false
    @Binding var streamToken: String
    
    // Rotating logo
    @State var degreesRotating = 0.0
    
    var onButtonTap: (() -> Void)?
    
    var body: some View {
            ZStack {
                // MARK: LOGIN RTM VIEW
                VStack {
                    
                    Spacer()
                    Image(systemName: icon)
                        .frame(width: 80, height: 80)
                        .aspectRatio(1.0, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .font(.system(size: 60))
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.accentColor.opacity(0.5), Color.accentColor, Color.accentColor.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            //                                .rotationEffect(.degrees(degreesRotating))
                        )
                        .foregroundStyle(Color.white.gradient)
                        .cornerRadius(24)
                        .shadow(radius: 5)
                    //                        .rotationEffect(.degrees(degreesRotating))
                    //                        .onAppear {
                    //                            withAnimation(.linear(duration: 1)
                    //                                .speed(0.1).repeatForever(autoreverses: false)) {
                    //                                    degreesRotating = 360.0
                    //                                }
                    //                        }
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 6){
                        Text("USERNAME")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        
                        TextField("", text: $userID)
                            .textFieldStyle(.plain)
                            .font(.headline)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.gray, lineWidth: 1.0)
                                
                            )
                    }
                    .padding(.bottom, 8)
                    
                    VStack(alignment: .leading, spacing: 6){
                        Text("TOKEN")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        
                        TextField("", text: $token)
                            .textFieldStyle(.plain)
                            .font(.headline)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.gray, lineWidth: 1.0)
                            )
                    }
                    .padding(.bottom, 8)
                    
                    
                    VStack(alignment: .leading, spacing: 6){
                        Text("CHANNEL NAME")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        
                        TextField("", text: $channelName)
                            .textFieldStyle(.plain)
                            .font(.headline)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.gray, lineWidth: 1.0)
                            )
                    }
                    .padding(.bottom, 8)
                    
                    
                    if isStreamChannel {
                        VStack(alignment: .leading, spacing: 6){
                            Text("RTC TOKEN")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            
                            TextField("Stream channel requires RTC token (must)", text: $streamToken)
                                .textFieldStyle(.plain)
                                .font(.headline)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.gray, lineWidth: 1.0)
                                )
                        }
                        .padding(.bottom, 8)
                        
                        
                    }
                    
                    
                    Spacer()
                    
                    
                    Text("LOGIN")
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.white)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .disabled(userID.isEmpty || channelName.isEmpty)
                        .onTapGesture {
                            isLoading = true
                            self.onButtonTap?()
                        }
                    
                    HStack {
                        Text(isStreamChannel ? "" : "Note: Leave token input empty if app certificate is NOT enabled")
                            .font(.footnote)
                            .foregroundStyle(.gray.opacity(0.7))
                        Spacer()
                    }
                    .padding(.top, 8)
                    
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
//                    })
//                }
//            })
        }
}

#Preview {
    LoginRTMView(isLoading: .constant(true), userID: .constant("Bac"), token: .constant(""), channelName: .constant("ChannelA"), isLoggedIn: .constant(false), icon: "person.2", streamToken: .constant(""))
    
}



