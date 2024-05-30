//
//  FileSharingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/29.
//

import SwiftUI
import AgoraRtmKit

struct FileSharingView: View {
    // Agora RTM
    @StateObject var agoraRTMVM: FileSharingViewModel = FileSharingViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    @State var isLoading: Bool = false
    var serviceIcon: String = "waveform"
    
    // Show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    
    // File Import and Export
    @State var showFileImporter = false
    @State var showFileExporter = false
    @State var exportFile : Data?
    
    
    var body: some View {
        ZStack(alignment: .center){
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, channelName: $agoraRTMVM.mainChannel, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon, isStreamChannel: false, streamToken: .constant((""))) {
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
                VStack {
                    ForEach(agoraRTMVM.fileInfos) { file in
                        
//                        if let fileURL = URL(string: file.url) {
//                            Link("open \(file.name)", destination: fileURL)
//                        }
                        
                        FileInfoItemView(file: file, currentUser: agoraRTMVM.userID, fileChunks: $agoraRTMVM.fileChunks[file.id])
                            .onTapGesture {
                                if let fileURL = URL(string: file.url) {
                                }
                                
                            }
                    }
                    
                    Spacer()
                
                    
                    Button(action: {
                        showFileImporter.toggle()
                    }, label: {
                        Text("Send a File")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(Color.white)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding()
                    })
                    .padding(.bottom)
                }
                
                
            }
            
            
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
        }
        
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.pdf, .plainText, .audio, .zip, .image, .webP], allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let file):
                print("Bac success file \(file)")
                Task {
                    if let fileURL = file.first {
                        let _ = await agoraRTMVM.publishToChannel(channelName: agoraRTMVM.mainChannel, fileURL: fileURL)
                    }
                }
            case .failure(let error):
                // handle error
                print(error)
            }
        }
//        .fileExporter(isPresented: $showFileExporter, document: URL(string: agoraRTMVM.fileInfos[0].url), contentType: .png, onCompletion: { result in
//            <#code#>
//        })
//        .fileExporter(isPresented: $showFileExporter, item: exportFile, onCompletion: { result in
//            switch result {
//            case .success(let url):
//                print("Saved to \(url)")
//            case .failure(let error):
//                print("Bac's code \(error.localizedDescription)")
//            }
//        })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "File Sharing" : "Login")
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
    FileSharingView()
}
