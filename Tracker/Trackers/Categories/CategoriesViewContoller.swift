import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

final class CategoriesViewContoller: UIViewController {
    
    // MARK: Properties
    
    weak var delegate: CategorySelectionDelegate?
    private let viewModel: CategoriesViewModel
    var selectedCategory: TrackerCategory?
    
    private let categoryStore: TrackerCategoryStore
    
    // MARK: - Initializer
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        self.viewModel = CategoriesViewModel(store: categoryStore)
        
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
        label.textColor = UIColor(resource: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoriesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(resource: .gray)
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
        button.backgroundColor = UIColor(resource: .black)
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(resource: .white), for: .normal)
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
        label.textColor = UIColor(resource: .black)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .white)
        
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        bindViewModel()
        viewModel.load()
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
        let hasCategories = !viewModel.categories.isEmpty
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.placeholderImageView.isHidden = hasCategories
            self?.placeholderLabel.isHidden = hasCategories
        }
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.categoriesTableView.reloadData()
            self?.updatePlaceholderVisibility()
        }
        viewModel.onSelect = { [weak self] category in
            self?.delegate?.didSelectCategory(category)
        }
    }
    
    private func presentDeleteAlert(category: TrackerCategory) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.categoryStore.delete(category)
            if self?.selectedCategory?.name == category.name {
                self?.selectedCategory = nil
            }
        })
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(alert, animated: true)
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
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let category = viewModel.categories[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = category.name
        content.textProperties.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        content.textProperties.color = UIColor(resource: .black)
        cell.contentConfiguration = content
        
        cell.selectionStyle = .default
        cell.backgroundColor = UIColor(resource: .background)
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
        viewModel.select(at: indexPath.row)
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = viewModel.categories[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                guard let self = self else { return }
                let editCategoryViewController = EditCategoryViewController(category: category, categoryStore: categoryStore)
                editCategoryViewController.delegate = self
                self.present(editCategoryViewController, animated: true)
            }
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                presentDeleteAlert(category: category)
                self.viewModel.load()
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

extension CategoriesViewContoller: AddCategoryDelegate {
    func didCreateCategory() {
        viewModel.load()
    }
}

extension CategoriesViewContoller: EditCategoryDelegate {
    func didEditCategory() {
        viewModel.load()
    }
}
