//
//  ImageDownloader.swift
//  GigaChat
//
//  Created by Gleb on 05.08.2024.
//

import Foundation


class FileDownloader {
    
    static let shared = FileDownloader()
    
    
    func downloadImage(withID imageID: String, token: String, completion: @escaping (Result<URL, Error>) -> Void) {
            let fileURL = URL(string: "https://gigachat.devices.sberbank.ru/api/v1/files/\(imageID)/content")!
            var request = URLRequest(url: fileURL)
            request.httpMethod = "GET"
            request.setValue("Accept: application/jpg", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "FileDownloader", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                // Get the path to the documents directory
                let fileManager = FileManager.default
                guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    completion(.failure(NSError(domain: "FileDownloader", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unable to access documents directory"])))
                    return
                }
                
                let fileURL = documentsDirectory.appendingPathComponent("\(imageID).jpg")
                
                do {
                    // Save the file data to the documents directory
                    try data.write(to: fileURL)
                    completion(.success(fileURL))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
  
   



