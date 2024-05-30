//
//  TextDocument.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/29.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct TextDocument: FileDocument {
    
    static public var readableContentTypes: [UTType] =
    [.text, .json, .xml, .plainText]
    
    var text: String = ""

    init(_ text: String = "") {
      self.text = text
    }
    
    
    init(configuration: ReadConfiguration) throws {
      if let data = configuration.file.regularFileContents {
        text = String(decoding: data, as: UTF8.self)
      }
    }
    
    func fileWrapper(configuration: WriteConfiguration)
      throws -> FileWrapper {
      let data = Data(text.utf8)
      return FileWrapper(regularFileWithContents: data)
    }

    
    
}
