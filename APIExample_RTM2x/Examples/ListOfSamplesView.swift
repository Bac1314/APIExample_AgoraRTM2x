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
        ("Location Sharing", ("location.viewfinder", AnyView(LocationView(serviceIcon:"location.viewfinder"))))
    ]
    
    
    var body: some View {
        NavigationStack {
            VStack {
//                Image(systemName: "bolt.brakesignal")
//                    .frame(width: 80, height: 80)
//                    .aspectRatio(1.0, contentMode: .fill)
//                    .font(.system(size: 60))
//                    .padding()
//                    .foregroundStyle(Color.accentColor.gradient)
////                    .background(Color(UIColor.secondarySystemGroupedBackground))
                
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
            .toolbar{
                // Internal testing button
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action : {
                        Task {
                            let token = try? await Personalize().customGenerateToken()
                            print("Bac's internal token \(token ?? "")")
                        }
                    }){
                        HStack{
                            Image(systemName: "wrench")
                            Text("Internal Testing")
                        }
                    }
                }
            }
            
//            Text("Logged in as \(userName)")
//                .padding(16)
//                .foregroundStyle(Color.gray)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("API Examples")

    }
}

#Preview {
    ListOfSamplesView()
}
