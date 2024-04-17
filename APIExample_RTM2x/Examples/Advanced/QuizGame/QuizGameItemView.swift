//
//  QuizGameItemView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/9.
//

import SwiftUI

struct QuizGameItemView: View {
    @Binding var quizGame : CustomQuiz // CustomQuiz(question: "(Example) I like pandas", options: ["Yes", "No"], answer: "Yes", sender: "panda_lover_1992", totalUsers: 10, totalSubmission: 9, timestamp: Int(Date().addingTimeInterval(-15).timeIntervalSince1970))
    @Binding var selectedAnswer : String
    
    var body: some View {
        VStack{
            // Show if user answerd correctly
            if !selectedAnswer.isEmpty {
                Text(selectedAnswer == quizGame.answer ? "Correct!" : "Incorrect")
                    .font(.title2)
                    .foregroundStyle(selectedAnswer == quizGame.answer ? Color.green : Color.red)
                    .padding([.bottom])
            }
            
            
            // Question
            HStack {
                Text(quizGame.question)
                    .font(.title3)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                
                Spacer()
            }
            .padding(.bottom, 10)
            
            // Show options
            ForEach(quizGame.options, id: \.self) { value in
                HStack{
                    
                    Image(systemName: selectedAnswer == value ? "checkmark.circle.fill" : "circle")
                        .imageScale(.large)
                    Text(value)
                        .foregroundStyle(selectedAnswer == "" || selectedAnswer == value ? Color.primary : Color.gray)
                    
                    Spacer()
                    
                }
                .onTapGesture {
                    withAnimation {
                        if selectedAnswer.isEmpty{
                            selectedAnswer = value
                        }
                    }
                }
                .disabled(!selectedAnswer.isEmpty)
                .padding(.vertical,2)
            }
            
            HStack{
                
                Text("# Users \(quizGame.totalUsers)")
                    .padding(4)
                    .font(.subheadline)
//                    .foregroundStyle(Color.white)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()

//                Text("# Submission \(quizGame.totalSubmission)")
//                    .padding(4)
//                    .font(.subheadline)
////                    .foregroundStyle(Color.white)
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(8)
                
                Text("From \(quizGame.sender)")
                    .font(.subheadline)
                    .bold()
                    .padding([.top])
                    .italic()
                
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

//#Preview {
//    QuizGameItemView(selectedAnswer: .constant(""))
//}
