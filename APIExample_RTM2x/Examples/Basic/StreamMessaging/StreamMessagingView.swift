//
//  StreamMessagingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/15.
//

import SwiftUI
import AgoraRtmKit

struct StreamMessagingView: View {
    @StateObject var agoraRTMVM: StreamMessagingViewModel = StreamMessagingViewModel()
    @FocusState private var keyboardIsFocused: Bool
    @State var isLoading: Bool = false
    
    // show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    @State var presentAlertSubscribe = false
    @State var newTopic = ""
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var serviceIcon: String = "message"
    
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, channelName: $agoraRTMVM.mainChannel, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon, isStreamChannel: true, streamToken: $agoraRTMVM.tokenRTC) {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
                            await agoraRTMVM.createAndJoinStreamChannel()
//                            await agoraRTMVM.preJoinSubTopics()
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
                    Text("Stream Channel:  \(agoraRTMVM.mainChannel)")
                        .padding()
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        
                        ForEach(agoraRTMVM.customStreamTopicList, id: \.id) { topicChannel in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(topicChannel.topic)
                                        .font(.headline)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    Text(topicChannel.lastMessage)
                                        .font(.callout)
                                        .foregroundStyle(Color.secondary)
                                        .lineLimit(1)
                                    
                                    Text("#\(topicChannel.users.count)")
                                }
                                Spacer()
                            }
                            .padding(24)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
                            .onTapGesture {
                                path.append(CustomChildNavType.StreamMessagingDetailedView(selectedTopic: topicChannel.topic))
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Displayed Logged in Username
                    Text("Logged in as \(agoraRTMVM.userID)")
                }
                .onChange(of: agoraRTMVM.isLoggedIn) { oldValue, newValue in
                    if newValue {
                        isLoading = false
                        
                    }
                }
            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Topics" : "Login")
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
            case .StreamMessagingDetailedView(let selectedTopic):
                StreamMessagingDetailedView(agoraRTMVM: agoraRTMVM, selectedTopic: selectedTopic, path: $path)
            default:
                Text("ChannelMessagingView Not found")
            }
            
        }
        .alert("Subscribe", isPresented: $presentAlertSubscribe, actions: {
            TextField("Enter channelname", text: $newTopic)
                .focused($keyboardIsFocused)
            
            Button("Subscribe", action: {
                Task{
                    keyboardIsFocused = false // dismiss keyboard
                    
                    if agoraRTMVM.customStreamTopicList.contains(where: { $0.topic == newTopic}) {
                        return
                    }
                    let _ = await agoraRTMVM.JoinAndSubTopic(topic: newTopic)
                    newTopic = "" //Reset
                }
            })
            
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Subscribe to another channel")
        })
    }
}

#Preview {
    StreamMessagingView(path: .constant(NavigationPath()))
}

// MARK: TO SHOW THE LIST OF MESSAGES OF SPECIFIED CHANNEL
struct StreamMessagingDetailedView: View {
    @ObservedObject var agoraRTMVM: StreamMessagingViewModel
    @FocusState private var keyboardIsFocused: Bool
    @State var selectedTopic: String = ""
    @State var message: String = ""
    @Binding var path: NavigationPath
    
    
    var body: some View {
        // List of messages
        VStack {
            // MARK: DISPLAY LIST OF MESSAGES
            ScrollViewReader {proxy in
                ScrollView{
                    ForEach(agoraRTMVM.customStreamTopicList.first(where: {$0.topic == selectedTopic})?.messages ?? [], id: \.self) { message in
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
                .onChange(of: agoraRTMVM.customStreamTopicList.first(where: {$0.topic == selectedTopic})?.messages.count ?? 0) { oldValue, newValue in
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
                        let result = await agoraRTMVM.publishToTopic(topic: selectedTopic, message: message)
                        if result {
                            message = ""
                        }
                        
                        keyboardIsFocused = false // dismiss keyboard
                        
                    }
                }, label: {
                    Text("Publish")
                })
                .buttonStyle(.bordered)
                .disabled(selectedTopic.isEmpty || message.isEmpty)
            }
        }
        .padding(.horizontal)
        .navigationTitle("\(selectedTopic) (\(agoraRTMVM.customStreamTopicList.first(where: {$0.topic == selectedTopic})?.users.count ?? 0))")
        
    }
    
}


#Preview {
    StreamMessagingDetailedView(agoraRTMVM: StreamMessagingViewModel(), path: .constant(NavigationPath()))
}

