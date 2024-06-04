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


**File Functions**
```swift


```

**Publish The File**
```swift
@MainActor
func publishToChannel(channelName: String, fileURL: URL) async -> Bool{
    
    if let fileData = convertFileToData(fileURL: fileURL), !fileURL.pathExtension.isEmpty {
        // Split the file into 32KB chunks
        let dataChunks = splitDataIntoChunks(data: fileData)
        
        // PART 1 :  First send the file info to receivers to let them know there is an incoming  file with filesize dataChunks.count
        let pubOptions = AgoraRtmPublishOptions()
        pubOptions.channelType = .message
        pubOptions.customType = fileInfoKey
        
        let fileInfo = FileInfo(id: UUID(), name: fileURL.lastPathComponent, countOf32KB: dataChunks.count, type: fileURL.pathExtension, url: "", owner: userID)
        
        if let JSONString = convertObjectToJsonString(object: fileInfo) {
            if let (_, error) = await agoraRtmKit?.publish(channelName: channelName, message: JSONString, option: pubOptions){
                if error == nil {
                    // Success - Add local record
                }else{
                    // Failed
                    return false
                }
            }
        }

        // PART 2 : Send the chunk files one by one
        let pubOptions2 = AgoraRtmPublishOptions()
        pubOptions2.channelType = .message
        pubOptions2.customType = fileChunkKey

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
        
        return true
    }
    
    return false
}

```

**Relevant Functions**
```swift
// MARK: FUNCTION TO RETRIEVE THE ACTUAL FILES ON LOCAL DIRECTORY
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
    
}

// MARK: FILE AND DATA CONVERSION
func convertFileToData(fileURL: URL) -> Data? {
    do {
        let fileData = try Data(contentsOf: fileURL)
        return fileData
    } catch {
        print("Failed to get data from file")
    }
    return nil
}

// MARK：Save the file to local storage
func convertSaveDataToFile(data: Data, fileName: String, fileType: String, sender: String) -> URL? {
    do {
        let tempFileURL = getDocumentsDirectory().appendingPathComponent("\(fileName)")
        
        try data.write(to: tempFileURL)
        
        return tempFileURL
    } catch {
        print("Failed to convert data to file: \(error)")
    }
    
    return nil
}

// MARK： Split the file ino chunks of 32KB since Message Channel packet size is 32KB
func splitDataIntoChunks(data: Data, chunkSize: Int = 32000) -> [Data] {
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

// MARK: After received all the data chunks, combine them into one file 
func combineDataChunks(chunks: [Data]) -> Data {
    var combinedData = Data()
    for chunk in chunks {
        combinedData.append(chunk)
    }
    return combinedData
}


func deleteAllFiles() {
    let fileManager = FileManager.default
    let documentsURL = getDocumentsDirectory()
    
    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        
        for file in fileURLs {
            try fileManager.removeItem(at: file)
            print("File \(file.lastPathComponent) was deleted.")
        }
        
    } catch {
        print("An error occurred while deleting files: \(error)")
    }
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
        if event.customType == fileInfoKey { 
            // Remote user event.publisher file details (e.g. size, name, type, etc)
        }
        else if event.customType == fileChunkKey { 
            // Remote user receiving the chunks of file
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
- (Alternative) You could upload the files to a cloud storage (e.g. AWS S3), then send the download link via RTM 


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Bac Huang  - bac@boldbright.studio

Project Link: [https://github.com/Bac1314/APIExample_AgoraRTM2x](https://github.com/Bac1314/APIExample_AgoraRTM2x)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



