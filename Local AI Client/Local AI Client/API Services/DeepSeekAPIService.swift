//
//  DeepSeekAPI.swift
//  Local AI Client
//
//  Created by Garret Kielburger on 2025-12-11.
//
import Foundation

class DeepSeekAPIService: AIServiceProtocol {
    private let baseURL: String
    private let modelName: String
    private let session: URLSession
    
//    let baseURL = "http://192.168.0.165:11434"
//    let baseURL = "http://127.0.0.1:11434"
    
    init(baseURL: String = "http://192.168.0.165:11434",
         modelName: String = "deepseek-r1:14b",
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.modelName = modelName
        self.session = session
    }
    
    func sendChat(messages: [Message]) async throws -> String {
        let request = try buildRequest(for: messages)
        let (data, _) = try await session.data(for: request)
        return try parseResponse(data)
    }
    
    private func buildRequest(for messages: [Message]) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/api/chat") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        let apiMessages = messages.map { ["role": $0.role.rawValue, "content": $0.content] }
        let body: [String: Any] = [
            "model": modelName,
            "messages": apiMessages,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }
    
    private func parseResponse(_ data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let message = json["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw APIError.invalidResponse
        }
        return content
    }
  
    
    // OLD POC function
//    func chat(messages: [[String: Any]], completion: @escaping (Result<String, Error>) -> Void) {
//        let url = URL(string: "\(baseURL)/api/chat")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.timeoutInterval = 600
//
//        let body: [String: Any] = [
//            "model": "deepseek-r1:14b",
//            "messages": messages,
//            "stream": false
//        ]
//        
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let data = data else {
//                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
//                return
//            }
//            
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                   let message = json["message"] as? [String: Any],
//                   let content = message["content"] as? String {
//                    completion(.success(content))
//                } else {
//                    completion(.failure(NSError(domain: "ParseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
//                }
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
//    }
}
