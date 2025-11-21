import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    
    let filters: [TrackerFilter] = [.all, .today, .completed, .incomplete]
    var selectedFilter: TrackerFilter = .all
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(resource: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let filtersTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(resource: .gray)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .white)
        
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
        filtersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup UI Methods
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(filtersTableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filtersTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let filter = filters[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = filter.title
        content.textProperties.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        content.textProperties.color = UIColor(resource: .black)
        cell.contentConfiguration = content
        
        cell.selectionStyle = .default
        cell.backgroundColor = UIColor(resource: .background)
        
        if filter == .completed || filter == .incomplete {
            cell.accessoryType = (filter == selectedFilter) ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        selectedFilter = filter
        delegate?.didSelectFilter(filter)
        tableView.reloadData()
        dismiss(animated: true)
    }
}
