//
//  Untitled.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2026-01-13.
//

// Protocols for Dependency Inversion
protocol MessageRepositoryProtocol {
    var messages: [Message] { get }
    func addMessage(_ message: Message)
    func removeLastMessage()
    func clearAll()
}
