
import UIKit

class ImageTableViewCell: UITableViewCell {
    
    static let ID = String(describing: ImageTableViewCell.self)
    
    var sendButtonCallback: (() -> Void)?
    
    private let sendButton: UIButton = {
        let obj = UIButton()
        obj.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        obj.tintColor = .lightGray
        return obj
    }()
    
    private let logoImageView: UIImageView = {
        let obj = UIImageView()
        obj.contentMode = .scaleAspectFit
        obj.image = UIImage(named: "logo")
        obj.clipsToBounds = true
        return obj 
    }()
    
    private let image: UIImageView = {
        let obj = UIImageView()
       obj.contentMode = .scaleAspectFill
       obj.layer.cornerRadius = 10
        obj.clipsToBounds = true
        return obj
    }()
    
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
        contentView.backgroundColor = .brandBG
        
        contentView.addSubview(image)
        contentView.addSubview(sendButton)
        contentView.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.leading.top.equalToSuperview().inset(5)
        }
        image.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(5)
            make.top.equalTo(logoImageView)
            make.leading.equalTo(logoImageView.snp.trailing).offset(10)
            make.width.equalTo(200)
        }
      
        
        sendButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.bottom.equalTo(image)
            make.leading.equalTo(image.snp.trailing).offset(5)
        }
        
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        
    }
    
    @objc func sendButtonTapped() {
        if sendButtonCallback != nil {
            sendButtonCallback!()
        }
    }
    
//    func loadImage(from url: URL) {
//        
//            DispatchQueue.global().async { [weak self] in
//                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
//                    print("✅Image exists")
//                    DispatchQueue.main.async {
//                        self?.image.image = image
//                    }
//                }
//            }
//    }\
    
    func loadImage(from url: URL) async {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    print("✅Image exists")
                    DispatchQueue.main.async { [weak self] in
                        self?.image.image = image
                    }
                }
            } catch {
                print("❌Failed to load image: \(error)")
            }
        }
}

