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
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon)  {
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
                    
//                    withAnimation {
//                        Marker(agoraRTMVM.userID, coordinate: CLLocationCoordinate2D(latitude: agoraRTMVM.localRegion.center.latitude, longitude: agoraRTMVM.localRegion.center.longitude))
                        
                        
                        Annotation(agoraRTMVM.userID, coordinate: CLLocationCoordinate2D(latitude: agoraRTMVM.localRegion.center.latitude, longitude: agoraRTMVM.localRegion.center.longitude)) {
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundStyle(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(.circle)
                        }
//                    }

                }
                
                
            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Location" : "Login")
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
