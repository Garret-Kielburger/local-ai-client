//
//  AIServiceProtocol.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2026-01-13.
//

// Protocols for Dependency Inversion
protocol AIServiceProtocol {
    func sendChat(messages: [Message]) async throws -> String
}
