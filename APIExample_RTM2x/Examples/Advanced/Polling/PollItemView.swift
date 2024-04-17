//
//  PollItemView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/1.
//

import SwiftUI

struct PollItemView: View {
    var pollItem: CustomPoll
    @State var seletecedItem: String = ""
    @Binding var selectedAnswer: String
    
    @State private var currentDate = Date()
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    

    var body: some View {
        VStack{
            HStack {
                Text(pollItem.question)
                    .font(.title3)
                
                Spacer()
                
                if currentDate < Date(timeIntervalSince1970: TimeInterval(pollItem.timestamp)) {
                    Text("\(remainingSeconds(currentDate: currentDate, timestamp: pollItem.timestamp))s")
                        .contentTransition(.numericText())
                        .font(.title2)
                        .foregroundStyle(.red)
                        .bold()
                }else {
                    Text("Finished")
                }
            }
            .padding(.bottom, 10)
            
            ForEach(pollItem.options.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                HStack{
                    Image(systemName: seletecedItem == key ? "checkmark.circle.fill" : "circle")
                        .imageScale(.large)
                    Text(key)
                        .foregroundStyle(seletecedItem == "" || seletecedItem == key ? Color.primary : Color.gray)
                    
                    Spacer()
                }
                .onTapGesture {
                    if !pollItem.options.keys.contains(seletecedItem) && Date() < Date(timeIntervalSince1970: TimeInterval(pollItem.timestamp)){
                        withAnimation {
                            seletecedItem = key
                            selectedAnswer = key
                        }
                    }
                }
                .padding(.vertical,2)
                
                // Show result when timer runs out
                if currentDate >= Date(timeIntervalSince1970: TimeInterval(pollItem.timestamp)) {
                    HStack {
                        ProgressView(value: Float(value), total: Float(pollItem.options.values.reduce(0, +)))
                            .progressViewStyle(.linear)
                            .padding(.bottom,2)
                        
                        Spacer()
                        
                        if pollItem.options.values.reduce(0, +) > 0  {
                            Text("\(Int(100*Double(value)/Double(pollItem.options.values.reduce(0, +))))%")
                        }else {
                            Text("0%")
                        }
                        
                    }
                }
            }
            
            HStack{
                
                Text("# Users \(pollItem.totalUsers)")
                    .padding(4)
                    .font(.subheadline)
//                    .foregroundStyle(Color.white)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                Text("# Submission \(pollItem.totalSubmission)")
                    .padding(4)
                    .font(.subheadline)
//                    .foregroundStyle(Color.white)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                Text("From \(pollItem.sender)")
                    .font(.subheadline)
                    .bold()
                    .padding([.top])
                    .italic()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .onReceive(timer) { _ in
            withAnimation {
                self.currentDate = Date()
            }
        }
        
        
    }
    

}


struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        let question = "(Example) Which one do you prefer?"
        let options = ["Black Shirt":4, "Blue Shirt":5, "White Shirt":3, "Pink Shirt":2]
        let sender = "User1"
        let totalUsers = 30
        let totalSubmission = 0
        let timestamp = Int(Date().addingTimeInterval(11).timeIntervalSince1970)
        
        let pollItem = CustomPoll(question: question, options: options, sender: sender, totalUsers: totalUsers, totalSubmission: totalSubmission, timestamp: timestamp)
        PollItemView(pollItem: pollItem, selectedAnswer: .constant("Black Shirt"))
    }
}
