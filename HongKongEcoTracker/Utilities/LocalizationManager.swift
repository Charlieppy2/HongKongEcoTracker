import Foundation
import SwiftUI

// MARK: - 本地化管理器
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = "en"
    
    private init() {
        // 从UserDefaults读取保存的语言设置
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            currentLanguage = savedLanguage
        } else {
            // 默认使用系统语言，如果是中文则使用繁体中文
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = systemLanguage.hasPrefix("zh") ? "zh-HK" : "en"
        }
    }
    
    // MARK: - 获取本地化字符串
    func localizedString(for key: String, comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
    
    // MARK: - 切换语言
    func setLanguage(_ language: String) {
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "selectedLanguage")
        
        // 更新Bundle的语言设置
        Bundle.setLanguage(language)
        
        // 发送通知更新UI
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
    
    // MARK: - 检查是否为中文
    func isChinese() -> Bool {
        return currentLanguage.hasPrefix("zh")
    }
    
    // MARK: - 获取香港地区名称
    func getDistrictName(for district: String) -> String {
        let key = district.lowercased().replacingOccurrences(of: " ", with: "_")
        return localizedString(for: key)
    }
    
    // MARK: - 获取支持的语言列表
    func getSupportedLanguages() -> [(code: String, name: String)] {
        return [
            ("en", "English"),
            ("zh-HK", "繁體中文")
        ]
    }
}

// MARK: - Bundle扩展 - 支持动态语言切换
extension Bundle {
    private static var bundle: Bundle = .main
    
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, Bundle.self)
        }
        
        objc_setAssociatedObject(Bundle.main, &Bundle.bundle, Bundle.main, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return
        }
        
        objc_setAssociatedObject(Bundle.main, &Bundle.bundle, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - 通知扩展
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
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

// MARK: - 语言切换视图
struct LanguageSelectorView: View {
    @ObservedObject var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                VStack(spacing: 8) {
                    Text("Language Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose your preferred language")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // 语言选项
                VStack(spacing: 12) {
                    ForEach(localizationManager.getSupportedLanguages(), id: \.code) { language in
                        LanguageOptionRow(
                            languageCode: language.code,
                            languageName: language.name,
                            isSelected: localizationManager.currentLanguage == language.code
                        ) {
                            localizationManager.setLanguage(language.code)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LanguageOptionRow: View {
    let languageCode: String
    let languageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(languageName)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(languageCode == "en" ? "English" : "繁體中文")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 语言切换按钮
struct LanguageToggleButton: View {
    @ObservedObject var localizationManager = LocalizationManager.shared
    @State private var showingLanguageSelector = false
    
    var body: some View {
        Button(action: { showingLanguageSelector = true }) {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .font(.caption)
                
                Text(localizationManager.isChinese() ? "繁中" : "EN")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .sheet(isPresented: $showingLanguageSelector) {
            LanguageSelectorView()
        }
    }
}