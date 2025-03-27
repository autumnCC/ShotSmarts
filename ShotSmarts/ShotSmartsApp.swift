//
//  ShotSmartsApp.swift
//  ShotSmarts
//
//  Created by austin CN on 2025/3/23.
//

import SwiftUI
import ObjectiveC

// 本地化字符串函数 - Localized string function
func LocalizedString(_ key: String, comment: String) -> String {
    return Bundle.localizedBundle.localizedString(forKey: key, value: comment, table: nil)
}

// Bundle扩展 - Bundle extension
extension Bundle {
    // 根据系统语言的本地化Bundle - Localized bundle based on system language
    static var localizedBundle: Bundle = {
        // 尝试使用系统首选语言，如果不是中文、英文或日文，则默认使用中文
        let systemPreferredLanguage = Bundle.main.preferredLocalizations.first ?? ""
        
        // 确定使用的语言代码
        let preferredLanguage: String
        if systemPreferredLanguage.contains("zh") {
            // 如果系统语言是中文的任何变体，使用简体中文
            preferredLanguage = "zh-Hans"
        } else if systemPreferredLanguage.contains("en") {
            preferredLanguage = "en"
        } else if systemPreferredLanguage.contains("ja") {
            preferredLanguage = "ja"
        } else {
            // 默认使用中文
            preferredLanguage = "zh-Hans"
        }
        
        // 获取语言资源路径 - Get language resource path
        guard let path = Bundle.main.path(forResource: preferredLanguage, ofType: "lproj", inDirectory: "Localizations") else {
            // 如果找不到对应语言资源，返回主Bundle - If language resource not found, return main bundle
            return Bundle.main
        }
        
        // 返回对应语言的Bundle - Return bundle for corresponding language
        return Bundle(path: path) ?? Bundle.main
    }()
    
    // 重置本地化Bundle - Reset localized bundle
    static func resetBundle() {
        // 清除Bundle缓存，下次访问时会重新加载 - Clear bundle cache, will reload on next access
        objc_sync_enter(Bundle.self)
        defer { objc_sync_exit(Bundle.self) }
        localizedBundle = {
            // 尝试使用系统首选语言，如果不是中文、英文或日文，则默认使用中文
            let systemPreferredLanguage = Bundle.main.preferredLocalizations.first ?? ""
            
            // 确定使用的语言代码
            let preferredLanguage: String
            if systemPreferredLanguage.contains("zh") {
                // 如果系统语言是中文的任何变体，使用简体中文
                preferredLanguage = "zh-Hans"
            } else if systemPreferredLanguage.contains("en") {
                preferredLanguage = "en"
            } else if systemPreferredLanguage.contains("ja") {
                preferredLanguage = "ja"
            } else {
                // 默认使用中文
                preferredLanguage = "zh-Hans"
            }
            
            // 获取语言资源路径 - Get language resource path
            guard let path = Bundle.main.path(forResource: preferredLanguage, ofType: "lproj", inDirectory: "Localizations") else {
                // 如果找不到对应语言资源，返回主Bundle - If language resource not found, return main bundle
                return Bundle.main
            }
            
            // 返回对应语言的Bundle - Return bundle for corresponding language
            return Bundle(path: path) ?? Bundle.main
        }()
    }
}

// 环境键，用于传递语言刷新状态 - Environment key for language refresh
private struct RefreshEnvironmentKey: EnvironmentKey {
    static let defaultValue = 0
}

extension EnvironmentValues {
    var refreshLanguage: Int {
        get { self[RefreshEnvironmentKey.self] }
        set { self[RefreshEnvironmentKey.self] = newValue }
    }
}

@main
struct ShotSmartsApp: App {
    // 环境对象 - Environment objects
    @StateObject private var historyManager = ParameterHistoryManager()
    @StateObject private var settings = AppSettings.shared
    
    // 用于初始化应用程序的标志
    @State private var isInitialized = false
    
    // 当系统语言变化时，重置本地化Bundle - Reset localization bundle when system language changes
    init() {
        // 强制设置应用程序使用中文环境 - Force app to use Chinese locale
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        let settingsRef = settings
        NotificationCenter.default.addObserver(
            forName: NSLocale.currentLocaleDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            // 系统语言变化，重置本地化Bundle - System language changed, reset localization bundle
            Bundle.resetBundle()
            // 触发UI刷新 - Trigger UI refresh
            settingsRef.refreshCounter += 1
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(historyManager)
                .environmentObject(settings)
                .environment(\.refreshLanguage, settings.refreshCounter)
                .onAppear {
                    // 应用启动时重置本地化Bundle - Reset localization bundle when app launches
                    Bundle.resetBundle()
                    settings.refreshCounter += 1
                }
                .task {
                    // 在应用启动时执行初始化逻辑
                    if !isInitialized {
                        print("应用程序首次启动，执行初始化...")
                        
                        // 检查是否有保存的参数
                        if historyManager.savedParameters.isEmpty {
                            print("参数列表为空，创建样本数据...")
                            // 创建3个示例参数
                            historyManager.createSampleParameters(count: 3)
                        } else {
                            print("已加载 \(historyManager.savedParameters.count) 条参数记录")
                        }
                        
                        isInitialized = true
                    }
                }
        }
    }
}

// 修复AppSettings中的resetLocalizationBundle方法 - Fix resetLocalizationBundle method in AppSettings
extension AppSettings {
    func resetLocalizationBundle() {
        Bundle.resetBundle()
        self.refreshCounter += 1
    }
}
