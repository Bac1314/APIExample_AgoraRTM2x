//
//  SamplesListView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/18.
//

import SwiftUI

struct ListOfSamplesView: View {
        
    typealias ServiceHandler = (String, (String, AnyView))
    
    let basicSamples: [ServiceHandler] =  [
        ("Channel Messaging", ("message", AnyView(ChannelMessagingView(serviceIcon: "message")))),
        ("Peer-to-Peer Messaging", ("person.2", AnyView(P2PMessagingView(serviceIcon: "person.2")))),
        ("Stream Messaging", ("bolt.brakesignal", AnyView(StreamMessagingView(serviceIcon: "bolt.brakesignal"))))
    ]
    
    
    let advancedSamples: [ServiceHandler] =  [
        ("Polling", ("chart.pie", AnyView(PollingView(serviceIcon:"chart.pie")))),
        ("Quiz Game", ("checklist", AnyView(QuizGameView(serviceIcon:"checklist")))),
        ("Live Bidding", ("dollarsign.circle", AnyView(BiddingView(serviceIcon:"dollarsign.circle")))),
        ("Location Sharing", ("location.viewfinder", AnyView(LocationView(serviceIcon:"location.viewfinder")))),
        ("Whiteboard", ("hand.draw", AnyView(WhiteBoardView(serviceIcon:"hand.draw"))))

    ]
    
    
//    // Rotating logo
//    @State var degreesRotating = 0.0
    
    var body: some View {
        NavigationStack {
            VStack {
//                Image(systemName: "bolt.brakesignal")
//                    .font(.system(size: 50))
//                    .padding(.top, 20)
//                    .foregroundStyle(LinearGradient(colors: [Color.accentColor.opacity(0.3), Color.accentColor, Color.accentColor.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
//                    .shadow(radius: 5)
//                    .rotationEffect(.degrees(degreesRotating))
//                    .onAppear {
//                        withAnimation(.linear(duration: 1)
//                            .speed(0.1).repeatForever(autoreverses: false)) {
//                                degreesRotating = 360.0
//                            }
//                    }
                
                
                Form{
                    // MARK: BASIC SAMPLES
                    Section(header: Text("Basic").font(.title3)) {
                        List(basicSamples, id:\.0){ sample in
                            NavigationLink(destination: sample.1.1) {
                                Image(systemName: sample.1.0)
                                Text(sample.0)
                            }
                        }
                    }
                    
                    
                    // MARK: ADVANCED SAMPLES
                    Section(header: Text("Advanced").font(.title3)) {
                        List(advancedSamples, id:\.0){ sample in
                            NavigationLink(destination: sample.1.1) {
                                Image(systemName: sample.1.0)
                                Text(sample.0)
                            }
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("RTM API Examples")
        }

    }
}

#Preview {
    ListOfSamplesView()
}
