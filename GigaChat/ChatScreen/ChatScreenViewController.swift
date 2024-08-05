import UIKit
import SnapKit

final class ChatScreenViewController: UIViewController {
    
    // MARK: Properties
    
    let API = APIClient.shared
    
    private let textFieldView: UIView = {
        let obj = UIView()
        obj.layer.cornerRadius = 20
        obj.backgroundColor = .textField
        return obj
    }()
    
    private let userTextField: UITextField = {
        let obj = UITextField()
        obj.backgroundColor = .clear
        obj.textColor = .white
        obj.font = FontBuilder.shared.jost(size: 16)
        obj.placeholder = "О чем поговорим?"
        obj.textAlignment = .left
        obj.returnKeyType = .send
        obj.clearsOnInsertion = true
        obj.clearsOnBeginEditing = true
        return obj
    }()
    
    private let chatTableView: UITableView = {
        let obj = UITableView()
        obj.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.ID)
        obj.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.ID)
        obj.backgroundColor = .brandBG
        obj.layer.cornerRadius = 10
        obj.separatorStyle = .none
        obj.showsVerticalScrollIndicator = false
        obj.allowsSelection = false
        return obj
    }()
    
    private var models = [ChatMessage]()
    
    private var textFieldBottomConstraint: Constraint?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        print("♦️ ChatVC deinited")
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Methods
    
    private func setupUI() {
        view.backgroundColor = .brandBG
        
        view.addSubview(chatTableView)
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        chatTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(50)
            make.bottom.equalToSuperview().inset(100)
        }
        
        view.addSubview(textFieldView)
        textFieldView.addSubview(userTextField)
        userTextField.delegate = self
        
        textFieldView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(chatTableView.snp.bottom).offset(10)
            make.height.equalTo(50)
            self.textFieldBottomConstraint = make.bottom.equalToSuperview().inset(20).constraint
        }
        
        userTextField.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.userTextField.resignFirstResponder()
    }
    
    func getResponse(input: String, completion: @escaping (Result<String, Error>) -> Void) {
        APIClient.shared.sendMessage(text: input) { [weak self] result in
            switch result {
            case .success(let model):
                // Safely unwrap the optional content
                guard let content = model.choices?.first?.message.content else {
                    completion(.failure(NSError(domain: "APIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "No message content found"])))
                    return
                }
                
                completion(.success(content))
                
                // Reload the chat table view and scroll to the bottom
                DispatchQueue.main.async {
                    self?.chatTableView.reloadData()
                    self?.scrollToBottom()
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            textFieldBottomConstraint?.update(inset: keyboardSize.height + 10)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        textFieldBottomConstraint?.update(inset: 20)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func scrollToBottom() {
        let numberOfSections = chatTableView.numberOfSections
        let numberOfRows = chatTableView.numberOfRows(inSection: numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows-1, section: numberOfSections-1)
            chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
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

    private func downloadImage(withID imageID: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let token = API.userToken else {
            completion(.failure(NSError(domain: "APIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "No token available"])))
            return
        }
        FileDownloader.shared.downloadImage(withID: imageID, token: token, completion: completion)
    }

}

// MARK: TextField Delegate

extension ChatScreenViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1) {
            self.textFieldView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            models.append(.text(text))
            chatTableView.reloadData()
            getResponse(input: text) { [weak self] result in
                switch result {
                case .success(let output):
                    print(output)
                    if let imageID = self?.extractImageID(from: output) {
                        // Download the image using the image ID
                        self?.downloadImage(withID: imageID) { result in
                            switch result {
                            case .success(let url):
                                // Append the image URL to the models
                                self?.models.append(.image(url))
                                DispatchQueue.main.async {
                                    self?.chatTableView.reloadData()
                                    self?.scrollToBottom()
                                }
                            case .failure(let error):
                                print("Failed to download image: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        // Append text message if no image URL is found
                        self?.models.append(.text(output))
                        DispatchQueue.main.async {
                            self?.chatTableView.reloadData()
                            self?.scrollToBottom()
                        }
                    }
                case .failure:
                    print("Failed")
                }
            }
        }
        textField.resignFirstResponder()
        textField.text = ""
        return true
    }
}

// MARK: TableView Delegate, Datasource

extension ChatScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = models[indexPath.row]
        
        print(message)
        
        switch message {
        case .text(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.ID, for: indexPath) as! ChatTableViewCell
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
            cell.loadImage(from: url)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let model = models[indexPath.row]
        
        switch model {
        case .text(let text):
            let label = UILabel()
            label.text = text
            label.numberOfLines = 0
            return label.systemLayoutSizeFitting(CGSize(width: tableView.frame.width - 20, height: CGFloat.greatestFiniteMagnitude)).height + 20
        case .image:
            return 200
        }
    }
}

