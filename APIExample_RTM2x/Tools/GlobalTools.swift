//
//  GlobalTools.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/1.
//

import Foundation
import SwiftUI


// Convert OBJECT to JSONSTRING
func convertObjectToJsonString<T: Encodable>(object: T) -> String? {
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(object)
        let jsonString = String(data: jsonData, encoding: .utf8)
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


extension Color {
    //MARK: Initialize hex to Color
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    //MARK: Color to Hex String
    func toHex() -> String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "#FEA400"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
