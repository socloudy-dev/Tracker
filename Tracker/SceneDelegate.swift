import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var coreDataStack = CoreDataStack.shared
    private lazy var trackerStore = TrackerStore(context: coreDataStack.context)
    private lazy var categoryStore = TrackerCategoryStore(context: coreDataStack.context)
    private lazy var recordStore = TrackerRecordStore(context: coreDataStack.context)
    
    private let didShowOnboarding = UserDefaults.standard.bool(forKey: "didShowOnboarding")
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let tabBarController = TabBarController(trackerStore: trackerStore,
                                                categoryStore: categoryStore,
                                                recordStore: recordStore)
        
        if !didShowOnboarding {
            let onboardingVC = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            
            onboardingVC.onFinishOnboarding = { [weak self] in
                guard let self = self else { return }
                let tabBarController = TabBarController(trackerStore: self.trackerStore,
                                                        categoryStore: self.categoryStore,
                                                        recordStore: self.recordStore)
                self.window?.rootViewController = tabBarController
            }
            
            
            window.rootViewController = onboardingVC
        } else {
            window.rootViewController = tabBarController
        }
        
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
    
    
}

