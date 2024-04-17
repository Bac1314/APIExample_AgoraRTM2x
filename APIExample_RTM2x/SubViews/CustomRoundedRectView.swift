//
//  CustomPillView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/19.
//

import SwiftUI

struct CustomRoundedRectView: View {
    var title: String = "channel"
    var color: Color = .accentColor
    @Binding var selectedValue: String
    
    
    var body: some View {
        
        Text(title)
            .foregroundColor(Color.white)
            .textCase(.lowercase)
            .padding(10)
            .background(title == selectedValue ? color : Color.gray.opacity(0.5))
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
            .padding(3)
            .overlay(
                RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)).stroke(color, lineWidth: title == selectedValue ? 2 : 0)
            )
            .padding(3)
        
    }
}

#Preview {
    CustomRoundedRectView(title: "general", selectedValue: .constant("general"))
}
