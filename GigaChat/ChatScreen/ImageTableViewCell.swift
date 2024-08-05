//
//  ImageTableViewCell.swift
//  GigaChat
//
//  Created by Gleb on 05.08.2024.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    static let ID = String(describing: ImageTableViewCell.self)
    
    private let image = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = .brandBG
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = .brandGray
        contentView.addSubview(image)
        image.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
    }
    
    func loadImage(from url: URL) {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    print("✅Image exists")
                    DispatchQueue.main.async {
                        self?.image.image = image
                    }
                }
            }
        }
}
