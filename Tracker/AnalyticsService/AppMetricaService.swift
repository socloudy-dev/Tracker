import AppMetricaCore

final class AppMetricaService {
    static let shared = AppMetricaService()
    
    func report(event: String, item: String? = nil) {
        var parameters: [String: Any] = [
            "event": event,
            "screen": "Main"
        ]
        if let item = item {
            parameters["item"] = item
        }
        AppMetrica.reportEvent(name: "ui_event", parameters: parameters)
        print("Analytics:", parameters)
    }
}
