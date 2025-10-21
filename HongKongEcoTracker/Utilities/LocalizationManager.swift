import Foundation

// MARK: - 本地化工具类
class LocalizationManager {
    static let shared = LocalizationManager()
    
    private init() {}
    
    // MARK: - 获取本地化字符串
    func localizedString(for key: String, comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
    
    // MARK: - 获取当前语言
    func currentLanguage() -> String {
        return Locale.current.languageCode ?? "en"
    }
    
    // MARK: - 检查是否为中文
    func isChinese() -> Bool {
        let language = currentLanguage()
        return language.hasPrefix("zh")
    }
    
    // MARK: - 获取香港地区名称
    func getDistrictName(for district: String) -> String {
        let key = district.lowercased().replacingOccurrences(of: " ", with: "_")
        return localizedString(for: key)
    }
}

// MARK: - 字符串扩展
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: LocalizationManager.shared.localizedString(for: self), arguments: arguments)
    }
}
