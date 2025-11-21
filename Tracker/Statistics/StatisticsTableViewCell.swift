import UIKit

class StatisticsTableViewCell: UITableViewCell {
    
    weak var delegate: TrackerCellDelegate?
    
    static let reuseIdentifier = "StatisticsCell"
    
    private let cellView: UIView = {
        let container = UIView()
        container.layer.cornerRadius = 16
        container.backgroundColor = UIColor(resource: .white)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textColor = UIColor(resource: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let counterLabel: UILabel = {
        let counter = UILabel()
        counter.font = .systemFont(ofSize: 34, weight: .bold)
        counter.textColor = UIColor(resource: .black)
        counter.translatesAutoresizingMaskIntoConstraints = false
        return counter
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureGradientBorders()
    }
    
    private func setupViews() {
        contentView.addSubview(cellView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(counterLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -12),
            
            counterLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 12),
            counterLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            counterLabel.topAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -37),
        ])
    }
    
    func configureCell(with statisticEntity: StatisticEntity) {
        titleLabel.text = statisticEntity.title
        counterLabel.text = String(statisticEntity.count)
    }
    
    func configureGradientBorders() {
        cellView.layer.sublayers?.removeAll(where: { $0.name == "gradientBorder" })
        
        let gradient = CAGradientLayer()
        gradient.name = "gradientBorder"
        gradient.frame = cellView.bounds
        gradient.colors = [
            UIColor(red: 0xFD/255, green: 0x4C/255, blue: 0x49/255, alpha: 1).cgColor,
            UIColor(red: 0x46/255, green: 0xE6/255, blue: 0x9D/255, alpha: 1).cgColor,
            UIColor(red: 0x00/255, green: 0x7B/255, blue: 0xFA/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)

        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: cellView.bounds.insetBy(dx: 1, dy: 1), cornerRadius: cellView.layer.cornerRadius).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        shape.lineWidth = 1.0
        
        gradient.mask = shape
        
        cellView.layer.addSublayer(gradient)
        backgroundColor = UIColor(resource: .white)
    }
}
