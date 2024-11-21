import Foundation

enum UserDefaultsKeys: String {
    case onboardingCompleted
    
}

extension UserDefaults {
    func bool(forKey key: UserDefaultsKeys) -> Bool {
        return self.bool(forKey: key.rawValue)
    }
    
    func set(_ value: Bool, forKey key: UserDefaultsKeys) {
        self.set(value, forKey: key.rawValue)
    }
}
