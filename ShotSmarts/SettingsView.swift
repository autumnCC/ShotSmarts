import SwiftUI

// 设置视图 - Settings View
struct SettingsView: View {
    // 环境对象 - Environment objects
    @ObservedObject private var settings = AppSettings.shared
    
    // 状态变量 - State variables
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 外观部分 - Appearance section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("Appearance", comment: "Appearance settings"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // 主题选择 - Theme selection
                            Button(action: {
                                // 主题切换逻辑保持不变
                            }) {
                                HStack {
                                    Label(
                                        title: { Text(NSLocalizedString("Theme", comment: "Theme")) },
                                        icon: { 
                                            Image(systemName: "paintbrush.fill")
                                                .foregroundColor(Color(hex: "#FF7648"))
                                        }
                                    )
                                    .font(.system(size: 16))
                                    
                                    Spacer()
                                    
                                    Text(NSLocalizedString(settings.theme.displayName, comment: "Theme name"))
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                            }
                            .foregroundColor(.black)
                            
                            Divider()
                                .padding(.horizontal)
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    }
                    .padding(.top, 8)
                    
                    // 关于部分 - About section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("About", comment: "About section"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                showingAbout = true
                            }) {
                                HStack {
                                    Label(
                                        title: { Text(NSLocalizedString("About ShotSmarts", comment: "About ShotSmarts")) },
                                        icon: { 
                                            Image(systemName: "info.circle")
                                                .foregroundColor(Color(hex: "#FF7648"))
                                        }
                                    )
                                    .font(.system(size: 16))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                            }
                            .foregroundColor(.black)
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // 版本信息 - Version info
                            HStack {
                                Text(NSLocalizedString("Version", comment: "Version"))
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGray6))
            .navigationTitle(NSLocalizedString("Settings", comment: "Settings title"))
            .navigationBarTitleDisplayMode(.large)
        }
        .accentColor(Color(hex: "#FF7648"))
        .sheet(isPresented: $showingAbout) {
            AboutView()
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
                            .fill(Color(hex: "#FF7648"))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "camera.aperture")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    // 应用名称 - App name
                    Text(NSLocalizedString("ShotSmarts", comment: "App name"))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    // 描述文本 - Description text
                    VStack(spacing: 16) {
                        Text(NSLocalizedString("ShotSmarts helps photographers of all levels calculate the optimal camera settings for any shooting scenario.", comment: "App description"))
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        Text(NSLocalizedString("Simply input your shooting conditions and let ShotSmarts recommend the ideal aperture, shutter speed, and other settings for the perfect shot.", comment: "App description 2"))
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    
                    // 功能列表 - Feature list
                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("Main Features", comment: "Main Features"))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top)
                        
                        FeatureRow(
                            icon: "camera.metering.matrix",
                            title: NSLocalizedString("Smart Recommendations", comment: "Feature: Smart Recommendations"),
                            description: NSLocalizedString("Intelligent camera parameter settings based on light and scene", comment: "Feature description")
                        )
                        
                        FeatureRow(
                            icon: "list.bullet",
                            title: NSLocalizedString("Shooting Records", comment: "Feature: Shooting Records"),
                            description: NSLocalizedString("Save and view historical shooting parameters anytime", comment: "Feature description")
                        )
                        
                        FeatureRow(
                            icon: "wand.and.stars",
                            title: NSLocalizedString("Scene Optimization", comment: "Feature: Scene Optimization"),
                            description: NSLocalizedString("Automatically optimize parameter configurations for different scenes", comment: "Feature description")
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                    
                    // 版权信息 - Copyright info
                    Text(NSLocalizedString("© 2025 ShotSmarts", comment: "Copyright info"))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.bottom)
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle(NSLocalizedString("About", comment: "About title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Done", comment: "Done button")) {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FF7648"))
                }
            }
        }
    }
}

// 功能行 - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#FF7648").opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#FF7648"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SettingsView()
} 
