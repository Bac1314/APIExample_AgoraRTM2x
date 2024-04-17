//
//  LoginRTM.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/3/15.
//
import Foundation


//class APIRequest {
//    
//    func generateToken(urlString: String) async throws -> String {
//        
//        guard let url = URL(string: urlString) else {
//            throw customTokenError.tokenURLerror
//        }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        urlRequest.setValue(Configurations.tokenGatewayKey, forHTTPHeaderField: "x-api-key")
//
//        // do catch block for custom error
//        do {
//            let (data, response) = try await URLSession.shared.data(for: urlRequest)
//            
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
//                throw customTokenError.tokenRequestNot200
//            }
//
//            let decodedResponse = try JSONDecoder().decode(AgoraToken.self, from: data)
//            
//            if decodedResponse.body.token.isEmpty {
//                throw customTokenError.tokenEmptyError
//            }
//            
//            return decodedResponse.body.token
//            
//        }catch let error as URLError {
//           print(" \(error)")
//           throw error
//       } catch let DecodingError.dataCorrupted(context) {
//           throw DecodingError.dataCorrupted(context)
//       } catch let DecodingError.keyNotFound(key, context) {
//           throw DecodingError.keyNotFound(key, context)
//       } catch let DecodingError.valueNotFound(value, context) {
//           throw DecodingError.valueNotFound(value, context)
//       } catch let DecodingError.typeMismatch(type, context) {
//           throw DecodingError.typeMismatch(type, context)
//       } catch {
//           throw customError.loginRTMError
//       }
//
//    }
//    
//    
//}
