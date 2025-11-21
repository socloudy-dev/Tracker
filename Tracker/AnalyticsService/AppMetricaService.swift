import AppMetricaCore

final class AppMetricaService {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let configuration = AppMetricaConfiguration(apiKey: AppMetricaKeys.apiKey) {
            AppMetrica.activate(with: configuration)
        }
            
        return true
    }
}
