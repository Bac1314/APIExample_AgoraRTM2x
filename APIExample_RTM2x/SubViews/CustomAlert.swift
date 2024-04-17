//
//  CustomAlert.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI

struct CustomAlert: View {
    @Binding var displayAlert: Bool
    var image: String = "exclamationmark.triangle.fill"
    var title: String = "Default title"
    var message: String = "Default message"
    var colorscheme: Color = .red
    @FocusState var textfieldInFocus: Bool
    
//    var onButtonTap: (Int) -> Void

    var body: some View {
        VStack {
            
            Image(systemName: image)
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(colorscheme)
                .padding()
            
            Text(title)
                .font(.headline)
                .padding(.vertical, 5)
            
            Text(message)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
            

            
            Button {
                displayAlert.toggle()
            } label: {
                Text("Okay")
            }
            .padding()
            .buttonStyle(.bordered)
            
        }
        .frame(minWidth: 300)
        .background(Color.white)
        .foregroundStyle(Color.black)
        .cornerRadius(16)
//        .aspectRatio(40/30, contentMode: .fit) // Aspect ratio of credit card
        .padding(24)
        .shadow(radius: 10)
        .onAppear(perform: {
            textfieldInFocus.toggle()
            
        })
        
        
        
    }
}

#Preview {
    CustomAlert(displayAlert: .constant(true), image: "exclamationmark.triangle.fill",
                title: "Alert",
                message: "Alert message2 ")
}
