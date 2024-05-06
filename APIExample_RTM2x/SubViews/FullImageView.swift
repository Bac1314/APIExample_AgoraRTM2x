//
//  FullImageView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/30.
//

import SwiftUI

struct FullImageView: View {
    @State private var scale: CGFloat = 1.0
    @GestureState private var position: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    
    var imageData: Data?
    
    var body: some View {
        // Display image
        if let imageData = imageData, let img = UIImage(data: imageData) {
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                .scaleEffect(scale)
                .offset(x: position.width + newPosition.width, y: position.height + newPosition.height)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            self.scale = value.magnitude
                            if self.scale < 1.0 {
                                self.scale = 1.0
                                self.newPosition.width = 0
                                self.newPosition.height = 0
                            }
                        }
                )
//                .gesture(
//                    DragGesture(minimumDistance: 0.1)
//                        .onChanged { value in
//                            print("onChange value \(value.location.x)")
//                        }
//                        .onEnded { value in
//                            
//                        }
//                    )
                .gesture(
                    DragGesture()
//                        .updating($position) { value, state, _ in
//                            state = value.translation
//                        }
                        .onEnded { value in
                            withAnimation(Animation.easeInOut(duration: 0.01)) {
                                if self.scale > 1.0 {
                                    self.newPosition.width += value.translation.width
                                    self.newPosition.height += value.translation.height
                                }
                            }
                        }
                )
            
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

