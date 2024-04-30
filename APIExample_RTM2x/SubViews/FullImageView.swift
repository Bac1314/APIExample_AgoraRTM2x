//
//  FullImageView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/30.
//

import SwiftUI

struct FullImageView: View {
    var imageData: Data?
    
    var body: some View {
        // Display image
        if let imageData = imageData, let img = UIImage(data: imageData) {
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        }
    }
}



#Preview {
    
//    let image = UIImage(named: "charizard")
//    var compressionQuality: CGFloat = 1.0
//    var imageData = image?.jpegData(compressionQuality: 0.5)
    
//    // Convert Imagedata to less than 32KB
//    while let data = imageData, data.count > 32 * 1024, compressionQuality > 0 {
//        compressionQuality -= 0.1
//        imageData = image?.jpegData(compressionQuality: compressionQuality)
//        print("Bac's publishImageToChannel imageData size \(Double(imageData?.count ?? 0)/1024)KB")
//    }
    FullImageView(imageData: UIImage(named: "charizard")?.jpegData(compressionQuality: 0.5))
}
