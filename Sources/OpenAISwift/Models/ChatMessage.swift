//
//  File.swift
//
//
//  Created by Bogdan Farca on 02.03.2023.
//

import Foundation

public struct ResponseFormat: Codable {
    public enum FormatType: String, Codable {
        case text = "text"
        case jsonObject = "json_object"
    }

    public var type: FormatType?

    public init(type: FormatType? = .text) {  // Defaults to 'text'
        self.type = type
    }
}


/// An enumeration of possible roles in a chat conversation.
public enum ChatRole: String, Codable {
    /// The role for the system that manages the chat interface.
    case system
    /// The role for the human user who initiates the chat.
    case user
    /// The role for the artificial assistant who responds to the user.
    case assistant
}

/// A structure that represents a single message in a chat conversation.

public struct ChatMessage: Codable, Identifiable {
    /// UUID to conform to the Identifiable protocol
    /// - Note: This property is not de- and encoded. A DTO or other logic might be required if the `ChatMessage` instance is stored locally.
    public var id = UUID()

    /// The role of the sender of the message.
    public let role: ChatRole?
    /// The content of the message.
    public let content: String?

    /// Creates a new chat message with a given role and content.
    /// - Parameters:
    ///   - role: The role of the sender of the message.
    ///   - content: The content of the message.
    public init(role: ChatRole, content: String) {
        self.role = role
        self.content = content
    }

    enum CodingKeys: CodingKey {
        case id
        case role
        case content
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<ChatMessage.CodingKeys> = try decoder.container(keyedBy: ChatMessage.CodingKeys.self)


        self.id = UUID()
        self.role = try container.decodeIfPresent(ChatRole.self, forKey: ChatMessage.CodingKeys.role)
        self.content = try container.decodeIfPresent(String.self, forKey: ChatMessage.CodingKeys.content)

    }

    public func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<ChatMessage.CodingKeys> = encoder.container(keyedBy: ChatMessage.CodingKeys.self)

        try container.encodeIfPresent(self.role, forKey: ChatMessage.CodingKeys.role)
        try container.encodeIfPresent(self.content, forKey: ChatMessage.CodingKeys.content)

    }
}

extension ChatMessage:  Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

/// A structure that represents a chat conversation.
public struct ChatConversation: Encodable {
    /// The name or identifier of the user who initiates the chat. Optional if not provided by the user interface.
    let user: String?

    /// The messages to generate chat completions for. Ordered chronologically from oldest to newest.
    let messages: [ChatMessage]

    /// The ID of the model used by the assistant to generate responses. See OpenAI documentation for details on which models work with the Chat API.
    let model: String

    /// A parameter that controls how random or deterministic the responses are, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. Optional, defaults to 1.
    let temperature: Double?

    /// A parameter that controls how diverse or narrow-minded the responses are, between 0 and 1. Higher values like 0.9 mean only the tokens comprising the top 90% probability mass are considered, while lower values like 0.1 mean only the top 10%. Optional, defaults to 1.
    let topProbabilityMass: Double?

    /// How many chat completion choices to generate for each input message. Optional, defaults to 1.
    let n: Int?

    /// An array of up to 4 sequences where the API will stop generating further tokens. Optional.
    let stop: [String]?

    /// The maximum number of tokens to generate in the chat completion. The total length of input tokens and generated tokens is limited by the model's context length. Optional.
    let maxCompletionTokens: Int?

    /// A parameter that penalizes new tokens based on whether they appear in the text so far, between -2 and 2. Positive values increase the model's likelihood to talk about new topics. Optional if not specified by default or by user input. Optional, defaults to 0.
    let presencePenalty: Double?

    /// A parameter that penalizes new tokens based on their existing frequency in the text so far, between -2 and 2. Positive values decrease the model's likelihood to repeat the same line verbatim. Optional if not specified by default or by user input. Optional, defaults to 0.
    let frequencyPenalty: Double?

    /// Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID in the OpenAI Tokenizer—not English words) to an associated bias value from -100 to 100. Values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
    let logitBias: [Int: Double]?
    
    /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
    
    let responseFormat: ResponseFormat?

    /// If you're generating long completions, waiting for the response can take many seconds. To get responses sooner, you can 'stream' the completion as it's being generated. This allows you to start printing or processing the beginning of the completion before the full completion is finished.
    /// https://github.com/openai/openai-cookbook/blob/main/examples/How_to_stream_completions.ipynb
    let stream: Bool?

    enum CodingKeys: String, CodingKey {
        case user
        case messages
        case model
        case temperature
        case topProbabilityMass = "top_p"
        case n
        case stop
        case maxCompletionTokens = "max_completion_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
        case responseFormat = "response_format"
        case stream
    }
}

public struct ChatError: Codable {
    public struct Payload: Codable {
        public let message, type: String
        public let param, code: String?
    }

    public let error: Payload
}

public struct Usage:Codable {
    public let prompt_tokens: Int
    public let completion_tokens: Int
    public let total_tokens: Int
}

public struct ChatResponse: Codable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let usage: Usage
}

