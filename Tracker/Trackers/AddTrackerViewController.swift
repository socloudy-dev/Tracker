import UIKit

protocol AddTrackerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, from category: String)
}

final class AddTrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AddTrackerDelegate?
    private var selectedCategory: String = "Важное"
    var selectedWeekDays: [WeekDay] = []
    private var trackerName: String = ""
    private var tableTopToTextField: NSLayoutConstraint!
    private var tableTopToLabel: NSLayoutConstraint!
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "White")
        
        parametersTableView.dataSource = self
        parametersTableView.delegate = self
        parametersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        trackerTextField.delegate = self
        
        setupViews()
        setupConstraints()
        setupTargets()
        
        saveTrackerButton.isEnabled = false
    }
    
    // MARK: - Setup UI Methods
    
    private func setupViews() {
        view.addSubview(headerLabel)
        view.addSubview(trackerTextField)
        view.addSubview(parametersTableView)
        view.addSubview(symbolLimitLabel)
        
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
        
        buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
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
        let categoryName = "Важное"
        
        let newTracker: Tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: UIColor(named: "5") ?? .green,
            emoji: "😍",
            schedule: selectedWeekDays)
        
        delegate?.didCreateTracker(newTracker, from: categoryName)
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
        let hasSchedule = !(selectedWeekDays.isEmpty)
        saveTrackerButton.isEnabled = hasText && hasSchedule
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
        content.secondaryText = indexPath.row == 0 ? "Важное" : scheduleString
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
