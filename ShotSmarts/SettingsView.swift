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
                        Text("外观设置")
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
                                        title: { Text("主题") },
                                        icon: { 
                                            Image(systemName: "paintbrush.fill")
                                                .foregroundColor(Color(hex: "#FF7648"))
                                        }
                                    )
                                    .font(.system(size: 16))
                                    
                                    Spacer()
                                    
                                    Text(settings.theme.displayName)
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
                        Text("关于")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                showingAbout = true
                            }) {
                                HStack {
                                    Label(
                                        title: { Text("关于大师快拍") },
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
                                Text("版本")
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
            .navigationTitle("设置")
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
                    Text("大师快拍")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    // 描述文本 - Description text
                    VStack(spacing: 16) {
                        Text("大师快拍帮助摄影师快速计算最佳相机参数，让您在任何拍摄场景下都能获得理想效果。")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        Text("只需输入拍摄条件，大师快拍就能为您推荐最适合的光圈、快门速度等参数设置。")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    
                    // 功能列表 - Feature list
                    VStack(alignment: .leading, spacing: 16) {
                        Text("主要功能")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top)
                        
                        FeatureRow(
                            icon: "camera.metering.matrix",
                            title: "智能推荐",
                            description: "基于光线和场景的智能相机参数设置"
                        )
                        
                        FeatureRow(
                            icon: "list.bullet",
                            title: "拍摄记录",
                            description: "保存并随时查看历史拍摄参数"
                        )
                        
                        FeatureRow(
                            icon: "wand.and.stars",
                            title: "场景优化",
                            description: "针对不同场景自动优化参数配置"
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                    
                    // 版权信息 - Copyright info
                    Text("© 2024 大师快拍")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.bottom)
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
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
