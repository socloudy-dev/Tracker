import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"
    
    let emojiSelectorView: UIView = {
        let emojiBackground = UIView()
        emojiBackground.layer.cornerRadius = 16
        emojiBackground.backgroundColor = UIColor(resource: .white)
        emojiBackground.clipsToBounds = true
        emojiBackground.translatesAutoresizingMaskIntoConstraints = false
        return emojiBackground
    }()
    
    private let emojiLabel: UILabel = {
        let emoji = UILabel()
        emoji.font = .systemFont(ofSize: 32, weight: .bold)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        return emoji
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(emojiSelectorView)
        contentView.addSubview(emojiLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiSelectorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiSelectorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiSelectorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiSelectorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiSelectorView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiSelectorView.centerYAnchor)
        ])
    }
    
    func configureCell(with emoji: String) {
        emojiLabel.text = emoji
    }
}
