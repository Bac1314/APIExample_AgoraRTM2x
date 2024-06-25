//
//  VideoCallInviteView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/6/14.
//

import SwiftUI
import AgoraRtmKit

struct VideoCallInviteView: View {
    @StateObject var agoraVM: VideoCallInviteViewModel = VideoCallInviteViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    @FocusState private var keyboardIsFocused: Bool
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "phone.bubble"
    
    // show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    @State var presentAlertSubscribe = false
    
    
    var body: some View {
        ZStack {
            // MARK: LOGIN VIEW
            if !agoraVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraVM.userID, token: $agoraVM.token, channelName: $agoraVM.mainChannel, isLoggedIn: $agoraVM.isLoggedIn, icon: serviceIcon, streamToken: .constant("")) {
                    Task {
                        do{
                            try await agoraVM.initRTMRTC()
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
            if agoraVM.isLoggedIn {
                VStack {
                    Text("\(agoraVM.users.count) online")
                    
                    // List of users
                    List {
                        ForEach(agoraVM.users.filter({$0.userId != agoraVM.userID}), id: \.userId) { user in
                            
                            NavigationLink(destination: CallingView(caller: agoraVM.userID, callee: user.userId).environmentObject(agoraVM)) {
                                VideoListItemView(userName: user.userId)
                            }
                        }
                    }
                    .listStyle(.plain)
                    
                }
                
            }
            
            // MARK: Show incoming call from remote users
            if agoraVM.currentCallState == .incoming {
                VStack{
                    HStack {
                        Image(systemName: "person")
                        Text("\(agoraVM.incomingUserID)")

                        // Decline call
                        Image(systemName: "phone.down.fill")
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .padding(12)
                            .background(Color.red)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .onTapGesture {
                                withAnimation {
                                    agoraVM.currentCallState = .none
                                }
                            }

                        
                        NavigationLink(destination: CallingView(caller: agoraVM.incomingUserID, callee: agoraVM.userID).environmentObject(agoraVM)) {
                            Image(systemName: "phone.arrow.up.right")
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                                .padding(12)
                                .background(Color.green)
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 8)
                    Spacer()
                }
          
            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraVM.isLoggedIn ? "Online Users" : "Login")
        .toolbar{
            // Back button
            ToolbarItem(placement: .topBarLeading) {
                Button(action : {
                    agoraVM.logoutRTM()
                    self.mode.wrappedValue.dismiss()
                }){
                    HStack{
                        Image(systemName: "arrow.left")
                        Text(agoraVM.isLoggedIn ? "Logout" : "Back")
                    }
                }
            }
        }
    }
}

#Preview {
    VideoCallInviteView()
}
