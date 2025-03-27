import SwiftUI

// 历史记录视图 - History View
struct HistoryView: View {
    // 环境对象 - Environment objects
    @EnvironmentObject var historyManager: ParameterHistoryManager
    @ObservedObject var settings = AppSettings.shared
    
    // 状态变量 - State variables
    @State private var showingEditNameAlert = false
    @State private var selectedParameter: ShootingParameters?
    @State private var newName = ""
    @State private var searchText = ""
    @State private var animateCards = false
    
    // 过滤后的参数列表 - Filtered parameter list
    var filteredParameters: [ShootingParameters] {
        if searchText.isEmpty {
            return historyManager.savedParameters
        } else {
            return historyManager.savedParameters.filter { parameter in
                parameter.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景颜色 - Background color
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    if historyManager.savedParameters.isEmpty {
                        // 空状态视图 - Empty state view
                        VStack(spacing: 24) {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "#FF7648"))
                            
                            Text("没有保存的参数")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("您保存的拍摄参数将显示在这里")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        // 搜索栏 - Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("搜索参数名称", text: $searchText)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // 参数列表 - Parameter list
                        ScrollView {
                            // 排序提示信息 - Sorting info
                            if !historyManager.savedParameters.isEmpty {
                                Text("按时间排序，最新保存的参数显示在最前面")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.bottom, 4)
                            }
                            
                            LazyVStack(spacing: 16) {
                                ForEach(filteredParameters) { parameter in
                                    NavigationLink(destination: ParameterDetailView(parameter: parameter)
                                        .environmentObject(historyManager)) {
                                        ParameterListItem(parameter: parameter)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        Button {
                                            selectedParameter = parameter
                                            newName = parameter.name
                                            showingEditNameAlert = true
                                        } label: {
                                            Label("重命名", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            if let index = historyManager.savedParameters.firstIndex(where: { $0.id == parameter.id }) {
                                                historyManager.deleteParameter(at: IndexSet(integer: index))
                                            }
                                        } label: {
                                            Label("删除", systemImage: "trash")
                                        }
                                    }
                                    .padding(.horizontal)
                                    .opacity(animateCards ? 1 : 0)
                                    .animation(
                                        .spring(response: 0.4, dampingFraction: 0.8)
                                        .delay(Double(filteredParameters.firstIndex(where: { $0.id == parameter.id }) ?? 0) * 0.05),
                                        value: animateCards
                                    )
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("参数记录")
            .navigationBarTitleDisplayMode(.large)
            .alert("重命名参数", isPresented: $showingEditNameAlert) {
                TextField("新名称", text: $newName)
                    .font(.system(size: 16))
                
                Button("取消", role: .cancel) {
                    newName = ""
                }
                
                Button("保存") {
                    if let parameter = selectedParameter, !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        historyManager.renameParameter(parameter, to: newName)
                        newName = ""
                    }
                }
            } message: {
                Text("为此参数设置新名称")
            }
        }
        .accentColor(Color(hex: "#FF7648"))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateCards = true
            }
        }
    }
}

// 参数列表项 - Parameter List Item
struct ParameterListItem: View {
    var parameter: ShootingParameters
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和日期行 - Title and date row
            HStack {
                // 场景图标 - Scene icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FF7648").opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: getSceneModeIcon(parameter.sceneMode))
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#FF7648"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(parameter.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(dateFormatter.string(from: parameter.date))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 光线条件图标 - Light condition icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FF7648").opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: getLightConditionIcon(parameter.lightCondition))
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#FF7648"))
                }
            }
            
            Divider()
            
