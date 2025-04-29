//
//  ShotSmartsApp.swift
//  ShotSmarts
//
//  Created by austin CN on 2025/3/23.
//

import SwiftUI
import ObjectiveC
import os.log

// 调试本地化函数 - Debug localization function
func debugLocalization() {
    let locale = Locale.current
    let language = locale.language.languageCode?.identifier ?? "unknown"
    let region = locale.region?.identifier ?? "unknown"
    let preferredLanguages = Bundle.main.preferredLocalizations
    
    print("======== DEBUG LOCALIZATION INFO ========")
    print("Current Locale: \(locale)")
    print("Language Code: \(language)")
    print("Region: \(region)")
    print("Preferred Languages: \(preferredLanguages)")
    
    // 测试本地化字符串 - Test localized strings
    let testKeys = ["Home", "Settings", "History", "ShotSmarts"]
    for key in testKeys {
        print("Test '\(key)': \(NSLocalizedString(key, comment: ""))")
    }
    
    print("=========================================")
}

// 确保系统语言设置正确应用 - Ensure system language settings are correctly applied
func ensureCorrectLanguageSettings() {
    let preferredLanguages = Bundle.main.preferredLocalizations
    print("系统首选语言: \(preferredLanguages)")
    
    // 检查应用是否正在使用系统语言 - Check if app is using system language
    let currentLocale = Locale.current
    print("当前Locale: \(currentLocale)")
    
    // 确保没有语言强制设置 - Ensure no language forcing is in place
    if let appleLanguages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String] {
        print("当前AppleLanguages: \(appleLanguages)")
    } else {
        print("AppleLanguages未设置，将使用系统默认语言")
    }
    
    // 测试几个关键界面元素的本地化 - Test localization of key UI elements
    print("Home -> \(NSLocalizedString("Home", comment: "Home tab"))")
    print("Settings -> \(NSLocalizedString("Settings", comment: "Settings tab"))")
    print("History -> \(NSLocalizedString("History", comment: "History tab"))")
}

// 解决CA Event launch measurements错误
func suppressCAPerfLogging() {
    // 禁用CoreAnimation性能日志
    if ProcessInfo.processInfo.environment["CA_DEBUG_DISABLE_PERFORMANCE_LOGGING"] == nil {
        setenv("CA_DEBUG_DISABLE_PERFORMANCE_LOGGING", "1", 1)
    }
    
    if #available(iOS 14.0, *) {
        // 使用更新的Logger API
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.shotsmarts", category: "AppLaunch")
        logger.info("已禁用CA性能日志")
    } else {
        // 旧版日志
        os_log("已禁用CA性能日志", type: .info)
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
    
    // 当系统语言变化时，刷新UI - Refresh UI when system language changes
    init() {
        // 禁用CA性能日志，解决launch measurements错误
        suppressCAPerfLogging()
        
        // 确保应用启动时使用系统语言 - Ensure system language is used when app launches
        // 如果之前有强制设置的语言，移除它 - Remove any forced language settings if they exist
        if UserDefaults.standard.object(forKey: "AppleLanguages") != nil {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            print("已移除AppleLanguages强制设置，将使用系统语言")
        }
        
        let settingsRef = settings
        NotificationCenter.default.addObserver(
            forName: NSLocale.currentLocaleDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            // 系统语言变化，触发UI刷新 - System language changed, trigger UI refresh
            DispatchQueue.main.async {
                print("检测到系统语言变化，刷新UI")
                settingsRef.refreshCounter += 1
                debugLocalization() // 打印当前语言环境信息
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(historyManager)
                .environmentObject(settings)
                .environment(\.refreshLanguage, settings.refreshCounter)
                .onAppear {
                    // 增加刷新计数触发UI更新
                    settings.refreshCounter += 1
                    
                    // 打印调试信息
                    debugLocalization()
                    
                    // 确保正确应用系统语言设置
                    ensureCorrectLanguageSettings()
                    
                    // 打印系统语言信息
                    print("系统首选语言: \(Bundle.main.preferredLocalizations)")
                    
                    // 测试几个本地化字符串
                    print("本地化测试 - '首页': \(NSLocalizedString("Home", comment: ""))")
                    print("本地化测试 - '参数记录': \(NSLocalizedString("Parameter History", comment: ""))")
                }
                .task {
                    // 在应用启动时执行初始化逻辑
                    if !isInitialized {
                        print("应用程序首次启动，执行初始化...")
                        
                        // 检查是否有保存的参数
                        if historyManager.savedParameters.isEmpty {
                            print("参数列表为空")
                        } else {
                            print("已加载 \(historyManager.savedParameters.count) 条参数记录")
                        }
                        
                        isInitialized = true
                    }
                }
        }
    }
}

