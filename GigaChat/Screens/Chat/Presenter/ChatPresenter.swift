//
//  ChatPresenter.swift
//  GigaChat
//
//  Created by Nikita Stepanov on 31.08.2024.
//

import Foundation
import UIKit

protocol ChatViewOutputProtocol: UITableViewDataSource {
    func getResponse(input text: String)
}

final class ChatPresenter: NSObject {
    // MARK: - Properties
    unowned var viewController: ChatViewInputProtocol
    let apiManager: APIManagerProtocol
    private var models = [ChatMessage]()
    
    // MARK: - Initializer
    init(viewController: ChatViewInputProtocol,
         apiManager: APIManagerProtocol) {
        self.viewController = viewController
        self.apiManager = apiManager
    }
}

extension ChatPresenter: ChatViewOutputProtocol {
    func getResponse(input text: String) {
        models.append(ChatMessage.text(text))
        viewController.reloadTable()
        getResponse(input: text,
                    completion: { [weak self] result in
            switch result {
            case .success(let output):
                if let imageID = self?.extractImageID(from: output) {
                    self?.downloadImage(withID: imageID) { result in
                        switch result {
                        case .success(let url):
                            self?.models.append(.image(url))
                            DispatchQueue.main.async {
                                self?.viewController.reloadTable()
                                self?.viewController.scrollToBottom()
                            }
                        case .failure(let error):
                            print("Failed to download image: \(error.localizedDescription)")
                        }
                    }
                } else {
                    self?.models.append(.text(output))
                    DispatchQueue.main.async {
                        self?.viewController.reloadTable()
                        self?.viewController.scrollToBottom()
                    }
                }
            case .failure:
                print("Failed")
            }
        })
    }
    
    private func getResponse(input: String,
                             completion: @escaping (Result<String,
                                                    Error>) -> Void) {
        apiManager.sendMessage(text: input) { [weak self] result in
            if let self = self {
                switch result {
                case .success(let model):
                    guard let content = model.choices?.first?.message.content else {
                        completion(.failure(NSError(domain: "APIClient",
                                                    code: 0,
                                                    userInfo: [NSLocalizedDescriptionKey: "No message content found"])))
                        return
                    }
                    completion(.success(content))
                    DispatchQueue.main.async {
                        self.viewController.reloadTable()
                        self.viewController.scrollToBottom()
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func extractImageID(from message: String) -> String? {
        let pattern = "<img src=\"([^\"]+)\""
        if let range = message.range(of: pattern,
                                     options: .regularExpression) {
            return String(message[range])
                .replacingOccurrences(of: "<img src=\"",
                                      with: "")
                .replacingOccurrences(of: "\"",
                                      with: "")
        }
        return nil
    }
    
    private func downloadImage(withID imageID: String,
                               completion: @escaping (Result<URL,
                                                      Error>) -> Void) {
        guard let token = apiManager.userToken else {
            completion(.failure(NSError(domain: "APIClient",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "No token available"])))
            return
        }
        FileDownloader.shared.downloadImage(withID: imageID,
                                            token: token,
                                            completion: completion)
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        print(models.count)
        return models.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = models[indexPath.row]
        
        switch message {
        case .text(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.ID,
                                                     for: indexPath) as! ChatTableViewCell
            cell.titleLabel.text = text
            cell.titleLabel.numberOfLines = 0
            if indexPath.row % 2 != 0 {
                cell.contentView.backgroundColor = UIColor.brandBG
                cell.titleLabel.textAlignment = .left
                cell.titleLabel.textColor = .white
                
            } else {
                cell.contentView.backgroundColor = .brandBG
                cell.titleLabel.textAlignment = .right
                cell.titleLabel.textColor = .lightGray
            }
            
            return cell
            
        case .image(let url):
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.ID, for: indexPath) as! ImageTableViewCell
            
            Task {
                await cell.loadImage(from: url)
                print("✅Image loaded to cell")
            }
            
            cell.sendButtonCallback = {
//                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
//                    let imageToShare = [image]
//                    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
//                    activityViewController.popoverPresentationController?.sourceView = self.view
//                    
//                    // exclude some activity types from the list (optional)
//                    activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop,
//                                                                     UIActivity.ActivityType.postToFacebook ]
//                    
//                    self.present(activityViewController, animated: true, completion: nil)
//                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = models[indexPath.row]
        switch model {
        case .text(_):
            return UITableView.automaticDimension
        case .image:
            return 200
        }
    }
}
