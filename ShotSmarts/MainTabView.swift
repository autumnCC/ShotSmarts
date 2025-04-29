import SwiftUI

// 主标签视图 - Main Tab View
struct MainTabView: View {
    // 状态变量 - State variables
    @State private var selectedTab = 0
    
    // 环境对象 - Environment objects
    @StateObject private var historyManager = ParameterHistoryManager()
    @ObservedObject private var settings = AppSettings.shared
    
    // 环境变量 - Environment values
    @Environment(\.tabBarVisible) private var tabBarVisible
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // 首页标签 - Home tab
                HomeView()
                    .tabItem {
                        Label(NSLocalizedString("Home", comment: "Home tab"), systemImage: "camera")
                            .font(.system(size: 12)) // 增加字体大小
                    }
                    .tag(0)
                
                // 历史记录标签 - History tab
                HistoryView()
                    .tabItem {
                        Label(NSLocalizedString("History", comment: "History tab"), systemImage: "list.bullet")
                            .font(.system(size: 12)) // 增加字体大小
                    }
                    .tag(1)
                
                // 设置标签 - Settings tab
                SettingsView()
                    .tabItem {
                        Label(NSLocalizedString("Settings", comment: "Settings tab"), systemImage: "gear")
                            .font(.system(size: 12)) // 增加字体大小
                    }
                    .tag(2)
            }
            .accentColor(Color(hex: "#FF7648")) // 橙色
            .environmentObject(historyManager)
            .preferredColorScheme(.light) // 固定使用浅色模式以匹配设计
            
            // 如果TabBar不可见，则在底部添加一个空白矩形覆盖TabBar区域
            if !tabBarVisible {
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 83) // 包括安全区域的TabBar高度
                        .edgesIgnoringSafeArea(.bottom)
                }
            }
        }
    }
}

#Preview {
    MainTabView()
} 