<a name="readme-top"></a>


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

This sample showcases how to send virtual gifts or emojis with Agora RTM SDK. Upload the gifts asset to your project (or through cloud storage like S3). In the UI, list the assets to the users. When the users tap a particular asset, use RTM to publish the asset name to the users in the same channel. RTM is used to send the gift name, while SwiftUI is used to display and animate the gifts

| Subscribe features | Description |
| --- | --- |
| `.message` | Callback to receive all messages of a subscribed channel |
| `.presence` | Callback to get the users states (e.g join/leave/userstates) |



<!-- Sample Code -->
## Sample Code

**Initialize the Agora RTM SDK**
```swift
// Initialize the Agora RTM SDK
let config = AgoraRtmClientConfig(appId: "your_app_id" , userId: "user_id")
var agoraRtmKit: AgoraRtmClientKit = try AgoraRtmClientKit(config, delegate: self)
```

**Login to Agora Server**
```swift
// Login to Agora Server
if let (response, error) = await agoraRtmKit?.login("user_token") {
    if error == nil{
       // Login successful
    }else{
      // Login failed
    }
} else {
    // Login failed
}
```

**Subscribe to a Channel**
```swift
// Define the subscription feature
let subOptions: AgoraRtmSubscribeOptions = AgoraRtmSubscribeOptions()
subOptions.features =  [.message, .presence]

// Subscribe to a channel  
if let (response, error) = await agoraRtmKit?.subscribe(channelName: channelName, option: subOptions){
    if error == nil{
       // Subscribe successful
    }else{
      // Subscribe failed
    }
}
```

**Publish a Gift Asset**
```swift
// Define the publish options
let pubOptions = AgoraRtmPublishOptions()
pubOptions.channelType = .message
pubOptions.customType = "customGiftType" // if you want to categorize the message


// Publish message to a channel  
if let (response, error) = await agoraRtmKit?.publish(channelName: channelName, message: giftAssetName, option: pubOptions){
    if error == nil {
        // Publish successful
        // Append gift to array e.g. gifts.append(giftAssetName)
    }else{
        // Publish failed
    }
    
}
```


**Logout RTM**
```swift
// Logout RTM server
func logoutRTM(){
    agoraRtmKit?.logout()
    agoraRtmKit?.destroy()
}
```

**Setup RTM Callbacks**
```swift
// Receive 'message' event notifications in subscribed message channels and subscribed topics.
func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
    switch event.channelType {
    case .message:
        print("Received msg = \(event.message.stringData ?? "Empty") from \(event.publisher)")
        // Received a new gift, display it 
        break
    case .stream:
        break
    case .user:
        break
    case .none:
        break
    @unknown default:
    }
}

```
**Gift View to animate the gifts**
```swift
struct GiftView: View {
    @State var offset: CGSize = .zero
    @State var opacity: Double = 1.0
    @State var scale: Double = 1.0
    var gift : Gift

    var body: some View {
        VStack {
            Image(gift.gift)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .opacity(opacity)
                .offset(offset)
                .scaleEffect(CGSize(width: 1.0*scale, height: 1.0*scale))
                .onAppear {
                    animateGift()
                }
        }
    }

    private func animateGift() {

        withAnimation(.interactiveSpring(duration: 8)) {
            offset = CGSize(width: Int.random(in: -100..<100), height: -600) // Adjust height as needed
            opacity = 0.0
            scale = 1.5
        }
        
    }
}

// In the mainview 
...
ForEach(giftarray) { giftInstance in
    GiftView(gift: giftInstance)
        .transition(.move(edge: .top))
        .zIndex(1) // Ensure gifts are on top
}
...

```



<!-- RTM API Limitation -->
## References

- API Reference (https://docs.agora.io/en/signaling/reference/api?platform=ios)
- Pricing (https://docs.agora.io/en/signaling/overview/pricing?platform=ios)
- API Limitations (https://docs.agora.io/en/signaling/reference/limitations?platform=android)
- Security/Compliance (https://docs.agora.io/en/signaling/reference/security?platform=android) 



<p align="right">(<a href="#readme-top">back to top</a>)</p>





<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Bac Huang  - bac@boldbright.studio

Project Link: [https://github.com/Bac1314/APIExample_AgoraRTM2x](https://github.com/Bac1314/APIExample_AgoraRTM2x)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



