//
//  CallingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/6/21.
//

import SwiftUI
import Foundation

struct InCallAudioView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode> // For the custom back button
    @EnvironmentObject var agoraVM: AudioCallKitViewModel

    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]


    var body: some View {
        VStack{
            // MARK: User details

            Spacer()

            VStack {
                Text("\(agoraVM.currentCallUser)")
                    .font(.title)
                Text(agoraVM.currentCallState.rawValue)
                    .font(.footnote)
            }
            .foregroundStyle(Color.white)


            Spacer()

            // MARK: Stream Controls
            LazyVGrid(columns: columns, spacing: 16) {
                // Mic
                VStack(alignment: .center) {
                    Image(systemName:  "mic.slash.fill")
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(agoraVM.enableMic ? .clear : .white)
                                .stroke(Color.gray, lineWidth: 2.0)
                        )
                        .foregroundStyle(agoraVM.enableMic ? .white : .black)
                        .contentTransition(.symbolEffect)
                        .onTapGesture {
                            withAnimation {
                                agoraVM.toggleMic()
                            }
                        }

                    Text("mute")
                        .font(.callout)
                        .bold()
                        .lineLimit(1)
                        .contentTransition(.identity)
                }

                // Speakerphone
                VStack(alignment: .center) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(agoraVM.enableSpeaker ? .white : .clear)
                                .stroke(Color.gray, lineWidth: 2.0)
                        )
                        .foregroundStyle(agoraVM.enableSpeaker ? .black : .white)
                        .contentTransition(.symbolEffect)
                        .onTapGesture {
                            withAnimation {
                                agoraVM.toggleSpeakerPhone()
                            }
                        }

                    Text("speaker")
                        .font(.callout)
                        .bold()
                        .lineLimit(1)
                        .contentTransition(.identity)
                }

            }
            .foregroundStyle(.white)

            .padding()

            Spacer()

            // MARK: End Call
            Image(systemName:  "phone.down.fill")
                .foregroundStyle(.white)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .frame(width: 50, height: 50)
                .padding(12)
                .background(Color.red)
                .clipShape(Circle())
                .padding(.bottom, 80)

        }
        .ignoresSafeArea(.all)
//        .background(Color.black.opacity(0.8))
        .background(LinearGradient(colors: [.black.opacity(1), .black.opacity(0.9), .black.opacity(0.75), .black.opacity(0.8), .black.opacity(1)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    InCallAudioView()
        .environmentObject(AudioCallKitViewModel())
}
