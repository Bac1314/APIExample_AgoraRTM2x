//
//  AudioItemView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/28.
//

import SwiftUI

struct AudioItemView: View {
    var audioMessage: AudioMessage
    var currentUser: String
    
    var body: some View {
        if currentUser == audioMessage.sender {
            HStack {
                Image(systemName: "person.crop.circle")
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(audioMessage.sender)")
                        .padding(.leading, 4)
                    
                    HStack {
                        Image(systemName: "dot.radiowaves.right")
                        Text("\(audioMessage.duration)s")
                        Spacer()
                    }
                    .frame(width: max(60 ,min(CGFloat(audioMessage.duration) * 20, 200)))
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }

                
                Spacer()
            }
        }else {
            HStack {
                
                Spacer()

             
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(audioMessage.sender)")
                        .padding(.trailing, 4)
                    
                    HStack {
                        Spacer()
                        Text("\(audioMessage.duration)s")
                        Image(systemName: "dot.radiowaves.right")
                            .scaleEffect(x: -1, y: 1)
                    }
                    .frame(width: max(60 ,min(CGFloat(audioMessage.duration) * 20, 200)))
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }

                Image(systemName: "person.crop.circle")
                    .font(.title)
                
            }
        }
    }
}

#Preview {
    AudioItemView(audioMessage: AudioMessage(id: UUID(), fileName: "filename", fileURL: URL(string: "/someting/something")!, sender: "bac", duration: 4 ), currentUser: "bac2")
}
