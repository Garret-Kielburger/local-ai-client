//
//  MessageRepository.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2026-01-13.
//

import Foundation

class MessageRepository: MessageRepositoryProtocol, ObservableObject {
    @Published private(set) var messages: [Message] = []
    
    func addMessage(_ message: Message) {
        messages.append(message)
    }
    
    func removeLastMessage() {
        messages.removeLast()
    }
    
    func clearAll() {
        messages.removeAll()
    }
}
