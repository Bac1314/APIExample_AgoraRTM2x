//
//  QuizViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/8.
//

import Foundation
import SwiftUI
import AgoraRtmKit

class QuizViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @Published var token: String = ""
    @Published var currentQuiz: CustomQuiz = CustomQuiz(question: "(Example) I like pandas", options: ["Yes", "No"], answer: "Yes", sender: "panda_lover_1992", totalUsers: 10, totalSubmission: 9, timestamp: Int(Date().addingTimeInterval(-15).timeIntervalSince1970))
    @Published var users: [QuizUser] = []
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    
    let mainChannel = "ChannelA" // to publish and receive poll questions/answers
    let customQuizQuestionType = "quizquestion"
    let customQuizResultType = "quizresult"
    
    // properties for keeping local user temporary score
    let scoreKey = "scoreKey"
    @Published var scoreValue = 0
    
    
    // list of random quiz questions from the web
    var listOfQuizzes : [QuizMockItem] = []
    
    @MainActor
    func loginRTM() async throws {
        do {
            if userID.isEmpty {
                throw customError.emptyUIDLoginError
            }
            
            // Initialize RTM instance
            if agoraRtmKit == nil {
                let config = AgoraRtmClientConfig(appId: Configurations.agora_AppdID , userId: userID)
                agoraRtmKit = try AgoraRtmClientKit(config, delegate: self)
            }
            
            // Login to RTM server
            // Use AppID to login if app certificate is NOT enabled for project
            if let (response, error) = await agoraRtmKit?.login(token.isEmpty ? Configurations.agora_AppdID : token) {
                if error == nil{
                    isLoggedIn = true
                }else{
                    print("Bac's code loginRTM login result = \(String(describing: response?.description)) | error \(String(describing: error))")
                    await agoraRtmKit?.logout()
                    throw error ?? customError.loginRTMError
                }
            } else {
                // Handle any cases where login fails or error is present
                print("Bac's code loginRTM login result = \(userID)")
            }
            
        }catch {
            print("Bac's Some other error occurred: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Logout RTM server
    func logoutRTM(){
        agoraRtmKit?.logout()
        agoraRtmKit?.destroy()
        isLoggedIn = false
    }
    
    //MARK: MESSAGE CHANNEL / POLL METHODS
    // Subscribe to channel in 'MessageChannel'
    @MainActor
    func subscribeChannel(channelName: String) async -> Bool {
        let subOptions: AgoraRtmSubscribeOptions = AgoraRtmSubscribeOptions()
        subOptions.features =  [.message, .presence]
        
        if let (_, error) = await agoraRtmKit?.subscribe(channelName: channelName, option: subOptions){
            if error == nil {
                return true
            }
            return false
        }
        return false
    }
    
    // Publish to channel in 'MessageChannel'
    @MainActor
    func publishQuizQuestion(newQuiz: CustomQuiz) async -> Bool{
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.customType = customQuizQuestionType
        pubOptions.channelType = .message
        
        //        let newQuiz: CustomQuiz = CustomQuiz(question: question, options: options, answer: answer, sender: userID, totalUsers: users.count, totalSubmission: 0, timestamp: Int(Date().addingTimeInterval(-15).timeIntervalSince1970))
        
        if let quizString = convertObjectToJsonString(object: newQuiz){
            if let (_, error) = await agoraRtmKit?.publish(channelName: mainChannel, message: quizString, option: pubOptions){
                if error == nil {
                    print("Bac's sendMessageToChannel success \(quizString)")
                    currentQuiz = newQuiz // Update local
                    return true
                }else{
                    print("Bac's sendMessageToChannel error \(String(describing: error))")
                    return false
                }
                
            }
        }
        return false
    }

    
    @MainActor
    func pubUserScore(channelName: String, key: String, score: Int) async -> Bool{
        
        
        // Define the rtm state item
        let item = AgoraRtmStateItem()
        item.key = scoreKey
        item.value = String(score)
        
        // Update local score OR add new item if it doesn't exist
        
        if let userIndex = users.firstIndex(where: {$0.userId == userID}) {
            // Local User exists
            users[userIndex].userScore = item.value
        }else {
            // Local user doesn't exists
            users.append(QuizUser(userId: userID, userScore: item.value))
        }
        
        // Send the score to remote users
        if let (_, error) = await agoraRtmKit?.getPresence()?.setState(channelName: channelName, channelType: .message, items: [item]){
            if error == nil {
                return true
            }
        }
        return false
    }
    
    @MainActor
    func getUserStateItems(channelName: String, userID: String) async -> [AgoraRtmStateItem] {
        if let (response, _) = await agoraRtmKit?.getPresence()?.getState(channelName: channelName, channelType: .message, userId: userID) {
            return response?.state.states ?? []
        }
        return []
    }
    
    @MainActor 
    func generateMockQuizzes(){
        listOfQuizzes = loadMockDataFromFile("quizmockdata.json")
    }
    
    func generateNewQuizFromList(){
        let randomIndex = Int.random(in: 0...listOfQuizzes.count-1)
        let mockQuiz: QuizMockItem = listOfQuizzes[randomIndex]
        
        var newOptions = mockQuiz.incorrectAnswers
        newOptions.append(mockQuiz.correctAnswer)
        
        let newQuiz: CustomQuiz = CustomQuiz(question: mockQuiz.question, options: newOptions.sorted(), answer: mockQuiz.correctAnswer, sender: userID, totalUsers: users.count, totalSubmission: 0, timestamp: Int(Date().addingTimeInterval(15).timeIntervalSince1970))
        
        withAnimation {
            currentQuiz = newQuiz
        }
        
        Task {
            let _ = await publishQuizQuestion(newQuiz: newQuiz)
        }
    }
    
    
}

extension QuizViewModel: AgoraRtmClientDelegate {
    
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        //        print("Bac's didReceiveMessageEvent msg = \(event.message.stringData ?? "Empty") from \(event.publisher) type \(String(describing: event.customType))")
        
        switch event.channelType {
        case .message:
            // Main Channel to receive POLL question or POLL result
            if event.customType == customQuizQuestionType {
                // Received new quiz, replace current quiz
                if let jsonString = event.message.stringData, let newQuiz = convertJsonStringToObject(jsonString: jsonString, objectType: CustomQuiz.self) {
                    print("Bac's didReceiveMessageEvent new quiz is \(jsonString)")
                    
                    currentQuiz = newQuiz
                }
            }else if event.customType == customQuizResultType {
                // Received answer from remote users
            }
            break
        case .stream:
            break
        case .user:
            break
        case .none:
            break
        @unknown default:
            print("Bac's didReceiveMessageEvent channelType is unknown")
        }
    }
    
    // Receive presence event notifications in subscribed message channels and joined stream channels.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceivePresenceEvent event: AgoraRtmPresenceEvent) {
        print("Bac's didReceivePresenceEvent channelType \(event.channelType) publisher \(String(describing: event.publisher)) channel \(event.channelName) type \(event.type) ")
        
        if event.type == .remoteLeaveChannel || event.type == .remoteConnectionTimeout {
            print("Bac's didReceivePresenceEvent remoteLeaveChannel/remoteConnectionTimeout publisher: \(event.publisher ?? "")")
            
            // Remove user from list
            if let userIndex = users.firstIndex(where: {$0.userId == event.publisher}) {
                users.remove(at: userIndex)
            }
            
        }else if event.type == .remoteJoinChannel && event.publisher != nil {
            print("Bac's didReceivePresenceEvent remoteJoinChannel publisher: \(event.publisher ?? "")")
            // Add user to list if it doesn't exist
            
            if let publisher = event.publisher {
                Task {
                    let userstates = await getUserStateItems(channelName: mainChannel, userID: event.publisher!) // It doesn't get the states of the user when user joins channel. Also presence doesn't disappear right away after user leaves the channel
                    let newUser : QuizUser = QuizUser(userId: publisher, userScore: userstates.first(where: {$0.key == scoreKey})?.value ?? "0")
                    await MainActor.run(body: {
                        users.append(newUser)
                    })
                }

            }
            
        }else if event.type == .snapshot {
            print("Bac's didReceivePresenceEvent snapshot")
            
            // Add users to list from snapshop
            for agoraUser in event.snapshot {
                let customUser: QuizUser = QuizUser(userId: agoraUser.userId, userScore: agoraUser.states.first(where: {$0.key == scoreKey})?.value ?? "0")
                users.append(customUser)
            }
            
        }else if event.type == .remoteStateChanged {
            print("Bac's didReceivePresenceEvent remoteStateChanged user:\(event.publisher ?? "")")
            
            if let newScore = event.states.first(where: {$0.key == scoreKey})?.value, let publisher = event.publisher{
                if let userIndex = users.firstIndex(where: {$0.userId == event.publisher}) {
                    // User exists
                    
                    users[userIndex].userScore = newScore
                }else {
                    // User doesn't exists (need to check code), add new user to list with new item
                    users.append(QuizUser(userId: publisher, userScore: newScore))
                }
            }
        }
    }
    
    // Triggers when connection changes
    func rtmKit(_ kit: AgoraRtmClientKit, channel channelName: String, connectionChangedToState state: AgoraRtmClientConnectionState, reason: AgoraRtmClientConnectionChangeReason) {
        print("Bac's connectionChangedToState \(state) reason \(reason.rawValue)")
        connectionState = connectionState
    }
    //
    //    // Trigger when token will expire
    //    func rtmKit(_ rtmKit: AgoraRtmClientKit, tokenPrivilegeWillExpire channel: String?) {
    //
    //    }
    
}


