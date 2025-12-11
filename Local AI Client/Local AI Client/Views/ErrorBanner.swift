//
//  ErrorBanner.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2025-12-11.
//
import SwiftUI

struct ErrorBanner: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Button("Retry") {
                onRetry()
            }
            .font(.caption.bold())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}
