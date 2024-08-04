//
//  APIClient.swift
//  GigaChat
//
//  Created by Gleb on 04.08.2024.
//

import Foundation
import Alamofire
import UUIDKit

class APIClient {
    
    static let shared = APIClient()
    
    let clientID = "c632f50e-6814-4092-9e06-dbc99c5c29a8"
    let clientSecret = "1feaaf86-2b70-468f-8131-a341e94396aa"
    let authorizationData = "YzYzMmY1MGUtNjgxNC00MDkyLTllMDYtZGJjOTljNWMyOWE4OjdkMmUzMGZhLTdhNjQtNDYxZS04ZWZmLTEwN2FkZjhmODQ5Ng=="
    
    let url = URL(string: "https://ngw.devices.sberbank.ru:9443/api/v2/oauth")!
    let scope = "GIGACHAT_API_PERS"
    var userToken = "eyJjdHkiOiJqd3QiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwiYWxnIjoiUlNBLU9BRVAtMjU2In0.DE0pylJbDY_NQqp1vyEDXF2LLz6Kph9PGnm1DRd1eawRAK8SN3d5aw4gpZxSXBVrPfAMVghDveABFHtG-fbGiS5DOGdmi9erOtYT4_ZcPR03K1q28Pno_RUZ_2K21fj3pNklVUNlHCUVvjMzXvPjTHukbn4qDYdXs4P9vCZXfuxp9WMdd97J-W1OjtIaNn9GrmBKwAiyKXBfKDI3eZIk_0ug_XRxJpfY0T5zBSeIYc252s0HmgNbNP6ujanUmnjqldZTpW-2g3Kquw9dpV0EsWhKnRkAy2TIQoH5x3AHJ247f2xau0t-C6De5KoIMZvg7xHUOPal-fP7qNlHcFlpdA.k0C8wfIS3PxmYrGS33dHaQ.TjyC2C1MaaiBV-VFLMe_rxVM2TDXN3biN0JsZXPGBJFif53Y3_yc1HX8gOBUhfU3HNdRLvxBIAK3a5fbZs4wXFQGjD5GjY6twLnwJiDQCHSn0QEu97a4aIc85oH3cCWro53KTO2rX7DnFSbzn5soMeabrdZ2Wla13XnW3bmTm9nbhc5Xk_HG_r-bXE_wYzR9-H3KGnoIHS9fg_ATvtJXv4tcnuZvmSXqN2KHxBV0JB-j4D6CYut-fZgd_b_JCbn9PyaxPu0t5Q4Foe4_Zee-3klsBWwj_8Va6NhRhocEuQ9RvU3aPk81fAAivDc2o7Mu3DYBYJPGDfWeypUXeXejJrOLlhZkzG5El66KSAbLzFDaEm8fOjDfF1VcZQ3Cg5keKiazo6vqkF-RmCh3lMu5jCG4mYdqmBXvxuVWD8PJZ77LibF33j72VvYA4JCVE5jvrqRSU-y1Zmdv1AdLUpD6ACRPzJZc9CPgCCQA8u27mTlYOJ8_sv00mTcozWy3G6w0OahaEvG8lyVf2uc0PvMFhNJ5d55aQXRTDxQIJ7VJirPzOQDSYqEOnk8Y8aUUpNI5UkSlbAUqj4fmNdrStgDwY1tseCAm2SdJAnnjDLO6WofWsIfLMICHUnHNt3HWNVIAl9WCJkN2YIeWbVhsG9U8EtaxCzxJAxFud4OLE7-S49sVglGHD_WxXOBR_s67JD3VKUyIYCdA-jX07TTY45pfStzue5nVWFlwi1hfCoxlTaY.pZidWgKciuLX_F_twsRPTDoj_CzNo-iMUfWN-TLebJM"
    
    let messageURL = URL(string: "https://gigachat.devices.sberbank.ru/api/v1/chat/completions")!
    
    let messages = [
        ["role": "system", "content": "Ты профессиональный переводчик на английский язык. Переведи точно сообщение пользователя."],
        ["role": "user", "content": "GigaChat — это сервис, который умеет взаимодействовать с пользователем в формате диалога, писать код, создавать тексты и картинки по запросу пользователя."]
    ]
    
    func getToken() {
        
        let requestID = UUIDv4().description
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(requestID, forHTTPHeaderField: "RqUID")
        request.setValue("Basic \(authorizationData)", forHTTPHeaderField: "Authorization")
        request.httpBody = "scope=\(scope)".data(using: .utf8)!
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌Error: \(error!.localizedDescription)")
                return
            }
            
            do {
                let json = try? JSONDecoder().decode(Token.self, from: data)
                if let accessToken = json?.access_token {
                    self.userToken = accessToken
                    print("✅🔑 Токен доступа: \(accessToken)")
                }
            } catch {
                print("❌\(error.localizedDescription)")
            }
        }.resume()
        

    }
    
    func sendMessage(text: String, completionHandler: @escaping (Result<MessageResponse,Error>) -> Void) {
        
        let url = URL(string: "https://gigachat.devices.sberbank.ru/api/v1/chat/completions")!
        
        let messages = [
            ["role": "user", "content": text]
        ]
        let params: [String:Any] = [
            "model": "GigaChat",
            "messages": messages,
            "n": 1,
            "stream": false,
            "update_interval": 0
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            print(data)
            do {
                let response = try JSONDecoder().decode(MessageResponse.self, from: data)
                completionHandler(.success(response))
                print("😎\(response)")
            } catch {
                print("Error decoding JSON: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("JSON data: \(dataString)")
                }
            }
          
        }.resume()
       
    }
    
    
    func test() {
        // Example usage
        let jsonString = """
        {
          "choices": [
            {
              "message": {
                "content": "Верно.",
                "role": "assistant"
              },
              "index": 0,
              "finish_reason": "stop"
            }
          ],
          "created": 1722798459,
          "model": "GigaChat:3.1.25.3",
          "object": "chat.completion",
          "usage": {
            "prompt_tokens": 45,
            "completion_tokens": 4,
            "total_tokens": 49
          }
        }
        """
        
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let messageResponse = try JSONDecoder().decode(MessageResponse.self, from: jsonData)
                print(messageResponse)
            } catch {
                print("Error decoding JSON: \(error)")
                if let dataString = String(data: jsonData, encoding: .utf8) {
                    print("JSON data: \(dataString)")
                }
            }
        }
    }
    
}
