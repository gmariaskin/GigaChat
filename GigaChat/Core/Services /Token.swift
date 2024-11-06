

import Foundation

struct Token: Decodable {
    let access_token: String?
    let expires_at: Int64?
}
