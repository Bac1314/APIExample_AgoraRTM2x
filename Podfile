# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'APIExample_RTM2x' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for APIExample_RTM2x
  pod 'AgoraRtcEngine_iOS', '4.3.0', :subspecs => ['RtcBasic', 'AINS', 'AudioBeauty', 'ClearVision', 'ContentInspect', 'VirtualBackground' , 'VQA']
  pod 'AgoraRtm_iOS', '2.2.2'
  #  pod 'CallAPI', :path => 'CallAPI.podspec' #includes AgoraRTM
  
  # To avoid aosl framework conflict in both RTC and RTM
  pre_install do |installer|
    # Define the path for the AgoraRtm framework
    rtm_pod_path = File.join(installer.sandbox.root, 'AgoraRtm_iOS')
    
    # Full path to aosl.xcframework
    aosl_xcframework_path = File.join(rtm_pod_path, 'aosl.xcframework')
    
    # Check if the file exists, and if it does, delete it
    if File.exist?(aosl_xcframework_path)
      puts "Deleting aosl.xcframework from #{aosl_xcframework_path}"
      FileUtils.rm_rf(aosl_xcframework_path)
    else
      puts "aosl.xcframework not found, skipping deletion."
    end
  end
  
end


