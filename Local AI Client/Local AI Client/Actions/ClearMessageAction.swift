//
//  ClearMessage.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2026-01-15.
//

class ClearChatAction {
    private let repository: any MessageRepositoryProtocol
    
    init(repository: MessageRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() {
        repository.clearAll()
    }
}
