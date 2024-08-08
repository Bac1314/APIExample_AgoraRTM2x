//
//  VirtualGiftingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/8/8.
//

import SwiftUI
import AgoraRtmKit

struct VirtualGiftingView: View {
    @StateObject var agoraRTMVM: VirtualGiftingViewModel = VirtualGiftingViewModel()
    @FocusState private var keyboardIsFocused: Bool
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "gift"
    @Binding var path: NavigationPath
    
    // First channelName
    @State var channelName: String = "ChannelA"
    
    // Show Alert alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    
    // List of virtual gifts
    var virtualgifts : [String] = [
        "yougo", "flower1", "flowers2", "present", "gold1", "gold2", "heart1", "fireworks1"
    ]
//    @State var newGift: String = "yougo"
//    @State var newGiftPosition: CGFloat = 0.0
//    @State var animateGift = false
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
            
            // MARK: Display list of gifts
            if agoraRTMVM.isLoggedIn {
                VStack{
                    
                    // List of gifts sent/received
                    ScrollView {
                        VStack {
                            ForEach(agoraRTMVM.listUserGifts.sorted(by: {$0.timestamp > $1.timestamp})) { giftInstance in
                                
                                Text("From \(giftInstance.userID)")
                                Image(giftInstance.gift)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                    Spacer()
                    
                    // Gift selection and sending
                    VStack{
                        Text("Send a gift")
                            .padding(.top)
                            .font(.headline)
//                            .foregroundStyle(Color.accentColor)
                        
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(virtualgifts, id: \.self) { giftimage in
                                    Image(giftimage)
                                        .resizable()
                                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .padding()
                                        .padding(.top, 24)
                                        .onTapGesture {
                                            Task {
                                                // Send gift
                                                let _ = await agoraRTMVM.publishToChannel(channelName: channelName, messageString: giftimage)
                                            }
                                        }
                                    
                                }
                            }
                        }
                    }
                    .background(.gray.gradient.opacity(0.4))
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: 16.0,
                        bottomLeading: 0,
                        bottomTrailing: 0,
                        topTrailing: 16.0),
                                                      style: .continuous))
                    .ignoresSafeArea(.container, edges: .bottom) // Ignore only the bottom safe area
                }
                
////                if animateGift {
//                    Image(newGift) // Use your image here
//                        .resizable()
//                        .frame(width: 200, height: 200)
//                        .offset(y: animateGift ? -800 : 0)
//                        .animation(.easeInOut(duration: 2), value: animateGift) // Apply animation modifier
////                }

                
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
    VirtualGiftingView(path: .constant(NavigationPath()))
}
