import UIKit

protocol AddCategoryDelegate: AnyObject {
    func didCreateCategory()
}

final class AddCategoryViewController: UIViewController {
    // MARK: Properties
    
    private var selectedCategory: TrackerCategory?
    weak var delegate: AddCategoryDelegate?
    
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
        label.text = "Новая категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(named: "Background")
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.clearButtonMode = .whileEditing
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveCategoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "Black")
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = UIColor(named: "White")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "White")
        
        setupViews()
        setupConstraints()
        setupTargets()
    }
    
    // MARK: - Setup UI Methods
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(categoryTextField)
        view.addSubview(saveCategoryButton)
    }
    
    private func setupTargets() {
        saveCategoryButton.addTarget(self, action: #selector(saveCategoryButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
        
            categoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoryTextField.heightAnchor.constraint(equalToConstant: 75),
        
            saveCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc
    private func saveCategoryButtonTapped() {
        guard let categoryName = categoryTextField.text,
              !categoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        _ = categoryStore.create(name: categoryName)
        delegate?.didCreateCategory()
        dismiss(animated: true)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}
