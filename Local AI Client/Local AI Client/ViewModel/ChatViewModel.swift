//
//  ChatViewModel.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2025-12-11.
//
import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let repository: MessageRepositoryProtocol
    private let sendMessageAction: SendMessageAction
    private let clearChatAction: ClearChatAction
    
    var messages: [Message] {
        repository.messages
    }
    
    init(repository: MessageRepositoryProtocol,
         sendMessageAction: SendMessageAction,
         clearChatAction: ClearChatAction) {
        self.repository = repository
        self.sendMessageAction = sendMessageAction
        self.clearChatAction = clearChatAction
    }
    
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !isLoading else { return }
        
        inputText = ""
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await sendMessageAction.execute(userMessage: trimmedText)
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func clearChat() {
        clearChatAction.execute()
        errorMessage = nil
    }
    
    func retryLastMessage() {
        guard let lastMessage = repository.messages.last, lastMessage.isUser else { return }
        inputText = lastMessage.content
        repository.removeLastMessage()
        sendMessage()
    }
}
