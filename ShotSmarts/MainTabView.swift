import SwiftUI

// 主标签视图 - Main Tab View
struct MainTabView: View {
    // 状态变量 - State variables
    @State private var selectedTab = 0
    
    // 环境对象 - Environment objects
    @StateObject private var historyManager = ParameterHistoryManager()
    @ObservedObject private var settings = AppSettings.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页标签 - Home tab
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "camera")
                }
                .tag(0)
            
            // 历史记录标签 - History tab
            HistoryView()
                .tabItem {
                    Label("记录", systemImage: "list.bullet")
                }
                .tag(1)
            
            // 设置标签 - Settings tab
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(2)
        }
        .environmentObject(historyManager)
        .preferredColorScheme(settings.theme.colorScheme)
        .environment(\.refreshLanguage, settings.refreshCounter)
    }
}

#Preview {
    MainTabView()
} 