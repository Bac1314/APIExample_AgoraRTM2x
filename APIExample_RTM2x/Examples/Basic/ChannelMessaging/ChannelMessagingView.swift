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
    @FocusState private var keyboardIsFocused: Bool
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "message"
    @Binding var path: NavigationPath

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
                    List(agoraRTMVM.customRTMChannelList, id: \.channelName) { channel in
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
                            .onTapGesture {
                                path.append(CustomChildNavType.ChannelMessagingDetailedView(selectedChannel: channel.channelName))
                            }
                            
                        
                    }
                    .listStyle(.plain)
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
            case .ChannelMessagingDetailedView(let selectedChannel):
                ChannelMessagingDetailedView(selectedChannel: selectedChannel, path: $path)
                    .environmentObject(agoraRTMVM)
            default:
                Text("ChannelMessagingView Not found")
            }
            
        }
    }
    
    
}



// MARK: TO SHOW THE LIST OF MESSAGES OF SPECIFIED CHANNEL
struct ChannelMessagingDetailedView: View {
    @EnvironmentObject var agoraRTMVM: ChannelMessagingViewModel
    @FocusState private var keyboardIsFocused: Bool
    @State var selectedChannel: String = ""
    @State var newMessage: String = ""
    
    // To display loaded images
    @State var presentFullImage: Bool = false
    @State var selectedImage: Data?
    
    // To display user selected image
    @State var presentImagePicker = false
    @State var userSelectedImage: UIImage?

    @Binding var path: NavigationPath

    
    var body: some View {
        // List of messages
        ZStack {
            VStack {
                // MARK: DISPLAY LIST OF MESSAGES
                ScrollViewReader {proxy in
                    ScrollView{
                        ForEach(agoraRTMVM.customRTMChannelList.first(where: {$0.channelName == selectedChannel})?.channelMessages ?? [], id: \.self) { event in
                            if event.publisher == agoraRTMVM.userID {
                                MessageItemLocalView(from: "\(event.publisher) \(event.channelTopic)", message: event.message.stringData, imageData: event.message.rawData)
                                    .listRowSeparator(.hidden)
                                    .listItemTint(.clear)
                                    .onTapGesture {
                                        if let imageData = event.message.rawData {
                                            withAnimation {
                                                selectedImage = imageData
                                                presentFullImage.toggle()
                                            }
                                        }
                                    }
                                
                            }else{
                                MessageItemRemoteView(from: "\(event.publisher) \(event.channelTopic)", message: event.message.stringData, imageData: event.message.rawData)
                                    .listRowSeparator(.hidden)
                                    .listItemTint(.clear)
                                    .onTapGesture {
                                        if let imageData = event.message.rawData {
                                            withAnimation {
                                                selectedImage = imageData
                                                presentFullImage.toggle()
                                            }
                                        }
                                    }
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
                    // Image button
                    Button(action: {
                        withAnimation {
                            presentImagePicker.toggle()
                        }
                    }, label: {
                        Image(systemName: "photo")
                            .foregroundColor(Color.white)
                            .textCase(.lowercase)
                            .padding(4)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
                    })
                    
                    
                    TextField("Enter Message", text: $newMessage)
                        .textFieldStyle(.roundedBorder)
                        .focused($keyboardIsFocused)
                    
                    Button(action: {
                        Task{
                            keyboardIsFocused = false // dismiss keyboard
                            let result = await agoraRTMVM.publishToChannel(channelName: selectedChannel, messageString: newMessage)
                            
                            if result {
                                newMessage = "" // clear text
                            }
                        }
                    }, label: {
                        Text("Publish")
                    })
                    .buttonStyle(.bordered)
                    .disabled(selectedChannel.isEmpty || newMessage.isEmpty)
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
            .navigationTitle("\(selectedChannel) (\(agoraRTMVM.customRTMChannelList.first(where: {$0.channelName == selectedChannel})?.listOfUsers.count ?? 0))")
            .sheet(isPresented: $presentImagePicker, onDismiss: loadImage) {
                ImagePicker(selectedImage: $userSelectedImage, resize400Width: true)
                 }
            .disabled(presentFullImage)
            .blur(radius: presentFullImage ? 8 : 0)
            
            // MARK: Display full image
            if presentFullImage {
                FullImageView(imageData: selectedImage)
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            presentFullImage.toggle()
                        }
                    }
            }
        }
        
    }
    
    func loadImage() {
        Task {
            if let image = userSelectedImage {
                _ = await agoraRTMVM.publishImageToChannel(channelName: selectedChannel, image: image)
            }
        }
    }
    
}


#Preview {
    ChannelMessagingView(path: .constant(NavigationPath()))
        .environmentObject(ChannelMessagingViewModel())
    
//    ChannelMessagingDetailedView(path: .constant(NavigationPath()))
//        .environmentObject(ChannelMessagingViewModel())
}
