//
//  AgoraUIView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/6/21.
//
import Foundation
import SwiftUI
import AgoraRtcKit

struct AgoraLocalUIView : UIViewRepresentable {
    @EnvironmentObject var agoraModel: VideoCallInviteViewModel
    
    func makeUIView(context: Context) -> some UIView {
        let UIview: UIView = UIView()
        agoraModel.setupLocalView(localView: UIview)
        return UIview
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
      
    }
    
}
