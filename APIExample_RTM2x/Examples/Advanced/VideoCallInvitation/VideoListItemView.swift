//
//  VideoListItemView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/6/21.
//

import SwiftUI

struct VideoListItemView: View {
    @State var userName: String = "Noname"
    var onButtonTap: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(userName)
            
            Spacer()
            
            Button {
                // Call tapped
                self.onButtonTap?()
            } label: {
                Image(systemName: "phone.arrow.up.right")
                    .foregroundStyle(.white)
                    .imageScale(.large)
                    .padding(8)
                    .background(Color.green)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            }
        }
        .padding()
    }
}

#Preview {
    VideoListItemView(userName: "Bac")
}
