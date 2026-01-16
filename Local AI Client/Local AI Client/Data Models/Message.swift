//
//  Message.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2025-12-11.
//

import Foundation

// MARK: - Models
struct Message: Identifiable, Equatable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    var isUser: Bool {
        role == .user
    }
}


enum MessageRole: String {
    case user
    case assistant
}
