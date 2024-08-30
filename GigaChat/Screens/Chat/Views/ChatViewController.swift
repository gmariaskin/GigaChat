//
//  ChatViewController.swift
//  GigaChat
//
//  Created by Nikita Stepanov on 30.08.2024.
//

import Foundation
import UIKit
import SnapKit

protocol ChatViewInputProtocol: NSObject {
    func scrollToBottom()
    func reloadTable()
}

final class ChatViewController: UIViewController {
    // MARK: - UI Components
    private lazy var responseView: UIView = makeResponseView()
    private lazy var userTextField: UITextField = makeUserTextField()
    private lazy var chatTableView: UITableView = makeChatTableView()
    
    // MARK: - Constraints
    private var responseViewBottomConstraint: Constraint?
    
    // MARK: - Properties
    public var presenter: ChatViewOutputProtocol? {
        didSet {
            chatTableView.dataSource = presenter
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()

        // to do - переосмыслить
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
}

extension ChatViewController: ChatViewInputProtocol {
    func reloadTable() {
        chatTableView.reloadData()
    }
    
    func scrollToBottom() {
        let numberOfSections = chatTableView.numberOfSections
        let numberOfRows = chatTableView.numberOfRows(inSection: numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows-1,
                                      section: numberOfSections-1)
            chatTableView.scrollToRow(at: indexPath,
                                      at: .bottom,
                                      animated: true)
        }
    }
}

extension ChatViewController {
    // MARK: - Final SetUp
    private func setUp() {
        setUpBackground()
        setUpLayout()
        setUpDelegates()
    }
    
    // MARK: - Appearance
    private func setUpBackground() {
        view.backgroundColor = .brandBG
    }
    
    private func setUpLayout() {
        view.addSubviews(chatTableView,
                         responseView)
        
        chatTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(50)
            make.bottom.equalToSuperview().inset(100)
        }
        
        responseView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(chatTableView.snp.bottom).offset(10)
            make.height.equalTo(50)
            self.responseViewBottomConstraint = make.bottom.equalToSuperview().inset(20).constraint
        }
        
        responseView.addSubview(userTextField)
        
        userTextField.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - SetUp Delegates
    func setUpDelegates() {
        chatTableView.delegate = self
        userTextField.delegate = self
    }
}

// MARK: - Actions
extension ChatViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            responseViewBottomConstraint?.update(inset: keyboardSize.height + 10)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        responseViewBottomConstraint?.update(inset: 20)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UI-Making Funcs
extension ChatViewController {
    private func makeResponseView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = .textField
        return view
    }
    
    private func makeUserTextField() -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(string: K.greetingText,
                                                             attributes: [NSAttributedString.Key.strokeColor : UIColor.white.cgColor,
                                                                          NSAttributedString.Key.font : K.jostFont(size: 16)])
        textField.textAlignment = .left
        textField.returnKeyType = .send
        textField.clearsOnInsertion = true
        textField.clearsOnBeginEditing = true
        textField.tintColor = .white
        return textField
    }
    
    private func makeChatTableView() -> UITableView {
        let tableView = UITableView()
        tableView.register(ChatTableViewCell.self,
                           forCellReuseIdentifier: ChatTableViewCell.ID)
        tableView.register(ImageTableViewCell.self,
                           forCellReuseIdentifier: ImageTableViewCell.ID)
        tableView.backgroundColor = .brandBG
        tableView.layer.cornerRadius = 10
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        return tableView
    }
}

// to do - вынести по файлам

// MARK: - UITextFieldDelegate extension
extension ChatViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.userTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1) {
            self.responseView.transform = CGAffineTransform(scaleX: 0.9,
                                                            y: 0.9)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text,
           !text.isEmpty {
            presenter?.getResponse(input: text)
            textField.resignFirstResponder()
            textField.text = ""
        }
        return true
    }
}

extension ChatViewController: UITableViewDelegate {
    
}
