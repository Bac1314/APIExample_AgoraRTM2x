//
//  ImagePicker.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/30.
//

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var resize400Width: Bool = false
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                if parent.resize400Width {
                    parent.selectedImage = resizeTo400Pixels(image)
                }else {
                    parent.selectedImage = image
                }
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        
        func resizeTo400Pixels(_ image: UIImage) -> UIImage? {
//            // Rough estimate JPEG File Size (in KB) = (Width x Height x 24) / (15 * 8 * 1024)
//            // Color depth : 24, Compression ratio 15:1
//            
//            // Width x Height <= (32) * (15 * 8 * 1024) / 24
//            
//            let scaleFactor = ((32) * (15 * 8 * 1024) / 24) / (image.size.width * image.size.height)
//            let newHeight = image.size.height * scaleFactor
//            let newWidth = image.size.width * scaleFactor
            
            // Set short side to 480p
            let scaleFactor =  image.size.width < image.size.height ? 400/image.size.width : 400/image.size.height
            let newHeight = image.size.height * scaleFactor
            let newWidth = image.size.width * scaleFactor
            
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()

            return newImage
        }
        
   
    }
}
