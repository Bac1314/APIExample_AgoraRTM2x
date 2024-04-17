//
//  QuizGameView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/15.
//

import SwiftUI
import AgoraRtmKit

struct QuizGameView: View {
    @StateObject var agoraRTMVM: QuizViewModel = QuizViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "message"

    // show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"

    // Quiz specific properties
    @State var score: Int = 0
    @State var userAnswer: String = ""
    @State var tempScore: Int = 3
    
    var body: some View {
        ZStack(alignment: .center){
            
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon)  {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
                            let _ = await agoraRTMVM.subscribeChannel(channelName: agoraRTMVM.mainChannel)
                            await MainActor.run{
                                agoraRTMVM.generateMockQuizzes()
                            }
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
                    
                    // MARK: SCORE BOARD
                    List{
                        Text("Your score: \(agoraRTMVM.scoreValue)")
                            .font(.headline)
                            .contentTransition(.numericText())
                            .shadow(radius: 10)
                        
                        ForEach(agoraRTMVM.users.sorted(by: {$0.userScore > $1.userScore}), id:\.userId) { user in
                            HStack{
                                Text("\(user.userId)")
                                Spacer()
                                Text("\(user.userScore)").font(.headline)
                            }
                        }
                    }
                    .listStyle(.plain)
                    
                        
                    //MARK: QUIZ VIEW
                    QuizGameItemView(quizGame: $agoraRTMVM.currentQuiz, selectedAnswer: $userAnswer)
                        .padding()
                        .transition(.slide)
                        .onChange(of: userAnswer) { oldValue, newValue in
                            Task {
                                if !newValue.isEmpty {
                                    // if answer is correct, update presence data
                                    if agoraRTMVM.currentQuiz.answer == userAnswer {
                                        agoraRTMVM.scoreValue += 1

                                        let _ = await agoraRTMVM.pubUserScore(channelName: agoraRTMVM.mainChannel, key: agoraRTMVM.scoreKey, score: agoraRTMVM.scoreValue)
                                    }

                                }
                            }
                        }
                        .onChange(of: agoraRTMVM.currentQuiz.id) { oldValue, newValue in
                            userAnswer = "" // Reset
                        }
   
                    //MARK: Generate Random Question
                    Button(action: {
                        // Testing
                        withAnimation {
                            agoraRTMVM.generateNewQuizFromList()
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "plus.app.fill")
                                .imageScale(.large)
                            Text("Generate Random Question")
                                .font(.title3)
                                .contentTransition(.numericText())
                            
                        }
//                        .disabled(remainingSeconds(currentDate: Date(), timestamp: agoraRTMVM.currentQuiz.timestamp) > 0)
                        .padding(8)
                        .foregroundColor(.white)
                        .background(.orange)
                        .cornerRadius(12)
                    })
                    
                }
            }
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Quiz Game (\(agoraRTMVM.users.count))" : "Login")
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
    QuizGameView()
}
