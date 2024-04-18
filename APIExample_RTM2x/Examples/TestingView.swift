//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI

struct TestingView: View {
    // define your custom date
    var customDate: Date = Date().addingTimeInterval(10)
    @State var dic : [String: String] = ["key1":"value1", "key2":"value2"]
    @State var count = 3

    var body: some View {

        Image(systemName: "person")
            .resizable()
            .padding(12)
//            .foregroundStyle( user.userId == agoraRTMVM.userID ? .red : .blue)
            .frame(width: 50, height: 50)
            .background(.green)
            .clipShape(.circle)
    }
}

#Preview {
    TestingView()
}
