//
//  APIErrors.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2026-01-13.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid server URL"
        case .invalidResponse: return "Invalid response from server"
        }
    }
}
