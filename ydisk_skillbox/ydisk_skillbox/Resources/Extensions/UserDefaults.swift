import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case token
    }
    
    var token: String? {
        get {
            string(forKey: UserDefaultsKeys.token.rawValue)
        }
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.token.rawValue)
        }
    }
}
