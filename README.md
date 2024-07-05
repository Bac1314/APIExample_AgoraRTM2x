<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/Bac1314/APIExample_AgoraRTM2x">
    <!-- <img src="images/logo.png" alt="Logo" width="80" height="80"> -->
  </a>

<h3 align="center">Agora Real-time Messaging (RTM) SDK APIExample</h3>


  <p align="center">
    <a href="https://docs.agora.io/en/signaling/reference/api?platform=ios"><strong>Explore the API Reference »</strong></a>

  </p>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

This project showcases how to use Agora RTM SDK to build real-time interactive scenarios such as chat messaging, live bidding, live poll/quiz.

Here is a video 

<!-- [![YouTube Video](https://img.youtube.com/vi/5ZqHV-nf7WY/0.jpg)](https://www.youtube.com/watch?v=5ZqHV-nf7WY) -->

<a href="https://www.youtube.com/watch?v=Qzi5t0L3xLM">
  <img src="https://img.youtube.com/vi/Qzi5t0L3xLM/0.jpg" alt="YouTube Video" style="border-radius: 16px;">
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>


### Built With

* Swift & SwiftUI
* Agora RTM SDK 2.x.x (aka Signaling SDK)
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started


### Prerequisites

* Xcode 13.0+
* Physical iOS device (iPhone or iPad) or simulators


### Installation

1. Create an Agora account and enable the Signaling/RTM product [https://docs.agora.io/en/signaling/get-started/beginners-guide?platform=ios]
2. Enable the Storage Configuration (Storage, User attribute callback, Channel attribute callback, and Distributed Lock)
3. Clone this repo to your local machine 
   ```
   git clone https://github.com/Bac1314/APIExample_RTM2x.git
   ```
4. Install the RTM SDK through Cocoapods
   ```
   pod install
   ```
5. Enter your API in `Configurations.swift` file
   ```swift
   static let agora_AppdID: String = "Agora App ID"
   ```
6. Build an agora token generator (This is needed to login to RTM server) [https://docs.agora.io/en/signaling/get-started/integrate-token-generation?platform=ios][Agora Token Generator]
7. (Alternative) You can also go to Agora Console to generate temp token for testing [https://console.agora.io/v2/]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

The list of samples and what feature is used


| **Samples**      | **Description**                                                                                      | **RTM ChannelType** | **RTM Features**  |
|------------------|------------------------------------------------------------------------------------------------------|---------------------|-------------------|
| [Channel Messaging](/APIExample_RTM2x/Examples/Basic/ChannelMessaging/) | Build a simple chat system using pub/sub model.                                                      | Message             | `.message`, `.presence` |
| [P2P Messaging](/APIExample_RTM2x/Examples/Basic/P2PMessaging/)     | Peer-to-peer messaging where a user can directly send a message to another user                      | User               | /                 |
| [Stream Messaging](APIExample_RTM2x/Examples/Basic/StreamMessaging/)          | Pub-and-sub model with RTM Stream Channel's topics | Stream             | `.presence`           |
| [Polling](APIExample_RTM2x/Examples/Advanced/Polling/)          | Publish poll question and poll options through the Message Channel.                                  | Message             | `.message`, `.presence` |
| [QuizGame](APIExample_RTM2x/Examples/Advanced/QuizGame/)         | Publish quiz question and answers through Message Channel.                                           | Message             | `.message`, `.presence` |
| [Bidding](APIExample_RTM2x/Examples/Advanced/Bidding/)          | Live bidding scenario where the auction data is stored using the `.storage` channel metadata feature. | Message             | `.storage`           |
| [Location Sharing](APIExample_RTM2x/Examples/Advanced/LocationSharing/)          | Real-time location sharing scenario where the location data is shared through `.presence` states | Message             | `.presence`           |
| [Whiteboard](APIExample_RTM2x/Examples/Advanced/WhiteBoard/)          | Real-time whiteboard collaboration tool  | Message, Stream             | `.message`, `.presence`             |
| [Audio Recording](APIExample_RTM2x/Examples/Advanced/AudioRecording/)          | Send audio recordings directly to users | Message             | `.message`, `.presence`             |
| [File Sharing](APIExample_RTM2x/Examples/Advanced/FileSharing/)          | Send files directly to users | Message             | `.message`, `.presence`             |
| [Video Call Invitation (Pending)](APIExample_RTM2x/Examples/Advanced/VideoCallInvitation/)          | Make a P2P video call with Agora RTC SDK | Message             | `.message`, `.presence` ,  `RTC_SDK`          |

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- Share images and files using third-party storage such as Amazon S3
- Real-time coding
- 1-to-1 video call using RTC + RTM + Apple CallKit

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- ROADMAP -->
## Potential Samples

- Online collaborative tools
- Interactive games
- Real-time IoT event sharing

If you have any requests/ideas, feel free to let me know. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- RTM API Limitation -->
## References

- API Reference (https://docs.agora.io/en/signaling/reference/api?platform=ios)
- Pricing (https://docs.agora.io/en/signaling/overview/pricing?platform=ios)
- API Limitations (https://docs.agora.io/en/signaling/reference/limitations?platform=android)
- Security/Compliance (https://docs.agora.io/en/signaling/reference/security?platform=android) 



<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

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



