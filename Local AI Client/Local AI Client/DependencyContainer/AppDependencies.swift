//
//  AppDependencies.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2026-01-15.
//

class AppDependencies {
    let repository: MessageRepository
    let aiService: AIServiceProtocol
    let sendMessageAction: SendMessageAction
    let clearChatAction: ClearChatAction
    
    init() {
        self.repository = MessageRepository()
        self.aiService = DeepSeekAPIService()
        self.sendMessageAction = SendMessageAction(aiService: aiService, repository: repository)
        self.clearChatAction = ClearChatAction(repository: repository)
    }
    
    @MainActor
    func makeViewModel() -> ChatViewModel {
        ChatViewModel(
            repository: repository,
            sendMessageAction: sendMessageAction,
            clearChatAction: clearChatAction
        )
    }
}
