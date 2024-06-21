//
//  AgoraUIView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/6/21.
//
import Foundation
import SwiftUI
import AgoraRtcKit

struct AgoraUIView : UIViewRepresentable {
//    @EnvironmentObject var agoraModel: AgoraRTCViewModel
    
    func makeUIView(context: Context) -> some UIView {
        let agoraUIView: UIView = UIView()
//        agoraModel.setupLocalView(localView: agoraUIView)
        
        return agoraUIView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
      
    }
    
}
