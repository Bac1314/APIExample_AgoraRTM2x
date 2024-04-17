//
//  GlobalTools.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/1.
//

import Foundation


// Convert OBJECT to JSONSTRING
func convertObjectToJsonString<T: Encodable>(object: T) -> String? {
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(object)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print("JSON string : " + jsonString!)
        return jsonString
    } catch {
        print("Error encoding object into JSON, error: \(error.localizedDescription)")
    }
    
    return nil
}

// CONVERT JSONSTRING to OBJECT (e.g. CustomPoll)
func convertJsonStringToObject<T: Decodable>(jsonString: String, objectType: T.Type) -> T? {
    let decoder = JSONDecoder()
    if let jsonData = jsonString.data(using: .utf8) {
        do {
            let object = try decoder.decode(objectType, from: jsonData)
            print("Decoded object from JSON string: \(object)")
            return object
        } catch {
            print("Error decoding JSON into object, error: \(error.localizedDescription)")
        }
    }
    
    return nil
}

// Loading mock data (for some reason this is causing Hang Risk, that's why I added MainActor
@MainActor
func loadMockDataFromFile<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

func remainingSeconds(currentDate: Date, timestamp: Int) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.second], from: currentDate, to: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    return components.second ?? 0
}

