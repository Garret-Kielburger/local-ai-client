//
//  ContentView.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2025-12-11.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ChatViewModel
    
    init(dependencies: AppDependencies = AppDependencies()) {
        _viewModel = StateObject(wrappedValue: dependencies.makeViewModel())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                MessageListView(messages: viewModel.messages, isLoading: viewModel.isLoading)
                
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error, onRetry: viewModel.retryLastMessage)
                }
                
                InputBar(
                    text: $viewModel.inputText,
                    isLoading: viewModel.isLoading,
                    onSend: viewModel.sendMessage
                )
            }
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.clearChat) {
                        Image(systemName: "trash")
                    }
                    .disabled(viewModel.messages.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
