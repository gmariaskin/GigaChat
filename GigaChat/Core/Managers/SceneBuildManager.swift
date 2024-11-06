
import Foundation

protocol SceneBuildManagerProtocol {
    func buildChatScreen() -> ChatViewController
}

final class SceneBuildManager {
    // MARK: - Private properties
    private var apiManager: APIManagerProtocol = APIClient() // TO DO: implement protocol
    
    // MARK: - Initializer
    init() {}
}

extension SceneBuildManager: SceneBuildManagerProtocol {
    func buildChatScreen() -> ChatViewController {
        let viewController = ChatViewController()
        let presenter = ChatPresenter(viewController: viewController,
                                      apiManager: apiManager)
        viewController.presenter = presenter
        return viewController
    }
}
