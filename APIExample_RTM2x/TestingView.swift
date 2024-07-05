//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI
import AVFoundation


struct TestingView: View {
    @State private var isTopRightCorner = true

    var body: some View {
        ZStack(alignment: .top){
            Button {
                let urlString = "https://bin.bnbstatic.com/static/live-ag/10212909921185/1fc7fc3f2d4fb874a8209aa4e78543f4_10212909921185.m3u8"
                guard let url = URL(string: urlString) else {
                    return
                }

                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)

                let player = AVPlayer(playerItem: playerItem)
                player.play()
                
                print("Reached here")
            } label: {
                Text("Load and play ")
            }

        }
     
    }
}

#Preview {
    struct Preview: View {

        var body: some View {
            TestingView()
        }
    }
    
    return Preview()
}
