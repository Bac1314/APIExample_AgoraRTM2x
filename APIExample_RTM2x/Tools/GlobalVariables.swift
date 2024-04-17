//
//  GlobalVariables.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/15.
//

import Foundation
import SwiftUI

enum customError: Error {
    case loginRTMError
    case emptyUIDLoginError
}


enum customTokenError: Error {
    case tokenURLerror
    case tokenEmptyError
    case tokenRequestNot200
}

let backgroundGradient = LinearGradient(colors: [.white, .teal.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
