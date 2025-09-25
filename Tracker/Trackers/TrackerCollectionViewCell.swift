import UIKit

class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCollectionViewCell"
    
    private let containerView: UIView = {
        let container = UIView()
        container.layer.cornerRadius = 16
        container.backgroundColor = UIColor(named: "Red")
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private let emojiBackgroundView: UIView = {
        let emojiBackground = UIView()
        emojiBackground.layer.cornerRadius = 12
        emojiBackground.backgroundColor = .white
        emojiBackground.alpha = 0.3
        emojiBackground.clipsToBounds = true
        emojiBackground.translatesAutoresizingMaskIntoConstraints = false
        return emojiBackground
    }()
    
    private let emojiLabel: UILabel = {
        let emoji = UILabel()
        emoji.font = .systemFont(ofSize: 16, weight: .medium)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        return emoji
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let counterLabel: UILabel = {
        let counter = UILabel()
        counter.font = .systemFont(ofSize: 12, weight: .medium)
        counter.textColor = UIColor(named: "Black")
        counter.translatesAutoresizingMaskIntoConstraints = false
        return counter
    }()
    
    private let completeTrackerButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.setImage(UIImage(named: "Increase Counter"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        completeTrackerButton.addTarget(self, action: #selector(completeTrackerButtonTapped), for: .touchUpInside)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        contentView.addSubview(emojiBackgroundView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(counterLabel)
        contentView.addSubview(completeTrackerButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            counterLabel.centerXAnchor.constraint(equalTo: completeTrackerButton.centerXAnchor),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: completeTrackerButton.leadingAnchor, constant: -8),
            counterLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            
            completeTrackerButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            completeTrackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeTrackerButton.heightAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configureCell(with tracker: Tracker) {
        containerView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.name
        completeTrackerButton.tintColor = tracker.color
        counterLabel.text = "0 дней"
    }
    
    @objc
    private func completeTrackerButtonTapped() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.completeTrackerButton.setImage(UIImage(named: "Tracker Completed"), for: .normal)
            
        }
    }
}
