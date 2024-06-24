//
//  AgoraRemoteUIView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/6/24.
//

import Foundation
import SwiftUI
import AgoraRtcKit

struct AgoraRemoteUIView : UIViewRepresentable {
    @EnvironmentObject var agoraModel: VideoCallInviteViewModel
    
    func makeUIView(context: Context) -> some UIView {
        let UIview: UIView = UIView()
        agoraModel.setupRemoteView(remoteView: UIview)
        return UIview
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
      
    }
    
}
