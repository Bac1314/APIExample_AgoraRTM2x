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
        ("Whiteboard", ("hand.draw", AnyView(WhiteBoardView(serviceIcon:"hand.draw")))),
        ("Audio Recording", ("waveform", AnyView(AudioRecordingView(serviceIcon:"waveform")))),
        ("File Sharing", ("filemenu.and.cursorarrow", AnyView(FileSharingView(serviceIcon:"filemenu.and.cursorarrow"))))


    ]
    
    var body: some View {
        NavigationStack {
            VStack {
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
