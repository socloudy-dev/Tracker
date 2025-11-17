import UIKit

protocol AddTrackerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, from category: String)
}

final class AddTrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AddTrackerDelegate?
    private var selectedCategory: String = ""
    var selectedWeekDays: [WeekDay] = []
    private var trackerName: String = ""
    private var trackerEmoji: String = ""
    private var trackerColor: String = ""
    private var tableTopToTextField: NSLayoutConstraint!
    private var tableTopToLabel: NSLayoutConstraint!
    private let categoryStore: TrackerCategoryStore
    
    private let emojis = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
    private let colors = TrackerColor.allCases
    
    // MARK: - Store Initializer
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trackerTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(named: "Background")
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.clearButtonMode = .whileEditing
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let parametersTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(named: "Gray")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "White")
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "Red")?.cgColor
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(named: "Red"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveTrackerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "Gray")
        button.layer.cornerRadius = 16
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let symbolLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(named: "Red")
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        collection.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        collection.register(AddTrackerCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AddTrackerCollectionHeader.reuseIdentifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "White")
        
        parametersTableView.dataSource = self
        parametersTableView.delegate = self
        parametersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        trackerTextField.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        
        setupViews()
        setupConstraints()
        setupTargets()
        
        saveTrackerButton.isEnabled = false
    }
    
    // MARK: - Setup UI Methods
    
    private func setupViews() {
        view.addSubview(headerLabel)
        view.addSubview(trackerTextField)
        view.addSubview(symbolLimitLabel)
        view.addSubview(parametersTableView)
        view.addSubview(collectionView)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(saveTrackerButton)
        view.addSubview(buttonsStackView)
    }
    
    private func setupConstraints() {
        tableTopToTextField = parametersTableView.topAnchor.constraint(equalTo: trackerTextField.bottomAnchor, constant: 24)
        tableTopToLabel = parametersTableView.topAnchor.constraint(equalTo: symbolLimitLabel.bottomAnchor, constant: 32)
        
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            
            trackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
            trackerTextField.heightAnchor.constraint(equalToConstant: 75),
            
            symbolLimitLabel.topAnchor.constraint(equalTo: trackerTextField.bottomAnchor, constant: 8),
            symbolLimitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableTopToTextField,
            parametersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            parametersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            parametersTableView.heightAnchor.constraint(equalToConstant: 150),
            
            collectionView.topAnchor.constraint(equalTo: parametersTableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTargets() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        saveTrackerButton.addTarget(self, action: #selector(saveTrackerButtonTapped), for: .touchUpInside)
        trackerTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setSymbolLimitVisible(_ visible: Bool) {
        if visible {
            tableTopToTextField.isActive = false
            tableTopToLabel.isActive = true
        } else {
            tableTopToLabel.isActive = false
            tableTopToTextField.isActive = true
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func saveTrackerButtonTapped() {
        let newTracker: Tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: UIColor(named: "\(trackerColor)") ?? .gray,
            emoji: "\(trackerEmoji)",
            schedule: selectedWeekDays)
        
        delegate?.didCreateTracker(newTracker, from: selectedCategory)
        dismiss(animated: true)
    }
    
    @objc
    func textFieldDidChange() {
        trackerName = trackerTextField.text ?? ""
        updateSaveButtonState()
    }
    
    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Setup Methods
    
    func updateSaveButtonState() {
        let hasText = !(trackerTextField.text?.isEmpty ?? true)
        let hasCategory = !selectedCategory.isEmpty
        let hasSchedule = !selectedWeekDays.isEmpty
        let hasEmoji = !trackerEmoji.isEmpty
        let hasColor = !trackerColor.isEmpty
        
        saveTrackerButton.isEnabled = hasText && hasCategory && hasSchedule && hasEmoji && hasColor
        saveTrackerButton.backgroundColor = saveTrackerButton.isEnabled ? UIColor(named: "Black") : UIColor(named: "Gray")
    }
}

extension AddTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let scheduleString: String
        if selectedWeekDays.count == WeekDay.allCases.count {
            scheduleString = "Каждый день"
        } else {
            scheduleString = selectedWeekDays.map { $0.shortName }.joined(separator: ", ")
        }
        
        var content = cell.defaultContentConfiguration()
        content.text = indexPath.row == 0 ? "Категория" : "Расписание"
        content.textProperties.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        content.textProperties.color = UIColor(named: "Black") ?? .black
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        content.secondaryTextProperties.color = UIColor(named: "Gray") ?? .gray
        content.secondaryText = indexPath.row == 0 ? selectedCategory : scheduleString
        cell.contentConfiguration = content
        
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(named: "Background")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            scheduleViewController.selectedWeekDays = self.selectedWeekDays
            scheduleViewController.modalPresentationStyle = .formSheet
            present(scheduleViewController, animated: true)
        } else {
            let categoriesViewContoller = CategoriesViewContoller(categoryStore: categoryStore)
            categoriesViewContoller.delegate = self
            categoriesViewContoller.modalPresentationStyle = .formSheet
            present(categoriesViewContoller, animated: true)
        }
    }
}

extension AddTrackerViewController: ScheduleDelegate {
    func didSelectWeekDays(_ days: [WeekDay]) {
        selectedWeekDays = days
        parametersTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        updateSaveButtonState()
    }
}

extension AddTrackerViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        if updatedText.count > 38 {
            symbolLimitLabel.isHidden = false
            setSymbolLimitVisible(true)
            return false
        } else {
            symbolLimitLabel.isHidden = true
            setSymbolLimitVisible(false)
            return true
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        symbolLimitLabel.isHidden = true
        setSymbolLimitVisible(false)
        return true
    }
}

extension AddTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }
            cell.configureCell(with: emojis[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            cell.configureCell(with: colors[indexPath.item].rawValue)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddTrackerCollectionHeader.reuseIdentifier, for: indexPath) as! AddTrackerCollectionHeader
            header.titleLabel.text = indexPath.section == 0 ? "Emoji" : "Цвет"
            return header
        }
        return UICollectionReusableView()
    }
}

extension AddTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.bounds.width / 6) - 10
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 18, bottom: 40, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 36)
    }
}
extension AddTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.indexPathsForSelectedItems?
            .filter { $0.section == indexPath.section && $0 != indexPath }
            .forEach { collectionView.deselectItem(at: $0, animated: false)
                self.collectionView(collectionView, didDeselectItemAt: $0)
            }
        
        if indexPath.section == 0 {
            let selectedEmoji = emojis[indexPath.item]
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            
            trackerEmoji = selectedEmoji
            updateSaveButtonState()
            
            UIView.animate(withDuration: 0.2) {
                cell?.emojiSelectorView.backgroundColor = .ypLightGray
            }
        } else {
            let selectedColor = colors[indexPath.item].rawValue
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            
            trackerColor = selectedColor
            updateSaveButtonState()
            
            UIView.animate(withDuration: 0.2) {
                cell?.colorSelectorView.layer.borderWidth = 3
                cell?.colorSelectorView.alpha = 0.3
                cell?.colorSelectorView.layer.borderColor = UIColor(named: selectedColor)?.cgColor
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            trackerEmoji = ""
            updateSaveButtonState()
            UIView.animate(withDuration: 0.2) {
                cell?.emojiSelectorView.backgroundColor = .ypWhite
            }
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            trackerColor = ""
            updateSaveButtonState()
            cell?.colorSelectorView.layer.borderWidth = 0
            cell?.colorSelectorView.layer.borderColor = UIColor.white.cgColor
        }
    }
}

extension AddTrackerViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category.name
        parametersTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        updateSaveButtonState()
    }
}
