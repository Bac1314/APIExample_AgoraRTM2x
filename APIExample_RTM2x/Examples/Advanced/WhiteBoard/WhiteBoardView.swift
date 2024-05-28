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
                            let _ = await agoraRTMVM.subscribeChannel()
                            await agoraRTMVM.createAndJoinStreamChannel()
                            await agoraRTMVM.preJoinSubTopics()
                            let _ = await agoraRTMVM.getDrawingsFromStorage()
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
                Canvas(currentDrawing: $currentDrawing, drawings: $agoraRTMVM.drawings) { action in
                    switch action {
                    case .delete(let uuid):
                        Task {
                            // Publish delete request to remote users
                            let _ = await agoraRTMVM.publishDeleteDrawing(drawingID: uuid)
                        }
                        break
                    case .submitNewDrawing(let newDrawing):
                        Task {
                            // Publish new drawing to remote users
                            let _ = await agoraRTMVM.publishNewDrawing(drawing: newDrawing)
                        }
                        break
                    case .submitFinishedDrawing(_):
                        Task {
                            // Save new finished drawing to Storage
                            let _ = await agoraRTMVM.saveDrawingsToStorage()
                        }
                        break
                    case .update(let drawingPoint):
                        Task {
                            // Publish new points of currentDrawint to remote users
                            await agoraRTMVM.publishDrawingUpdate(newPoint: drawingPoint)
                        }
                        break
                    case .move(_):
                        break
                    }
                }
                
                // TESTING
//                VStack{
//                    Text("Fails # \(agoraRTMVM.fails)")
//                        .onTapGesture {
//                            print(agoraRTMVM.drawings)
//                        }
//                    Spacer()
//                }

            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Whiteboard (\(agoraRTMVM.users.count))" : "Login")
        .toolbar{
            if agoraRTMVM.isLoggedIn {
                // Clear All drawings
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action : {
                        Task {
                            await agoraRTMVM.publishDeleteAllDrawing()
                        }
                    }){
                        HStack{
                            Text("Clear all").foregroundStyle(Color.red)
                        }
                    }
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
