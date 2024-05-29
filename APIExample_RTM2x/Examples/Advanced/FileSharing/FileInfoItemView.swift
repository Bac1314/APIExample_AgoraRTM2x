//
//  FileInfoItemView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/29.
//

import SwiftUI

struct FileInfoItemView: View {
    var fileInfo: FileInfo
    var currentUser: String
    @Binding var fileChunks : [Data]?
    
    var body: some View {
        if currentUser == fileInfo.owner {
            HStack {
                Image(systemName: "person.crop.circle")
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(fileInfo.owner)")
                        .padding(.leading, 4)
                    
                    HStack {
                        Image(systemName: "doc")
                        Text("\(fileInfo.name)")
                    }
                    .padding(10)
                    .background(Color.indigo.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    
                    if let fileChunkCount = fileChunks?.count {
                        ProgressView(value: Float(fileChunkCount), total: Float(fileInfo.size))
                            .frame(width: 300)
                    }
                    
                }

                
                Spacer()
            }
            .padding(.leading)
        }else {
            HStack {
                Spacer()
             
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(fileInfo.owner)")
                        .padding(.trailing, 4)
                    
                    HStack {
                        Image(systemName: "doc")
                        Text("\(fileInfo.name)")
                    }
                    .padding(10)
                    .background(Color.indigo.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    
                    if let fileChunkCount = fileChunks?.count {
                        ProgressView(value: Float(fileChunkCount), total: Float(fileInfo.size))
                            .frame(width: 300)
                    }
                    
                }

                Image(systemName: "person.crop.circle")
                    .font(.title)
                
            }
            .padding(.trailing)

        }
    }
}

