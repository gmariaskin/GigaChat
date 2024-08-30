//
//  SceneBuildManager.swift
//  GigaChat
//
//  Created by Nikita Stepanov on 31.08.2024.
//

import Foundation

protocol SceneBuildManagerProtocol {
    func buidChatScreen() -> ChatViewController
}

final class SceneBuildManager {
    // MARK: - Private properties
    private var apiManager: APIManagerProtocol = APIClient() // TO DO: implement protocol
    
    // MARK: - Initializer
    init() {}
}

extension SceneBuildManager: SceneBuildManagerProtocol {
    func buidChatScreen() -> ChatViewController {
        let viewController = ChatViewController()
        let presenter = ChatPresenter(viewController: viewController,
                                      apiManager: apiManager)
        viewController.presenter = presenter
        return viewController
    }
}
