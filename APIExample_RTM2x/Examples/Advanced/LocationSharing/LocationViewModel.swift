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
    @Published var token: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var connectionState: AgoraRtmClientConnectionState = .disconnected
    
    @Published var mainChannel = "LocationRootChannel" // to publish the storage
    
    // Location Properties
    @Published var users : [LocationUser] = []
    let locationManager : CLLocationManager = CLLocationManager()
    let locationSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    let latitudeKey = "latitude"
    let longitudeKey = "longitude"
    
    override init() {
        super.init()
        
        requestLocationAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.startUpdatingLocation()
    }
    
    private func requestLocationAuthorization()  {

        Task.detached(priority: .background) {
            switch self.locationManager.authorizationStatus {
                //If we are authorized then we request location just once,
                // to center the map
            case .authorizedWhenInUse:
//                self.locationManager.requestLocation()
                self.locationManager.startUpdatingLocation()
            case .notDetermined:
                self.locationManager.startUpdatingLocation()
                self.locationManager.requestWhenInUseAuthorization()
            
            default:
                break
            }
        }
    }
    
    @MainActor
    func loginRTM() async throws {
        do {
            if userID.isEmpty {
                throw customError.emptyUIDLoginError
            }
            
            // Initialize RTM instance
            if agoraRtmKit == nil {
                let config = AgoraRtmClientConfig(appId: Configurations.agora_AppID , userId: userID)
                agoraRtmKit = try AgoraRtmClientKit(config, delegate: self)
            }
            
            // Login to RTM server
            // Use AppID to login if app certificate is NOT enabled for project
            if let (response, error) = await agoraRtmKit?.login(token.isEmpty ? Configurations.agora_AppID : token) {
                if error == nil{
                    isLoggedIn = true
                }else{
                    print("Bac's code loginRTM login result = \(String(describing: response?.description)) | error \(String(describing: error))")
                    await agoraRtmKit?.logout()
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
    
    // Publish local user location
    func publishLocalLocation(newLocation: MKCoordinateRegion) async -> Bool {
        Task {
            await MainActor.run {
                // Update local view location
                if let userIndex = users.firstIndex(where: {$0.userId == userID}) {
                    // Local User exists
                    users[userIndex].userLocation = newLocation
                }else {
                    // Local user doesn't exists
                    users.append(LocationUser(userId: userID, userLocation: newLocation))
                }
            }
        }

        
        // publish location to remote users
        let itemLatitude = AgoraRtmStateItem()
        itemLatitude.key = latitudeKey
        itemLatitude.value = String(newLocation.center.latitude)
        
        let itemLongitude = AgoraRtmStateItem()
        itemLongitude.key = longitudeKey
        itemLongitude.value = String(newLocation.center.longitude)
        
        if let (_, error) = await agoraRtmKit?.getPresence()?.setState(channelName: mainChannel, channelType: .message, items: [itemLatitude, itemLongitude]){
            if error == nil {
                return true
            }
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
            
            // Remove user from list
            if let userIndex = users.firstIndex(where: {$0.userId == event.publisher}) {
                users.remove(at: userIndex)
            }
            
        }else if event.type == .remoteJoinChannel && event.publisher != nil {
            print("Bac's didReceivePresenceEvent remoteJoinChannel publisher: \(event.publisher ?? "")")

        }else if event.type == .snapshot {
            print("Bac's didReceivePresenceEvent snapshot")
            // Add users to list from snapshop
            for remoteUser in event.snapshot {
                // Update remote location
                if let latitude =  remoteUser.states.first(where: {$0.key == latitudeKey})?.value, let longitude = remoteUser.states.first(where: {$0.key == longitudeKey})?.value{
                    let publisher = remoteUser.userId
                    
                    print("Bac's didReceivePresenceEvent snapshot user \(publisher) latitude \(latitude) longitude \(longitude) ")

                    let newLocation : MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0), span: locationSpan)
                    users.append(LocationUser(userId: publisher, userLocation: newLocation))
                }
            }
            
            
        }else if event.type == .remoteStateChanged {
            print("Bac's didReceivePresenceEvent remoteStateChanged user:\(event.publisher ?? "")")
            
            // Update remote location
            if let latitude =  event.states.first(where: {$0.key == latitudeKey})?.value, let longitude = event.states.first(where: {$0.key == longitudeKey})?.value, let publisher = event.publisher {
                let newLocation : MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0), span: locationSpan)
                
                
                if let userIndex = users.firstIndex(where: {$0.userId == event.publisher}) {
                    print("Bac's didReceivePresenceEvent remoteStateChanged exists")
                    users[userIndex].userLocation = newLocation
                }else {
                    print("Bac's didReceivePresenceEvent remoteStateChanged DOESN'T exists")
                    users.append(LocationUser(userId: publisher, userLocation: newLocation))
                }
            }
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
            let localRegion = MKCoordinateRegion(
                center: $0.coordinate,
                span: locationSpan
            )
            
            Task {
                await publishLocalLocation(newLocation: localRegion)
            }
            
            print("Bac's didUpdateLocations latitude \(localRegion.center.latitude) longitude \(localRegion.center.longitude) ")
            
        }
    }
}

