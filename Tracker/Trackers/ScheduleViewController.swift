import UIKit

protocol ScheduleDelegate: AnyObject {
    func didSelectWeekDays(_ days: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    
    // MARK: Properties
    
    weak var delegate: ScheduleDelegate?
    var selectedWeekDays: [WeekDay] = []
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weekDayTableView: UITableView = {
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
    
    private let saveScheduleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "Black")
        button.layer.cornerRadius = 16
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = UIColor(named: "White")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "White")
        
        weekDayTableView.dataSource = self
        weekDayTableView.delegate = self
        weekDayTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        saveScheduleButton.addTarget(self, action: #selector(saveScheduleButtonTapped), for: .touchUpInside)
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup UI Methods
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(weekDayTableView)
        view.addSubview(saveScheduleButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
        
        weekDayTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        weekDayTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        weekDayTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
        weekDayTableView.heightAnchor.constraint(equalToConstant: 525),
        
        saveScheduleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        saveScheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        saveScheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        saveScheduleButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc
    private func saveScheduleButtonTapped() {
        delegate?.didSelectWeekDays(selectedWeekDays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let day = WeekDay.displayOrder[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = day.displayName
        content.textProperties.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        content.textProperties.color = UIColor(named: "Black") ?? .black
        cell.contentConfiguration = content
        
        let toggle = UISwitch()
        toggle.isOn = selectedWeekDays.contains(day)
        toggle.onTintColor = UIColor(named: "Blue")
        toggle.tag = indexPath.row
        toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        cell.backgroundColor = UIColor(named: "Background")
        cell.selectionStyle = .none
        cell.accessoryView = toggle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    @objc
    func switchChanged(_ sender: UISwitch) {
        let day = WeekDay.displayOrder[sender.tag]
        if sender.isOn {
            if !selectedWeekDays.contains(day) {
                selectedWeekDays.append(day)
            }
        } else {
            selectedWeekDays.removeAll { $0 == day }
        }
        
        selectedWeekDays.sort { day1, day2 in
                guard let index1 = WeekDay.displayOrder.firstIndex(of: day1),
                      let index2 = WeekDay.displayOrder.firstIndex(of: day2) else { return false }
                return index1 < index2
            }
    }
}
