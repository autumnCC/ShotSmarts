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
    @State private var isRefreshing = false
    
    // 环境值，用于检测语言变化 - Environment value for language change detection
    @Environment(\.refreshLanguage) var refreshLanguage
    
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
                    // 搜索栏 - Search bar
                    if !historyManager.savedParameters.isEmpty {
                        searchBarView
                    }
                    
                    // 添加下拉刷新功能
                    if #available(iOS 15.0, *) {
                        parameterContentView
                            .refreshable {
                                await refreshParameterList()
                            }
                    } else {
                        parameterContentView
                    }
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle(NSLocalizedString("Parameter History", comment: "Parameter History title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // 添加刷新按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await refreshParameterList()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color(hex: "#FF7648"))
                    }
                }
            }
            .alert(NSLocalizedString("Rename Parameter", comment: "Rename parameter dialog title"), isPresented: $showingEditNameAlert) {
                TextField(NSLocalizedString("New name", comment: "New name field"), text: $newName)
                    .font(.system(size: 16))
                
                Button(NSLocalizedString("Cancel", comment: "Cancel button"), role: .cancel) {
                    newName = ""
                }
                
                Button(NSLocalizedString("Save", comment: "Save button")) {
                    if let parameter = selectedParameter, !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        historyManager.renameParameter(parameter, to: newName)
                        newName = ""
                    }
                }
            } message: {
                Text(NSLocalizedString("Enter a new name for this parameter", comment: "Rename dialog message"))
            }
        }
        .accentColor(Color(hex: "#FF7648"))
        .onAppear {
            loadAndRefreshParameters()
        }
        // 当语言变化或刷新计数器变化时重新加载视图
        .onChange(of: refreshLanguage) { oldValue, newValue in
            if oldValue != newValue {
                print("HistoryView检测到语言变化或刷新触发，重新加载UI")
                // 通过强制重新排序参数来刷新视图
                historyManager.resortParameters()
            }
        }
    }
    
    // 搜索栏视图组件
    var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(NSLocalizedString("Search by name", comment: "Search placeholder"), text: $searchText)
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
    }
    
    // 参数内容视图 - Parameter content view
    var parameterContentView: some View {
        Group {
            if historyManager.savedParameters.isEmpty {
                // 空状态视图 - Empty state view
                GeometryReader { geometry in
                    VStack(spacing: 30) {
                        Spacer()
                        
                        // 图标 - Icon
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#FF7648").opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "#FF7648"))
                        }
                        
                        VStack(spacing: 12) {
                            Text(NSLocalizedString("No Saved Parameters", comment: "No saved parameters title"))
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(NSLocalizedString("Your saved shooting parameters will appear here\nTap the Save button on the home screen to add parameters", comment: "Empty state message"))
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // 刷新按钮已移除
                        
                        Spacer()
                        Spacer() // 保留两个Spacer确保内容居中偏上
                    }
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                }
                .background(Color.white)
            } else {
                // 参数列表 - Parameter list
                VStack(spacing: 0) {
                    // 添加统计信息
                    HStack {
                        Text(String(format: NSLocalizedString("Total: %d records", comment: "Records count"), historyManager.savedParameters.count))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                        // 排序提示信息 - Sorting info
                        Text(NSLocalizedString("Sorted by time, newest first", comment: "Sorting info"))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    
                    // 使用List代替ScrollView，更符合iOS标准
                    List {
                        ForEach(filteredParameters) { parameter in
                            NavigationLink(destination: ParameterDetailView(parameter: parameter)
                                .environmentObject(historyManager)) {
                                ParameterListItem(parameter: parameter)
                                    .contentShape(Rectangle())
                                    .padding(.vertical, 8)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    if let index = historyManager.savedParameters.firstIndex(where: { $0.id == parameter.id }) {
                                        historyManager.deleteParameter(at: IndexSet(integer: index))
                                    }
                                } label: {
                                    Label(NSLocalizedString("Delete", comment: "Delete button"), systemImage: "trash")
                                }
                                
                                Button {
                                    selectedParameter = parameter
                                    newName = parameter.name
                                    showingEditNameAlert = true
                                } label: {
                                    Label(NSLocalizedString("Rename", comment: "Rename button"), systemImage: "pencil")
                                }
                                .tint(Color(hex: "#FF7648"))
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.white)
                }
            }
        }
    }
    
    // 刷新参数列表
    private func refreshParameterList() async {
        isRefreshing = true
        
        // 先重新加载参数
        historyManager.resortParameters()
        
        // 打印参数列表以便调试
        print("刷新参数列表: 发现 \(historyManager.savedParameters.count) 条参数记录")
        for (index, param) in historyManager.savedParameters.enumerated() {
            print("  [\(index)] \(param.name): \(param.date)")
        }
        
        // 简单的延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 刷新UI动画
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                animateCards = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    animateCards = true
                }
                isRefreshing = false
            }
        }
    }
    
    // 加载参数并刷新UI
    private func loadAndRefreshParameters() {
        // 视图出现时主动请求重新排序参数
        print("历史记录视图出现，主动请求重新加载参数")
        
        // 确保参数被重新加载和排序
        historyManager.resortParameters()
        
        // 打印当前参数状态
        print("当前参数列表状态：\(historyManager.savedParameters.count)个参数")
        if historyManager.savedParameters.isEmpty {
            print("参数列表为空，请先保存一些参数")
        } else {
            print("参数列表非空，包含以下参数:")
            for (index, param) in historyManager.savedParameters.enumerated() {
                print("  [\(index)] \(param.name): \(param.date)")
            }
        }
        
        // 延迟执行以确保数据加载完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                animateCards = true
            }
        }
    }
}

