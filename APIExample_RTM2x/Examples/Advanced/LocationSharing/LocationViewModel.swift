//
//  LocationViewModel.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/17.
//

import Foundation
import SwiftUI
import AgoraRtmKit
import MapKit

class LocationViewModel: NSObject, ObservableObject {
    
    var agoraRtmKit: AgoraRtmClientKit? = nil
    @AppStorage("userID") var userID: String = ""
    @AppStorage("userToken") var token: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    
    let mainChannel = "ChannelA" // to publish the storage

    // Location Properties
    let locationManager = CLLocationManager()
    @Published var localRegion = MKCoordinateRegion()
    @Published var remoteRegion : [String : MKCoordinateRegion] = [:] // List of username and their location
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationAuthorization()
    }
    
    private func requestLocationAuthorization() {
      switch locationManager.authorizationStatus {
      //If we are authorized then we request location just once,
      // to center the map
      case .authorizedWhenInUse:
        locationManager.requestLocation()
      //If we don´t, we request authorization
      case .notDetermined:
          locationManager.startUpdatingLocation()
          locationManager.requestWhenInUseAuthorization()
      default:
        break
      }
    }
    
    @MainActor
    func loginRTM() async throws {
        do {
            if userID.isEmpty {
                throw customError.emptyUIDLoginError
            }
            
            if token.isEmpty {
                throw customTokenError.tokenEmptyError
            }
            
            // Initialize RTM instance
            if agoraRtmKit == nil {
                let config = AgoraRtmClientConfig(appId: Configurations.agora_AppdID , userId: userID)
                agoraRtmKit = try AgoraRtmClientKit(config, delegate: self)
            }
            
            if let (response, error) = await agoraRtmKit?.login(token) {
                if error == nil{
                    isLoggedIn = true
                }else{
                    print("Bac's code loginRTM login result = \(String(describing: response?.description)) | error \(String(describing: error))")
                    throw error ?? customError.loginRTMError
                }
            } else {
                // Handle any cases where login fails or error is present
                print("Bac's code loginRTM login result = \(userID)")
            }
            
        }catch {
            print("Bac's Some other error occurred: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Logout RTM server
    func logoutRTM(){
        agoraRtmKit?.logout()
        agoraRtmKit?.destroy()
        isLoggedIn = false
    }
    
    //MARK: Storage/MetaData/Bidding functions
    @MainActor
    func subscribeChannel(channelName: String) async -> Bool {
        let subOptions: AgoraRtmSubscribeOptions = AgoraRtmSubscribeOptions()
        subOptions.features =  [.message, .presence]
                
        if let (_, error) = await agoraRtmKit?.subscribe(channelName: channelName, option: subOptions){
            if error == nil {
                return true
            }
            return false
        }
        
        return false
    }


    
}


extension LocationViewModel: AgoraRtmClientDelegate {
    
    // Receive message event notifications in subscribed message channels and subscribed topics.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
        switch event.channelType {
        case .message:
            
            break
        case .stream:
            break
        case .user:
            break
        case .none:
            break
        @unknown default:
            print("Bac's didReceiveMessageEvent channelType is unknown")
        }
    }
    
    // Receive presence event notifications in subscribed message channels and joined stream channels.
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceivePresenceEvent event: AgoraRtmPresenceEvent) {
        print("Bac's didReceivePresenceEvent channelType \(event.channelType) publisher \(String(describing: event.publisher)) channel \(event.channelName) type \(event.type) ")
        
        if event.type == .remoteLeaveChannel || event.type == .remoteConnectionTimeout {

        }else if event.type == .remoteJoinChannel && event.publisher != nil {
            print("Bac's didReceivePresenceEvent remoteJoinChannel publisher: \(event.publisher ?? "")")

            
        }else if event.type == .snapshot {
            print("Bac's didReceivePresenceEvent snapshot")
 
            
        }else if event.type == .remoteStateChanged {
            print("Bac's didReceivePresenceEvent remoteStateChanged user:\(event.publisher ?? "")")

        }
    }
    
    // Receive storage event
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveStorageEvent event: AgoraRtmStorageEvent) {
        if event.storageType == .channel {
            // Channel Metadata is udpated
        }
    }
    
    func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveLockEvent event: AgoraRtmLockEvent) {
    }
    
    // Triggers when connection changes
    func rtmKit(_ kit: AgoraRtmClientKit, channel channelName: String, connectionChangedToState state: AgoraRtmClientConnectionState, reason: AgoraRtmClientConnectionChangeReason) {
        print("Bac's connectionChangedToState \(state) reason \(reason.rawValue)")
        connectionState = connectionState
    }
}


//MARK: MapKit Callbacks
extension LocationViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Authorization change
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Sometime failed
        print("Bac's didFailWithError \(error) ")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Local user info is updated

        print("Bac's didUpdateLocations ")

        locations.last.map {
              localRegion = MKCoordinateRegion(
                  center: $0.coordinate,
                  span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
              )
            
            print("Bac's didUpdateLocations latitute \(localRegion.center.latitude) longitude \(localRegion.center.longitude) ")

          }
    }
}

