//
//  P2PMessagingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/15.
//

import SwiftUI
import AgoraRtmKit

struct P2PMessagingView: View {
    @StateObject var agoraRTMVM: P2PMessagingViewModel = P2PMessagingViewModel()
    @FocusState private var keyboardIsFocused: Bool
    @State var newUser = ""
    @State var presentAlert = false
    @State var isLoading = false
    
    var serviceIcon: String = "message"
    
    @Binding var path: NavigationPath

    // First user
    @State var userName: String = "DummyUser"
    
    // show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
        
    var body: some View {
        ZStack {
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, channelName: $userName, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon, streamToken: .constant(""))  {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
                            agoraRTMVM.subscribedUsers[userName] = "New User"
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
            
            // MARK: Display list of users
            if agoraRTMVM.isLoggedIn {
                VStack {
                    List(agoraRTMVM.subscribedUsers.sorted(by: { $0.key < $1.key }), id: \.key) { user in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.key)
                                        .font(.headline)
                                    Text(user.value)
                                        .font(.callout)
                                        .foregroundStyle(Color.secondary)
                                }
                                Spacer()
                            }
                            .padding(24)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
                            .onTapGesture {
                                path.append(CustomChildNavType.P2PMessagingDetailedView(selectedUser: user.key))
                            }
                    }
                    .listStyle(.plain)
                    .task {
                        if agoraRTMVM.subscribedUsers.count == 0 {
                            // Add some dummy users
                            agoraRTMVM.subscribedUsers["DummyUser1"] = "New User"
                            agoraRTMVM.subscribedUsers["DummyUser2"] = "New User"
                        }
                    }
                }
                .alert("Add", isPresented: $presentAlert, actions: {
                    TextField("Enter username", text: $newUser)
                        .focused($keyboardIsFocused)
                    
                    Button("Add", action: {
                        Task{
                            keyboardIsFocused = false // dismiss keyboard
                            agoraRTMVM.subscribedUsers[newUser] = "New User"
                            newUser = "" //Reset
                            
                        }
                    })
                    Button("Cancel", role: .cancel, action: {})
                }, message: {
                    Text("Add users to list")
                })
            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Users" : "Login")
        .toolbar{
            if agoraRTMVM.isLoggedIn {
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        withAnimation {
                            presentAlert.toggle()
                        }
                    }, label: {
                        Text("Subscribe User")
                    })
                }
            }
            
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
        .navigationDestination(for: CustomChildNavType.self) { value in
            switch value {
            case .P2PMessagingDetailedView(let selectedUser):
                P2PMessagingDetailedView(selectedUser: selectedUser, path: $path)
                    .environmentObject(agoraRTMVM)
            default:
                Text("ChannelMessagingView Not found")
            }
            
        }
        
    }
    
}

#Preview {
    P2PMessagingView(path: .constant(NavigationPath()))
        .environmentObject(P2PMessagingViewModel())

}


// MARK: TO SHOW THE LIST OF MESSAGES OF SPECIFIED CHANNEL
struct P2PMessagingDetailedView: View {
    @EnvironmentObject var agoraRTMVM: P2PMessagingViewModel
    @FocusState private var keyboardIsFocused: Bool
    @State var selectedUser: String = ""
    @State var message: String = ""
    @Binding var path: NavigationPath

    
    var body: some View {
        // List of messages
        VStack {
            // MARK: DISPLAY LIST OF MESSAGES
            ScrollViewReader {proxy in
                ScrollView{
                    LazyVStack {
                        ForEach(Array(agoraRTMVM.rtmUsersMessages.filter { $0.channelType == .user }.enumerated()), id: \.1) { index, message in
                            if message.publisher == agoraRTMVM.userID && message.channelName == selectedUser {
                                MessageItemLocalView(from: "\(message.publisher) \(message.channelTopic)", message: "\(message.message.stringData ?? "")")
                                    .listRowSeparator(.hidden)
                                    .listItemTint(.clear)
                            }else if message.publisher == selectedUser  {
                                MessageItemRemoteView(from: "\(message.publisher) \(message.channelTopic)", message: "\(message.message.stringData ?? "")")
                                    .listRowSeparator(.hidden)
                                    .listItemTint(.clear)
                            }
                        }
                        
                    }
                }
                .onChange(of: agoraRTMVM.rtmUsersMessages.count) { oldValue, newValue in
                    withAnimation {
                        if newValue != 0 {
                            proxy.scrollTo(newValue-1)
                        }
                    }
                }
            }
            
            
            // MARK: SEND MESSAGE VIEW
            HStack{
                TextField("Enter Message", text: $message)
                    .textFieldStyle(.roundedBorder)
                    .focused($keyboardIsFocused)
                
                Button(action: {
                    Task{
                        keyboardIsFocused = false // dismiss keyboard
                        let result = await agoraRTMVM.publishToUser(userName: selectedUser, messageString: message, customType: nil)
                        
                        if result {
                            message = "" // Reset
                        }
                    }
                }, label: {
                    Text("Publish")
                })
                .buttonStyle(.bordered)
                .disabled(selectedUser.isEmpty || message.isEmpty)
            }
        }
        .padding(.horizontal)
        .navigationTitle(selectedUser)
    }
    
}
