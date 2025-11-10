import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    let colorSelectorView: UIView = {
        let selector = UIView()
        selector.layer.cornerRadius = 8
        selector.clipsToBounds = true
        selector.translatesAutoresizingMaskIntoConstraints = false
        return selector
    }()
    
    private let colorView: UIView = {
        let color = UIView()
        color.layer.cornerRadius = 8
        color.clipsToBounds = true
        color.translatesAutoresizingMaskIntoConstraints = false
        return color
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
        contentView.addSubview(colorSelectorView)
        contentView.addSubview(colorView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorSelectorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorSelectorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorSelectorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorSelectorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            colorView.centerXAnchor.constraint(equalTo: colorSelectorView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: colorSelectorView.centerYAnchor),
            colorView.topAnchor.constraint(equalTo: colorSelectorView.topAnchor, constant: 6),
            colorView.leadingAnchor.constraint(equalTo: colorSelectorView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: colorSelectorView.trailingAnchor, constant: -6),
            colorView.bottomAnchor.constraint(equalTo: colorSelectorView.bottomAnchor, constant: -6)
        ])
    }
    
    func configureCell(with color: String) {
        colorView.backgroundColor = UIColor(named: color)
    }
}
