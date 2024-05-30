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

//                    Text("\((Int(Double(fileChunks?.reduce(0) { $0 + $1.count } ?? 0)/1024).rounded())) KB")
//                        .font(.caption)
//                        .foregroundStyle(.gray)
//                        .padding(.bottom, 5)
//                    
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

                }

                Image(systemName: "person.crop.circle")
                    .font(.title)
                
            }
            .padding(.trailing)

        }
    }
}

