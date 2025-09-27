import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor(named: "Blue")
        
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        let trackersWithNavigationBar = UINavigationController(rootViewController: trackersViewController)
        trackersWithNavigationBar.navigationBar.prefersLargeTitles = true
        let statisticsWithNavigationBar = UINavigationController(rootViewController: statisticsViewController)
        statisticsWithNavigationBar.navigationBar.prefersLargeTitles = true
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Tab bar Trackers"),
            selectedImage: nil
        )
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Tab bar Statistics"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersWithNavigationBar, statisticsViewController]
    }
}

