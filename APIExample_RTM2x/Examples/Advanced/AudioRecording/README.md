<a name="readme-top"></a>


<!-- ### Architecture

![alt text](../../../../MyAssets/Arch_Polling.png) -->


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

This sample showcases how to send audio recordings. 

| Subscribe features | Description |
| --- | --- |
| `.message` | Callback to receive all messages of a subscribed channel  |
| `.presence` | Callback to get the users states (e.g join/leave/userstates) of a channel |


#### Set the Microphone permission from Your_project > Target > Info 

"Privacy - Microphone Usage Description" - "For recording audio files"



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


**Recording Audio Functions**
```swift
// Make sure import AVFoundation
import AVFoundation

var audioRecorder: AVAudioRecorder! // For recording audio files
var audioPlayer: AVAudioPlayer! // For playing audio files


// MARK: RECORDING/STOPPING
let localDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let recordingURL = localDirectory.appendingPathComponent("filename_recording.m4a")

let settings = [
    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
    AVSampleRateKey: 12000,
    AVNumberOfChannelsKey: 1,
    AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
]

// Start Recording
do {
    try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)

    audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
    audioRecorder.record()
    isRecording = true
} catch {
    print("Recording failed")
}

// Stop Recording
audioRecorder.stop()
audioRecorder = nil


// MARK: PLAY AUDIO FILE 
do {
    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

    audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
    audioPlayer.prepareToPlay()
    audioPlayer.play()
} catch {
    print("Failed to play audio file \(fileURL): \(error)")
}

// MARK: DELETE ALL AUDIO FILE
let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
let audioFileURLs = fileURLs.filter({ $0.pathExtension == "m4a" })

for audioFileURL in audioFileURLs {
    try fileManager.removeItem(at: audioFileURL)
    print("File \(audioFileURL.lastPathComponent) was deleted.")
}

```

**Publish a Audio Message**
```swift
// Since the message size is 32KB, you'll need to split the audio file into chunks of 32KB then publish them one-by-one
func publishToChannel(channelName: String, audioData: Data) async -> Bool{
    // Split the audio into 32KB chunks
    let dataChunks = splitDataIntoChunks(data: audioData)

    // PART 1 :  First send the audio file info to receivers to let them know there is an incoming audio file with filesize dataChunks.count
    let pubOptions = AgoraRtmPublishOptions()
    pubOptions.channelType = .message
    pubOptions.customType = audioFileInfoType
    
    if let (_, error) = await agoraRtmKit?.publish(channelName: channelName, message: "\(dataChunks.count)", option: pubOptions){
        if error == nil {
            // Publish successful
        }else{
            print("publishToChannel audioFileInfoType failed ")
            return false
        }
    }
    
    // PART 2: Then send each datachunk to the remote users
    let pubOptions2 = AgoraRtmPublishOptions()
    pubOptions2.channelType = .message
    pubOptions2.customType = audioChunkType
    
    // Publish each chunk one-by-one
    for dataChunk in dataChunks {
        if let (_, error) = await agoraRtmKit?.publish(channelName: channelName, data: dataChunk, option: pubOptions2){
            if error == nil {
                // Publish successful
            }else{
                // Publish failed
            }
        }
    }
    

    return false
}

```

**Relevant Functions**
```swift
// Convert the Audiofile to DATA type
func convertAudioToData(fileName: String) -> Data? {
    let audioFileURL = getDocumentsDirectory().appendingPathComponent(fileName)
    do {
        let audioData = try Data(contentsOf: audioFileURL)
        return audioData
    } catch {
        print("Failed to get data from audio file")
    }
    return nil
}

// Convert DATA to AudioFile
func convertDataToAudio(data: Data, sender: String) -> URL? {
    do {
        let tempFileURL = getDocumentsDirectory().appendingPathComponent("\(sender)_\(Date().timeIntervalSince1970)_recording.m4a")
        
        try data.write(to: tempFileURL)
        
        return tempFileURL
    } catch {
        print("Failed to convert data to audio: \(error)")
    }
    
    return nil
}

// Split DATA to 32KB chunks 
func splitDataIntoChunks(data: Data, chunkSize: Int = 30720) -> [Data] {
    var offset = 0
    var chunks = [Data]()
    
    while offset < data.count {
        let length = min(chunkSize, data.count - offset)
        let chunk = data.subdata(in: offset..<(offset+length))
        chunks.append(chunk)
        offset += length
    }
    return chunks
}
    

// Combine chunks into whole DATA 
func combineDataChunks(chunks: [Data]) -> Data {
    var combinedData = Data()
    for chunk in chunks {
        combinedData.append(chunk)
    }
    return combinedData
}
```


**Logout RTM**
```swift
// Logout RTM server
func logoutRTM(){
    agoraRtmKit?.logout()
    agoraRtmKit?.destroy()

    // call delete all function to delete all audio files stored in local directory
    deleteAllAudioFiles()
}
```

**Setup RTM Callbacks**
```swift
// Receive 'message' event notifications in subscribed message channels and subscribed topics.
func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceiveMessageEvent event: AgoraRtmMessageEvent) {
    switch event.channelType {
    case .message:
        print("Received msg = \(event.message.stringData ?? "Empty") from \(event.publisher)")
        if event.customType == audioFileInfoType { 
            // Remote user event.publisher is sending an audio file with length event.message.stringData 
        }
        else if event.customType == audioChunkType { 
            // Remote user receiving the chunks of audio files 
            // Combine them into one 
            // audioChunks.append(event.message.rawData)
        }
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

// Receive 'presence' event notifications in subscribed message channels and joined stream channels.
func rtmKit(_ rtmKit: AgoraRtmClientKit, didReceivePresenceEvent event: AgoraRtmPresenceEvent) {

    if event.type == .remoteLeaveChannel || event.type == .remoteConnectionTimeout {
    // A remote user left the channel
        
    }else if event.type == .remoteJoinChannel && event.publisher != nil {
     // A remote user subscribe the channel
        
    }else if event.type == .snapshot {
    // Get a snapshot of all the subscribed users' including 'presence' data (aka temporary key-value pairs storage)
        
    }else if event.type == .remoteStateChanged {
    // A remote user's 'presence' data was changed
    }
}
```




<!-- RTM API Limitation -->
## References

- API Reference (https://docs.agora.io/en/signaling/reference/api?platform=ios)
- Pricing (https://docs.agora.io/en/signaling/overview/pricing?platform=ios)
- API Limitations (https://docs.agora.io/en/signaling/reference/limitations?platform=android)
- Security/Compliance (https://docs.agora.io/en/signaling/reference/security?platform=android) 



<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- Note -->
## Note
- This sample is using a customType property to differentiate whether an incoming message is a poll question or poll answer. 
    - (Alternativel) You could also subscribe to 2 channels. 1 to publish the poll question, and 1 to receive the poll answers. 
    - (Alternative 2) You could also use the `.presence` to update publish the answer
- This sample is designed where every user will receive everyone's poll answer in real-time. This is helpful if you want to display the score or number of submissions in real-time. The number of messages (aka cost) increases **exponentially** the more users in the channel. 
    - (Alternative) You could design a solution where only the publisher receives the poll answers from the user. After certain time, the host can send the poll result back to the users. The number of messages (aka cost) increases **linearly**. 
    - (Alternative 2) You could design a solution where Linux Server (Agora Linux SDK) to manage all the answers and send back the poll result back to the users after a certain time.  **linearly**. 


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Bac Huang  - bac@boldbright.studio

Project Link: [https://github.com/Bac1314/APIExample_AgoraRTM2x](https://github.com/Bac1314/APIExample_AgoraRTM2x)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



