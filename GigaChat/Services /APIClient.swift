import Foundation
import UUIDKit

class APIClient {
    
    //MARK: Properties
    
    static let shared = APIClient()
    
    private let clientID = "c632f50e-6814-4092-9e06-dbc99c5c29a8"
    private let clientSecret = "1feaaf86-2b70-468f-8131-a341e94396aa"
    private let authorizationData = "YzYzMmY1MGUtNjgxNC00MDkyLTllMDYtZGJjOTljNWMyOWE4OjdkMmUzMGZhLTdhNjQtNDYxZS04ZWZmLTEwN2FkZjhmODQ5Ng=="
    private let tokenURL = URL(string: "https://ngw.devices.sberbank.ru:9443/api/v2/oauth")!
    private let scope = "GIGACHAT_API_PERS"
    var userToken: String?
    
    private let messageURL = URL(string: "https://gigachat.devices.sberbank.ru/api/v1/chat/completions")!
    
    private var tokenRefreshTimer: Timer?
    
    var chatHistory: [[String:String]] = []
    
    //MARK: Lifecycle
    
    private init() {
        setupTokenRefreshTimer()
    }
    
    deinit {
        print("♦️APIClient deinited")
        tokenRefreshTimer?.invalidate()
        tokenRefreshTimer = nil
    }
    
    //MARK: Methods
    
    private func setupTokenRefreshTimer() {
        getToken { success in
            if success {
                self.tokenRefreshTimer = Timer.scheduledTimer(withTimeInterval: 30 * 60, repeats: true) { _ in
                    self.getToken { _ in }
                }
            } else {
                print("Failed to get initial token")
            }
        }
    }
    
    private func getToken(completion: @escaping (Bool) -> Void) {
        
        let requestID = UUIDv4().description
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(requestID, forHTTPHeaderField: "RqUID")
        request.setValue("Basic \(authorizationData)", forHTTPHeaderField: "Authorization")
        request.httpBody = "scope=\(scope)".data(using: .utf8)!
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌Error: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            do {
                let json = try JSONDecoder().decode(Token.self, from: data)
                if let accessToken = json.access_token {
                    self.userToken = accessToken
                    print("✅🔑 Токен доступа: \(accessToken)")
                    completion(true)
                } else {
                    print("❌ No access token found in response")
                    completion(false)
                }
            } catch {
                print("❌\(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
    
    func sendMessage(text: String, completionHandler: @escaping (Result<MessageResponse, Error>) -> Void) {
        guard let token = userToken else {
            // Token is not available, fetch it first
            getToken { success in
                if success {
                    self.performSendMessage(text: text, completionHandler: completionHandler)
                } else {
                    completionHandler(.failure(NSError(domain: "APIClient", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch token"])))
                }
            }
            return
        }
        
        performSendMessage(text: text, completionHandler: completionHandler)
    }
    
    private func performSendMessage(text: String, completionHandler: @escaping (Result<MessageResponse, Error>) -> Void) {
        guard let token = userToken else {
            completionHandler(.failure(NSError(domain: "APIClient", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token is missing"])))
            return
        }
        
        chatHistory.append(["role": "user", "content": text])
        
        var params: [String: Any] = [
            "model": "GigaChat",
            "messages": chatHistory,
            "n": 1,
            "stream": false,
            "update_interval": 0,
        ]
        
        if containsWord("нарисуй", in: text.lowercased()) {
            params["function_call"] = "auto"
        }
        
        var request = URLRequest(url: messageURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌Error: \(error!.localizedDescription)")
                completionHandler(.failure(error!))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(MessageResponse.self, from: data)
                
                // Append the response message to chatHistory
                if let responseMessage = response.choices?.first?.message.content {
                    self.chatHistory.append(["role" :"assistant", "content":responseMessage])
                    
                    if let imageID = self.extractImageID(from: responseMessage) {
                        FileDownloader.shared.downloadImage(withID: imageID, token: token) { [weak self] result in
                            switch result {
                            case .success(let fileURL):
                            
                                print("✅Image downloaded to: \(fileURL)")
                            
                            case .failure(let error):
                                print("❌Failed to download image: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                
                completionHandler(.success(response))
                
               
            } catch {
                print("❌Error decoding JSON: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("JSON data: \(dataString)")
                }
                completionHandler(.failure(error))
            }
        }.resume()
    }
    
    func containsWord(_ word: String, in string: String) -> Bool {
        let pattern = "\\b\(word)\\b"
        return string.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func extractImageID(from message: String) -> String? {
        let pattern = "<img src=\"([^\"]+)\""
        if let range = message.range(of: pattern, options: .regularExpression) {
            return String(message[range])
                .replacingOccurrences(of: "<img src=\"", with: "")
                .replacingOccurrences(of: "\"", with: "")
        }
        return nil
    }
}

