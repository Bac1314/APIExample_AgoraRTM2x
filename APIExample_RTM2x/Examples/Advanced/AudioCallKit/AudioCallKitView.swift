//
//  AudioCallKitView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/7/5.
//

import SwiftUI
import AgoraRtmKit

struct AudioCallKitView: View {
    @StateObject var agoraVM: AudioCallKitViewModel = AudioCallKitViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    @FocusState private var keyboardIsFocused: Bool
    @State var isLoading: Bool = false
    @State var path = NavigationPath()

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
                    Text("\(agoraVM.users.count > 0 ? agoraVM.users.count-1 : 0) online")
                    
                    // List of users
                    List {
                        ForEach(agoraVM.users.filter({$0.userId != agoraVM.userID}), id: \.userId) { user in
                            Text("Call \(user.userId)")
                                .onTapGesture {
                                    Task {
                                        await agoraVM.callUser(userID:user.userId)
                                    }
                                }
                            
                        }
                    }
                    .listStyle(.plain)
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
                    agoraVM.logoutAll()
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
    AudioCallKitView()
}
