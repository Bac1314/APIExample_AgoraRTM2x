//
//  LoginAgoraRTMView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/21.
//

import SwiftUI


struct LoginRTMView: View {
    
    //    @EnvironmentObject var agoraRTMVM: AgoraRTMViewModel
    @Binding var isLoading: Bool
    @Binding var userID: String
    @Binding var token: String
    @Binding var isLoggedIn: Bool
    var icon: String = "message"
    var onButtonTap: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: LOGIN VIEW
                VStack {
                    Image(systemName: icon)
                        .frame(width: 80, height: 80)
                        .aspectRatio(1.0, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .font(.system(size: 60))
                        .padding()
                        .background(LinearGradient(colors: [Color.accentColor, Color.blue, Color.accentColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundStyle(Color.white.gradient)
                        .cornerRadius(24)
                        .shadow(radius: 5)
                        .padding(.vertical, 100)
                    
                    Spacer()
                    
                    TextField("UserName", text: $userID)
                        .textFieldStyle(.roundedBorder)
                        .font(.headline)
                    
                    TextField("Token", text: $token)
                        .textFieldStyle(.roundedBorder)
                        .font(.headline)
                    
                    Button {
                        isLoading = true
                        self.onButtonTap?()
                    } label: {
                        Text("Login to Agora")
                    }
                    .padding()
                    .buttonStyle(.bordered)
                    .disabled(userID.isEmpty)
                    
                    
                    Spacer()
                }
                .padding()
                
                
                // MARK: Loading Icon
                if isLoading {
                    ProgressView()
                        .scaleEffect(CGSize(width: 3.0, height: 3.0))
                }
            }
            .onChange(of: isLoggedIn) { oldValue, newValue in
                if newValue {
                    isLoading = false
                    
                }
            }
        }
    }
}

#Preview {
    LoginRTMView(isLoading: .constant(true), userID: .constant("Bac"), token: .constant("jaisodjioajsiodhio1h2312"), isLoggedIn: .constant(false), icon: "person.2")
    
}



