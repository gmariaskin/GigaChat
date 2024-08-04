//
//  ChatScreenViewController.swift
//  GigaChat
//
//  Created by Gleb on 04.08.2024.
//

import UIKit
import SnapKit




final class ChatScreenViewController: UIViewController {
    
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
        obj.backgroundColor = .brandBG
        obj.layer.cornerRadius = 10
        obj.separatorStyle = .none
        obj.resignFirstResponder()
        return obj
    }()
    
    private var models = [String]()
    
    override func viewDidLoad() {
        
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
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
        APIClient.shared.sendMessage(text: input) { result in
            switch result {
            case .success(let model):
                let output = model.choices?.first?.message.content ?? ""
                print("🥳")
                completion(.success(output))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}


extension ChatScreenViewController: UITextFieldDelegate {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1) {
            self.textFieldView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let text = textField.text, !text.isEmpty {
            models.append(text)
            chatTableView.reloadData()
            getResponse(input: text) { [weak self] result in
                switch result {
                case .success(let output):
                    self?.models.append(output)
                    
                    DispatchQueue.main.async {
                        self?.chatTableView.reloadData()
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

extension ChatScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.ID, for: indexPath) as? ChatTableViewCell else { return UITableViewCell()}
        cell.titleLabel.text = models[indexPath.row]
        cell.titleLabel.numberOfLines = 0
        if indexPath.row % 2 != 0 {
            cell.contentView.backgroundColor = UIColor.brandBG
            cell.titleLabel.textAlignment = .left
            cell.titleLabel.textColor = .white
            cell.titleLabel.font = FontBuilder.shared.jost(size: 16)
        } else {
            cell.contentView.backgroundColor = .brandBG
            cell.titleLabel.textAlignment = .right
            cell.titleLabel.textColor = .lightGray
            cell.titleLabel.font = FontBuilder.shared.jost(size: 16)
//            cell.label.charInterval = 0
            
        }
        return cell
    }
    
    
}




