import UIKit

final class TabBarController: UITabBarController {
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    init(trackerStore: TrackerStore,
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor(named: "Blue")
        
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        
        let trackersViewController = TrackersViewController(trackerStore: trackerStore,
                                                            categoryStore: categoryStore,
                                                            recordStore: recordStore)
        let statisticsViewController = StatisticsViewController(trackerStore: trackerStore,
                                                                recordStore: recordStore)
        
        let trackersWithNavigationBar = UINavigationController(rootViewController: trackersViewController)
        trackersWithNavigationBar.navigationBar.prefersLargeTitles = true
        let statisticsWithNavigationBar = UINavigationController(rootViewController: statisticsViewController)
        statisticsWithNavigationBar.navigationBar.prefersLargeTitles = true
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: Loc.TabBar.trackers,
            image: UIImage(named: "Tab bar Trackers"),
            selectedImage: nil
        )
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: Loc.TabBar.statistics,
            image: UIImage(named: "Tab bar Statistics"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersWithNavigationBar, statisticsViewController]
    }
}

