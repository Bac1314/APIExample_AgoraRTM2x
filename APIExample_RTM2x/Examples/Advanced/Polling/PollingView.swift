//
//  PollingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/15.
//

import SwiftUI
import AgoraRtmKit

struct PollingView: View {
    @StateObject var agoraRTMVM: PollingViewModel = PollingViewModel()
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "message"

    // show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    
    // new poll
    @State var presentPollSheet: Bool = false
    @State var question: String = ""
    @State var option: String = ""
    @State var tempOptions = Array<String>.init(repeating: "", count: 4)
    @State var pollAnswer: String = ""

    @Binding var path: NavigationPath

    
    var body: some View {
        ZStack(alignment: .center){
                        
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, channelName: $agoraRTMVM.mainChannel, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon,  streamToken: .constant("")) {
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
                VStack{
                    //MARK: POLL VIEW
                    PollItemView(pollItem: agoraRTMVM.currentPoll, selectedAnswer: $pollAnswer)
                        .padding()
                        .transition(.slide)
                        .onChange(of: pollAnswer) { oldValue, newValue in
                            Task {
                                if !newValue.isEmpty{
                                    let _ = await agoraRTMVM.publishPollResponse(channelName: agoraRTMVM.mainChannel,  answer: pollAnswer)
                                    pollAnswer = "" // Reset to zero
                                }
                            }
                        }
                    
                    //MARK: Send Poll Question
                    Button(action: {
                        // Open poll view
                        withAnimation {
                            presentPollSheet.toggle()
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "plus.app.fill")
                                .imageScale(.large)
                            
                            Text("Create New Poll ")
                                .font(.title3)
                        }
                        .padding(8)
                        .foregroundColor(.white)
                        .background(.orange)
                        .cornerRadius(12)
                    })
                    
                    Spacer()
                    
                    // MARK: Show login user and channel
                    Text("Username: \(agoraRTMVM.userID) | Channel: \(agoraRTMVM.mainChannel)")
                        .minimumScaleFactor(0.8)
                    
                }
            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Polling(\(agoraRTMVM.users.count))" : "Login")
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
        .sheet(isPresented: $presentPollSheet, content: {
            //MARK: Creating a new poll
            VStack {
                VStack{
                    TextField("", text: $question, prompt: Text("What is your question?").foregroundStyle(Color.gray))
                        .font(.title2)
                        .foregroundStyle(Color.white)
                        .background(.clear)
                        .padding()
                        .padding(.vertical, 20)
                    
                }
                .background(Color.black)
                .padding(.bottom)
                
                // Options
                ForEach(0..<tempOptions.count, id: \.self) { index in
                    HStack {
                        Image(systemName: "circle")
                            .padding(.horizontal, 8)
                            .imageScale(.large)
                            .foregroundColor(Color.gray)
                        TextField("Enter option", text: $tempOptions[index])
                        Spacer()
                    }
                    .padding(.vertical)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)

                }

                Divider()
            

                Button(action: {
                    Task {
                        var newOptions : [String: Int] = [:]

                        for tempOption in tempOptions {
                            if !tempOption.isEmpty {
                                newOptions[tempOption] = 0 // Append to newOptions
                            }
                        }
                        
                        let result = await agoraRTMVM.publishPollQuestion(question: self.question, options: newOptions)
                        // Reset
                        if result {
                            withAnimation {
                                presentPollSheet = false
                                question = ""
                                option = ""
                                tempOptions = Array<String>.init(repeating: "", count: 4)                            }
                        }
                    }
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .disabled(question.isEmpty || tempOptions.filter { !$0.isEmpty }.count < 2)
                .padding()
                
                Spacer()
            }
        })
    }
}

#Preview {
    PollingView(path: .constant(NavigationPath()))
}
