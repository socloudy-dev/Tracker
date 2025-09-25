import UIKit

class TrackersViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var filteredTrackers: [Tracker] = []
    var allTrackers: [Tracker] = []
    
    // MARK: - UI Elements
    
    let navBarAppearance = UINavigationBarAppearance()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()
    
    let searchField: UISearchTextField = {
        let search = UISearchTextField()
        search.placeholder = "Поиск"
        search.font = .systemFont(ofSize: 17)
        search.clearButtonMode = .whileEditing
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    let searchContainer: UIView = {
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
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
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
    
    let placeholderLabel: UILabel = {
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
        let hasTrackers = !allTrackers.isEmpty
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.placeholderImageView.isHidden = hasTrackers
            self?.placeholderLabel.isHidden = hasTrackers
        }
    }
    
    // MARK: - Actions
    
    @objc
    func addButtonDidTap() {
        let viewController = AddTrackerViewController()
        viewController.delegate = self
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: true)
    }
    
    @objc
    func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(dateString)")
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        
        cell.configureCell(with: allTrackers[indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeaderView.reuseIdentifier, for: indexPath) as! TrackerCategoryHeaderView
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
        let count = allTrackers.count
        if count == 0 {
            return .zero
        } else {
            return CGSize(width: collectionView.bounds.width, height: 26)
        }
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    
}

extension TrackersViewController: AddTrackerDelegate {
    func didCreateTracker(_ tracker: Tracker, from category: String) {
        filteredTrackers.append(tracker)
        allTrackers.append(tracker)
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}


