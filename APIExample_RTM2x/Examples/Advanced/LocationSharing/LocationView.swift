//
//  LocationView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/17.
//

import SwiftUI
import MapKit
import AgoraRtmKit


struct LocationView: View {
    @StateObject var agoraRTMVM: LocationViewModel = LocationViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "message"
    
    // show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    @State var showCustomAmountAlert: Bool = false
    @State var customAmount: Int = 0
    
    @FocusState private var keyboardIsFocused: Bool
    
    var body: some View {
        ZStack(alignment: .center){
            
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon, streamToken: .constant(""))  {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
                            let _ = await agoraRTMVM.subscribeChannel(channelName: agoraRTMVM.mainChannel)
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
            
            // MARK: Main View
            if agoraRTMVM.isLoggedIn {
                Map {
                    // Display a list of users locations
                    ForEach(agoraRTMVM.users.sorted(by: {$0.userId > $1.userId}), id:\.userId) { user in
                        Annotation(user.userId, coordinate: CLLocationCoordinate2D(latitude: user.userLocation.center.latitude, longitude: user.userLocation.center.longitude)) {
                            Image(systemName: "person")
                                .resizable()
                                .padding(12)
                                .foregroundStyle( user.userId == agoraRTMVM.userID ? .white : .blue)
                                .frame(width: 50, height: 50)
                                .background(user.userId == agoraRTMVM.userID ? .red : .white)
                                .clipShape(.circle)
                        }
                    }
                    
                }
                
            }
            
            
            VStack {
                Spacer()
                // MARK: Show login user and channel
                Text("Username: \(agoraRTMVM.userID) | Channel: \(agoraRTMVM.mainChannel)")
                    .minimumScaleFactor(0.8)
            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Real-Time Location" : "Login")
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
    LocationView()
}
