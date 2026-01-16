//
//  MessageListView.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2026-01-15.
//

import SwiftUI

struct MessageListView: View {
    let messages: [Message]
    let isLoading: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    
                    if isLoading {
                        LoadingIndicator()
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) {
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}
