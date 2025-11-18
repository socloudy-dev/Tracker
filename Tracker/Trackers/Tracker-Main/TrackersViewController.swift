import UIKit

class TrackersViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    private var currentDate: Date = Calendar.current.startOfDay(for: Date())
    
    // MARK: - Initializer for stores
    
    init(trackerStore: TrackerStore,
         categoryStore: TrackerCategoryStore,
         recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    private let navBarAppearance = UINavigationBarAppearance()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()
    
    private let searchField: UISearchTextField = {
        let search = UISearchTextField()
        search.placeholder = "Поиск"
        search.font = .systemFont(ofSize: 17)
        search.clearButtonMode = .whileEditing
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private let searchContainer: UIView = {
        let container = UIView()
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        collection.register(TrackerCategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeaderView.reuseIdentifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: - Placeholder UI Elements
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Trackers is empty"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupTargets()
        setupNavigation()
        setupViews()
        setupConstraints()
        
        trackerStore.dataDidChange = { [weak self] in
            DispatchQueue.main.async {
                self?.reloadTrackers()
            }
        }
        
        reloadTrackers()
    }
    
    // MARK: - Setup UI Methods
    
    func setupViews() {
        view.addSubview(searchContainer)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(collectionView)
        
        searchContainer.addSubview(searchField)
    }
    
    private func setupNavigation() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(image: UIImage(named: "Add Button"))
        addButton.tintColor = UIColor.ypBlack
        addButton.target = self
        addButton.action = #selector(addButtonDidTap)
        
        navBarAppearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.ypBlack
        ]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupTargets() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            searchField.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchField.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            searchField.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
            
            searchContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    // MARK: - Setup Methods
    
    private func updatePlaceholderVisibility() {
        let sectionsCount = trackerStore.numberOfSections()
        var hasTrackers = false
        
        for section in 0..<sectionsCount {
            if trackerStore.numberOfTrackers(in: section, for: currentDate) > 0 {
                hasTrackers = true
                break
            }
        }
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.placeholderImageView.isHidden = hasTrackers
            self?.placeholderLabel.isHidden = hasTrackers
        }
    }
    
    private func reloadTrackers() {
        trackerStore.fetchTrackers()
        
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc
    private func addButtonDidTap() {
        let viewController = AddTrackerViewController(categoryStore: categoryStore)
        viewController.delegate = self
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: true)
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = Calendar.current.startOfDay(for: sender.date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: currentDate)
        print("[ℹ️ TrackersViewController/datePickerValueChanged]: Выбранная дата: \(dateString)")
        
        reloadTrackers()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfTrackers(in: section, for: currentDate)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        guard let tracker = trackerStore.tracker(at: indexPath, for: currentDate) else { return cell }
        
        let daysCounter = recordStore.fetchRecords(for: tracker.id).count
        let isCompleted = recordStore.hasRecord(for: tracker.id, date: currentDate)
        cell.configureCell(with: tracker, daysCounter: daysCounter, isCompleted: isCompleted)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeaderView.reuseIdentifier, for: indexPath) as! TrackerCategoryHeaderView
            if let name = trackerStore.categoryName(for: indexPath.section) {
                header.configure(with: name)
            }
            return header
        }
        return UICollectionReusableView()
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width / 2) - 4.5, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let count = trackerStore.numberOfTrackers(in: section, for: currentDate)
        if count == 0 {
            return .zero
        } else {
            return CGSize(width: collectionView.bounds.width, height: 26)
        }
    }
}

extension TrackersViewController: AddTrackerDelegate {
    func didCreateTracker(_ tracker: Tracker, from category: String) {
        let categoriesCore = categoryStore.fetchAll()
        let categoryCoreData: TrackerCategoryCoreData
        if let existing = categoriesCore.first(where: { $0.name == category }) {
            categoryCoreData = existing
        } else {
            categoryCoreData = categoryStore.create(name: category)
        }
        
        trackerStore.create(
            id: tracker.id,
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emoji,
            schedule: tracker.schedule,
            category: categoryCoreData
        )
        
        reloadTrackers()
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapComplete(_ cell: TrackerCollectionViewCell, for trackerId: UUID) {
        let today = Calendar.current.startOfDay(for: Date())
        if currentDate > today { return }
        
        
        if recordStore.hasRecord(for: trackerId, date: currentDate) {
            recordStore.removeRecord(for: trackerId, date: currentDate)
            cell.updateCompleteButtonState(completed: false)
        } else {
            recordStore.addRecord(for: trackerId, date: currentDate)
            cell.updateCompleteButtonState(completed: true)
        }
        
        let daysCounter = recordStore.fetchRecords(for: trackerId).count
        cell.updateCounterLabel(daysCounter: daysCounter.dayWithEnding)
    }
}
