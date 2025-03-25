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
                return LocalizedString("System Default", comment: "System default theme")
            case .light: 
                return LocalizedString("Light", comment: "Light theme")
            case .dark: 
                return LocalizedString("Dark", comment: "Dark theme")
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
    
    // 私有初始化方法 - Private initialization method
    private init() {
        // 从用户默认设置加载主题设置 - Load theme settings from user defaults
        let savedTheme = UserDefaults.standard.string(forKey: SettingKeys.theme.rawValue) ?? AppTheme.system.rawValue
        self.theme = AppTheme(rawValue: savedTheme) ?? .system
        
        // 初始化刷新计数器
        self.refreshCounter = 0
        
        // 监听系统语言变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(localeDidChange),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
    
    // 系统语言变化通知处理
    @objc private func localeDidChange() {
        // 增加刷新计数器触发视图更新
        DispatchQueue.main.async {
            self.refreshCounter += 1
            // 重置本地化Bundle缓存
            self.resetLocalizationBundle()
        }
    }
    
    // 重置为默认设置 - Reset to default settings
    func resetToDefaults() {
        theme = .system
    }
} 