//
//  CustomModifiers.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/30.
//

import SwiftUI

struct CustomRectangleOutline: ViewModifier {
    @Binding var isEditing: Bool
    
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .font(.headline)
            .padding(isEditing ? 12 : 0)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray, lineWidth: isEditing ? 1.0 : 0.0)
            )
    }
}

struct CustomRoundedRect: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .bold()
            .imageScale(.large)
            .padding(5)
            .foregroundStyle(Color.black)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .foregroundStyle(Color.white.opacity(0.5))
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            )
    }
}

