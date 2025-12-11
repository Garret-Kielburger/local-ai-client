//
//  LoadingIndicator.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2025-12-11.
//
import SwiftUI

struct LoadingIndicator: View {
    var body: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Thinking...")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
