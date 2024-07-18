//
//  BiddingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/15.
//

import SwiftUI
import AVFoundation
import AgoraRtmKit

struct BiddingView: View {
    @StateObject var agoraRTMVM: BiddingViewModel = BiddingViewModel()
    @State var isLoading: Bool = false
    
    var serviceIcon: String = "message"
    
    // show alert
    @State var showAlert: Bool = false
    @State var alertMessage: String = "Error"
    
    @State var showCustomAmountAlert: Bool = false
    @State var customAmount: Int = 0
    
    @FocusState private var keyboardIsFocused: Bool
    
    // bidding properties
    //    @State var tenMoreDollars: Int = 0
    @Binding var path: NavigationPath

    
    var body: some View {
        ZStack(alignment: .center){
            
            // MARK: LOGIN VIEW
            if !agoraRTMVM.isLoggedIn {
                LoginRTMView(isLoading: $isLoading, userID: $agoraRTMVM.userID, token: $agoraRTMVM.token, channelName: $agoraRTMVM.mainChannel, isLoggedIn: $agoraRTMVM.isLoggedIn, icon: serviceIcon,  streamToken: .constant(""))  {
                    Task {
                        do{
                            try await agoraRTMVM.loginRTM()
                            let _ = await agoraRTMVM.subscribeChannel(channelName: agoraRTMVM.mainChannel)
                        }catch {
                            if let agoraError = error as? AgoraRtmErrorInfo {
                                alertMessage = "\(agoraError.code) : \(agoraError.reason)"
                            }else{
                                alertMessage = error.localizedDescription
                            }
                            withAnimation {
                                isLoading = false
                                showAlert.toggle()
                            }
                        }
                    }
                }
            }
            
            // MARK: Main View
            if agoraRTMVM.isLoggedIn {
                if let currentAuctionItem = agoraRTMVM.currentAuctionItem {
                    VStack{
                        AuctionItemView(currentAuction: currentAuctionItem)
                            .id(currentAuctionItem.id)
                        //                            .transition(.slide)
                            .animation(.easeInOut, value: 2)
                            .onChange(of: currentAuctionItem.id) { oldValue, newValue in
                                playCashsound()
                            }
                        
                        Spacer()
                        
                        
                        if (currentAuctionItem.highestBidder == agoraRTMVM.userID){
                            Text("You are the highest bidder!")
                        }
                        
                        // Buttons to place bid
                        HStack {
                            // Submit 10 more dollars
                            Button(action: {
                                Task {
                                    let newAmount = (agoraRTMVM.currentAuctionItem?.currentBid ?? 0)  + 10
                                    print("Bid amount \(newAmount)")
                                    let success = await agoraRTMVM.sendBidPrice(price: newAmount)
                                    
                                    if success {
                                        playCashsound()
                                    }
                                }
                            }, label: {
                                Text("Bid $\((agoraRTMVM.currentAuctionItem?.currentBid ?? 0) + 10)")
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity, minHeight: 80)
                                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.accentColor))
                                    .foregroundStyle(Color.white)
                                    .font(.title3)
                                    .contentTransition(.numericText())
                                
                            })
                            
                            Spacer()
                            
                            
                            // Add custom amount
                            Button(action: {
                                Task {
                                    withAnimation {
                                        showCustomAmountAlert.toggle()
                                    }
                                }
                            }, label: {
                                Text("CUSTOM AMOUNT")
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity, minHeight: 80)
                                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.gray.opacity(0.5)))
                                    .foregroundStyle(Color.white)
                            })
                        }
                        //.disabled(currentAuctionItem.highestBidder == agoraRTMVM.userID)
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        // MARK: Show login user and channel
                        Text("Username: \(agoraRTMVM.userID) | Channel: \(agoraRTMVM.mainChannel)")
                            .minimumScaleFactor(0.8)
                    }
                    
                }
                else {
                    // Create a new auction
                    Button(action: {
                        Task {
                            await agoraRTMVM.publishNewAuction(auctionName: "Charizard PSA 10", startingPrice: 10)
                        }
                    }, label: {
                        Text("Create new auction")
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.accentColor))
                            .foregroundStyle(Color.white)
                            .font(.title3)
                            .contentTransition(.numericText())
                    })
                }
            }
            
            
            // MARK: SHOW CUSTOM ALERT
            if showAlert {
                CustomAlert(displayAlert: $showAlert, title: "Alert", message: alertMessage)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(agoraRTMVM.isLoggedIn ? "Live Bidding" : "Login")
        .toolbar{
            // Back button
            ToolbarItem(placement: .topBarLeading) {
                Button(action : {
                    agoraRTMVM.logoutRTM()
                    if path.count > 0 {
                        path.removeLast()
                    }
                }){
                    HStack{
                        Image(systemName: "arrow.left")
                        Text(agoraRTMVM.isLoggedIn ? "Logout"  : "Back")
                    }
                }
            }
            
            if agoraRTMVM.isLoggedIn && agoraRTMVM.currentAuctionItem != nil {
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        Task {
                            let _ = await agoraRTMVM.deleteAuctionStorage()
                        }
                    }, label: {
                        Text("Delete")
                    })
                }
            }
        }
        .alert("Enter custom amount", isPresented: $showCustomAmountAlert, actions: {
            //            TextField("Bid value", text: $customAmount)
            //                .focused($keyboardIsFocused)
            //                .keyboardType(.decimalPad)
            
            TextField("Bid Value", value: $customAmount, format: .number)
                .focused($keyboardIsFocused)
                .keyboardType(.decimalPad)
            
            Button("Submit", action: {
                Task{
                    print("Bac's submitting bid \(customAmount)")
                    let result = await agoraRTMVM.sendBidPrice(price: customAmount)
                    customAmount = result ? 0 : customAmount //Reset
                    keyboardIsFocused = result
                }
            })
            .disabled(customAmount < agoraRTMVM.currentAuctionItem?.currentBid ?? 0)
            
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Submit a new bid")
        })
    }
    
    func playCashsound(){
        AudioServicesPlaySystemSound(SystemSoundID(1110)) // vibrate
        AudioServicesPlaySystemSound(SystemSoundID(1016)) // sound
        
    }
}

#Preview {
    BiddingView(path: .constant(NavigationPath()))
}
