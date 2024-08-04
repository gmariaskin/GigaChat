//
//  ChatTableViewCell.swift
//  GigaChat
//
//  Created by Gleb on 05.08.2024.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
//    
//    let label: CLTypingLabel = {
//        let obj = CLTypingLabel()
//        obj.charInterval = 0.02
//        obj.numberOfLines = 0
//        return obj
//    }()
    
    let titleLabel = UILabel()
    
    static let ID = String(describing: ChatTableViewCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        backgroundColor = .brandBG
        contentView.layer.cornerRadius = 5
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }
    
}