// 参数列表项 - Parameter List Item (改进版)
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
                    
                    // 移除ID和日期显示
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
                    label: NSLocalizedString("Aperture", comment: "Aperture label"),
                    value: parameter.formattedAperture,
                    icon: "camera.aperture"
                )
                
                // 快门 - Shutter
                CompactParameterIndicator(
                    label: NSLocalizedString("Shutter", comment: "Shutter label"),
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
                    label: NSLocalizedString("Exp. Comp.", comment: "Exposure compensation label"),
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
        case .macro: return "leaf.fill"
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
        formatter.dateStyle = .medium // 改为中等详细度，与详情页一致
        formatter.timeStyle = .short 
        // 使用系统默认区域设置，而非强制中文
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
                    
                    // 移除日期显示
                }
                .padding(.top, 16)
                
                // 相机参数卡片网格 - Camera Parameters Grid
                VStack(alignment: .leading, spacing: 16) {
                    Text(NSLocalizedString("Camera Parameters", comment: "Camera parameters section title"))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        // 光圈卡片 - Aperture card
                        CameraParameterCard(
                            icon: "camera.aperture",
                            title: NSLocalizedString("Aperture", comment: "Aperture label"),
                            value: displayedParameter?.formattedAperture ?? parameter.formattedAperture,
                            color: themeColor
                        )
                        
                        // 快门卡片 - Shutter card
                        CameraParameterCard(
                            icon: "timer",
                            title: NSLocalizedString("Shutter", comment: "Shutter label"),
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
                            title: NSLocalizedString("Exp. Comp.", comment: "Exposure compensation label"),
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
                    Text(NSLocalizedString("Shooting Conditions", comment: "Shooting conditions section title"))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        // 光线条件行 - Light Condition row
                        InfoRow(
                            icon: getLightConditionIcon(displayedParameter?.lightCondition ?? parameter.lightCondition),
                            title: NSLocalizedString("Light Condition", comment: "Light condition label"),
                            value: NSLocalizedString(displayedParameter?.lightCondition.rawValue ?? parameter.lightCondition.rawValue, comment: "Light condition value"),
                            color: themeColor
                        )
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // 场景模式行 - Scene Mode row
                        InfoRow(
                            icon: getSceneModeIcon(displayedParameter?.sceneMode ?? parameter.sceneMode),
                            title: NSLocalizedString("Scene Mode", comment: "Scene mode label"),
                            value: NSLocalizedString(displayedParameter?.sceneMode.rawValue ?? parameter.sceneMode.rawValue, comment: "Scene mode value"),
                            color: themeColor
                        )
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // 测光模式行 - Metering Mode row
                        InfoRow(
                            icon: "viewfinder",
                            title: NSLocalizedString("Metering Mode", comment: "Metering mode label"),
                            value: NSLocalizedString(displayedParameter?.meteringMode.rawValue ?? parameter.meteringMode.rawValue, comment: "Metering mode value"),
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
                    Text(NSLocalizedString("Parameter Summary", comment: "Parameter summary section title"))
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
        .navigationTitle(NSLocalizedString("Parameter Details", comment: "Parameter details title")) // 导航栏标题
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
        .alert(NSLocalizedString("Rename Parameter", comment: "Rename parameter dialog title"), isPresented: $showingEditAlert) {
            // 名称输入框 - Name input field
            TextField("新名称", text: $newName)
            
            // 取消按钮 - Cancel button
            Button(NSLocalizedString("Cancel", comment: "Cancel button"), role: .cancel) {
                newName = ""
            }
            
            // 保存按钮 - Save button
            Button(NSLocalizedString("Save", comment: "Save button")) {
                // 检查新名称是否有效 - Check if new name is valid
                if !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    // 修改参数名称和更新状态 - Modify parameter name and update states
                    renameParameter(to: newName)
                }
            }
        } message: {
            Text(NSLocalizedString("Enter a new name for this parameter", comment: "Rename dialog message"))
        }
        .onAppear {
            // 视图出现时加载参数 - Load parameter when view appears
            self.loadParameter()
        }
        // 使用 iOS 14+ 兼容的方式处理参数变化
        .onChange(of: parameter.id) { _ in
            // 当参数更改时更新显示内容
            self.displayedParameter = parameter
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
        
        // 确保返回列表时参数已经重新排序
        historyManager.resortParameters()
    }
    
    // 生成参数总结 - Generate parameter summary
    private func generateParameterSummary() -> String {
        // 使用显示参数或原始参数 - Use displayed parameter or original parameter
        let param = displayedParameter ?? parameter
        
        // 添加本地化参数总结模板
        let templatePart1 = NSLocalizedString(
            "Parameter configuration for %@ scene, under %@ light conditions.",
            comment: "Parameter summary first part"
        )
        let templatePart2 = NSLocalizedString(
            "Using aperture %@, shutter speed %@, ISO %d, with %@ metering, exposure compensation %@.",
            comment: "Parameter summary second part"
        )
        let templatePart3 = NSLocalizedString(
            "These parameters will help you achieve balanced exposure and good imaging results.",
            comment: "Parameter summary third part"
        )
        
        // 格式化第一部分
        let part1 = String(format: templatePart1, 
                           NSLocalizedString(param.sceneMode.rawValue, comment: ""), 
                           NSLocalizedString(param.lightCondition.rawValue, comment: ""))
        
        // 格式化第二部分
        let part2 = String(format: templatePart2, 
                           param.formattedAperture, 
                           param.formattedShutterSpeed, 
                           Int(param.iso),
                           NSLocalizedString(param.meteringMode.rawValue, comment: ""),
                           param.formattedExposureCompensation)
        
        // 返回格式化的文本总结 - Return formatted text summary
        return part1 + "\n\n" + part2 + "\n\n" + templatePart3
    }
    
    // 格式化日期 - Format date
    private func formatDate(_ date: Date) -> String {
        // 创建日期格式化器 - Create date formatter
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // 中等详细度的日期格式
        formatter.timeStyle = .short // 简短的时间格式
        // 使用系统默认区域设置而非强制中文
        
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
        case .macro: return "leaf.fill" // 微距场景图标
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

#Preview {
    HistoryView()
        .environmentObject(ParameterHistoryManager())
} 

