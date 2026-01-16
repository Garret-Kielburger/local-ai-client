//
//  SendMessage.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2026-01-15.
//

import Foundation

class SendMessageAction {
    private let aiService: AIServiceProtocol
    private let repository: any MessageRepositoryProtocol
    
    init(aiService: AIServiceProtocol, repository: MessageRepositoryProtocol) {
        self.aiService = aiService
        self.repository = repository
    }
    
    func execute(userMessage: String) async throws -> Message {
        let message = Message(role: .user, content: userMessage, timestamp: Date())
        repository.addMessage(message)
        
        do {
            let response = try await aiService.sendChat(messages: repository.messages)
            let assistantMessage = Message(role: .assistant, content: response, timestamp: Date())
            repository.addMessage(assistantMessage)
            return assistantMessage
        } catch {
            repository.removeLastMessage()
            throw error
        }
    }
}
