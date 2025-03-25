import SwiftUI

// 设置视图 - Settings View
struct SettingsView: View {
    // 环境对象 - Environment objects
    @ObservedObject private var settings = AppSettings.shared
    
    // 状态变量 - State variables
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            Form {
                // 外观部分 - Appearance section
                Section(header: Text(LocalizedString("Appearance", comment: "Appearance section header"))) {
                    // 主题选择 - Theme selection
                    HStack {
                        Label(
                            title: { Text(LocalizedString("Theme", comment: "Theme label")) },
                            icon: { Image(systemName: "paintbrush.fill").foregroundColor(.purple) }
                        )
                        
                        Spacer()
                        
                        Picker("", selection: $settings.theme) {
                            ForEach(AppSettings.AppTheme.allCases) { theme in
                                HStack {
                                    Image(systemName: themeIcon(for: theme))
                                        .foregroundColor(themeColor(for: theme))
                                    Text(theme.displayName)
                                }
                                .tag(theme)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // 关于部分 - About section
                Section {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Label(
                                title: { Text(LocalizedString("About ShotSmarts", comment: "About button")) },
                                icon: { Image(systemName: "info.circle").foregroundColor(.blue) }
                            )
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 版本信息 - Version info
                Section {
                    HStack {
                        Text(LocalizedString("Version", comment: "Version label"))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(LocalizedString("Settings", comment: "Settings title"))
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
        .onChange(of: settings.refreshCounter) { _ in 
            // 响应语言变化但不重建整个视图结构
        }
    }
    
    // 获取主题图标 - Get theme icon
    private func themeIcon(for theme: AppSettings.AppTheme) -> String {
        switch theme {
        case .system: return "circle.lefthalf.fill"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    // 获取主题颜色 - Get theme color
    private func themeColor(for theme: AppSettings.AppTheme) -> Color {
        switch theme {
        case .system: return .purple
        case .light: return .orange
        case .dark: return .indigo
        }
    }
}

// 关于视图 - About View
struct AboutView: View {
    // 环境变量 - Environment variables
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 应用图标 - App icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue, .blue.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 120, height: 120)
                        
                       Image(systemName: "camera.aperture")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    // 应用名称 - App name
                    Text(Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? "ShotSmarts")
                        .font(.system(size: 26, weight: .bold))
                    
                    // 描述文本 - Description text
                    VStack(spacing: 20) {
                        Text(LocalizedString("ShotSmarts helps photographers of all levels calculate the optimal camera settings for any shooting scenario.", comment: "App description part 1"))
                        
                        Text(LocalizedString("Simply input your shooting conditions and let ShotSmarts recommend the ideal aperture, shutter speed, and other settings for the perfect shot.", comment: "App description part 2"))
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    
                    // 功能列表 - Feature list
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedString("Features", comment: "Features section"))
                            .font(.headline)
                            .padding(.top)
                        
                        FeatureRow(
                            icon: "camera.metering.matrix",
                            color: .blue,
                            title: LocalizedString("Smart Recommendations", comment: "Feature title"),
                            description: LocalizedString("Intelligent camera settings based on lighting and scene", comment: "Feature description")
                        )
                        
                        FeatureRow(
                            icon: "list.bullet",
                            color: .green,
                            title: LocalizedString("Shot History", comment: "Feature title"),
                            description: LocalizedString("Save and refer to previous shooting parameters", comment: "Feature description")
                        )
                        
                        FeatureRow(
                            icon: "globe",
                            color: .orange,
                            title: LocalizedString("Multiple Languages", comment: "Feature title"),
                            description: LocalizedString("Supports Chinese, English and Japanese", comment: "Feature description")
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer(minLength: 30)
                    
                    // 版权信息 - Copyright info
                
                    Text("© Visen ShotSmarts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
                .padding()
            }
            .navigationTitle(LocalizedString("About", comment: "About navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text(LocalizedString("Done", comment: "Done button"))
                    }
                }
            }
        }
        .onChange(of: settings.refreshCounter) { _ in
            // 响应语言变化但不重建整个视图
        }
    }
}

// 功能行 - Feature Row
struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
} 
