//
//  SamplesListView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/18.
//

import SwiftUI

enum CustomNavigationType: Hashable {
    // Basic
    case ChannelMessagingView(serviceIcon: String)
    case P2PMessagingView(serviceIcon: String)
    case StreamMessagingView(serviceIcon: String)
    
    // Advanced
    case PollingView(serviceIcon: String)
    case QuizGameView(serviceIcon: String)
    case BiddingView(serviceIcon: String)
    case LocationView(serviceIcon: String)
    case WhiteBoardView(serviceIcon: String)
    case AudioRecordingView(serviceIcon: String)
    case FileSharingView(serviceIcon: String)
    case AudioCallKitView(serviceIcon: String)
    case VirtualGiftingView(serviceIcon: String)
}

enum CustomChildNavType: Hashable {
   // ChildViews
    case ChannelMessagingDetailedView(selectedChannel: String)
    case P2PMessagingDetailedView(selectedUser: String)
    case StreamMessagingDetailedView(selectedTopic: String)
    case InCallAudioView
    
}

struct ListOfSamplesView: View {
    
    @State var path = NavigationPath() {
        willSet(newVal) {
            print("NavigationPath new \(newVal)")
        }
        didSet(oldVal) {
            print("NavigationPath old \(oldVal)")
        }
    }
    
    typealias ServiceHandler = (String, (String, CustomNavigationType))
    
    let basicSamples: [ServiceHandler] =  [
        ("Channel Messaging", ("message", CustomNavigationType.ChannelMessagingView(serviceIcon: "message"))),
        ("Peer-to-Peer Messaging", ("person.2", CustomNavigationType.P2PMessagingView(serviceIcon: "person.2"))),
        ("Stream Messaging", ("bolt.brakesignal", CustomNavigationType.StreamMessagingView(serviceIcon: "bolt.brakesignal")))
    ]
    
    
    let advancedSamples: [ServiceHandler] =  [
        ("Polling", ("chart.pie", CustomNavigationType.PollingView(serviceIcon:"chart.pie"))),
        ("Quiz Game", ("checklist", CustomNavigationType.QuizGameView(serviceIcon:"checklist"))),
        ("Live Bidding", ("dollarsign.circle", CustomNavigationType.BiddingView(serviceIcon:"dollarsign.circle"))),
        ("Location Sharing", ("location.viewfinder", CustomNavigationType.LocationView(serviceIcon:"location.viewfinder"))),
        ("Whiteboard", ("hand.draw",CustomNavigationType.WhiteBoardView(serviceIcon:"hand.draw"))),
        ("Audio Recording", ("waveform", CustomNavigationType.AudioRecordingView(serviceIcon:"waveform"))),
        ("File Sharing", ("filemenu.and.cursorarrow", CustomNavigationType.FileSharingView(serviceIcon:"filemenu.and.cursorarrow"))),
        ("P2P Audio Call", ("phone.down", CustomNavigationType.AudioCallKitView(serviceIcon:"phone.down"))),
        ("Virtual Gifting", ("gift", CustomNavigationType.VirtualGiftingView(serviceIcon:"gift")))
    ]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Form{
                    // MARK: BASIC SAMPLES
                    Section(header: Text("Basic").font(.title3)) {
                        List(basicSamples, id:\.0){ sample in
                            HStack {
                                Image(systemName: sample.1.0)
                                Text(sample.0)
                                Spacer()
                            }
                            .onTapGesture {
                                print("Bac's basic navigation to \(sample.1.1)")
                                path.append(sample.1.1)
                            }
                        }
                    }
                    
                    
                    // MARK: ADVANCED SAMPLES
                    Section(header: Text("Advanced").font(.title3)) {
                        List(advancedSamples, id:\.0){ sample in
                            HStack {
                                Image(systemName: sample.1.0)
                                Text(sample.0)
                                Spacer()
                            }
                            .background()
                            .onTapGesture {
                                path.append(sample.1.1)
                            }
                        }
                    }
                }
            }
            //            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("RTM API Examples")
            .navigationDestination(for: CustomNavigationType.self) { value in
                switch value {
                case .ChannelMessagingView(let serviceIcon):
                    ChannelMessagingView(serviceIcon: serviceIcon, path: $path)
                case .P2PMessagingView(let serviceIcon):
                    P2PMessagingView(serviceIcon: serviceIcon, path: $path)
                case .StreamMessagingView(let serviceIcon):
                    StreamMessagingView(serviceIcon: serviceIcon, path: $path)
                case .PollingView(let serviceIcon):
                    PollingView(serviceIcon: serviceIcon, path: $path)
                case .QuizGameView(let serviceIcon):
                    QuizGameView(serviceIcon: serviceIcon, path: $path)
                case .BiddingView(let serviceIcon):
                    BiddingView(serviceIcon: serviceIcon, path: $path)
                case .LocationView(let serviceIcon):
                    LocationView(serviceIcon: serviceIcon, path: $path)
                case .WhiteBoardView(let serviceIcon):
                    WhiteBoardView(serviceIcon: serviceIcon, path: $path)
                case .AudioRecordingView(let serviceIcon):
                    AudioRecordingView(serviceIcon: serviceIcon, path: $path)
                case .FileSharingView(let serviceIcon):
                    FileSharingView(serviceIcon: serviceIcon, path: $path)
                case .AudioCallKitView(let serviceIcon):
                    AudioCallKitView(serviceIcon: serviceIcon, path: $path)
                case .VirtualGiftingView(serviceIcon: let serviceIcon):
                    VirtualGiftingView(serviceIcon: serviceIcon, path: $path)
                }
            }
        }
        
    }
}

#Preview {
    ListOfSamplesView()
}
