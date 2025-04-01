import Foundation
import SwiftUI

// 应用程序设置 - Application Settings
class AppSettings: ObservableObject {
    // 单例模式 - Singleton pattern
    static let shared = AppSettings()
    
    // 主题选项 - Theme options
    enum AppTheme: String, CaseIterable, Identifiable {
        case system = "system" // 系统默认 - System default
        case light = "light" // 浅色 - Light
        case dark = "dark" // 深色 - Dark
        
        var id: String { self.rawValue }
        
        // 显示名称 - Display name
        var displayName: String {
            switch self {
            case .system: 
                return NSLocalizedString("System Default", comment: "System default theme")
            case .light: 
                return NSLocalizedString("Light", comment: "Light theme")
            case .dark: 
                return NSLocalizedString("Dark", comment: "Dark theme")
            }
        }
        
        // 转换为ColorScheme - Convert to ColorScheme
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    // 设置键名 - Setting key names
    private enum SettingKeys: String {
        case theme = "app_theme"
    }
    
    // 发布的属性 - Published properties
    @Published var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: SettingKeys.theme.rawValue)
        }
    }
    
    // 刷新计数器 - 用于在语言变化时通知视图更新
    @Published var refreshCounter: Int = 0
    
    // 系统语言 - System language
    @Published var systemLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    // 私有初始化方法 - Private initialization method
    private init() {
        // 从用户默认设置加载主题设置 - Load theme settings from user defaults
        let savedTheme = UserDefaults.standard.string(forKey: SettingKeys.theme.rawValue) ?? AppTheme.system.rawValue
        self.theme = AppTheme(rawValue: savedTheme) ?? .system
        
        // 初始化刷新计数器
        self.refreshCounter = 0
        
        // 记录当前系统语言
        self.systemLanguage = Bundle.main.preferredLocalizations.first ?? "en"
        print("初始化应用设置 - 当前系统语言: \(self.systemLanguage)")
        
        // 监听系统语言变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(localeDidChange),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
        
        // 确保没有强制设置语言
        ensureSystemLanguage()
    }
    
    // 确保使用系统语言
    private func ensureSystemLanguage() {
        // 检查是否有强制设置的语言，如果有则移除
        if UserDefaults.standard.object(forKey: "AppleLanguages") != nil {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            print("AppSettings: 移除AppleLanguages强制设置")
        }
    }
    
    // 系统语言变化通知处理
    @objc private func localeDidChange() {
        // 增加刷新计数器触发视图更新
        DispatchQueue.main.async {
            // 更新记录的系统语言
            let newLanguage = Bundle.main.preferredLocalizations.first ?? "en"
            let oldLanguage = self.systemLanguage
            
            if newLanguage != oldLanguage {
                print("系统语言变化: \(oldLanguage) -> \(newLanguage)")
                self.systemLanguage = newLanguage
            }
            
            self.refreshCounter += 1
            // 刷新UI
            self.refreshUI()
            
            // 确保没有强制设置语言
            self.ensureSystemLanguage()
        }
    }
    
    // 刷新UI
    func refreshUI() {
        self.refreshCounter += 1
    }
    
    // 重置为默认设置 - Reset to default settings
    func resetToDefaults() {
        theme = .system
        
        // 确保使用系统语言
        ensureSystemLanguage()
    }
} 