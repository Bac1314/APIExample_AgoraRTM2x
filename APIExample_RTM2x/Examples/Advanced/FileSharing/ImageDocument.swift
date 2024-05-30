//
//  ImageDocument.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/29.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct ImageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.png] }

    var image: UIImage

    init(image: UIImage?) {
        self.image = image ?? UIImage()
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let image = UIImage(data: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.image = image
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: image.pngData()!)
    }
    
}
