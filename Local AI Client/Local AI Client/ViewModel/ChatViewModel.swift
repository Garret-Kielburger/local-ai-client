//
//  ChatViewModel.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2025-12-11.
//
import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let api = DeepSeekAPI()
    
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !isLoading else { return }
        
        // Add user message
        let userMessage = Message(role: "user", content: trimmedText, timestamp: Date())
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        errorMessage = nil
        
        // Convert messages to API format
        let apiMessages = messages.map { message in
            ["role": message.role, "content": message.content]
        }
        
        // Call API
        api.chat(messages: apiMessages) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    let assistantMessage = Message(role: "assistant", content: response, timestamp: Date())
                    self.messages.append(assistantMessage)
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    // Remove the user message if request failed
                    if let lastMessage = self.messages.last, lastMessage.id == userMessage.id {
                        self.messages.removeLast()
                    }
                }
            }
        }
    }
    
    func clearChat() {
        messages.removeAll()
        errorMessage = nil
    }
    
    func retryLastMessage() {
        guard let lastMessage = messages.last, lastMessage.isUser else { return }
        inputText = lastMessage.content
        messages.removeLast()
        sendMessage()
    }
}
