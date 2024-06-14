//
//  VideoCallInviteView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/6/14.
//

import SwiftUI
import AgoraRtmKit

struct VideoCallInviteView: View {
    @StateObject var agoraRTMVM: VideoCallInviteViewModel = VideoCallInviteViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    @FocusState private var keyboardIsFocused: Bool
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "phone.bubble"
    
    // First channelName
    @State var channelName: String = "ChannelA"
    
    // show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    @State var presentAlertSubscribe = false
    @State var newChannelName = ""
    
    
    
    
    var body: some View {
        ZStack {
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, channelName: $channelName, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon, streamToken: .constant("")) {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
                            _ = await agoraRTMVM.subscribeChannel(channelName: channelName)
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
            
            // MARK: Display list of subscribed channels
            if agoraRTMVM.isLoggedIn {
                VStack {
                    Text("\(agoraRTMVM.users) online")
                    
                    // List of users
                    List {
                        ForEach(agoraRTMVM.users, id: \.userId) { user in
                            Text("\(user.userId)")
                        }
                    }
                    
                    // On tap 
                }
                
            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Online Users" : "Login")
        .toolbar{

            // Back button
            ToolbarItem(placement: .topBarLeading) {
                Button(action : {
                    agoraRTMVM.logoutRTM()
                    self.mode.wrappedValue.dismiss()
                }){
                    HStack{
                        Image(systemName: "arrow.left")
                        Text(agoraRTMVM.isLoggedIn ? "Logout" : "Back")
                    }
                }
            }
        }
    }
}

#Preview {
    VideoCallInviteView()
}
