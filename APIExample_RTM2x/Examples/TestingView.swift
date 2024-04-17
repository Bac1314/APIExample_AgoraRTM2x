//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI

struct TestingView: View {
    // define your custom date
    var customDate: Date = Date().addingTimeInterval(10)
    @State var dic : [String: String] = ["key1":"value1", "key2":"value2"]
    @State var count = 3

    var body: some View {

        VStack {
            List {
                ForEach(dic.sorted(by: {$0.key > $1.key}), id:\.key) { item in
                    Text("\(item.key) \(item.value)")
                    
                }
            }
            
            
            Button(action: {
                dic["key\(count)"] = "new value\(count)"
            }, label: {
                Text("Append New")
            })
            
            Button(action: {
                dic["key1"] = "new value1"
                
            }, label: {
                Text("Append Old")
            })
            
            if Date() < customDate {
                Text("Current date is less than custom date")
                    .padding()
            } else {
                Text("Current date is greater than custom date")
                    .padding()
            }
        }
    }
}

#Preview {
    TestingView()
}
