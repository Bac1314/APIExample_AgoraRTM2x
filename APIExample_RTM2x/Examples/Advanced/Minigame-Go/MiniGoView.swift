//
//  MiniGoView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/15.
//

import SwiftUI
import AgoraRtmKit

struct MiniGoView: View {
    @StateObject var agoraRTMVM: MiniGoViewModel = MiniGoViewModel()
    @FocusState private var keyboardIsFocused: Bool
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "gamecontroller"
    @Binding var path: NavigationPath
    
    
    // Show Alert alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, channelName: $agoraRTMVM.mainChannel, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon, streamToken: .constant("")) {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
                            _ = await agoraRTMVM.subscribeChannel(channelName: agoraRTMVM.mainChannel)
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
            
            // MARK: Display Go Board
            if agoraRTMVM.isLoggedIn {
                VStack {
                    Spacer()
                    GoBoardView()
                        .environmentObject(agoraRTMVM)
                    Spacer()
                    Text("Logged in as \(agoraRTMVM.userID)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Gomuku" : "Login")
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
                        Text(agoraRTMVM.isLoggedIn ? "Logout" : "Back")
                    }
                }
            }
        }
        
    }
}

#Preview {
    MiniGoView(path: .constant(NavigationPath()))
}
