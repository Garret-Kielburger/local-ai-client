//
//  ContentView.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2025-12-11.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // Messages List
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                
                                if viewModel.isLoading {
                                    LoadingIndicator()
                                }
                            }
                            .padding()
                        }
                        .onChange(of: viewModel.messages.count) {
                            if let lastMessage = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error) {
                            viewModel.retryLastMessage()
                        }
                    }
                    
                    // Input Area
                    InputBar(
                        text: $viewModel.inputText,
                        isLoading: viewModel.isLoading,
                        onSend: viewModel.sendMessage
                    )
                }
                .navigationTitle("Garret's Super AI App")
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
