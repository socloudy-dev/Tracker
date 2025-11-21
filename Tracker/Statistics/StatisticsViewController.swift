import UIKit

class StatisticsViewController: UIViewController {
    //MARK: - Properties
    
    private let reuseIdentifier = "StatisticsCell"
    private var statisticEntities: [StatisticEntity] = []
    
    private var trackers: [Tracker] = []
    private var records: [TrackerRecord] = []
    
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    // MARK: - Store Initializer
    
    init(trackerStore: TrackerStore,
         recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(resource: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statisticsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(resource: .white)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = true
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.rowHeight = 102
        return tableView
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .nothingToAnalyze))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .white)
        
        statisticsTableView.dataSource = self
        statisticsTableView.register(StatisticsTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        trackers = trackerStore.fetchAllTrackers()
        records = recordStore.fetchAllRecords()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recordsDidChange), name: .NSManagedObjectContextDidSave, object: nil)
        
        setupViews()
        setupConstraints()
        calculateStatistics()
    }
    
    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    // MARK: - Setup UI Methods
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(statisticsTableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            statisticsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statisticsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            statisticsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            statisticsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -28),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    // MARK: - Setup Methods
    
    private func calculateStatistics() {
        let calendar = Calendar.current
        
        let recordsByDate = Dictionary(grouping: records, by: { calendar.startOfDay(for: $0.date) })

        let idealDays = recordsByDate.filter { (_, recs) in
            Set(recs.map { $0.trackerId }).count == trackers.count
        }.count

        let sortedDays = recordsByDate.keys.sorted()
        var bestStreak = 0, currentStreak = 0
        var prevDay: Date?
        for day in sortedDays {
            if let prev = prevDay, calendar.dateComponents([.day], from: prev, to: day).day == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            bestStreak = max(bestStreak, currentStreak)
            prevDay = day
        }
        
        let totalCompletions = records.count

        let average = sortedDays.isEmpty ? 0 : totalCompletions / sortedDays.count

        statisticEntities = [
            StatisticEntity(title: "Лучший период", count: bestStreak),
            StatisticEntity(title: "Идеальные дни", count: idealDays),
            StatisticEntity(title: "Трекеров завершено", count: totalCompletions),
            StatisticEntity(title: "Среднее значение", count: average)
        ]
        
        statisticsTableView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        let hasRecords = statisticEntities.contains { $0.count > 0 }
        let shouldShowPlaceholder = !hasRecords
        
        statisticsTableView.isHidden = shouldShowPlaceholder
        placeholderImageView.isHidden = !shouldShowPlaceholder
        placeholderLabel.isHidden = !shouldShowPlaceholder
    }
    
    @objc
    private func recordsDidChange() {
        trackers = trackerStore.fetchAllTrackers()
        records = recordStore.fetchAllRecords()
        calculateStatistics()
    }
    
}

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        statisticEntities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? StatisticsTableViewCell else { return UITableViewCell() }
        
        let statisticEntity = statisticEntities[indexPath.row]
        cell.configureCell(with: statisticEntity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
}
