import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

final class CategoriesViewContoller: UIViewController {
    // MARK: Properties
    
    weak var delegate: CategorySelectionDelegate?
    private var categories: [TrackerCategory] = []
    private var selectedCategory: TrackerCategory?
    
    private let categoryStore: TrackerCategoryStore
    
    // MARK: - Store Initializer
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoriesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(named: "Gray")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = true
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.rowHeight = 75
        return tableView
    }()
    
    private let addCategoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "Black")
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = UIColor(named: "White")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Placeholder UI Elements
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Trackers is empty"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\n объединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.ypBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = categoryStore.fetchAll().map { TrackerCategory(name: $0.name ?? "", trackers: []) }
        
        view.backgroundColor = UIColor(named: "White")
        
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        setupViews()
        setupConstraints()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Setup UI Methods
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(categoriesTableView)
        view.addSubview(addCategoryButton)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoriesTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -44),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    // MARK: - Setup Methods
    
    private func updatePlaceholderVisibility() {
        let categoriesCount = categories.count
        let hasCategories = categoriesCount > 0
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.placeholderImageView.isHidden = hasCategories
            self?.placeholderLabel.isHidden = hasCategories
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func addCategoryButtonTapped() {
        let addCategoryViewController = AddCategoryViewController(categoryStore: categoryStore)
        addCategoryViewController.delegate = self
        present(addCategoryViewController, animated: true)
    }
}

extension CategoriesViewContoller: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let category = categories[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = category.name
        content.textProperties.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        content.textProperties.color = UIColor(named: "Black") ?? .black
        cell.contentConfiguration = content
        
        cell.selectionStyle = .default
        cell.backgroundColor = UIColor(named: "Background")
        cell.accessoryType = (category.name == selectedCategory?.name) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let maskPath = UIBezierPath(
            roundedRect: cell.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        let maskLayer = CAShapeLayer()
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            maskLayer.path = maskPath.cgPath
            cell.layer.mask = maskLayer
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else {
            cell.layer.mask = nil
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        selectedCategory = category
        tableView.reloadData()
        delegate?.didSelectCategory(category)
        dismiss(animated: true)
    }
}

extension CategoriesViewContoller: AddCategoryDelegate {
    func didCreateCategory() {
        categories = categoryStore.fetchAll().map { TrackerCategory(name: $0.name ?? "", trackers: []) }
        updatePlaceholderVisibility()
        categoriesTableView.reloadData()
    }
}
