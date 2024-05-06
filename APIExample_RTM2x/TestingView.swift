//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI

struct TestingView: View {
    
    @State var avatarImageNames : [String] = [
        "avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6", "avatar7", "avatar8", "avatar9", "avatar10", "avatar11", "avatar12"
    ]

    var body: some View {
        

        ScrollView(.horizontal) {
            HStack{
                ForEach(avatarImageNames, id: \.self) { imageName in
                      Image(imageName)
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(width: 100, height: 100)
                          .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
                }
            }

        }
    }
}


#Preview {
    struct Preview: View {
//        @State private var currentDrawing: Drawing = Drawing()
//        @State private var drawings: [Drawing] = [Drawing]()
//        
        var body: some View {
            TestingView()
        }
    }
    
    return Preview()
}
