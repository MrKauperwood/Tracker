import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        let configuration = AppMetricaConfiguration(apiKey: "11938a1f-c92e-4eac-8982-5b627bba6ebe")
        AppMetrica.activate(with: configuration!)
    }
    
    func report(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen
        ]
        
        if let item = item {
            params["item"] = item
        }
        
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
