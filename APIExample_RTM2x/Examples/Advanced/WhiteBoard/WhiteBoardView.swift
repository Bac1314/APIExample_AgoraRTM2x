//
//  WhiteBoardView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/24.
//

import SwiftUI
import AgoraRtmKit

struct WhiteBoardView: View {
    
    // Agora RTM
    @StateObject var agoraRTMVM: WhiteBoardViewModel = WhiteBoardViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "hand.draw"

    // Show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    
    // Whiteboard properties
    @State private var currentDrawing: Drawing = Drawing()
//    @State private var drawings: [Drawing] = [Drawing]()
    
    var body: some View {
        
        ZStack(alignment: .center){
            
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, channelName: $agoraRTMVM.mainChannel, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon, isStreamChannel: true, streamToken: $agoraRTMVM.tokenRTC) {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
                            await agoraRTMVM.createAndJoinStreamChannel()
                            await agoraRTMVM.preJoinSubTopics()
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
                Canvas(currentDrawing: $currentDrawing, drawings: $agoraRTMVM.drawings){
//                    // OnSubmitDrawing
//                    if let lastDrawing = agoraRTMVM.drawings.last {
//                        Task {
//                            await agoraRTMVM.publishNewDrawing(drawing: lastDrawing)
//                        }
//                    }
                }
                .onChange(of: currentDrawing.points) { oldValue, newValue in
                    if newValue.count == 1 {
                        Task {
                            await agoraRTMVM.publishNewDrawing(drawing: currentDrawing)
                        }
                    }
                    else if newValue.count > 1 {
                        if let newPoint = currentDrawing.points.last {
                            Task {
                                await agoraRTMVM.publishDrawingUpdate(newPoint: DrawingPoint(id: currentDrawing.id, point:  newPoint))
                            }
                        }

                    }
                }
                .onChange(of: agoraRTMVM.drawings.count) { oldValue, newValue in
                    
                    
                }
            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Whiteboard" : "Login")
        .toolbar{
            // Back button
            ToolbarItem(placement: .topBarLeading) {
                Button(action : {
                    agoraRTMVM.logoutRTM()
                    self.mode.wrappedValue.dismiss()
                }){
                    HStack{
                        Image(systemName: "arrow.left")
                        Text(agoraRTMVM.isLoggedIn ? "Logout"  : "Back")
                    }
                }
            }
            
        }
    }
}

#Preview {
    WhiteBoardView()
}
