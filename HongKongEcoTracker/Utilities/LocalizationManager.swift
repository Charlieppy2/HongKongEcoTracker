import Foundation
import SwiftUI

// MARK: - Simplified Localization Manager (English Only)
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    private init() {}
    
    // MARK: - Get localized string (returns English directly)
    func localizedString(for key: String, comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
    
    // MARK: - Get district name
    func getDistrictName(for district: String) -> String {
        return district
    }
}

// MARK: - String Extension
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: LocalizationManager.shared.localizedString(for: self), arguments: arguments)
    }
}