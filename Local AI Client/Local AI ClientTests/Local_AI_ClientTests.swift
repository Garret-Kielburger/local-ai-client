//
//  Local_AI_ClientTests.swift
//  Local AI ClientTests
//
//  Created by Garret Kielburger on 2025-12-11.
//

import Testing
import Foundation
import XCTest
@testable import Local_AI_Client


// MARK: - Mock Implementations

class MockAIService: AIServiceProtocol {
    var shouldFail = false
    var mockResponse = "Mock AI Response"
    var capturedMessages: [Message] = []
    var callCount = 0
    
    func sendChat(messages: [Message]) async throws -> String {
        callCount += 1
        capturedMessages = messages
        
        if shouldFail {
            throw MockError.serviceFailed
        }
        
        return mockResponse
    }
}

class MockMessageRepository: MessageRepositoryProtocol, ObservableObject {
    @Published private(set) var messages: [Message] = []
    
    var addMessageCallCount = 0
    var removeLastCallCount = 0
    var clearAllCallCount = 0
    
    func addMessage(_ message: Message) {
        addMessageCallCount += 1
        messages.append(message)
    }
    
    func removeLastMessage() {
        removeLastCallCount += 1
        if !messages.isEmpty {
            messages.removeLast()
        }
    }
    
    func clearAll() {
        clearAllCallCount += 1
        messages.removeAll()
    }
}

enum MockError: Error {
    case serviceFailed
}

// MARK: - Model Tests

class MessageTests: XCTestCase {
    func testMessageIsUser() {
        let userMessage = Message(role: .user, content: "Hello", timestamp: Date())
        let assistantMessage = Message(role: .assistant, content: "Hi", timestamp: Date())
        
        XCTAssertTrue(userMessage.isUser)
        XCTAssertFalse(assistantMessage.isUser)
    }
    
    func testMessageEquality() {
        let date = Date()
        let message1 = Message(role: .user, content: "Hello", timestamp: date)
        let message2 = Message(role: .user, content: "Hello", timestamp: date)
        
        // Different IDs means not equal
        XCTAssertNotEqual(message1, message2)
    }
}

// MARK: - Repository Tests

class MessageRepositoryTests: XCTestCase {
    var repository: MessageRepository!
    
    override func setUp() {
        super.setUp()
        repository = MessageRepository()
    }
    
    override func tearDown() {
        repository = nil
        super.tearDown()
    }
    
    func testAddMessage() {
        let message = Message(role: .user, content: "Test", timestamp: Date())
        
        repository.addMessage(message)
        
        XCTAssertEqual(repository.messages.count, 1)
        XCTAssertEqual(repository.messages.first?.content, "Test")
    }
    
    func testRemoveLastMessage() {
        let message1 = Message(role: .user, content: "First", timestamp: Date())
        let message2 = Message(role: .user, content: "Second", timestamp: Date())
        
        repository.addMessage(message1)
        repository.addMessage(message2)
        repository.removeLastMessage()
        
        XCTAssertEqual(repository.messages.count, 1)
        XCTAssertEqual(repository.messages.first?.content, "First")
    }
    
    func testClearAll() {
        repository.addMessage(Message(role: .user, content: "Test", timestamp: Date()))
        repository.clearAll()
        
        XCTAssertTrue(repository.messages.isEmpty)
    }
}

// MARK: - Use Case Tests

class SendMessageActionTests: XCTestCase {
    var mockService: MockAIService!
    var mockRepository: MockMessageRepository!
    var action: SendMessageAction!
    
    override func setUp() {
        super.setUp()
        mockService = MockAIService()
        mockRepository = MockMessageRepository()
        action = SendMessageAction(aiService: mockService, repository: mockRepository)
    }
    
    override func tearDown() {
        action = nil
        mockRepository = nil
        mockService = nil
        super.tearDown()
    }
    
    func testExecuteSuccess() async throws {
        mockService.mockResponse = "AI Response"
        
        let result = try await action.execute(userMessage: "Hello")
        
        XCTAssertEqual(mockRepository.messages.count, 2) // User + Assistant
        XCTAssertEqual(mockRepository.messages.first?.content, "Hello")
        XCTAssertEqual(mockRepository.messages.first?.role, .user)
        XCTAssertEqual(result.content, "AI Response")
        XCTAssertEqual(result.role, .assistant)
        XCTAssertEqual(mockService.callCount, 1)
    }
    
    func testExecuteFailureRemovesUserMessage() async {
        mockService.shouldFail = true
        
        do {
            _ = try await action.execute(userMessage: "Hello")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(mockRepository.messages.isEmpty)
            XCTAssertEqual(mockRepository.addMessageCallCount, 1)
            XCTAssertEqual(mockRepository.removeLastCallCount, 1)
        }
    }
    
