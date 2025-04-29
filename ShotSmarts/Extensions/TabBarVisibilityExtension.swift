import SwiftUI

// TabBar可见性的环境键
struct TabBarVisibilityKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

// 环境值扩展
extension EnvironmentValues {
    var tabBarVisible: Bool {
        get { self[TabBarVisibilityKey.self] }
        set { self[TabBarVisibilityKey.self] = newValue }
    }
}

// 视图扩展
extension View {
    func tabBarVisible(_ visible: Bool) -> some View {
        environment(\.tabBarVisible, visible)
    }
} 