
import UIKit
import DWAnimatedLabel

enum Author {
    case gigaChat
    case user
}

class ChatTableViewCell: UITableViewCell {

    private let senderImageView: UIImageView = {
        let obj = UIImageView()
        obj.contentMode = .scaleAspectFit
        obj.image = UIImage(named: "logo")
        obj.clipsToBounds = true
        return obj
    }()
    
    let titleLabel: UILabel = {
        let obj = UILabel()
        obj.font = FontBuilder.shared.jost(size: 16)
        obj.numberOfLines = 0
        return obj
    }()
    
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
            make.verticalEdges.equalToSuperview().inset(10)
            make.horizontalEdges.equalToSuperview().inset(35)
        }
    }
    
//    func configure(author: Author) {
//        
//        contentView.addSubview(senderImageView)
//        switch author {
//        case .gigaChat:
//            senderImageView.snp.makeConstraints { make in
//                make.size.equalTo(20)
//                make.leading.top.equalToSuperview().inset(5)
//            }
//        case .user:
//            senderImageView.image = UIImage(named: "user")
//            senderImageView.backgroundColor = .lightGray
//            senderImageView.layer.cornerRadius = 10
//            senderImageView.snp.makeConstraints { make in
//                make.size.equalTo(20)
//                make.trailing.top.equalToSuperview().inset(5)
//            }
//        }
//    }
    
}
