//
//  ChatResponse.swift
//  GigaChat
//
//  Created by Gleb on 04.08.2024.
//

import Foundation

// MARK: - Message
struct Message: Codable {
    let role: String
    let content: String
}

enum Role: String, Codable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
    case function = "function"
    
}

// MARK: - MessageRequest

struct MessageRequest: Codable {
    let model: String
    let messages: [Message]
    let n: Int
    let stream: Bool
    let update_interval: Int
}


import Foundation

// MARK: - MessageResponse
struct MessageResponse: Codable {
    let choices: [Choice]?
    let created: Int?
    let model, object: String?
    let usage: Usage?
}

// MARK: - Choice
struct Choice: Codable {
    let message: Message
    let index: Int
    let finish_reason: String
//
//    enum CodingKeys: String, CodingKey {
//          case message, index
//          case finishReason
//      }
}

// MARK: - Usage
struct Usage: Codable {
    let prompt_tokens, completion_tokens, total_tokens: Int
//
//    enum CodingKeys: String, CodingKey {
//        case promptTokens
//        case completionTokens
//        case totalTokens
//    }
}
