//
//  ApiServiceError.swift
//  CryptoTrack
//
//  Created by Quentin Gaillardet on 13/12/2023.
//

import Foundation

enum ApiServiceError: Error {
    case invalidURL
    case networkError(Error)
    case invalidStatusCode(Int)
    case decodingError(Error)
    case customError(message: String)
    
    var localizedDescription: String {
        switch self {
            case .invalidURL:
                return "Invalid URL"
            case .networkError(let error):
                return "Network Error: \(error.localizedDescription)"
            case .invalidStatusCode(let statusCode):
                return "Invalid Status Code: \(statusCode)"
            case .decodingError(let error):
                return "Decoding Error: \(error.localizedDescription)"
            case .customError(let message):
                return message
            }
    }
}
