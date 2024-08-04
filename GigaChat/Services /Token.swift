//
//  Token.swift
//  GigaChat
//
//  Created by Gleb on 04.08.2024.
//

import Foundation

struct Token: Decodable {
    let access_token: String
    let expires_at: Int64
}
