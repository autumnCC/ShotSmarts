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
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if historyManager.savedParameters.isEmpty {
                        // 空状态视图 - Empty state view
                        VStack(spacing: 20) {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text(LocalizedString("没有保存的参数", comment: "No saved parameters"))
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Text(LocalizedString("您保存的拍摄参数将显示在这里", comment: "Saved parameters explanation"))
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        // 搜索栏 - Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField(LocalizedString("搜索参数名称", comment: "Search prompt"), text: $searchText)
                                .foregroundColor(.primary)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        // 参数列表 - Parameter list
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredParameters) { parameter in
                                    NavigationLink(destination: ParameterDetailView(parameter: parameter)
                                        .environmentObject(historyManager)) {
                                        ParameterListItem(parameter: parameter)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        // 重命名按钮 - Rename button
                                        Button {
                                            selectedParameter = parameter
                                            newName = parameter.name
                                            showingEditNameAlert = true
                                        } label: {
                                            Label(LocalizedString("重命名", comment: "Rename"), systemImage: "pencil")
                                        }
                                        
                                        // 删除按钮 - Delete button
                                        Button(role: .destructive) {
                                            if let index = historyManager.savedParameters.firstIndex(where: { $0.id == parameter.id }) {
                                                historyManager.deleteParameter(at: IndexSet(integer: index))
                                            }
                                        } label: {
                                            Label(LocalizedString("删除", comment: "Delete"), systemImage: "trash")
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
            .navigationTitle(LocalizedString("参数记录", comment: "Parameter history title"))
            .alert(LocalizedString("重命名参数", comment: "Rename parameter alert title"), isPresented: $showingEditNameAlert) {
                TextField(LocalizedString("新名称", comment: "New name field"), text: $newName)
                
                Button(LocalizedString("取消", comment: "Cancel button"), role: .cancel) {
                    newName = ""
                }
                
                Button(LocalizedString("保存", comment: "Save button")) {
                    if let parameter = selectedParameter, !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        historyManager.renameParameter(parameter, to: newName)
                        newName = ""
                    }
                }
            } message: {
                Text(LocalizedString("为此参数设置新名称", comment: "Rename parameter message"))
            }
        }
        .onChange(of: settings.refreshCounter) { _ in
            // 响应语言变化但不重建整个视图
        }
        .onAppear {
            // 进入动画效果
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
        VStack(alignment: .leading, spacing: 10) {
            // 标题和日期行 - Title and date row
            HStack {
                // 场景图标 - Scene icon
                SceneIconView(sceneMode: parameter.sceneMode)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 2) {
            // 参数名称 - Parameter name
            Text(parameter.name)
                .font(.headline)
                        .foregroundColor(.primary)
            
            // 日期 - Date
                    Text(dateFormatter.string(from: parameter.date))
                .font(.caption)
                .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 光线条件图标 - Light condition icon
                LightConditionIcon(lightCondition: parameter.lightCondition)
                    .frame(width: 28, height: 28)
            }
            
            Divider()
            
            // 参数指示器 - Parameter indicators
            HStack(spacing: 0) {
                // 主要参数 - Primary parameters
                HStack(spacing: 0) {
                    CompactParameterIndicator(
                        label: LocalizedString("光圈", comment: "Aperture"),
                        value: parameter.formattedAperture,
                        icon: "camera.aperture",
                        color: .blue
                    )
                    
                    CompactParameterIndicator(
                        label: LocalizedString("快门", comment: "Shutter"),
                        value: parameter.formattedShutterSpeed,
                        icon: "timer",
                        color: .orange
                    )
                    
                    CompactParameterIndicator(
                    label: "ISO",
                        value: "\(Int(parameter.iso))",
                        icon: "camera.metering.center.weighted",
                        color: .green
                    )
                    
                    CompactParameterIndicator(
                        label: LocalizedString("测光", comment: "Metering"),
                        value: shortMeteringName(for: parameter.meteringMode),
                        icon: "viewfinder",
                        color: .purple
                    )
                    
                    CompactParameterIndicator(
                        label: LocalizedString("曝光", comment: "Exposure"),
                        value: shortExposureValue(parameter.formattedExposureCompensation),
                        icon: "plusminus",
                        color: .pink
                    )
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
        .cornerRadius(12)
    }
    
    // 短格式的测光模式名称 - Short metering mode name
    private func shortMeteringName(for mode: ShootingParameters.MeteringMode) -> String {
        switch mode {
        case .evaluative: return "评价"
        case .centerWeighted: return "中央"
        case .spot: return "点测"
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
    var color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// 场景图标视图 - Scene Icon View
struct SceneIconView: View {
    var sceneMode: ShootingParameters.SceneMode
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
            
            Image(systemName: iconName)
                .font(.system(size: 18))
                .foregroundColor(.blue)
        }
    }
    
    private var iconName: String {
        switch sceneMode {
        case .sport: return "figure.run"
        case .portrait: return "person.fill"
        case .landscape: return "mountain.2.fill"
        case .macro: return "flower"
        case .night: return "moon.stars.fill"
        }
    }
}

// 光线条件图标 - Light Condition Icon
struct LightConditionIcon: View {
    var lightCondition: ShootingParameters.LightCondition
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.orange.opacity(0.2))
            
            Image(systemName: iconName)
                .font(.system(size: 14))
                .foregroundColor(.orange)
        }
    }
    
    private var iconName: String {
        switch lightCondition {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.sun.fill"
        case .overcast: return "cloud.fill"
        case .night: return "moon.fill"
        case .indoor: return "house.fill"
        }
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 名称和日期部分 - Name and date section
                VStack(spacing: 8) {
                    Text(displayedParameter?.name ?? parameter.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(formatDate(displayedParameter?.date ?? parameter.date))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // 基本信息卡片 - Basic Info Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.blue)
                            .clipShape(Circle())
                        
                        Text(LocalizedString("基本信息", comment: "Basic Info"))
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 基本参数网格 - Basic Parameters Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        // 光线条件卡片 - Light Condition card
                        DetailParameterCard(
                            icon: getLightConditionIcon(displayedParameter?.lightCondition ?? parameter.lightCondition),
                            title: LocalizedString("光线条件", comment: "Light Condition"),
                            value: LocalizedString(displayedParameter?.lightCondition.rawValue ?? parameter.lightCondition.rawValue, comment: "Light condition value"),
                            color: .orange
                        )
                        
                        // 场景模式卡片 - Scene Mode card
                        DetailParameterCard(
                            icon: getSceneModeIcon(displayedParameter?.sceneMode ?? parameter.sceneMode),
                            title: LocalizedString("场景模式", comment: "Scene Mode"),
                            value: LocalizedString(displayedParameter?.sceneMode.rawValue ?? parameter.sceneMode.rawValue, comment: "Scene mode value"),
                            color: .blue
                        )
                        
                        // ISO感光度卡片 - ISO card
                        DetailParameterCard(
                            icon: "camera.metering.center.weighted",
                            title: "ISO",
                            value: "\(Int(displayedParameter?.iso ?? parameter.iso))",
                            color: .green
                        )
                        
                        // 测光模式卡片 - Metering Mode card
                        DetailParameterCard(
                            icon: "viewfinder",
                            title: LocalizedString("测光模式", comment: "Metering Mode"),
                            value: LocalizedString(displayedParameter?.meteringMode.rawValue ?? parameter.meteringMode.rawValue, comment: "Metering mode value"),
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // 相机参数部分 - Camera Parameters Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.indigo)
                            .clipShape(Circle())
                        
                        Text(LocalizedString("相机参数", comment: "Camera Parameters"))
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 核心参数 - Core Parameters
                    VStack(spacing: 16) {
                        // 光圈参数行 - Aperture parameter row
                        CoreParameterRow(
                            icon: "camera.aperture",
                            title: LocalizedString("光圈", comment: "Aperture"),
                            value: displayedParameter?.formattedAperture ?? parameter.formattedAperture,
                            description: LocalizedString("控制进入镜头的光量和景深", comment: "Aperture description"),
                            color: .blue
                        )
                        
                        // 快门速度参数行 - Shutter Speed parameter row
                        CoreParameterRow(
                            icon: "timer",
                            title: LocalizedString("快门速度", comment: "Shutter Speed"),
                            value: displayedParameter?.formattedShutterSpeed ?? parameter.formattedShutterSpeed,
                            description: LocalizedString("控制曝光时间和动态拍摄", comment: "Shutter speed description"),
                            color: .orange
                        )
                        
                        // 曝光补偿参数行 - Exposure Compensation parameter row
                        CoreParameterRow(
                            icon: "plusminus",
                            title: LocalizedString("曝光补偿", comment: "Exposure Compensation"),
                            value: displayedParameter?.formattedExposureCompensation ?? parameter.formattedExposureCompensation,
                            description: LocalizedString("调整最终成像的亮度", comment: "Exposure compensation description"),
                            color: .pink
                        )
                    }
                    .padding(.horizontal)
                }
                
                // 笔记区域 - Notes area
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "note.text")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.gray)
                            .clipShape(Circle())
                        
                        Text(LocalizedString("笔记", comment: "Notes"))
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 笔记内容文本 - Notes content text
                    Text(displayedParameter?.notes.isEmpty ?? true ? LocalizedString("暂无笔记内容", comment: "No notes") : (displayedParameter?.notes ?? parameter.notes))
                        .font(.system(size: 16))
                        .foregroundColor((displayedParameter?.notes.isEmpty ?? true) ? .secondary : .primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color(hex: "#3a3a3a") : Color(hex: "#f5f5f7"))
                        )
                        .padding(.horizontal)
                }
                .padding(.top, 8)
                .hidden() // 暂时隐藏笔记内容模块 - Temporarily hide notes module
                
                // 参数总结部分 - Parameters Summary section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.green)
                            .clipShape(Circle())
                        
                        Text(LocalizedString("参数总结", comment: "Parameters Summary"))
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 参数总结文本 - Parameter summary text
                    Text(generateParameterSummary())
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color(hex: "#3a3a3a") : Color(hex: "#f5f5f7"))
                        )
                        .padding(.horizontal)
                }
                .padding(.top, 8)
                
                Spacer(minLength: 40) // 底部间距
            }
            .padding(.bottom, 20)
        }
        .navigationTitle(LocalizedString("参数详情", comment: "Parameter details")) // 导航栏标题
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
                        .foregroundColor(.primary)
                }
            }
        }
        // 重命名参数弹窗 - Rename parameter alert
        .alert(LocalizedString("重命名参数", comment: "Rename parameter"), isPresented: $showingEditAlert) {
            // 名称输入框 - Name input field
            TextField(LocalizedString("新名称", comment: "New name field"), text: $newName)
            
            // 取消按钮 - Cancel button
            Button(LocalizedString("取消", comment: "Cancel button"), role: .cancel) {
                newName = ""
            }
            
            // 保存按钮 - Save button
            Button(LocalizedString("保存", comment: "Save button")) {
                // 检查新名称是否有效 - Check if new name is valid
                if !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    // 修改参数名称和更新状态 - Modify parameter name and update states
                    renameParameter(to: newName)
                }
            }
        } message: {
            Text(LocalizedString("为此参数设置新名称", comment: "Rename parameter message"))
        }
        .onAppear {
            // 视图出现时加载参数 - Load parameter when view appears
            self.loadParameter()
        }
        .onChange(of: parameter) { newValue in
            // 当参数更改时更新显示内容 - Update displayed content when parameter changes
            self.displayedParameter = newValue
        }
        .onChange(of: settings.refreshCounter) { _ in
            // 响应语言变化但不重建整个视图 - Respond to language changes without rebuilding the entire view
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

// 详情参数卡片 - Detail Parameter Card
struct DetailParameterCard: View {
    var icon: String
    var title: String
    var value: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// 核心参数行 - Core Parameter Row
struct CoreParameterRow: View {
    var icon: String
    var title: String
    var value: String
    var description: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // 图标 - Icon
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(color)
                    .clipShape(Circle())
                
                // 标题和值 - Title and value
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 参数值 - Parameter value
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
                    .padding(.trailing, 4)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
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

