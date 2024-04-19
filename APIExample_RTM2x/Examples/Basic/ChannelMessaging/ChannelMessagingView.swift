//
//  ChannelMessageView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/15.
//

import SwiftUI
import AgoraRtmKit

struct ChannelMessagingView: View {
    @StateObject var agoraRTMVM: ChannelMessagingViewModel = ChannelMessagingViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    @FocusState private var keyboardIsFocused: Bool
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "message"

    // show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    @State var presentAlertSubscribe = false
    @State var newChannelName = ""
        
    var body: some View {
        ZStack {
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon, streamToken: .constant("")) {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
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
                    List(agoraRTMVM.customRTMChannelList, id: \.channelName) { channel in
                        NavigationLink(destination: ChannelMessagingDetailedView(selectedChannel: channel.channelName).environmentObject(agoraRTMVM)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(channel.channelName)
                                        .font(.headline)
                                    Text(channel.lastMessage)
                                        .font(.callout)
                                        .foregroundStyle(Color.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                // Number of users
                                Label("\(channel.listOfUsers.count)x", image: "person.2")
                     
                            }
                            .padding(24)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
                            
                        }
                    }
                    .listStyle(.plain)
                    .task {
                        if agoraRTMVM.customRTMChannelList.count == 0 {
                            // When user first the screen, subscribe to a couple random channels
                            let _ = await agoraRTMVM.subscribeChannel(channelName: "ChannelA")
                            let _ = await agoraRTMVM.subscribeChannel(channelName: "ChannelB")
                        }
                    }
                    
                    
                    // Displayed Logged in Username
                    Text("Logged in as \(agoraRTMVM.userID)")
                }
                .onChange(of: agoraRTMVM.isLoggedIn) { oldValue, newValue in
                    if newValue {
                        isLoading = false
                        
                    }
                }
                .alert("Subscribe", isPresented: $presentAlertSubscribe, actions: {
                    TextField("Enter channelname", text: $newChannelName)
                        .focused($keyboardIsFocused)
                    
                    Button("Subscribe", action: {
                        Task{
                            keyboardIsFocused = false // dismiss keyboard
                            
                            if agoraRTMVM.customRTMChannelList.contains(where: { $0.channelName == newChannelName}) {
                                return
                            }
                            let _ = await agoraRTMVM.subscribeChannel(channelName: newChannelName)
                            newChannelName = "" //Reset
                        }
                    })
                    
                    Button("Cancel", role: .cancel, action: {})
                }, message: {
                    Text("Subscribe to another channel")
                })

            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Channels" : "Login")
        .toolbar{
            if agoraRTMVM.isLoggedIn {
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        withAnimation {
                            presentAlertSubscribe.toggle()
                        }
                    }, label: {
                        Text("Subscribe")
                    })
                }
            }
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



// MARK: TO SHOW THE LIST OF MESSAGES OF SPECIFIED CHANNEL
struct ChannelMessagingDetailedView: View {
    @EnvironmentObject var agoraRTMVM: ChannelMessagingViewModel
    @FocusState private var keyboardIsFocused: Bool
    @State var selectedChannel: String = ""
    @State var message: String = ""
    
    
    var body: some View {
        // List of messages
        VStack {
            // MARK: DISPLAY LIST OF MESSAGES
            ScrollViewReader {proxy in
                ScrollView{
                    ForEach(agoraRTMVM.customRTMChannelList.first(where: {$0.channelName == selectedChannel})?.channelMessages ?? [], id: \.self) { message in
                        if message.publisher == agoraRTMVM.userID {
                            MessageItemLocalView(from: "\(message.publisher) \(message.channelTopic)", message: "\(message.message.stringData ?? "")")
                                .listRowSeparator(.hidden)
                                .listItemTint(.clear)
                        }else{
                            MessageItemRemoteView(from: "\(message.publisher) \(message.channelTopic)", message: "\(message.message.stringData ?? "")")
                                .listRowSeparator(.hidden)
                                .listItemTint(.clear)
                        }
                    }
                }
                .onChange(of: agoraRTMVM.customRTMChannelList.first(where: {$0.channelName == selectedChannel})?.channelMessages.count ?? 0) { oldValue, newValue in
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
                        let result = await agoraRTMVM.publishToChannel(channelName: selectedChannel, messageString: message, customType: nil)
                        
                        if result {
                            message = "" // clear text
                        }
                    }
                }, label: {
                    Text("Publish")
                })
                .buttonStyle(.bordered)
                .disabled(selectedChannel.isEmpty || message.isEmpty)
            }
        }
        .padding(.horizontal)
        .navigationTitle("\(selectedChannel) (\(agoraRTMVM.customRTMChannelList.first(where: {$0.channelName == selectedChannel})?.listOfUsers.count ?? 0))")
    
    }
    
}


#Preview {
    ChannelMessagingView()
        .environmentObject(ChannelMessagingViewModel())
}