            // 参数网格 - Parameter grid (4 columns in one row)
            HStack(spacing: 4) {
                // 光圈 - Aperture
                CompactParameterIndicator(
                    label: "光圈",
                    value: parameter.formattedAperture,
                    icon: "camera.aperture"
                )
                
                // 快门 - Shutter
                CompactParameterIndicator(
                    label: "快门",
                    value: parameter.formattedShutterSpeed,
                    icon: "timer"
                )
                
                // ISO
                CompactParameterIndicator(
                    label: "ISO",
                    value: "\(Int(parameter.iso))",
                    icon: "camera.metering.center.weighted"
                )
                
                // 曝光 - Exposure
                CompactParameterIndicator(
                    label: "曝光",
                    value: shortExposureValue(parameter.formattedExposureCompensation),
                    icon: "plusminus"
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // 获取场景模式图标 - Get scene mode icon
    private func getSceneModeIcon(_ mode: ShootingParameters.SceneMode) -> String {
        switch mode {
        case .sport: return "figure.run"
        case .portrait: return "person.fill"
        case .landscape: return "mountain.2.fill"
        case .macro: return "flower"
        case .night: return "moon.stars.fill"
        }
    }
    
    // 获取光线条件图标 - Get light condition icon
    private func getLightConditionIcon(_ condition: ShootingParameters.LightCondition) -> String {
        switch condition {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.sun.fill"
        case .overcast: return "cloud.fill"
        case .night: return "moon.fill"
        case .indoor: return "house.fill"
        }
    }
    
    // 短格式的曝光补偿 - Short exposure compensation
    private func shortExposureValue(_ fullValue: String) -> String {
        return fullValue.replacingOccurrences(of: " EV", with: "")
    }
    
    // 日期格式化器 - Date formatter
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

// 紧凑参数指示器 - Compact Parameter Indicator
struct CompactParameterIndicator: View {
    var label: String
    var value: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#FF7648"))
                .frame(height: 16)
            
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// 参数详情视图 - Parameter Detail View (全屏页面)
struct ParameterDetailView: View {
    // 输入参数 - Input parameter
    var parameter: ShootingParameters
    
    // 环境变量 - Environment variables
    @Environment(\.colorScheme) var colorScheme // 当前颜色模式（深色/浅色）
    @Environment(\.presentationMode) var presentationMode // 用于控制视图的展示状态
    @EnvironmentObject var historyManager: ParameterHistoryManager // 参数历史记录管理器
    
    // 状态变量 - State variables
    @State private var showingEditAlert = false // 控制编辑弹窗显示
    @State private var newName = "" // 存储新的名称
    @State private var animateCards = false // 控制卡片动画
    @State private var displayedParameter: ShootingParameters? // 当前显示的参数对象
    @State private var isNameChanged = false // 标记名称是否已更改
    
    // 应用设置 - App settings
    @ObservedObject var settings = AppSettings.shared
    
    // 主题色 - Theme color
    let themeColor = Color(hex: "#FF7648") // 统一使用橙色
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 名称和日期部分 - Name and date section
                VStack(spacing: 8) {
                    Text(displayedParameter?.name ?? parameter.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(formatDate(displayedParameter?.date ?? parameter.date))
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                
                // 相机参数卡片网格 - Camera Parameters Grid
                VStack(alignment: .leading, spacing: 16) {
                    Text("相机参数")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        // 光圈卡片 - Aperture card
                        CameraParameterCard(
                            icon: "camera.aperture",
                            title: "光圈",
                            value: displayedParameter?.formattedAperture ?? parameter.formattedAperture,
                            color: themeColor
                        )
                        
                        // 快门卡片 - Shutter card
                        CameraParameterCard(
                            icon: "timer",
                            title: "快门",
                            value: displayedParameter?.formattedShutterSpeed ?? parameter.formattedShutterSpeed,
                            color: themeColor
                        )
                        
                        // ISO卡片 - ISO card
                        CameraParameterCard(
                            icon: "camera.metering.center.weighted",
                            title: "ISO",
                            value: "\(Int(displayedParameter?.iso ?? parameter.iso))",
                            color: themeColor
                        )
                        
                        // 曝光补偿卡片 - Exposure card
                        CameraParameterCard(
                            icon: "plusminus",
                            title: "曝光",
                            value: displayedParameter?.formattedExposureCompensation ?? parameter.formattedExposureCompensation,
                            color: themeColor
                        )
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // 拍摄条件部分 - Shooting Conditions Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("拍摄条件")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        // 光线条件行 - Light Condition row
                        InfoRow(
                            icon: getLightConditionIcon(displayedParameter?.lightCondition ?? parameter.lightCondition),
                            title: "光线条件",
                            value: LocalizedString(displayedParameter?.lightCondition.rawValue ?? parameter.lightCondition.rawValue, comment: "Light condition value"),
                            color: themeColor
                        )
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // 场景模式行 - Scene Mode row
                        InfoRow(
                            icon: getSceneModeIcon(displayedParameter?.sceneMode ?? parameter.sceneMode),
                            title: "场景模式",
                            value: LocalizedString(displayedParameter?.sceneMode.rawValue ?? parameter.sceneMode.rawValue, comment: "Scene mode value"),
                            color: themeColor
                        )
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // 测光模式行 - Metering Mode row
                        InfoRow(
                            icon: "viewfinder",
                            title: "测光模式",
                            value: LocalizedString(displayedParameter?.meteringMode.rawValue ?? parameter.meteringMode.rawValue, comment: "Metering mode value"),
                            color: themeColor
                        )
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // 参数总结部分 - Parameters Summary section
                VStack(alignment: .leading, spacing: 16) {
                    Text("参数总结")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    // 参数总结文本 - Parameter summary text
                    Text(generateParameterSummary())
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .lineSpacing(6)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.top, 8)
                
                Spacer(minLength: 30) // 底部间距
            }
            .padding(.bottom, 24)
        }
        .background(Color.white) // 白色背景
        .navigationTitle("参数详情") // 导航栏标题
        .navigationBarTitleDisplayMode(.inline) // 导航栏标题显示模式
        .toolbar {
            // 编辑按钮 - Edit button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // 打开编辑弹窗并设置初始名称
                    newName = displayedParameter?.name ?? parameter.name
                    showingEditAlert = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(themeColor) // 使用主题色
                }
            }
        }
        // 重命名参数弹窗 - Rename parameter alert
        .alert("重命名参数", isPresented: $showingEditAlert) {
            // 名称输入框 - Name input field
            TextField("新名称", text: $newName)
            
            // 取消按钮 - Cancel button
            Button("取消", role: .cancel) {
                newName = ""
            }
            
            // 保存按钮 - Save button
            Button("保存") {
                // 检查新名称是否有效 - Check if new name is valid
                if !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    // 修改参数名称和更新状态 - Modify parameter name and update states
                    renameParameter(to: newName)
                }
            }
        } message: {
            Text("为此参数设置新名称")
        }
        .onAppear {
            // 视图出现时加载参数 - Load parameter when view appears
            self.loadParameter()
        }
        .onChange(of: parameter) { newValue in
            // 当参数更改时更新显示内容 - Update displayed content when parameter changes
            self.displayedParameter = newValue
        }
    }
    
    // 加载参数 - Load parameter
    private func loadParameter() {
        // 设置显示参数，确保内容加载时准备就绪 - Set the displayed parameter to ensure content is ready
        self.displayedParameter = parameter
        print("参数详情页面打开: \(parameter.name), 光圈:\(parameter.formattedAperture), 快门:\(parameter.formattedShutterSpeed)")
    }
    
    // 重命名参数 - Rename parameter
    private func renameParameter(to newName: String) {
        // 创建当前参数的可变副本 - Create a mutable copy of the current parameter
        var currentParam = displayedParameter ?? parameter
        
        // 跳过相同的名称 - Skip if the name is the same
        if currentParam.name == newName {
            return
        }
        
        // 更新参数名称 - Update parameter name
        let oldName = currentParam.name
        currentParam.name = newName
        
        // 调用管理器更新数据库 - Call manager to update database
        historyManager.renameParameter(currentParam, to: newName)
        
        // 更新当前显示的参数 - Update currently displayed parameter
        self.displayedParameter = currentParam
        
        // 设置已修改标志 - Set modified flag
        self.isNameChanged = true
        
        print("参数已重命名: \(oldName) -> \(newName)") // Parameter has been renamed
    }
    
    // 生成参数总结 - Generate parameter summary
    private func generateParameterSummary() -> String {
        // 使用显示参数或原始参数 - Use displayed parameter or original parameter
        let param = displayedParameter ?? parameter
        
        // 返回格式化的文本总结 - Return formatted text summary
        return """
        此参数配置适用于\(LocalizedString(param.sceneMode.rawValue, comment: ""))场景，在\(LocalizedString(param.lightCondition.rawValue, comment: ""))光线条件下拍摄。
        
        使用光圈\(param.formattedAperture)，快门速度\(param.formattedShutterSpeed)，ISO感光度\(Int(param.iso))，采用\(LocalizedString(param.meteringMode.rawValue, comment: ""))测光，曝光补偿\(param.formattedExposureCompensation)。
        
        这组参数可以帮助您获得平衡的曝光和良好的成像效果。
        """
    }
    
    // 格式化日期 - Format date
    private func formatDate(_ date: Date) -> String {
        // 创建日期格式化器 - Create date formatter
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // 中等详细度的日期格式
        formatter.timeStyle = .short // 简短的时间格式
        formatter.locale = Locale(identifier: "zh_CN") // 强制使用中文日期格式
        
        // 返回格式化的日期字符串 - Return formatted date string
        return formatter.string(from: date)
    }
    
    // 获取光线条件图标 - Get light condition icon
    private func getLightConditionIcon(_ condition: ShootingParameters.LightCondition) -> String {
        // 根据光线条件返回对应的系统图标名称 - Return corresponding system icon name based on light condition
        switch condition {
        case .sunny: return "sun.max.fill" // 晴天图标
        case .cloudy: return "cloud.sun.fill" // 多云图标
        case .overcast: return "cloud.fill" // 阴天图标
        case .night: return "moon.fill" // 夜间图标
        case .indoor: return "house.fill" // 室内图标
        }
    }
    
    // 获取场景模式图标 - Get scene mode icon
    private func getSceneModeIcon(_ mode: ShootingParameters.SceneMode) -> String {
        // 根据场景模式返回对应的系统图标名称 - Return corresponding system icon name based on scene mode
        switch mode {
        case .sport: return "figure.run" // 运动场景图标
        case .portrait: return "person.fill" // 人像场景图标
        case .landscape: return "mountain.2.fill" // 风景场景图标
        case .macro: return "flower" // 微距场景图标
        case .night: return "moon.stars.fill" // 夜景场景图标
        }
    }
}

// 相机参数卡片 - Camera Parameter Card
struct CameraParameterCard: View {
    var icon: String
    var title: String
    var value: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(height: 28)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// 信息行 - Info Row
struct InfoRow: View {
    var icon: String
    var title: String
    var value: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// Color扩展 - 从十六进制字符串创建颜色
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red, green, blue, alpha: Double
        
        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            red = Double((rgb >> 8) & 0xF) / 15.0
            green = Double((rgb >> 4) & 0xF) / 15.0
            blue = Double(rgb & 0xF) / 15.0
            alpha = 1.0
        case 6: // RGB (24-bit)
            red = Double((rgb >> 16) & 0xFF) / 255.0
            green = Double((rgb >> 8) & 0xFF) / 255.0
            blue = Double(rgb & 0xFF) / 255.0
            alpha = 1.0
        case 8: // ARGB (32-bit)
            alpha = Double((rgb >> 24) & 0xFF) / 255.0
            red = Double((rgb >> 16) & 0xFF) / 255.0
            green = Double((rgb >> 8) & 0xFF) / 255.0
            blue = Double(rgb & 0xFF) / 255.0
        default:
            red = 1.0
            green = 1.0
            blue = 1.0
            alpha = 1.0
        }
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}

#Preview {
    HistoryView()
        .environmentObject(ParameterHistoryManager())
} 

