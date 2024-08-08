//
//  FileInfoItemView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/5/29.
//

import SwiftUI

struct FileInfoItemView: View {
    var file: FileInfo
    var currentUser: String
    @Binding var fileChunks : [Data]?
    
    var body: some View {
        if currentUser == file.owner {
           
                HStack {
                    Image(systemName: "person.crop.circle")
                        .font(.title)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(file.owner)")
                            .padding(.leading, 4)
                        
                        // Display image
                        if let imageData = fileChunks?.reduce(Data(), +), let img = UIImage(data: imageData) {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 100)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
                        }
                        
                        HStack {
                            Image(systemName: "doc")
                            Text("\(file.name)")
                        }
                        .padding(10)
                        .background(
                            ProgressView(value: Float(fileChunks?.count ?? file.countOf32KB), total: Float(file.countOf32KB))
                                .scaleEffect(CGSize(width: 1.1, height: 10.0))
                                .tint(.green.opacity(0.8))
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 36))

                        Text("\(Int( (fileChunks?.reduce(0){$0 + $1.count} ?? 0) / 1024)) KB")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .padding(.bottom, 5)
                    }

                    
                    Spacer()
                }
                .padding(.leading)

        }else {
            HStack {
                Spacer()
             
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(file.owner)")
                        .padding(.trailing, 4)
                    
                    // Display image
                    if let imageData = fileChunks?.reduce(Data(), +), let img = UIImage(data: imageData) {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 100)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
                    }
                    
                    HStack {
                        Image(systemName: "doc")
                        if let fileURL = URL(string: file.url) {
                            ShareLink(item: fileURL) {
                                Text("\(file.name)")
                            }
                        }else {
                            Text("\(file.name)")
                        }
                    }
                    .padding(10)
                    .background(
                        ProgressView(value: Float(fileChunks?.count ?? file.countOf32KB), total: Float(file.countOf32KB))
                            .scaleEffect(CGSize(width: 1.1, height: 10.0))
                            .tint(.green.opacity(0.8))
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 36))
                    
                    Text("\(Int( (fileChunks?.reduce(0){$0 + $1.count} ?? 0) / 1024)) KB")

                }

                Image(systemName: "person.crop.circle")
                    .font(.title)
                
            }
            .padding(.trailing)

        }
    }
}