    func testExecuteSendsFullConversationHistory() async throws {
        // Add existing messages
        mockRepository.addMessage(Message(role: .user, content: "First", timestamp: Date()))
        mockRepository.addMessage(Message(role: .assistant, content: "Response", timestamp: Date()))
        
        _ = try await action.execute(userMessage: "Second")
        
        XCTAssertEqual(mockService.capturedMessages.count, 3)
        XCTAssertEqual(mockService.capturedMessages[0].content, "First")
        XCTAssertEqual(mockService.capturedMessages[1].content, "Response")
        XCTAssertEqual(mockService.capturedMessages[2].content, "Second")
    }
}

class ClearChatActionTests: XCTestCase {
    var mockRepository: MockMessageRepository!
    var action: ClearChatAction!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMessageRepository()
        action = ClearChatAction(repository: mockRepository)
    }
    
    override func tearDown() {
        action = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testExecuteClearsMessages() {
        mockRepository.addMessage(Message(role: .user, content: "Test", timestamp: Date()))
        
        action.execute()
        
        XCTAssertEqual(mockRepository.clearAllCallCount, 1)
        XCTAssertTrue(mockRepository.messages.isEmpty)
    }
}

// MARK: - ViewModel Tests

@MainActor
class ChatViewModelTests: XCTestCase {
    var mockService: MockAIService!
    var mockRepository: MockMessageRepository!
    var sendMessageAction: SendMessageAction!
    var clearChatAction: ClearChatAction!
    var viewModel: ChatViewModel!
    
    override func setUp() {
        super.setUp()
        mockService = MockAIService()
        mockRepository = MockMessageRepository()
        sendMessageAction = SendMessageAction(aiService: mockService, repository: mockRepository)
        clearChatAction = ClearChatAction(repository: mockRepository)
        viewModel = ChatViewModel(
            repository: mockRepository,
            sendMessageAction: sendMessageAction,
            clearChatAction: clearChatAction
        )
    }
    
    override func tearDown() {
        viewModel = nil
        clearChatAction = nil
        sendMessageAction = nil
        mockRepository = nil
        mockService = nil
        super.tearDown()
    }
    
    func testSendMessageSuccess() async {
        viewModel.inputText = "Hello"
        mockService.mockResponse = "AI Response"
        
        viewModel.sendMessage()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        XCTAssertEqual(viewModel.inputText, "")
        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSendMessageWithEmptyText() {
        viewModel.inputText = "   "
        
        viewModel.sendMessage()
        
        XCTAssertEqual(viewModel.messages.count, 0)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSendMessageFailure() async {
        viewModel.inputText = "Hello"
        mockService.shouldFail = true
        
        viewModel.sendMessage()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testClearChat() {
        mockRepository.addMessage(Message(role: .user, content: "Test", timestamp: Date()))
        viewModel.errorMessage = "Some error"
        
        viewModel.clearChat()
        
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testRetryLastMessage() async {
        let userMessage = Message(role: .user, content: "Retry this", timestamp: Date())
        mockRepository.addMessage(userMessage)
        mockService.mockResponse = "Retry response"
        
        viewModel.retryLastMessage()
        
        // Wait a bit for the async send to start
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // The message should be removed and resent
        XCTAssertEqual(mockService.callCount, 1)
        XCTAssertEqual(mockRepository.messages.count, 2) // Resent user message + AI response
    }
    
    func testRetryLastMessageWithAssistantMessage() {
        let assistantMessage = Message(role: .assistant, content: "Response", timestamp: Date())
        mockRepository.addMessage(assistantMessage)
        
        viewModel.retryLastMessage()
        
        // Should not retry if last message is from assistant
        XCTAssertEqual(viewModel.inputText, "")
        XCTAssertEqual(viewModel.messages.count, 1)
    }
    
    func testDoesNotSendWhileLoading() {
        viewModel.inputText = "First message"
        viewModel.isLoading = true
        
        viewModel.sendMessage()
        
        XCTAssertEqual(mockService.callCount, 0)
    }
}

// MARK: - API Service Tests

class DeepSeekAPIServiceTests: XCTestCase {
    var service: DeepSeekAPIService!
    
    func testAPIRequestBuilding() {
        // Test that we can create the service
        service = DeepSeekAPIService(baseURL: "http://test.local", modelName: "test-model")
        XCTAssertNotNil(service)
    }
    
    // Note: Full API integration tests would require a running server
    // or more complex URLProtocol mocking. For unit tests, focus on
    // testing use cases with mock services instead.
}
